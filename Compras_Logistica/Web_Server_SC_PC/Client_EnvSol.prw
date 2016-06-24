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

*******************************************************************************
User function Client_EnvSol()
	*******************************************************************************

	Local oWsEnvSol 	:= Nil
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

	//WSDLParser ( cWSDL, @aLocalType,@aLocalMsg, @aLocalPort, @aLocalBind,@aLocalServ, @aLocalName, @aLocalImport, @cError, @cWarning )

	WSDLDbgLevel( 3 )

	//oWsEnvSol:oWSsolicitacao := WSCLASSNEW ( < oWsEnvSol:oWSsolicitacao > )
	//cFile := "\Sol_Syson.xml"
	//oXml := XmlParserFile( cFile, "_", @cError, @cWarning )

	cSolicitacao := MontaXml()
	cSolicitacao := XmlC14N( cSolicitacao, " ",@cError,@cWarning)

	oSolicitacao := VSService_solicitacao():New()
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

	//oSolicitacao:oWScabecalho 	:= oCabecalho
	//Aadd(oSolicitacao:oWSdetalhes,oDetalhes)
	//oSolicitacao:oWSretorno 	:= oRetorno
	oWsEnvSol:oWsSolicitacao:oWsCabecalho := oCabecalho
	Aadd(oWsEnvSol:oWsSolicitacao:oWSdetalhes,oDetalhes)
	oWsEnvSol:oWsSolicitacao:oWSretorno := oRetorno

	lRetorno := oWsEnvSol:enviaSolicitacao(oWsEnvSol:oWsSolicitacao)

	//VarInfo("Objeto", oWsEnvSol:enviaSolicitacao:oXmlRet)

	If lRetorno

		cOcorrencia := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OCORRENCIA:TEXT)
		cObservacao := AllTrim(oWsEnvSol:oWsSolicitacao:_RETORNO:_OBSERVACAO:TEXT)

		IW_MsgBox("Ocorrencia: "+ Iif(cOcorrencia=="S","Recebido","Não Recebido")  + _ENTER +;
				  "Observação: "+ cObservacao , "Transmitido com Sucesso", iif(cOcorrencia=="S","INFO","ALERT") )
	Else
		cSvcError   := GetWSCError()  // Resumo do erro
		cSoapFCode  := GetWSCError(2)  // Soap Fault Code
		cSoapFDescr := GetWSCError(3)

		If !empty(cSoapFCode)    // Caso a ocorrencia de erro esteja com o fault_code preenchido ,
			// a mesma teve relacao com a chamada do servico .
			Alert(cSoapFDescr,cSoapFCode)
		Else   // Caso a ocorrencia nao tenha o soap_code preenchido
			// Ela esta relacionada a uma outra falha ,    /
			// provavelmente local ou interna.
			Alert(cSvcError,'FALHA INTERNA DE EXECUCAO DO SERVICO')
		Endif
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