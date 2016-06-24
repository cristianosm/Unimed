#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://sys-on.com.br:8080/SocWebService/VS?wsdl
Gerado em        06/23/16 16:43:46
Observa______es      C___digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera______es neste arquivo podem causar funcionamento incorreto
                 e ser___o perdidas caso o c___digo-fonte seja gerado novamente.
=============================================================================== */

User Function _WFIRKSP ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSVSService
------------------------------------------------------------------------------- */

WSCLIENT WSVSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RECEBEHORA
	WSMETHOD ENVIATESTE
	WSMETHOD enviaPedido
	WSMETHOD recebePedido
	WSMETHOD enviaSolicitacao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cHORA                     AS string
	WSDATA   nPARAM                    AS int
	WSDATA   cTESTE                    AS string
	WSDATA   oWSPEDIDO                 AS VSService_pedido
	WSDATA   oWSsolicitacao            AS VSService_solicitacao

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSVSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C___digo-Fonte Client atual requer os execut___veis do Protheus Build [7.00.131227A-20151103] ou superior. Atualize o Protheus ou gere o C___digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSVSService
	::oWSPEDIDO          := VSService_PEDIDO():New()
	::oWSsolicitacao     := VSService_SOLICITACAO():New()
Return

WSMETHOD RESET WSCLIENT WSVSService
	::cHORA              := NIL
	::nPARAM             := NIL
	::cTESTE             := NIL
	::oWSPEDIDO          := NIL
	::oWSsolicitacao     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSVSService
Local oClone := WSVSService():New()
	oClone:_URL          := ::_URL
	oClone:cHORA         := ::cHORA
	oClone:nPARAM        := ::nPARAM
	oClone:cTESTE        := ::cTESTE
	oClone:oWSPEDIDO     :=  IIF(::oWSPEDIDO = NIL , NIL ,::oWSPEDIDO:Clone() )
	oClone:oWSsolicitacao :=  IIF(::oWSsolicitacao = NIL , NIL ,::oWSsolicitacao:Clone() )
Return oClone

// WSDL Method RECEBEHORA of Service WSVSService

WSMETHOD RECEBEHORA WSSEND NULLPARAM WSRECEIVE cHORA WSCLIENT WSVSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RECEBEHORA xmlns="http://services.soc.syson.com.br/">'
cSoap += "</RECEBEHORA>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"",;
	"DOCUMENT","http://services.soc.syson.com.br/",,,;
	"http://sys-on.com.br:8080/SocWebService/VS")

::Init()
::cHORA              :=  WSAdvValue( oXmlRet,"_RECEBEHORARESPONSE:_HORA:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ENVIATESTE of Service WSVSService

WSMETHOD ENVIATESTE WSSEND nPARAM WSRECEIVE cTESTE WSCLIENT WSVSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ENVIATESTE xmlns="http://services.soc.syson.com.br/">'
cSoap += WSSoapValue("PARAM", ::nPARAM, nPARAM , "int", .F. , .F., 0 , NIL, .F.)
cSoap += "</ENVIATESTE>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"",;
	"DOCUMENT","http://services.soc.syson.com.br/",,,;
	"http://sys-on.com.br:8080/SocWebService/VS")

::Init()
::cTESTE             :=  WSAdvValue( oXmlRet,"_ENVIATESTERESPONSE:_TESTE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviaPedido of Service WSVSService

WSMETHOD enviaPedido WSSEND BYREF oWSPEDIDO WSRECEIVE NULLPARAM WSCLIENT WSVSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<enviaPedido xmlns="http://services.soc.syson.com.br/">'
cSoap += WSSoapValue("PEDIDO", ::oWSPEDIDO, oWSPEDIDO , "pedido", .F. , .F., 0 ,Nil, .F.)
cSoap += "</enviaPedido>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"",;
	"DOCUMENT","http://services.soc.syson.com.br/",,,;
	"http://sys-on.com.br:8080/SocWebService/VS")

::Init()
::oWSPEDIDO:SoapRecv( WSAdvValue( oXmlRet,"_ENVIAPEDIDORESPONSE:_PEDIDO","pedido",NIL,NIL,NIL,NIL,@oWSPEDIDO,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method recebePedido of Service WSVSService

WSMETHOD recebePedido WSSEND BYREF oWSPEDIDO WSRECEIVE NULLPARAM WSCLIENT WSVSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<recebePedido xmlns="http://services.soc.syson.com.br/">'
cSoap += WSSoapValue("PEDIDO", ::oWSPEDIDO, oWSPEDIDO , "pedido", .F. , .F., 0 , Nil, .F.)
cSoap += "</recebePedido>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"",;
	"DOCUMENT","http://services.soc.syson.com.br/",,,;
	"http://sys-on.com.br:8080/SocWebService/VS")

::Init()
::oWSPEDIDO:SoapRecv( WSAdvValue( oXmlRet,"_RECEBEPEDIDORESPONSE:_PEDIDO","pedido",NIL,NIL,NIL,NIL,@oWSPEDIDO,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviaSolicitacao of Service WSVSService

WSMETHOD enviaSolicitacao WSSEND BYREF oWSsolicitacao WSRECEIVE oWSsolicitacao WSCLIENT WSVSService
Local cSoap := "" , oXmlRet := Nil

BEGIN WSMETHOD

cSoap += '<enviaSolicitacao xmlns="http://services.soc.syson.com.br/">'

cSoap += 	WSSoapValue("solicitacao"	, ::oWSsolicitacao	, oWSsolicitacao 	, "solicitacao"	, .F. , .F., 0 , Nil, .T.)

cSoap += "</enviaSolicitacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"","DOCUMENT","http://services.soc.syson.com.br/",,"1.031217","http://sys-on.com.br:8080/SocWebService/VS")

::Init()
::oWSsolicitacao:SoapRecv( WSAdvValue( oXmlRet,"_ENVIASOLICITACAORESPONSE:_SOLICITACAO","solicitacao",NIL,NIL,NIL,NIL,@oWSsolicitacao,NIL) )
::oWSsolicitacao := XmlChildEx( oXmlRet:_NS2_ENVIASOLICITACAORESPONSE , "_SOLICITACAO" ) // Retorno
END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure pedido

WSSTRUCT VSService_pedido
	WSDATA   oWSCABECALHO              AS VSService_cabecalho OPTIONAL
	WSDATA   oWSDETALHES               AS VSService_itens OPTIONAL
	WSDATA   oWSRETORNO                AS VSService_retorno OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_pedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_pedido
Return

WSMETHOD CLONE WSCLIENT VSService_pedido
	Local oClone := VSService_pedido():NEW()
	oClone:oWSCABECALHO         := IIF(::oWSCABECALHO = NIL , NIL , ::oWSCABECALHO:Clone() )
	oClone:oWSDETALHES          := IIF(::oWSDETALHES = NIL , NIL , ::oWSDETALHES:Clone() )
	oClone:oWSRETORNO           := IIF(::oWSRETORNO = NIL , NIL , ::oWSRETORNO:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_pedido
	Local cSoap := ""
	cSoap += WSSoapValue("CABECALHO", ::oWSCABECALHO, ::oWSCABECALHO , "cabecalho", .F. , .F., 0 , Nil, .F.)
	//cSoap += WSSoapValue("DETALHES", ::oWSDETALHES, ::oWSDETALHES , "itens", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("DETALHES", ::oWSDETALHES, ::oWSDETALHES , "itens", .T. , .F., 0 , Nil, .T.)
	cSoap += WSSoapValue("RETORNO", ::oWSRETORNO, ::oWSRETORNO , "retorno", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_pedido
	Local oNode1
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_CABECALHO","cabecalho",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWSCABECALHO := VSService_cabecalho():New()
		::oWSCABECALHO:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_DETALHES","itens",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode2 != NIL
		::oWSDETALHES := VSService_itens():New()
		::oWSDETALHES:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_RETORNO","retorno",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode3 != NIL
		::oWSRETORNO := VSService_retorno():New()
		::oWSRETORNO:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure solicitacao

WSSTRUCT VSService_solicitacao
	WSDATA   oWScabecalho              AS VSService_cabecalho OPTIONAL
	WSDATA   oWSdetalhes               AS VSService_detalhes OPTIONAL
	WSDATA   oWSretorno                AS VSService_retorno OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_solicitacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_solicitacao
	::oWSdetalhes          := {} // Array Of  VSService_DETALHES():New()
Return

WSMETHOD CLONE WSCLIENT VSService_solicitacao
	Local oClone := VSService_solicitacao():NEW()
	oClone:oWScabecalho         := IIF(::oWScabecalho = NIL , NIL , ::oWScabecalho:Clone() )
	oClone:oWSdetalhes := NIL
	If ::oWSdetalhes <> NIL
		oClone:oWSdetalhes := {}
		aEval( ::oWSdetalhes , { |x| aadd( oClone:oWSdetalhes , x:Clone() ) } )
	Endif
	oClone:oWSretorno           := IIF(::oWSretorno = NIL , NIL , ::oWSretorno:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_solicitacao
	Local cSoap := ""
	cSoap += WSSoapValue("cabecalho", ::oWScabecalho, ::oWScabecalho , "cabecalho", .F. , .F., 0 , Nil, .F.)
	aEval( ::oWSdetalhes , {|x| cSoap := cSoap  +  WSSoapValue("detalhes", x , x , "detalhes", .F. , .F., 0 , Nil, .F.)  } )
	cSoap += WSSoapValue("retorno", ::oWSretorno, ::oWSretorno , "retorno", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_solicitacao
	Local oNode1
	Local nRElem2, oNodes2, nTElem2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_CABECALHO","cabecalho",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		::oWScabecalho := VSService_cabecalho():New()
		::oWScabecalho:SoapRecv(oNode1)
	EndIf
	oNodes2 :=  WSAdvValue( oResponse,"_DETALHES","detalhes",{},NIL,.T.,"O",NIL,NIL)
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWSdetalhes , VSService_detalhes():New() )
			::oWSdetalhes[len(::oWSdetalhes)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
	oNode3 :=  WSAdvValue( oResponse,"_RETORNO","retorno",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode3 != NIL
		::oWSretorno := VSService_retorno():New()
		::oWSretorno:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure cabecalho

WSSTRUCT VSService_cabecalho
	WSDATA   nnumero                   AS int OPTIONAL
	WSDATA   nunidade                  AS long OPTIONAL
	WSDATA   csolicitante              AS string OPTIONAL
	WSDATA   nlocentrega               AS int OPTIONAL
	WSDATA   cemissao                  AS string OPTIONAL
	WSDATA   oWScomprador              AS VSService_comprador OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_cabecalho
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_cabecalho
Return

WSMETHOD CLONE WSCLIENT VSService_cabecalho
	Local oClone := VSService_cabecalho():NEW()
	oClone:nnumero              := ::nnumero
	oClone:nunidade             := ::nunidade
	oClone:csolicitante         := ::csolicitante
	oClone:nlocentrega          := ::nlocentrega
	oClone:cemissao             := ::cemissao
	oClone:oWScomprador         := IIF(::oWScomprador = NIL , NIL , ::oWScomprador:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_cabecalho
	Local cSoap := ""
	cSoap += WSSoapValue("numero"		, ::nnumero		, ::nnumero 		, "int"			, .T. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("unidade"		, ::nunidade	, ::nunidade 		, "long"		, .T. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("solicitante"	, ::csolicitante, ::csolicitante 	, "string"		, .T. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("locentrega"	, ::nlocentrega	, ::nlocentrega 	, "int"			, .T. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("emissao"		, ::cemissao	, ::cemissao 		, "string"		, .T. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("comprador"	, ::oWScomprador, ::oWScomprador 	, "comprador"	, .T. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_cabecalho
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nnumero            :=  WSAdvValue( oResponse,"_NUMERO","int",NIL,NIL,NIL,"N",NIL,NIL)
	::nunidade           :=  WSAdvValue( oResponse,"_UNIDADE","long",NIL,NIL,NIL,"N",NIL,NIL)
	::csolicitante       :=  WSAdvValue( oResponse,"_SOLICITANTE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nlocentrega        :=  WSAdvValue( oResponse,"_LOCENTREGA","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cemissao           :=  WSAdvValue( oResponse,"_EMISSAO","string",NIL,NIL,NIL,"S",NIL,NIL)
	oNode6 :=  WSAdvValue( oResponse,"_COMPRADOR","comprador",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode6 != NIL
		::oWScomprador := VSService_comprador():New()
		::oWScomprador:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure itens

WSSTRUCT VSService_itens
	WSDATA   oWSN_ITEM                 AS VSService_item OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_itens
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_itens
	::oWSN_ITEM            := {} // Array Of  VSService_ITEM():New()
Return

WSMETHOD CLONE WSCLIENT VSService_itens
	Local oClone := VSService_itens():NEW()
	oClone:oWSN_ITEM := NIL
	If ::oWSN_ITEM <> NIL
		oClone:oWSN_ITEM := {}
		aEval( ::oWSN_ITEM , { |x| aadd( oClone:oWSN_ITEM , x:Clone() ) } )
	Endif
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_itens
	Local cSoap := ""
	aEval( ::oWSN_ITEM , {|x| cSoap := cSoap  +  WSSoapValue("N_ITEM", x , x , "item", .F. , .F., 0 , Nil, .F.)  } )
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_itens
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNodes1 :=  WSAdvValue( oResponse,"_N_ITEM","item",{},NIL,.T.,"O",NIL,NIL)
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSN_ITEM , VSService_item():New() )
			::oWSN_ITEM[len(::oWSN_ITEM)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure retorno

WSSTRUCT VSService_retorno
	WSDATA   cocorrencia               AS string OPTIONAL
	WSDATA   cobservacao               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_retorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_retorno
Return

WSMETHOD CLONE WSCLIENT VSService_retorno
	Local oClone := VSService_retorno():NEW()
	oClone:cocorrencia          := ::cocorrencia
	oClone:cobservacao          := ::cobservacao
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_retorno
	Local cSoap := ""
	cSoap += WSSoapValue("ocorrencia", ::cocorrencia, ::cocorrencia , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("observacao", ::cobservacao, ::cobservacao , "string", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_retorno
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cocorrencia        :=  WSAdvValue( oResponse,"_OCORRENCIA","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cobservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure detalhes

WSSTRUCT VSService_detalhes
	WSDATA   nitem                     AS int OPTIONAL
	WSDATA   cproduto                  AS string OPTIONAL
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   cprodfor                  AS string OPTIONAL
	WSDATA   cunimed                   AS string OPTIONAL
	WSDATA   nquantidade               AS float OPTIONAL
	WSDATA   cnecessidade              AS string OPTIONAL
	WSDATA   cobs                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_detalhes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_detalhes
Return

WSMETHOD CLONE WSCLIENT VSService_detalhes
	Local oClone := VSService_detalhes():NEW()
	oClone:nitem                := ::nitem
	oClone:cproduto             := ::cproduto
	oClone:cdescricao           := ::cdescricao
	oClone:cprodfor             := ::cprodfor
	oClone:cunimed              := ::cunimed
	oClone:nquantidade          := ::nquantidade
	oClone:cnecessidade         := ::cnecessidade
	oClone:cobs                 := ::cobs
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_detalhes
	Local cSoap := ""
	cSoap += WSSoapValue("item", ::nitem, ::nitem , "int", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("produto", ::cproduto, ::cproduto , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("descricao", ::cdescricao, ::cdescricao , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("prodfor", ::cprodfor, ::cprodfor , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("unimed", ::cunimed, ::cunimed , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("quantidade", ::nquantidade, ::nquantidade , "float", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("necessidade", ::cnecessidade, ::cnecessidade , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("obs", ::cobs, ::cobs , "string", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_detalhes
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nitem              :=  WSAdvValue( oResponse,"_ITEM","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cproduto           :=  WSAdvValue( oResponse,"_PRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cprodfor           :=  WSAdvValue( oResponse,"_PRODFOR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cunimed            :=  WSAdvValue( oResponse,"_UNIMED","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nquantidade        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cnecessidade       :=  WSAdvValue( oResponse,"_NECESSIDADE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cobs               :=  WSAdvValue( oResponse,"_OBS","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure comprador

WSSTRUCT VSService_comprador
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cfone                     AS string OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_comprador
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_comprador
Return

WSMETHOD CLONE WSCLIENT VSService_comprador
	Local oClone := VSService_comprador():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cnome                := ::cnome
	oClone:cfone                := ::cfone
	oClone:cemail               := ::cemail
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_comprador
	Local cSoap := ""
	cSoap += WSSoapValue("codigo", ::ncodigo, ::ncodigo , "int", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("nome", ::cnome, ::cnome , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("fone", ::cfone, ::cfone , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_comprador
	::Init()
	If oResponse = NIL ; Return ; Endif
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cfone              :=  WSAdvValue( oResponse,"_FONE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cemail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure item

WSSTRUCT VSService_item
	WSDATA   nITEM                     AS int OPTIONAL
	WSDATA   cPRODUTO                  AS string OPTIONAL
	WSDATA   cPRODFOR                  AS string OPTIONAL
	WSDATA   cUNIMED                   AS string OPTIONAL
	WSDATA   cQUANTIDADE               AS string OPTIONAL
	WSDATA   cPRCUNIT                  AS string OPTIONAL
	WSDATA   cTOTAL                    AS string OPTIONAL
	WSDATA   cDATAENTR                 AS string OPTIONAL
	WSDATA   cOBS                      AS string OPTIONAL
	WSDATA   nNUMSC                    AS int OPTIONAL
	WSDATA   nITEMSC                   AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT VSService_item
	::Init()
Return Self

WSMETHOD INIT WSCLIENT VSService_item
Return

WSMETHOD CLONE WSCLIENT VSService_item
	Local oClone := VSService_item():NEW()
	oClone:nITEM                := ::nITEM
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:cPRODFOR             := ::cPRODFOR
	oClone:cUNIMED              := ::cUNIMED
	oClone:cQUANTIDADE          := ::cQUANTIDADE
	oClone:cPRCUNIT             := ::cPRCUNIT
	oClone:cTOTAL               := ::cTOTAL
	oClone:cDATAENTR            := ::cDATAENTR
	oClone:cOBS                 := ::cOBS
	oClone:nNUMSC               := ::nNUMSC
	oClone:nITEMSC              := ::nITEMSC
Return oClone

WSMETHOD SOAPSEND WSCLIENT VSService_item
	Local cSoap := ""
	cSoap += WSSoapValue("ITEM", ::nITEM, ::nITEM , "int", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("PRODFOR", ::cPRODFOR, ::cPRODFOR , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("UNIMED", ::cUNIMED, ::cUNIMED , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("QUANTIDADE", ::cQUANTIDADE, ::cQUANTIDADE , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("PRCUNIT", ::cPRCUNIT, ::cPRCUNIT , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("TOTAL", ::cTOTAL, ::cTOTAL , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("DATAENTR", ::cDATAENTR, ::cDATAENTR , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("OBS", ::cOBS, ::cOBS , "string", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("NUMSC", ::nNUMSC, ::nNUMSC , "int", .F. , .F., 0 , Nil, .F.)
	cSoap += WSSoapValue("ITEMSC", ::nITEMSC, ::nITEMSC , "int", .F. , .F., 0 , Nil, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT VSService_item
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nITEM              :=  WSAdvValue( oResponse,"_ITEM","int",NIL,NIL,NIL,"N",NIL,NIL)
	::cPRODUTO           :=  WSAdvValue( oResponse,"_PRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPRODFOR           :=  WSAdvValue( oResponse,"_PRODFOR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cUNIMED            :=  WSAdvValue( oResponse,"_UNIMED","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPRCUNIT           :=  WSAdvValue( oResponse,"_PRCUNIT","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTOTAL             :=  WSAdvValue( oResponse,"_TOTAL","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDATAENTR          :=  WSAdvValue( oResponse,"_DATAENTR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cOBS               :=  WSAdvValue( oResponse,"_OBS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nNUMSC             :=  WSAdvValue( oResponse,"_NUMSC","int",NIL,NIL,NIL,"N",NIL,NIL)
	::nITEMSC            :=  WSAdvValue( oResponse,"_ITEMSC","int",NIL,NIL,NIL,"N",NIL,NIL)
Return


