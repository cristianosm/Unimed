#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://sys-on.com.br:8080/SocWebService/VS?wsdl
Gerado em        05/30/16 18:52:55
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KMQOFWG

// Novo teste 

Return  // "dummy" function - Internal Use

/* ====================== SERVICE WARNING MESSAGES ======================
Definition for pedido as element FOUND AS [ns1:pedido]. This Object COULD NOT HAVE RETURN.
Definition for solicitacao as element FOUND AS [ns2:solicitacao]. This Object COULD NOT HAVE RETURN.
====================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSVSService
------------------------------------------------------------------------------- */

WSCLIENT WSVSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD recebePedido
	WSMETHOD enviaPedido
	WSMETHOD enviaSolicitacao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSpedido                 AS VSService_pedido
	WSDATA   oWSsolicitacao            AS VSService_solicitacao

ENDWSCLIENT
*******************************************************************************
WSMETHOD NEW WSCLIENT WSVSService
*******************************************************************************

	::Init()

	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20151103] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf

Return Self

*******************************************************************************
WSMETHOD INIT WSCLIENT WSVSService
*******************************************************************************
	::oWSpedido          := VSService_PEDIDO():New()
	::oWSsolicitacao     := VSService_SOLICITACAO():New()
Return

*******************************************************************************
WSMETHOD RESET WSCLIENT WSVSService
*******************************************************************************
	::oWSpedido          := NIL
	::oWSsolicitacao     := NIL
	::Init()
Return

*******************************************************************************
WSMETHOD CLONE WSCLIENT WSVSService
*******************************************************************************

	Local oClone := WSVSService():New()

	oClone:_URL          := ::_URL
	oClone:oWSpedido     :=  IIF(::oWSpedido = NIL , NIL ,::oWSpedido:Clone() )
	oClone:oWSsolicitacao :=  IIF(::oWSsolicitacao = NIL , NIL ,::oWSsolicitacao:Clone() )

Return oClone


// WSDL Method recebePedido of Service WSVSService
*******************************************************************************
WSMETHOD recebePedido WSSEND BYREF oWSpedido WSRECEIVE NULLPARAM WSCLIENT WSVSService
*******************************************************************************
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<recebePedido xmlns="http://services.soc.syson.com.br/">'
		cSoap += WSSoapValue("pedido", ::oWSpedido, oWSpedido , "pedido", .F. , .F., 0 , "http://services.soc.syson.com.br/", .F.)
		cSoap += "</recebePedido>"

		oXmlRet := SvcSoapCall(	Self,cSoap,;
			"",;
			"DOCUMENT","http://services.soc.syson.com.br/",,,;
			"http://sys-on.com.br:8080/SocWebService/VS")

		::Init()

		::oWSpedido:SoapRecv( WSAdvValue( oXmlRet,"_RECEBEPEDIDORESPONSE:_PEDIDO","pedido",NIL,NIL,NIL,NIL,@oWSpedido,NIL) )

	END WSMETHOD

	oXmlRet := NIL

Return .T.

// WSDL Method enviaPedido of Service WSVSService

*******************************************************************************
WSMETHOD enviaPedido WSSEND BYREF oWSpedido WSRECEIVE NULLPARAM WSCLIENT WSVSService
*******************************************************************************

	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<enviaPedido xmlns="http://services.soc.syson.com.br/">'
		cSoap += WSSoapValue("pedido", ::oWSpedido, oWSpedido , "pedido", .F. , .F., 0 , "http://services.soc.syson.com.br/", .F.)
		cSoap += "</enviaPedido>"

		oXmlRet := SvcSoapCall(	Self,cSoap,;
			"",;
			"DOCUMENT","http://services.soc.syson.com.br/",,,;
			"http://sys-on.com.br:8080/SocWebService/VS")

		::Init()

		::oWSpedido:SoapRecv( WSAdvValue( oXmlRet,"_ENVIAPEDIDORESPONSE:_PEDIDO","pedido",NIL,NIL,NIL,NIL,@oWSpedido,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method enviaSolicitacao of Service WSVSService

WSMETHOD enviaSolicitacao WSSEND BYREF oWSsolicitacao WSRECEIVE NULLPARAM WSCLIENT WSVSService
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<enviaSolicitacao xmlns="http://services.soc.syson.com.br/">'
		cSoap += WSSoapValue("solicitacao", ::oWSsolicitacao, oWSsolicitacao , "solicitacao", .F. , .F., 0 , "http://services.soc.syson.com.br/", .F.)
		cSoap += "</enviaSolicitacao>"

		oXmlRet := SvcSoapCall(	Self,cSoap,;
			"",;
			"DOCUMENT","http://services.soc.syson.com.br/",,,;
			"http://sys-on.com.br:8080/SocWebService/VS")

		::Init()
		::oWSsolicitacao:SoapRecv( WSAdvValue( oXmlRet,"_ENVIASOLICITACAORESPONSE:_SOLICITACAO","solicitacao",NIL,NIL,NIL,NIL,@oWSsolicitacao,NIL) )

	END WSMETHOD

	oXmlRet := NIL

Return .T.

*******************************************************************************
// WSDL Data Structure pedido
*******************************************************************************
WSSTRUCT VSService_pedido
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV

ENDWSSTRUCT

*******************************************************************************
WSMETHOD NEW WSCLIENT VSService_pedido
*******************************************************************************
	::Init()
Return Self

*******************************************************************************
WSMETHOD INIT WSCLIENT VSService_pedido
*******************************************************************************
Return

*******************************************************************************
WSMETHOD CLONE WSCLIENT VSService_pedido
*******************************************************************************
	Local oClone := VSService_pedido():NEW()

Return oClone

*******************************************************************************
WSMETHOD SOAPSEND WSCLIENT VSService_pedido
*******************************************************************************
	Local cSoap := ""
Return cSoap

*******************************************************************************
WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_pedido
*******************************************************************************
	::Init()
	If oResponse = NIL
		Return
	Endif

Return

*******************************************************************************
// WSDL Data Structure solicitacao
*******************************************************************************
WSSTRUCT VSService_solicitacao
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

*******************************************************************************
WSMETHOD NEW WSCLIENT VSService_solicitacao
*******************************************************************************
	::Init()

Return Self

*******************************************************************************
WSMETHOD INIT WSCLIENT VSService_solicitacao
*******************************************************************************

Return

*******************************************************************************
WSMETHOD CLONE WSCLIENT VSService_solicitacao
*******************************************************************************	
	Local oClone := VSService_solicitacao():NEW()

Return oClone
*******************************************************************************
WSMETHOD SOAPSEND WSCLIENT VSService_solicitacao
*******************************************************************************

	Local cSoap := ""

Return cSoap
*******************************************************************************
WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_solicitacao
*******************************************************************************
	::Init()
	If oResponse = NIL
		Return
	Endif

Return