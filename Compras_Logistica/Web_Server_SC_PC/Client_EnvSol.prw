#include 'protheus.ch'
#include 'parmtype.ch'
#include "apwebsrv.ch"
#include 'Totvs.ch'

#Define SC_CA00 	1
#Define SC_DT00 	2

#Define SC_CA01 	1
#Define SC_CA02		2
#Define SC_CA03 	3
#Define SC_CA04   	4
#Define SC_CA05		5
#Define SC_CA06		6
#Define SC_CA07		7

#Define SC_CO01		1
#Define SC_CO02		2
#Define SC_CO03		3
#Define SC_CO04		4

#Define SC_DT01		1
#Define SC_DT02		2
#Define SC_DT03		3
#Define SC_DT04		4
#Define SC_DT05		5
#Define SC_DT06		6
#Define SC_DT07		7
#Define SC_DT08		8
#Define SC_DT09		9

#Define _ENTER		CHR(13)+CHR(10)

#Define NAOR		"N" //|Solicitação Não Recebida no Sys-On
#Define SIMR		"S" //|Solicitação Não Recebida no Sys-On

*******************************************************************************
User function Client_EnvSol()
*******************************************************************************

	Local oWsEnvSol := WSVSService():New()	//| Objeto Estrutura WsService. Baseado em Layout v1.2
	Local cRetOcor	:= SIMR					//| Ocorrencia de Retorno
	Local cRetObs	:= ""					//| Observação de Retorno
	Local aAreaSC1	:= GetArea()

	Private cNumSol	:= SC1->C1_NUM
	Private nRecSC1	:= 0 // Salva o Recno do Item 0001
	Private cForeLj	:= "AS005201" // Unimed Central loja 01

	If ValidaEnvio(@cRetOcor,@cRetObs) //| Pre-Validações para Envio |

		MSolicitacao(@oWsEnvSol) //| Monta os Dados da Solicitação e Alimenta o Ws-Envelope

		ESolicitação(@oWsEnvSol,@cRetOcor,@cRetObs) //| Envia a Solicitação

		If cRetOcor == NAOR 	// Solicitação não Recebida....
			ShowErr(cRetObs)
		ElseIf cRetOcor == SIMR // Solicitação Recebida....
			ShowOk(cRetObs)
		EndIF

	Else
		ShowErr(cRetObs) // Apresenta Mensagem de Erro.
	EndIf

	RestArea(aAreaSC1)
Return()
*******************************************************************************
Static Function  ShowErr(cRetObs)// Solicitação não Recebida....
*******************************************************************************

	Local cTexto := "Solcitacao: " + cNumSol + " nao recebida no Sys-On... " + _ENTER + _ENTER + "Motivo: " + cRetObs

	Define FONT oFont NAME "Tahoma" Size 8,15
	Define MsDialog oDlgMemo Title "Solicitação Não Transmitida com Sucesso!!! " From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cTexto MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,245 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
*******************************************************************************
Static Function  ShowOk(cRetObs)// Solicitação não Recebida....
*******************************************************************************

	Local cTexto := "Solcitacao: " + cNumSol + " recebida no Sys-On Com Sucesso... " + _ENTER + _ENTER + "Obs: " + cRetObs

	Iw_MsgBox(cTexto,"Transmissao","INFO")

Return()
*******************************************************************************
Static Function ValidaEnvio(cRetOcor,cRetObs) //| Pre-Validações para Envio |
*******************************************************************************
//| Solicitação só pode ser enviada após estar Aprovada no Protheus.
//| Durante a confecção da Solicitação de Compras, verificar se existe o relacionamento Produto X Fornecedor com a UNIMED CENTRAL
	Local bVNIEnter := {|| cRetObs += If(Empty(cRetObs),"",_ENTER) }

	DbSelectArea("SC1");DbSetOrder(1)

	// Posiciona se Necessario
	If SC1->C1_ITEM <> "0001"
		DbSeek(xFilial("SC1")+cNumSol+"0001",.F.)
	EndIf
	nRecSC1 := Recno()

	If SC1->C1_INTWSO <> "S"
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs := "Esta Solicitação não se trata de uma Solicitação que pode ser transmitid ao Sys-On.. O->Outros ..."
		Return(.F.)
	EndIf

	If SC1->C1_APROV <> "L"
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Solicitação não esta Aprovada, por favor faça a Liberação antes de Transmitir..."
	EndIF

	If SC1->C1_TX == 'TR'
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Solicitação ja foi Transmitida ao Sys-On..."
	Else

		// Valida Prod x Fornecedor
		While cNumSol == SC1->C1_NUM .And. !EOF()

			If Empty(Alltrim(Posicione("SA5",1,xFilial("SA5")+cForeLj+SC1->C1_PRODUTO,"A5_CODPRF")))
				cRetOcor := "N" ;eVal(bVNIEnter)
				cRetObs += "O Item " + SC1->C1_ITEM + " Produto: "+SC1->C1_PRODUTO+" Nao possui cadastro de Produto x Fornecedor ("+cForeLj+")"
			EndIf

			DbSelectArea("SC1");DbSkip()

		EndDo
		// Restaura o Recno
		DbGoto(nRecSC1)

	EndIf

	If cRetOcor == NAOR
		Return(.F.)
	EndIF

Return(.T.)
*******************************************************************************
Static Function AComprador(oComprador)
*******************************************************************************

  	oComprador:ncodigo      := Val(SC1->C1_CODCOMP)
	oComprador:cnome        := Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_NOME"))
	oComprador:cfone       	:= "51 "+Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_NOME"))
	oComprador:cemail      	:= Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_EMAIL"))

Return()
*******************************************************************************
Static Function ACabecalho(oCabecalho)
*******************************************************************************

	oCabecalho:nnumero      := Val( cNumSol )
	oCabecalho:nunidade     := Val( SM0->M0_CGC )
	oCabecalho:csolicitante := Alltrim(SC1->C1_SOLICIT)
	oCabecalho:nlocentrega  := Val( SC1->C1_FILENT )
	oCabecalho:cemissao     := DtoS(SC1->C1_EMISSAO)

Return()
*******************************************************************************
Static Function ADetalhes(oDetalhes)
*******************************************************************************
	Local oDetAux	:=  VSService_detalhes():New()

	While cNumSol == SC1->C1_NUM .And. !EOF()

		oDetAux:nitem			:= Val(		SC1->C1_ITEM    )
		oDetAux:cproduto		:= Alltrim(	SC1->C1_PRODUTO )
		oDetAux:cdescricao		:= Alltrim(Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_DESC"))
		oDetAux:cprodfor  		:= Alltrim(Posicione("SA5",1,xFilial("SA5")+cForeLj+SC1->C1_PRODUTO,"A5_CODPRF"))
		oDetAux:cunimed   		:= Alltrim(Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_UM"))
		oDetAux:nquantidade		:= SC1->C1_QUANT
		oDetAux:cnecessidade	:= DtoS(SC1->C1_DATPRF)
		oDetAux:cobs        	:= Alltrim( SubsTr(SC1->C1_OBS,1,150) )

		Aadd(oDetalhes,oDetAux)

		oDetAux	:=  VSService_detalhes():New()

		DbSelectArea("SC1");DbSkip()

	EndDo
	// Reposiciona o SC1
	DbGoto(nRecSC1)

Return()
*******************************************************************************
Static Function IniStruct(oWsEnvSol)
*******************************************************************************

	// Inicaliza as Estruturas
	oWsEnvSol:oWsSolicitacao:oWsCabecalho	 			:= VSService_cabecalho():New()

	oWsEnvSol:oWsSolicitacao:oWsCabecalho:oWsComprador	:= VSService_comprador():New()

	oWsEnvSol:oWsSolicitacao:oWsDetalhes	 			:= {}

	oWsEnvSol:oWsSolicitacao:oWsRetorno	 				:= VSService_retorno():New()

Return()
*******************************************************************************
Static Function MSolicitacao(oWsEnvSol)
*******************************************************************************

	IniStruct(@oWsEnvSol) //| Inicializa as Estrutura

	AComprador(@oWsEnvSol:oWsSolicitacao:oWsCabecalho:oWsComprador) //| Alimenta Dados do Comprador

	ACabecalho(@oWsEnvSol:oWsSolicitacao:oWsCabecalho) //| Alimenta Dados do Cabecalho

	ADetalhes(@oWsEnvSol:oWsSolicitacao:oWsDetalhes) //| Alimenta os Detalhes com os Itens

Return()

/*
	Local aSolicitacao 	:= {Nil,Nil}
	Local aCabecalho 	:= {Nil,Nil,Nil,Nil,Nil,Nil,Nil}
	Local aComprador 	:= {Nil,Nil,Nil,Nil}
	Local aDetalhes 	:= {Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil}

	Local oSolicitacao	:= Nil
	Local oCabecalho	:= Nil
	Local oComprador	:= Nil
	Local oDetalhes		:= Nil
	Local oRetorno		:= Nil

	Local cSolicitacao	:= Nil
	Local cRetorno
	Local lRetorno
	Local cError		:= ""
	Local cWarning		:= ""


	//WSDLParser (
	/*
	Local cWSDL :=  "http://sys-on.com.br:8080/SocWebService/VS?wsdl"
	Local aLocalType := {}
	Local aLocalMsg  := {}
	Local aLocalPort := {}
	Local aLocalBind := {}
	Local aLocalServ := {}
	Local aLocalName := {}
	Local aLocalImport := {}


	aComprador[SC_CO01] := 32
	aComprador[SC_CO02] := "Alexandre Machado"
	aComprador[SC_CO03] := "51 9999-9999"
	aComprador[SC_CO04] := "alex.machado@unimed-vs.com.br"

	aCabecalho[SC_CA01] := 756469
	aCabecalho[SC_CA02] := 88258884000120
	aCabecalho[SC_CA03] := "Cristiano Machado"
	aCabecalho[SC_CA04] := 13
	aCabecalho[SC_CA05] := DtoS(Date())
	aCabecalho[SC_CA06] := aComprador

	aDetalhes[SC_DT01]	:= 1
	aDetalhes[SC_DT02]	:= "UNIF129"
	aDetalhes[SC_DT03]	:= "ESPARADRAPO 10CMX4,5M REF.198973 CREMER"
	aDetalhes[SC_DT04]	:= "MHMG053" //??
	aDetalhes[SC_DT05]	:= "UN"
	aDetalhes[SC_DT06]	:= 10
	aDetalhes[SC_DT07]	:= DtoS(Date()+7)
	aDetalhes[SC_DT08]	:= "Observacao"
	aDetalhes[SC_DT09]	:= "Justificativa"
	//Um material: 10170 - esparadrapo 05cm x 4,5m 1x12
	aSolicitacao[SC_CA00] := aCabecalho
	aSolicitacao[SC_DT00] := aDetalhes

	// Criando o objeto Web Service
	oWsEnvSol := WSVSService():New()

	//oSolicitacao := VSService_solicitacao():New()
	oCabecalho	 := VSService_cabecalho():New()
	oComprador	 := VSService_comprador():New()
	oDetalhes	 := VSService_detalhes():New()
    oRetorno	 := VSService_retorno():New()

   	oComprador:ncodigo      := aComprador[SC_CO01]
	oComprador:cnome        := aComprador[SC_CO02]
	oComprador:cfone       	:= aComprador[SC_CO03]
	oComprador:cemail      	:= aComprador[SC_CO04]

    oCabecalho:nnumero      := aCabecalho[SC_CA01]
	oCabecalho:nunidade     := aCabecalho[SC_CA02]
	oCabecalho:csolicitante := aCabecalho[SC_CA03]
	oCabecalho:nlocentrega  := aCabecalho[SC_CA04]
	oCabecalho:cemissao     := aCabecalho[SC_CA05]
	oCabecalho:oWScomprador := oComprador

    oDetalhes:nitem			:= aDetalhes[SC_DT01]
	oDetalhes:cproduto		:= aDetalhes[SC_DT02]
	oDetalhes:cdescricao	:= aDetalhes[SC_DT03]
	oDetalhes:cprodfor  	:= aDetalhes[SC_DT04]
	oDetalhes:cunimed   	:= aDetalhes[SC_DT05]
	oDetalhes:nquantidade	:= aDetalhes[SC_DT06]
	oDetalhes:cnecessidade	:= aDetalhes[SC_DT07]
	oDetalhes:cobs        	:= aDetalhes[SC_DT08]

	oWsEnvSol:oWsSolicitacao:oWsCabecalho := oCabecalho
	Aadd(oWsEnvSol:oWsSolicitacao:oWSdetalhes,oDetalhes)
	oWsEnvSol:oWsSolicitacao:oWSretorno := oRetorno
*/
*******************************************************************************
Static Function ESolicitação(oWsEnvSol,cRetOcor,cRetObs)
*******************************************************************************

	WSDLDbgLevel( 3 )

	lRetorno := oWsEnvSol:enviaSolicitacao(oWsEnvSol:oWsSolicitacao)


	If lRetorno

		cRetOcor := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OCORRENCIA:TEXT)
		cRetObs  := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OBSERVACAO:TEXT)

		///IW_MsgBox("Ocorrencia: "+ Iif(cOcorrencia=="S","Recebido","Não Recebido")  + _ENTER +;
		//	  "Observação: "+ cObservacao , "Transmitido com Sucesso", iif(cOcorrencia=="S","INFO","ALERT") )
	Else

		cRetOcor	:= "N"

		cRetObs   	:= Alltrim( GetWSCError( )) // Resumo do erro
		cRetObs  	+= Alltrim( GetWSCError(2)) // Soap Fault Code
		cRetObs 	+= Alltrim( GetWSCError(3))	// Soap Det
		cRetObs 	+= _ENTER + _ENTER + 'Falha Interna de Execucao do Servico !'

	EndIf

Return()
*******************************************************************************
Static Function MontaXml(aSolicitacao)
*******************************************************************************
Local cXml := ""


//	cXml += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.soc.syson.com.br/">' + _ENTER
// 	cXml += '<soapenv:Header/> ' + _ENTER
// 	cXml += '<soapenv:Body> ' + _ENTER
// 	cXml += '	<ser:enviaSolicitacao> ' + _ENTER
 	cXml += '		<solicitacao> ' + _ENTER
 	cXml += '			<cabecalho> ' + _ENTER
 	cXml += '				<numero>756469</numero> ' + _ENTER
 	cXml += '				<unidade>88258884000120</unidade> ' + _ENTER
 	cXml += '				<solicitante>"Cristiano Machado"</solicitante> ' + _ENTER
    cXml += '				<locentrega>13</locentrega> ' + _ENTER
    cXml += '				<emissao>20160622</emissao> ' + _ENTER
    cXml += '				<comprador> ' + _ENTER
    cXml += '					<codigo>32</codigo> ' + _ENTER
    cXml += '					<nome>"Alexandre Machado"</nome> ' + _ENTER
    cXml += '					<fone>"51 9999-9999"</fone> ' + _ENTER
    cXml += '					<email>"alex.machado@unimed-vs.com.br"</email> ' + _ENTER
    cXml += '				</comprador> ' + _ENTER
    cXml += '			</cabecalho> ' + _ENTER
    cXml += '			<detalhes> ' + _ENTER
    cXml += '				<item>1</item> ' + _ENTER
    cXml += '				<produto>"UNIF129"</produto> ' + _ENTER
    cXml += '				<descricao>"ESPARADRAPO 10CMX4,5M REF.198973 CREMER"</descricao> ' + _ENTER
    cXml += '				<prodfor>"MHMG053"</prodfor> ' + _ENTER
    cXml += '				<unimed>"UN"</unimed> ' + _ENTER
    cXml += '				<quantidade>10</quantidade> ' + _ENTER
    cXml += '				<necessidade>20160629</necessidade> ' + _ENTER
    cXml += '				<obs>"Observacao"</obs> ' + _ENTER
    cXml += '			</detalhes> ' + _ENTER
    cXml += '			<retorno> ' + _ENTER
    cXml += '				<ocorrencia></ocorrencia> ' + _ENTER
    cXml += '				<observacao></observacao> ' + _ENTER
    cXml += '			</retorno> ' + _ENTER
    cXml += '		</solicitacao> ' + _ENTER
//    cXml += '	</ser:enviaSolicitacao> ' + _ENTER
//    cXml += '</soapenv:Body> ' + _ENTER
//    cXml += '</soapenv:Envelope> ' + _ENTER



    Return(cXml)