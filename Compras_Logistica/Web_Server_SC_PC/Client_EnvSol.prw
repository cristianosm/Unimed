#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "apwebsrv.ch"
#Include 'Totvs.ch'

#Define _ENTER		CHR(13)+CHR(10)

#Define NAOR		"N" //|Solicitacao nao Recebida no Sys-On
#Define SIMR		"S" //|Solicitacao nao Recebida no Sys-On

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO    :Client_EnvSol | AUTOR : Cristiano Machado  | DATA : 18/02/2016 **
**---------------------------------------------------------------------------**
** DESCRICAO : Envia Solcitacao de Compras ao Sys-on Atravess do WS          **
**           : Client_Syson                                                  **
**---------------------------------------------------------------------------**
** USO       : Especifico para o cliente Unimed Vale do Sinos                **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function Client_EnvSol()
*******************************************************************************

	Private cNumSol	:= SC1->C1_NUM
	Private nRecSC1	:= 0 			// Salva o Recno do Item 0001
	Private cForeLj	:= "AS005201" 	// Unimed Central loja 01
	Private cFilHom	:= SuperGetMv( "UM_FILHOMS", .F., "13" 	)// Filial Homologada a Receber Enviar Solicitacao e Receber Pedidos Sys-ON

	Private oProcess 	:= Nil
	Private lEnd 		:= Nil


	If Iw_MsgBox("Confirma a Transmissao da Solicitacao: "+cNumSol,"Confirmacao...","YESNO")

		oProcess := MsNewProcess():New( {|lEnd| Transmissao()(@oProcess, @lEnd)} , "Transmitindo Solicitacao..."+cNumSol, "", .T. )
		oProcess:Activate()

	EndIf

Return()
*******************************************************************************
Static function Transmissao()//| Funcao Principal
*******************************************************************************

	Local oWsEnvSol := WSVSService():New()	//| Objeto Estrutura WsService. Baseado em Layout v1.2
	Local cRetOcor	:= SIMR					//| Ocorrencia de Retorno
	Local cRetObs	:= ""					//| Observacao de Retorno
	Local aAreaSC1	:= GetArea()

	oProcess:SetRegua1(5)
	oProcess:SetRegua2(0)

	//| Obtem Dados do Cliente
	oProcess:IncRegua1("Validando Solicitacao...")
	If ValidaEnvio(@cRetOcor,@cRetObs) //| Pre-Validacoes para Envio |

		oProcess:IncRegua1("Montando Solicitacao para Envio...")
		MSolicitacao(@oWsEnvSol) //| Monta os Dados da Solicitacao e Alimenta o Ws-Envelope

		oProcess:IncRegua1("Enviando Solicitacao ao Sys-On...")
		ESolicitacao(@oWsEnvSol,@cRetOcor,@cRetObs) //| Envia o Envelope com a Solicitacao

		oProcess:IncRegua1("Analisando Retorno do Sys-On...")
		If cRetOcor == NAOR 	// Solicitacao nao Recebida....
			ShowErr(cRetObs)
		ElseIf cRetOcor == SIMR // Solicitacao Recebida....
			ShowOk(cRetObs)
		EndIF

	Else
		oProcess:IncRegua1("Erros Identificados...")
		ShowErr(cRetObs) // Apresenta Mensagem de Erro.
	EndIf

	RestArea(aAreaSC1)
Return()
*******************************************************************************
Static Function ValidaEnvio(cRetOcor,cRetObs) //| Pre-Validacoes para Envio |
*******************************************************************************
//| Solicitacao so pode ser enviada apos estar Aprovada no Protheus.
//| Durante a confeccao da Solicitacao de Compras, verificar se existe o relacionamento Produto X Fornecedor com a UNIMED CENTRAL
	Local bVNIEnter := {|| cRetObs += If(Empty(cRetObs),"",_ENTER) }
	Local lVal	:= .T.
	DbSelectArea("SC1");DbSetOrder(1)

	// Posiciona se Necessario
	If SC1->C1_ITEM <> "0001"
		DbSeek(xFilial("SC1")+cNumSol+"0001",.F.)
	EndIf
	nRecSC1 := Recno()

	If !(SC1->C1_FILIAL $ cFilHom ) //| Codigo das Filiais Homologadas...|
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Filial nao esta Homologada a enviar Solicitacoes ao Sys-On..." + _ENTER
		lVal	:= .F.
	EndIf

	If SC1->C1_INTWSO <> "S"
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Solicitacao nao pode ser transmitida ao Sys-On.. Tipo Icorreto: O->Outros ..." + _ENTER
		lVal	:= .F.
	EndIf

	If SC1->C1_APROV <> "L"
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Solicitacao nao esta Aprovada, Deve estar Aprovada para ser Transmitida ..." + _ENTER
		lVal	:= .F.
	EndIF

	If SC1->C1_TX == 'TR'
		cRetOcor := "N" ;eVal(bVNIEnter)
		cRetObs += "Esta Solicitacao ja foi Transmitida ao Sys-On..." + _ENTER
		lVal	:= .F.
	Else

		// Valida Prod x Fornecedor
		While cNumSol == SC1->C1_NUM .And. !EOF()

			If Empty(Alltrim(Posicione("SA5",1,xFilial("SA5")+cForeLj+SC1->C1_PRODUTO,"A5_CODPRF")))
				cRetOcor := "N" ;eVal(bVNIEnter)
				cRetObs += "O Item " + Alltrim(SC1->C1_ITEM) + " Produto: "+Alltrim(SC1->C1_PRODUTO)+" nao possui cadastro de Produto x Fornecedor ("+cForeLj+")" + _ENTER
				lVal := .F.
			EndIf

			// Valida Segunda Unidade de Medida
			If SC1->C1_QTSEGUM > 0
				If Mod(SC1->C1_QTSEGUM, 1) > 0
					cRetOcor := "N" ;eVal(bVNIEnter)
					cRetObs += "O Item " + Alltrim(SC1->C1_ITEM) + " Produto: "+Alltrim(SC1->C1_PRODUTO)+" possui uma quantidade invalida na Segunda Unidade de Medida. Valor Fracionado! ("+cForeLj+")" + _ENTER
					lVal := .F.
				EndIf
			EndIf

			DbSelectArea("SC1");DbSkip()

		EndDo
		// Restaura o Recno
		DbGoto(nRecSC1)

	EndIf

	If cRetOcor == NAOR
		Return(.F.)
	EndIF

Return(lVal)
*******************************************************************************
Static Function MSolicitacao(oWsEnvSol)//| Monta a Solicitacao no Envelope WS
*******************************************************************************

	IniStruct(@oWsEnvSol) //| Inicializa as Estrutura

	AComprador(@oWsEnvSol:oWsSolicitacao:oWsCabecalho:oWsComprador) //| Alimenta Dados do Comprador

	ACabecalho(@oWsEnvSol:oWsSolicitacao:oWsCabecalho) //| Alimenta Dados do Cabecalho

	ADetalhes(@oWsEnvSol:oWsSolicitacao:oWsDetalhes) //| Alimenta os Detalhes com os Itens

Return()
*******************************************************************************
Static Function IniStruct(oWsEnvSol)//| Inicializa as Estrutura
*******************************************************************************

	// Inicaliza as Estruturas
	oWsEnvSol:oWsSolicitacao:oWsCabecalho	 			:= VSService_cabecalho():New()

	oWsEnvSol:oWsSolicitacao:oWsCabecalho:oWsComprador	:= VSService_comprador():New()

	oWsEnvSol:oWsSolicitacao:oWsDetalhes	 			:= {}

	oWsEnvSol:oWsSolicitacao:oWsRetorno	 				:= VSService_retorno():New()

Return()
*******************************************************************************
Static Function AComprador(oComprador)//| Alimenta Dados do Comprador
*******************************************************************************

  	oComprador:ncodigo      := Val(SC1->C1_CODCOMP)
	oComprador:cnome        := Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_NOME"))
	oComprador:cfone       	:= "51 "+Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_NOME"))
	oComprador:cemail      	:= Alltrim(Posicione("SY1",1,xFilial("SY1")+SC1->C1_CODCOMP,"Y1_EMAIL"))

Return()
*******************************************************************************
Static Function ACabecalho(oCabecalho)//| Alimenta Dados do Cabecalho
*******************************************************************************

	oCabecalho:nnumero      := Val( cNumSol )
	oCabecalho:nunidade     := Val( SM0->M0_CGC )
	oCabecalho:csolicitante := Alltrim(SC1->C1_SOLICIT)
	oCabecalho:nlocentrega  := Val( SC1->C1_FILENT )
	oCabecalho:cemissao     := DtoS(SC1->C1_EMISSAO)

Return()
*******************************************************************************
Static Function ADetalhes(oDetalhes)//| Alimenta os Detalhes com os Itens
*******************************************************************************
	Local oDetAux	:=  VSService_detalhes():New()

	While cNumSol == SC1->C1_NUM .And. !EOF()

		oDetAux:nitem			:= Val(		SC1->C1_ITEM    )
		oDetAux:cproduto		:= Alltrim(	SC1->C1_PRODUTO )
		oDetAux:cdescricao		:= Alltrim(Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_DESC"))
		oDetAux:cprodfor  		:= Alltrim(Posicione("SA5",1,xFilial("SA5")+cForeLj+SC1->C1_PRODUTO,"A5_CODPRF"))
		oDetAux:cunimed   		:= Iif( SC1->C1_QTSEGUM > 0, SC1->C1_SEGUM, SC1->C1_UM ) // ENVIA NA SEGUNDA UNIDADE //Alltrim(Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_UM"))
		oDetAux:nquantidade		:= Iif( SC1->C1_QTSEGUM > 0, SC1->C1_QTSEGUM, SC1->C1_QUANT) // ENVIA NA SEGUNDA UNIDADE
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
Static Function ESolicitacao(oWsEnvSol,cRetOcor,cRetObs)//| Envia o Envelope com a Solicitacao
*******************************************************************************

	WSDLDbgLevel( 3 )

	lRetorno := oWsEnvSol:enviaSolicitacao(oWsEnvSol:oWsSolicitacao)


	If lRetorno

		cRetOcor := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OCORRENCIA:TEXT)
		cRetObs  := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OBSERVACAO:TEXT)

		///IW_MsgBox("Ocorrencia: "+ Iif(cOcorrencia=="S","Recebido","nao Recebido")  + _ENTER +;
		//	  "Observacao: "+ cObservacao , "Transmitido com Sucesso", iif(cOcorrencia=="S","INFO","ALERT") )
	Else

		cRetOcor	:= "N"

		cRetObs   	:= Alltrim( GetWSCError( )) // Resumo do erro
		cRetObs  	+= Alltrim( GetWSCError(2)) // Soap Fault Code
		cRetObs 	+= Alltrim( GetWSCError(3))	// Soap Det
		cRetObs 	+= _ENTER + _ENTER + 'Falha Interna de Execucao do Servico !'

	EndIf

Return()
*******************************************************************************
Static Function  ShowErr(cRetObs)// Solicitacao nao Recebida....
*******************************************************************************

	Local cTexto := "SOLICITACAO " + cNumSol + " NAO TRANSMITIDA !!! " + _ENTER + _ENTER + "MOTIVOS(S): " + _ENTER + _ENTER + cRetObs

	Define FONT oFont NAME "Tahoma" Size 6,14

	oFont := TFont():New('Tahoma',,16,.F.)

	Define MsDialog oDlgMemo Title "Solicitacao nao Transmitida !!! " From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cTexto MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,245 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
*******************************************************************************
Static Function  ShowOk(cRetObs)// Solicitacao nao Recebida....
*******************************************************************************

	Local cTexto := "Solcitacao: " + cNumSol + " recebida no Sys-On Com Sucesso... " + _ENTER + _ENTER + "Obs: " + cRetObs

	Iw_MsgBox(cTexto,"Transmissao","INFO")

	MarkScSend() // Marca a Silicitacao como enviada.

	//| SendMail()
	U_SMProxSys(cNumSol , cTexto, "Solicitacao Transmitida ao Sys-on ","T")

Return()
*******************************************************************************
Static Function MarkScSend() // Marca a Silicitacao como Transmitida.
*******************************************************************************

	DbSelectArea("SC1");DbGoto(nRecSC1)
	While !Eof() .And. cNumSol == SC1->C1_NUM

		RecLock("SC1", .F.)

		SC1->C1_INTWSO 	:= 'S'
		SC1->C1_TX 		:= 'TR'
		SC1->C1_QUJE 	:= 0

		MsUnlock()

		DbSelectArea("SC1")
		DbSkip()

		EndDo


Return()