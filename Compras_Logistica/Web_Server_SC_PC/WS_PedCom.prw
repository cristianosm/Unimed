#Include "Protheus.ch"
#Include "Apwebsrv.ch"
#Include "TbiConn.ch"

#XCOMMAND CLOSETRANSACTION LOCKIN <aAlias,...>   => EndTran( \{ <aAlias> \}  ); End Sequence

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
	Private cRetorno 	:= ""
	Private lMsErroAuto := .F.

	cRetorno := U_Rec_PedCom(@Pedido,@lMsErroAuto)

	If lMsErroAuto
		oRetorno:Pedido:Retorno:Ocorrencia := "N"
		oRetorno:Pedido:Retorno:Observacao := "Pedido nao recebido..." + cRetorno
	Else
		oRetorno:Pedido:Retorno:Ocorrencia := "S"
		oRetorno:Pedido:Retorno:Observacao := "Pedido Recebido com Sucesso...Numero: " + cRetorno
	EndIf

Return .T.
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

	WsData Emissao		   	As String
	WsData Fornecedor	  	As Integer
	WsData CondPag		   	As String
	WsData Contato		   	As String       Optional
	WsData UnidadeSol	   	As Integer 		Optional
	WsData Frete		   	As SPC_Frete 	Optional

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT SPC_Frete // Frete do Pedido de compras
*******************************************************************************

	WsData Cnpj		      	As Integer 	Optional
	WsData Nome		      	As String 	Optional
	WsData Tipo		      	As String 	Optional
	WsData Valor		  	As String 	Optional
	WsData Seguro		  	As String 	Optional

ENDWSSTRUCT
*******************************************************************************
WSSTRUCT N_ITEM //| Cabecalho do Pedido de compras
*******************************************************************************

	WsData Item		      	As Integer
	WsData Produto	      	As String 	Optional
	WsData ProdFor	      	As String
	WsData UniMed        	As String
	WsData Quantidade		As String
	WsData PrcUnit	      	As String
	WsData Total         	As String
	WsData DataEntr       	As String
	WsData Obs	         	As String 	Optional
	WsData NumSC	       	As Integer
	WsData ItemSC           As Integer

ENDWSSTRUCT