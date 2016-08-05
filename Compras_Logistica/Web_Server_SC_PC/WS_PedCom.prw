#Include "Protheus.ch"
#Include "Apwebsrv.ch"
#Include "TbiConn.ch"

#XCOMMAND CLOSETRANSACTION LOCKIN <aAlias,...>   => EndTran( \{ <aAlias> \}  ); End Sequence

#Define CRLF	CHR(13)+CHR(10)
#Define ENTER 	CHR(13)+CHR(10)

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO    :WS_PEDCOM    | AUTOR : Cristiano Machado  | DATA : 18/02/2016 **
**---------------------------------------------------------------------------**
** DESCRICAO : Ws-Service utilizado na Integracao Unimed-Vs(Protheus)        **
**           :  e Unimed-Central(Sys-ON). Recebe Pedido.                     **
**           : Layout WebService v1.3                                        **
**---------------------------------------------------------------------------**
** USO       : WSDL :  http://sys-on.com.br:8080/SocWebService/VS?wsdl       **
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
	Private WScRetorno  := ""
	
	cRetorno 	:= U_Rec_PedCom(@Pedido,@lMsErroAuto)
	WScRetorno 	:= Substr(cRetorno, 1 , If( Len(cRetorno) > 177, 177 , Len(cRetorno)) )
	
	If lMsErroAuto
	
		
		oRetorno:Pedido:Retorno:Ocorrencia := "N"
		oRetorno:Pedido:Retorno:Observacao := "Pedido nao recebido..." + WScRetorno
	Else
		oRetorno:Pedido:Retorno:Ocorrencia := "S"
		oRetorno:Pedido:Retorno:Observacao := "Pedido Recebido com Sucesso...Numero: " + WScRetorno

		//| SendMail()
		U_SMProxSys( StrZero(Pedido:Detalhes[1]:NumSC,6) , "Pedido Recebido com Sucesso...Numero: " + cRetorno + ENTER + ENTER , "Pedido Recebido do Sys-on" , "T" )

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