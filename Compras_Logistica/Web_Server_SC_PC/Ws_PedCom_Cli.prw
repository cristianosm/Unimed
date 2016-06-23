#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://srv-hu-tst01:81/ws/WS_PEDCOM.apw?WSDL
Gerado em        06/22/16 15:38:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _EMTSZDO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_PEDCOM
------------------------------------------------------------------------------- */

WSCLIENT WSWS_PEDCOM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RECEBEPEDIDO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSPEDIDO                 AS WS_PEDCOM_SPC_PEDIDO
	WSDATA   oWSRECEBEPEDIDORESULT     AS WS_PEDCOM_SPC_RETORNO

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSPC_PEDIDO             AS WS_PEDCOM_SPC_PEDIDO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_PEDCOM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20151103] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_PEDCOM
	::oWSPEDIDO          := WS_PEDCOM_SPC_PEDIDO():New()
	::oWSRECEBEPEDIDORESULT := WS_PEDCOM_SPC_RETORNO():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSPC_PEDIDO      := ::oWSPEDIDO
Return

WSMETHOD RESET WSCLIENT WSWS_PEDCOM
	::oWSPEDIDO          := NIL 
	::oWSRECEBEPEDIDORESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSPC_PEDIDO      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_PEDCOM
Local oClone := WSWS_PEDCOM():New()
	oClone:_URL          := ::_URL 
	oClone:oWSPEDIDO     :=  IIF(::oWSPEDIDO = NIL , NIL ,::oWSPEDIDO:Clone() )
	oClone:oWSRECEBEPEDIDORESULT :=  IIF(::oWSRECEBEPEDIDORESULT = NIL , NIL ,::oWSRECEBEPEDIDORESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSPC_PEDIDO := oClone:oWSPEDIDO
Return oClone

// WSDL Method RECEBEPEDIDO of Service WSWS_PEDCOM

WSMETHOD RECEBEPEDIDO WSSEND oWSPEDIDO WSRECEIVE oWSRECEBEPEDIDORESULT WSCLIENT WSWS_PEDCOM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RECEBEPEDIDO xmlns="http://172.22.0.185:81/ws/">'
cSoap += WSSoapValue("PEDIDO", ::oWSPEDIDO, oWSPEDIDO , "SPC_PEDIDO", .T. , .F., 0 , NIL, .F.) 
cSoap += "</RECEBEPEDIDO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://172.22.0.185:81/ws/RECEBEPEDIDO",; 
	"DOCUMENT","http://172.22.0.185:81/ws/",,"1.031217",; 
	"http://srv-hu-tst01:81/ws/WS_PEDCOM.apw")

::Init()
::oWSRECEBEPEDIDORESULT:SoapRecv( WSAdvValue( oXmlRet,"_RECEBEPEDIDORESPONSE:_RECEBEPEDIDORESULT","SPC_RETORNO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure SPC_PEDIDO

WSSTRUCT WS_PEDCOM_SPC_PEDIDO
	WSDATA   oWSCABECALHO              AS WS_PEDCOM_SPC_CABECALHO
	WSDATA   oWSDETALHES               AS WS_PEDCOM_ARRAYOFN_ITEM
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_SPC_PEDIDO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_SPC_PEDIDO
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_SPC_PEDIDO
	Local oClone := WS_PEDCOM_SPC_PEDIDO():NEW()
	oClone:oWSCABECALHO         := IIF(::oWSCABECALHO = NIL , NIL , ::oWSCABECALHO:Clone() )
	oClone:oWSDETALHES          := IIF(::oWSDETALHES = NIL , NIL , ::oWSDETALHES:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_PEDCOM_SPC_PEDIDO
	Local cSoap := ""
	cSoap += WSSoapValue("CABECALHO", ::oWSCABECALHO, ::oWSCABECALHO , "SPC_CABECALHO", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DETALHES", ::oWSDETALHES, ::oWSDETALHES , "ARRAYOFN_ITEM", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure SPC_RETORNO

WSSTRUCT WS_PEDCOM_SPC_RETORNO
	WSDATA   oWSRETORNO                AS WS_PEDCOM_SPC_OCORRENCIA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_SPC_RETORNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_SPC_RETORNO
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_SPC_RETORNO
	Local oClone := WS_PEDCOM_SPC_RETORNO():NEW()
	oClone:oWSRETORNO           := IIF(::oWSRETORNO = NIL , NIL , ::oWSRETORNO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_PEDCOM_SPC_RETORNO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_RETORNO","SPC_OCORRENCIA",NIL,"Property oWSRETORNO as s0:SPC_OCORRENCIA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSRETORNO := WS_PEDCOM_SPC_OCORRENCIA():New()
		::oWSRETORNO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure SPC_CABECALHO

WSSTRUCT WS_PEDCOM_SPC_CABECALHO
	WSDATA   cCONDPAG                  AS string
	WSDATA   cCONTATO                  AS string
	WSDATA   dEMISSAO                  AS date
	WSDATA   nFORNECEDOR               AS integer
	WSDATA   oWSFRETE                  AS WS_PEDCOM_SPC_FRETE OPTIONAL
	WSDATA   nUNIDADESOL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_SPC_CABECALHO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_SPC_CABECALHO
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_SPC_CABECALHO
	Local oClone := WS_PEDCOM_SPC_CABECALHO():NEW()
	oClone:cCONDPAG             := ::cCONDPAG
	oClone:cCONTATO             := ::cCONTATO
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:nFORNECEDOR          := ::nFORNECEDOR
	oClone:oWSFRETE             := IIF(::oWSFRETE = NIL , NIL , ::oWSFRETE:Clone() )
	oClone:nUNIDADESOL          := ::nUNIDADESOL
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_PEDCOM_SPC_CABECALHO
	Local cSoap := ""
	cSoap += WSSoapValue("CONDPAG", ::cCONDPAG, ::cCONDPAG , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CONTATO", ::cCONTATO, ::cCONTATO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("EMISSAO", ::dEMISSAO, ::dEMISSAO , "date", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FORNECEDOR", ::nFORNECEDOR, ::nFORNECEDOR , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FRETE", ::oWSFRETE, ::oWSFRETE , "SPC_FRETE", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UNIDADESOL", ::nUNIDADESOL, ::nUNIDADESOL , "integer", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFN_ITEM

WSSTRUCT WS_PEDCOM_ARRAYOFN_ITEM
	WSDATA   oWSN_ITEM                 AS WS_PEDCOM_N_ITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_ARRAYOFN_ITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_ARRAYOFN_ITEM
	::oWSN_ITEM            := {} // Array Of  WS_PEDCOM_N_ITEM():New()
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_ARRAYOFN_ITEM
	Local oClone := WS_PEDCOM_ARRAYOFN_ITEM():NEW()
	oClone:oWSN_ITEM := NIL
	If ::oWSN_ITEM <> NIL 
		oClone:oWSN_ITEM := {}
		aEval( ::oWSN_ITEM , { |x| aadd( oClone:oWSN_ITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_PEDCOM_ARRAYOFN_ITEM
	Local cSoap := ""
	aEval( ::oWSN_ITEM , {|x| cSoap := cSoap  +  WSSoapValue("N_ITEM", x , x , "N_ITEM", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure SPC_OCORRENCIA

WSSTRUCT WS_PEDCOM_SPC_OCORRENCIA
	WSDATA   cOBSERVACAO               AS string OPTIONAL
	WSDATA   cOCORRENCIA               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_SPC_OCORRENCIA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_SPC_OCORRENCIA
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_SPC_OCORRENCIA
	Local oClone := WS_PEDCOM_SPC_OCORRENCIA():NEW()
	oClone:cOBSERVACAO          := ::cOBSERVACAO
	oClone:cOCORRENCIA          := ::cOCORRENCIA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_PEDCOM_SPC_OCORRENCIA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cOBSERVACAO        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOCORRENCIA        :=  WSAdvValue( oResponse,"_OCORRENCIA","string",NIL,"Property cOCORRENCIA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SPC_FRETE

WSSTRUCT WS_PEDCOM_SPC_FRETE
	WSDATA   nCNPJ                     AS integer OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSDATA   nSEGURO                   AS float OPTIONAL
	WSDATA   cTIPO                     AS string OPTIONAL
	WSDATA   nVALOR                    AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_SPC_FRETE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_SPC_FRETE
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_SPC_FRETE
	Local oClone := WS_PEDCOM_SPC_FRETE():NEW()
	oClone:nCNPJ                := ::nCNPJ
	oClone:cNOME                := ::cNOME
	oClone:nSEGURO              := ::nSEGURO
	oClone:cTIPO                := ::cTIPO
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_PEDCOM_SPC_FRETE
	Local cSoap := ""
	cSoap += WSSoapValue("CNPJ", ::nCNPJ, ::nCNPJ , "integer", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NOME", ::cNOME, ::cNOME , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SEGURO", ::nSEGURO, ::nSEGURO , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure N_ITEM

WSSTRUCT WS_PEDCOM_N_ITEM
	WSDATA   dDATAENTR                 AS date
	WSDATA   nITEM                     AS integer
	WSDATA   nITEMSC                   AS integer
	WSDATA   nNUMSC                    AS integer
	WSDATA   cOBS                      AS string OPTIONAL
	WSDATA   nPRCUNIT                  AS float
	WSDATA   cPRODFOR                  AS string
	WSDATA   cPRODUTO                  AS string OPTIONAL
	WSDATA   nQUANTIDADE               AS float
	WSDATA   nTOTAL                    AS float
	WSDATA   cUNIMED                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_PEDCOM_N_ITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_PEDCOM_N_ITEM
Return

WSMETHOD CLONE WSCLIENT WS_PEDCOM_N_ITEM
	Local oClone := WS_PEDCOM_N_ITEM():NEW()
	oClone:dDATAENTR            := ::dDATAENTR
	oClone:nITEM                := ::nITEM
	oClone:nITEMSC              := ::nITEMSC
	oClone:nNUMSC               := ::nNUMSC
	oClone:cOBS                 := ::cOBS
	oClone:nPRCUNIT             := ::nPRCUNIT
	oClone:cPRODFOR             := ::cPRODFOR
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:nTOTAL               := ::nTOTAL
	oClone:cUNIMED              := ::cUNIMED
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_PEDCOM_N_ITEM
	Local cSoap := ""
	cSoap += WSSoapValue("DATAENTR", ::dDATAENTR, ::dDATAENTR , "date", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ITEM", ::nITEM, ::nITEM , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ITEMSC", ::nITEMSC, ::nITEMSC , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NUMSC", ::nNUMSC, ::nNUMSC , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("OBS", ::cOBS, ::cOBS , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PRCUNIT", ::nPRCUNIT, ::nPRCUNIT , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PRODFOR", ::cPRODFOR, ::cPRODFOR , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QUANTIDADE", ::nQUANTIDADE, ::nQUANTIDADE , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TOTAL", ::nTOTAL, ::nTOTAL , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UNIMED", ::cUNIMED, ::cUNIMED , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap


