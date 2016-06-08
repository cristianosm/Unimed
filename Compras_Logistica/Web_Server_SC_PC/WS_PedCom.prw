#Include "Protheus.ch"
#Include "Apwebsrv.ch"

#Define CRLF	CHR(13)+CHR(10)
#Define ENTER 	CHR(13)+CHR(10)

*******************************************************************************
WsService WS_PEDCOM Description "WS Integracao Protheus x Syson - Recebe Pedido de Compras" NAMESPACE "http://172.22.0.185:81/ws/"
	*******************************************************************************

	WsData oPedido		As SPC_Pedido
	WsData oRetorno		As SPC_Retorno

	WsMethod RecebePedido Description	"Metodo que recebe o Pedido de Compras apartir do Sys-on"

EndWsService

*******************************************************************************
WsMethod RecebePedido WsReceive oPedido WsSend oRetorno WsService WS_PEDCOM //| Metodo Recebe Pedido de Compras
	*******************************************************************************

	Local lReturn 	:= .T.
	Local iTmp 		:= 1

	/*
	AAdd(::aRetProdutos, WSClassNew("aRetorno"))
	nX := len(::aRetProdutos)
	::aRetProdutos[nX]:cMsgIntegra		:= cErro
	::aRetProdutos[nX]:bStatus			:= bRet
	::aRetProdutos[nX]:aItensProdutos	:= Array(Len(aResults))
	For iTmp := 1 To Len(aResults)
		::aRetProdutos[nX]:aItensProdutos[iTmp]             	:= WSClassNew("ItensGL_GETPRODUTO")
		::aRetProdutos[nX]:aItensProdutos[iTmp]:B1_COD     	:= aResults[iTmp][1]
		::aRetProdutos[nX]:aItensProdutos[iTmp]:B1_DESC   		:= aResults[iTmp][2]
	Next iTmp
	*/

	If lReturn == .F.
		SetSoapFault('Metodo não disponível','Inconsistencia')
		Return lReturn
	EndIF

Return lReturn

*******************************************************************************
WSSTRUCT SPC_Retorno //| Retorno de Ocorrencia do Recebimento do Pedido
	*******************************************************************************

	WsData ocorrencia     	As Boolean
	WsData observacao		As String Optional

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Pedido //| Pedido de Compras
	*******************************************************************************

	WsData cabecalho		As SPC_Cabecalho
	WsData detalhes		   	As Array of SPC_Detalhes

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Cabecalho //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData emissao		   	As Date  		//| Data de emissao do pedido
	WsData fornecedor	  	As Integer  	//|
	WsData condpag		   	As String
	WsData contato		   	As String
	WsData unidadesol	   	As Integer
	WsData frete		   	As SPC_Frete Optional

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Frete // Frete do Pedido de compras
	*******************************************************************************

	WsData cnpj		      	As Integer
	WsData nome		      	As String
	WsData tipo		      	As String
	WsData valor		  	As Float
	WsData seguro		  	As Float

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Detalhes //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData item		      	As Integer  	//|
	WsData produto	      	As String  	//|
	WsData prodfor	      	As String
	WsData unimed        	As String
	WsData quantidade		As Float
	WsData prcunit	      	As Float
	WsData total         	As Float
	WsData dataentr       	As Date
	WsData obs	         	As String
	WsData numsc	       	As Integer
	WsData itemsc         As Integer

ENDWSSTRUCT