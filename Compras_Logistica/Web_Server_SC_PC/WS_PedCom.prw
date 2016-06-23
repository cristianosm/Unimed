+//#Include "Protheus.ch"
#Include "Apwebsrv.ch"
#Include "Totvs.ch"
//#Include "RestFul.ch"

#Define CRLF	CHR(13)+CHR(10)
#Define ENTER 	CHR(13)+CHR(10)

*******************************************************************************
WsService WS_PEDCOM Description "WS Integracao Protheus x Syson - Recebe Pedido de Compras" NAMESPACE "http://172.22.0.185:81/ws/"
*******************************************************************************


	WsData Pedido	As SPC_Pedido
	WsData oRetorno	As SPC_RPedido

	WsMethod RecebePedido Description	"Metodo que recebe o Pedido de Compras apartir do Sys-on"

EndWsService

*******************************************************************************
WsMethod RecebePedido WsReceive Pedido WsSend oRetorno WsService WS_PEDCOM //| Metodo Recebe Pedido de Compras
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

		oRetorno:Pedido:Retorno:Ocorrencia := "N"
		oRetorno:Pedido:Retorno:Observacao := "Pedido nao recebido..."

	Else

		oRetorno:Pedido:Retorno:Ocorrencia := "S"
		oRetorno:Pedido:Retorno:Observacao := "Pedido Recebido com Sucesso..."
	EndIf

Return lReturn
*******************************************************************************
WSSTRUCT  SPC_RPedido//| Retorno de Ocorrencia do Recebimento do Pedido
*******************************************************************************

	WsData Pedido          As SPC_Retorno

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Retorno //| Ocorrencia do Recebimento do Pedido
*******************************************************************************

	WsData Retorno     	As SPC_Ocorrencia

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Ocorrencia //| Ocorrencia do Recebimento do Pedido
*******************************************************************************

	WsData Ocorrencia     	As String
	WsData Observacao		As String 	Optional

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Pedido //| Pedido de Compras
	*******************************************************************************

	WsData Cabecalho		As SPC_Cabecalho
	WsData Detalhes		   	As Array of N_ITEM

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Cabecalho //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData Emissao		   	As Date
	WsData Fornecedor	  	As Integer
	WsData CondPag		   	As String
	WsData Contato		   	As String
	WsData UnidadeSol	   	As Integer 		Optional
	WsData Frete		   	As SPC_Frete 	Optional

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Frete // Frete do Pedido de compras
	*******************************************************************************

	WsData Cnpj		      	As Integer 	Optional
	WsData Nome		      	As String 	Optional
	WsData Tipo		      	As String 	Optional
	WsData Valor		  	As Float 	Optional
	WsData Seguro		  	As Float 	Optional

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT N_ITEM //| Cabecalho do Pedido de compras
	*******************************************************************************

	WsData Item		      	As Integer
	WsData Produto	      	As String 	Optional
	WsData ProdFor	      	As String
	WsData UniMed        	As String
	WsData Quantidade		As Float
	WsData PrcUnit	      	As Float
	WsData Total         	As Float
	WsData DataEntr       	As Date
	WsData Obs	         	As String 	Optional
	WsData NumSC	       	As Integer
	WsData ItemSC           As Integer

ENDWSSTRUCT