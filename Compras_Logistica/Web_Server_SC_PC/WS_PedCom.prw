#Include "Protheus.ch"
#Include "Apwebsrv.ch"
#Include "Totvs.ch"
#XCOMMAND CLOSETRANSACTION LOCKIN <aAlias,...>   => EndTran( \{ <aAlias> \}  ); End Sequence

// Parametros AutoExec
#Define PEDCOMPRA	1
#Define INCLUI		3

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
	Local cNumSc7	:= Nil
	Local cFornece	:= "AS0052"
	Local cLoja		:= "01"
	Local cCond		:= "000" // 000 -> A Vista
	Local cFilEnt	:= "13" // 13 - Hospital unimed
	Local oItem		:= WSClassNew("N_ITEM")

	Local aDet		:= {}
	Local aCab		:= {}
	Local cFilOri	:= cFilant

	Local cRpcEmp	:= "01"	//| Caracter 	Codigo da empresa.
	Local cRpcFil	:= "13"	//| Caracter	Codigo da filial.
	Local cEnvUser	:= "lindomar.silva"//"maicon.souza"	//| Caracter	Nome do usuario.
	Local cEnvPass	:= "lindomar"//"maicon"	//| Caracter	Senha do usuario.
	Local cEnvMod	:= "COM"	//| Caracter	Codigo do modulo.			'FAT'
	Local cFunName	:= "MATA120"	//| Caracter	Nome da rotina que sera setada para retorno da funcao FunName().			'RPC'
	Local aTables	:= {"SX6","SB1","SC1","SC7"}		//| Vetor		Array contendo as tabelas a serem abertas.			{}
	Local lShowFinal:= .T.		//| Logico		Alimenta a variavel publica lMsFinalAuto.			.F.
	Local lAbend	:= .T.		//| Logico		Se .T., gera mensagem de erro ao ocorrer erro ao checar a licenca para a estacao.			.T.
	Local lOpenSX	:= .T.		//| Logico		SE .T. pega a primeira filial do arquivo SM0 quando nao passar a filial e realiza a abertura dos SXs.			.T.
	Local lConnect	:= .T.		//| Logico		Se .T., faz a abertura da conexao com servidor As400, SQL Server etc.			.T.

	Private cRetorno := ""
	Private lMsErroAuto := .F.

	cFilAnt			:= cRpcFil
	RpcSetEnv(cRpcEmp,cRpcFil,cEnvUser,cEnvPass,cEnvMod,cFunName,aTables,lShowFinal,lAbend,lOpenSX,lConnect)


	cNumSc7 := GetSX8Num("SC7","C7_NUM") //"A12875"

		aAdd(aCab, {'C7_NUM'	, cNumSc7 					/*SC7->C7_NUM*/		, Nil})	//--Numero do Pedido
		aAdd(aCab, {'C7_EMISSAO', Pedido:Cabecalho:Emissao 	/*SC7->C7_EMISSAO*/	, Nil})	//--Data de Emissao
		aAdd(aCab, {'C7_FORNECE', cFornece 					/*SC7->C7_FORNECE*/	, Nil})	//--Fornecedor
		aAdd(aCab, {'C7_LOJA'	, cLoja 					/*SC7->C7_LOJA*/	, Nil})	//--Loja do Fornecedor
		aAdd(aCab, {'C7_CONTATO', Pedido:Cabecalho:Contato 	/*SC7->C7_CONTATO*/ , Nil})	//--Contato
		aAdd(aCab, {'C7_COND'	, cCond 					/*SC7->C7_COND*/	, Nil})	//--Condicao de Pagamento
		aAdd(aCab, {'C7_FILENT'	, cFilEnt 					/*SC7->C7_FILENT*/	, Nil})	//--Filial de Entrega


	For nPC := 1 to len(Pedido:Detalhes)

		oItem := Pedido:Detalhes[nPC]
//TamSx3("C7_VLDESC")[2])
		aadd(aDet,{{"C7_ITEM"   	,StrZero(oItem:Item,4)	,nil},;
					 {"C7_PRODUTO"	,oItem:Produto			,nil},;
					 {"C7_CLVL"		,"0900001"				,nil},;
					 {"C7_QUANT"  	,oItem:Quantidade		,nil},;
					 {"C7_PRECO"  	,oItem:PrcUnit			,nil},;
					 {"C7_TOTAL"  	,oItem:Total			,nil},;
					 {"C7_DATPRF"	,oItem:DataEntr			,nil},;
					 {"C7_OBS"    	,oItem:Obs				,nil},;
					 {"C7_NUMSC"   	,StrZero(oItem:NumSC,6)	,nil},;
					 {"C7_ITEMSC"  	,StrZero(oItem:ItemSC,4),nil},;
					 {"C7_CC"    	,"11813"				,nil},;
					 {"C7_LOCAL"	,"01"					,nil}})
					 //{"C7_TES"    	,"001"			,nil},;

	Next nPC

	If Len( aCab ) > 0 .And. Len( aDet ) > 0
   		Begin Transaction
			lMsErroAuto := .F.
			MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)},PEDCOMPRA, aCab, aDet, INCLUI, .F. )

		If lMsErroAuto
			cTxtLog := NomeAutoLog()
			If ValType( cTxtLog ) == 'C'
				cTxtAux 	:= ( Memoread( cTxtLog ) )
				conout 		:= cTxtAux
				cTxtAux     := StrTran(cTxtAux,ENTER," ")
				cTxtSea := "  "
				While AT( cTxtSea, cTxtAux ) > 0

					cTxtAux :=  StrTran(cTxtAux,cTxtSea," ")

				EndDo
				cRetorno 	:= "MSExecAuto: MATA120: " + Substr(cTxtAux,1,150) + "..."
			EndIf
			Disarmtransaction()
		EndIf
		End Transaction
	EndIf
	SC7->(ConfirmSX8())
	//U_PC_SC7_Auto(aCab,aDet)
	/*If Len(aDet) > 0

		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)}, 1, aCab, aItPC,3, .F. )
		MsExecAuto({|X,Y,Z,W| MATA120(X,Y,Z,W)},1, aCab, aDet, 3)
		SC7->(ConfirmSX8())

		If lMsErroAuto //SE NAO HOUVE ERRO
			lOK:=.F.
			MostraErro()
		EndIf
	EndIf

*/
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


	If lReturn == .F. .Or. lMsErroAuto
		///SetSoapFault('Metodo nao disponivel','Inconsistencia')

		oRetorno:Pedido:Retorno:Ocorrencia := "N"
		oRetorno:Pedido:Retorno:Observacao := "Pedido nao recebido..." + cRetorno

	Else

		oRetorno:Pedido:Retorno:Ocorrencia := "S"
		oRetorno:Pedido:Retorno:Observacao := "Pedido Recebido com Sucesso...Numero: " + cNumSc7
	EndIf


	//cFilant := cFilOri
	//RpcClearEnv()

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