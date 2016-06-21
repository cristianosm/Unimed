#Include "Protheus.ch"
#Include "Apwebsrv.ch"

#Define CRLF	CHR(13)+CHR(10)
#Define ENTER 	CHR(13)+CHR(10)

*******************************************************************************
WsService WS_PEDCOM Description "WS Integracao Protheus x Syson - Recebe Pedido de Compras" NAMESPACE "http://172.22.0.185:81/ws/"
	*******************************************************************************

	WsData Pedido		As SPC_Pedido
	WsData Retorno		As SPC_Retorno

	WsMethod RecebePedido Description	"Metodo que recebe o Pedido de Compras apartir do Sys-on"

EndWsService

*******************************************************************************
WsMethod RecebePedido WsReceive Pedido WsSend Retorno WsService WS_PEDCOM //| Metodo Recebe Pedido de Compras
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
		SetSoapFault('Metodo nao disponivel','Inconsistencia')

		Retorno:Ocorrencia := !lReturn
		Retorno:Observacao := "Pedido nao recebido..."
		Return Retorno
	Else

		Retorno:Ocorrencia := lReturn
		Retorno:Observacao := "Pedido Recebido com Sucesso..."
	EndIf

Return lReturn
*******************************************************************************
WSSTRUCT SPC_Retorno //| Retorno de Ocorrencia do Recebimento do Pedido
	*******************************************************************************

	WsData Ocorrencia     	As Boolean
	WsData Observacao		As String Optional

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Pedido //| Pedido de Compras
	*******************************************************************************

	WsData Cabecalho		As SPC_Cabecalho
	WsData Detalhes		   	As Array of SPC_Detalhes

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Cabecalho //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData Emissao		   	As Date  		//| Data de emissao do pedido
	WsData Fornecedor	  	As String  	//|
	WsData Condpag		   	As String
	WsData Contato		   	As String
	WsData UnidadeSol	   	As Integer
	WsData Frete		   	As SPC_Frete Optional

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Frete // Frete do Pedido de compras
	*******************************************************************************

	WsData Cnpj		      	As String Optional
	WsData Nome		      	As String Optional
	WsData Tipo		      	As String Optional
	WsData Valor		  	As Float Optional
	WsData Seguro		  	As Float Optional

ENDWSSTRUCT

*******************************************************************************
WSSTRUCT SPC_Detalhes //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData Item		      	As String
	WsData Produto	      	As String
	WsData ProdFor	      	As String
	WsData UniMed        	As String
	WsData Quantidade		As Float
	WsData PrcUnit	      	As Float
	WsData Total         	As Float
	WsData DataEntr       	As Date
	WsData Obs	         	As String
	WsData NumSC	       	As String
	WsData ItemSC           As String

ENDWSSTRUCT