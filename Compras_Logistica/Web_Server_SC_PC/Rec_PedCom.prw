#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "TbiConn.ch"
#Include "TopConn.ch"

// Parametros AutoExec
#Define PEDCOMPRA	1
#Define INCLUI		3
#Define DOISES		"  "
*******************************************************************************
User Function Rec_PedCom(Pedido,lMsErroAuto)
*******************************************************************************

	PrepVareAmb()

	If Valida(@Pedido,@lMsErroAuto)

		Estrutura(@aCab, @adet)

		Begin Transaction
			ExecAuto(@aCab, @adet,@lMsErroAuto)
		End Transaction

	Else
		lMsErroAuto := .T.
	EndIf

	SC7->(ConfirmSX8())

	Return(cRetorno)
*******************************************************************************
Static Function PrepVareAmb()
*******************************************************************************


	DbSelectArea("SA2");DbSetOrder(3)

	_SetOwnerPrvt( 'cFornece'		, "AS0052" 				)//Codigo Unimed Centtral [AS0052][01] |
	_SetOwnerPrvt( 'cLoja'			, "01" 					)//Loja Unimed Centtral [AS0052][01] |
	_SetOwnerPrvt( 'cFilHom'		, "13" 					)//Filial Homologada a Receber Enviar Solicitacao e Receber Pedidos Sys-ON
	_SetOwnerPrvt( 'cRetorno'		, "" 					)//Variavel de Retorno de Erro e Validacao
	_SetOwnerPrvt( 'lRpcSet'		, .F. 					)//Variavel de Retorno da Montagem do Ambiente
	_SetOwnerPrvt( 'aCab'			, {} 					)//Variavel a ser utilizada no Cabecalho do MSExecAuto
	_SetOwnerPrvt( 'aDet'			, {} 					)//Variavel a ser utilizada no Detalhe do MSExecAuto
	_SetOwnerPrvt( 'oItem'			, WSClassNew("N_ITEM")	)//oItem Auxiliar para receber os dados do WS
	_SetOwnerPrvt( 'cNumSc7'		, ""					)// Armazena o Numero de Pedido Obtido..
	_SetOwnerPrvt( 'cCondPag'		, ""					)// Armazena o Numero de Pedido Obtido..

	cFilAnt			:= cFilHom

	RpcSetType( 3 )

	lRpcSet :=  RpcSetEnv("01",cFilAnt,Nil,Nil,"COM","MATA120", {"SX6","SB1","SC1","SC7"} )

	cNumSc7 := GetSX8Num("SC7","C7_NUM") //"A12875"

Return()
*******************************************************************************
Static Function Valida(Pedido,lMsErroAuto)
*******************************************************************************

	If !lRpcSet
		cRetorno := "Não Foi Possivel inicializar o ambinete (RpcSetEnv) com a Filial: "+cFilAnt
		Return(.F.)
	Endif

	// Valida se existe Cadastro de Comprador Syson

	// Valida se o Fornecedor Existe no cadastro da Unimed-VS
	cAuxCnpj := StrZero(Pedido:Cabecalho:Fornecedor,14)
	If !(SA2->(DbSeek(xFilial("SA2")+cAuxCnpj,.F.)))
		cRetorno := "Fornecedor não localizado no Cadastro de Fornecedores. CNPJ:"+Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")+""
		Return(.F.)
	Else
		cFornece := SA2->A2_COD
		cLoja	 := SA2->A2_LOJA
	EndIF

	// Valida se Fornecedor esta bloqueado e Retornou apenas uma loja
	If SA2->A2_MSBLQL == "1" //Bloqueado
		cRetorno := "Este Fornecedor esta com o Cadastro Bloqueado. CNPJ:"+Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")+""
		Return(.F.)
	EndIF


	// Validar Unidade Solicitante

	// Validar condicao de Pagto
	cCondPag := Alltrim( GetCond( Pedido:Cabecalho:CondPag ) )
	If Empty(cCondPag)
		cRetorno := "Condicao de Pagamento nao Localizada no Protheus. ["+Pedido:Cabecalho:CondPag+" Dias]..."
		Return(.F.)
	EndIf

	// Validar Cadastro de Prod x For

	// Validar se Solicitacao é Sys-On

	// Validar se Solicitacao esta Liberada

	// Validar Saldo em Solicitacao

Return(.T.)
*******************************************************************************
Static Function Estrutura(Cab,adet)
*******************************************************************************

	MaCab(@aCab)

	MDet(@adet)

Return()
*******************************************************************************
Static Function MaCab(Cab)
*******************************************************************************

	aAdd(aCab, {'C7_NUM'	, cNumSc7 							, Nil})	//--Numero do Pedido
	aAdd(aCab, {'C7_EMISSAO', StoD(Pedido:Cabecalho:Emissao)	, Nil})	//--Data de Emissao
	aAdd(aCab, {'C7_FORNECE', cFornece 							, Nil})	//--Fornecedor
	aAdd(aCab, {'C7_LOJA'	, cLoja 							, Nil})	//--Loja do Fornecedor
	aAdd(aCab, {'C7_CONTATO', Pedido:Cabecalho:Contato 	 		, Nil})	//--Contato

	aAdd(aCab, {'C7_COND'	, cCondPag 							, Nil})	//--Condicao de Pagamento

	aAdd(aCab, {'C7_FILENT'	, cFilHom 							, Nil})	//--Filial de Entrega

	If !Empty(Pedido:Cabecalho:Frete:Tipo)
		aAdd(aCab, {'C7_TPFRETE', Pedido:Cabecalho:Frete:Tipo 			, Nil})	//--Tipo Frete
		aAdd(aCab, {'C7_FRETE'	, SToV(Pedido:Cabecalho:Frete:Valor	)	, Nil})	//--Vlr.Frete
		aAdd(aCab, {'C7_SEGURO'	, SToV(Pedido:Cabecalho:Frete:Seguro )	, Nil})	//--Vlr.Seguro
	EndIf

Return()
*******************************************************************************
Static Function MDet(adet)
*******************************************************************************

	For nPC := 1 to len(Pedido:Detalhes)

		oItem := Pedido:Detalhes[nPC]

		aadd(aDet,{	{"C7_ITEM"   	,StrZero(oItem:Item,4)		,nil},;
					{"C7_PRODUTO"	,RetProd(oItem:ProdFor)		,nil},;
					{"C7_CLVL"		,"0900001"					,nil},; // pegar da Solicitacao
					{"C7_QUANT"  	,SToV(oItem:Quantidade)		,nil},;
					{"C7_PRECO"  	,SToV(oItem:PrcUnit	 )		,nil},;
					{"C7_TOTAL"  	,SToV(oItem:Total	 )		,nil},;
					{"C7_DATPRF"	,StoD(oItem:DataEntr)		,nil},;
					{"C7_OBS"    	,oItem:Obs					,nil},;
					{"C7_NUMSC"   	,StrZero(oItem:NumSC,6)		,nil},;
					{"C7_ITEMSC"  	,StrZero(oItem:ItemSC,4)	,nil},;
					{"C7_QTDSOL"  	,SToV(oItem:Quantidade)		,nil},;
					{"C7_CC"    	,"11813"					,nil},; // pegar da Solicitacao
					{"C7_LOCAL"  	,"02"						,nil},; // pegar da Solicitacao
					{"C7_OBS"  		,"Observacao"				,nil},; // pegar da Solicitacao
					{"C7_JUST"  	,"Justificativa"			,nil}}) // pegar da Solicitacao

	Next nPC

Return()
*******************************************************************************
Static Function ExecAuto(aCab, adet ,lMsErroAuto)
*******************************************************************************

	If Len( aCab ) > 0 .And. Len( aDet ) > 0

		MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)},PEDCOMPRA, aCab, aDet, INCLUI, .F. )

		If lMsErroAuto
			cRetorno := AjusRet()
			Disarmtransaction()
		Else
			cRetorno := cNumSc7
		EndIf

	Else
		lMsErroAuto := .T.
		cRetorno := "Não Foi Possivel Montar o Cabecalho e/ou Itens do Pedido.. MSExecAuto ! "
	EndIF

Return()
*******************************************************************************
Static Function AjusRet()
*******************************************************************************

	Local cTxtLog := NomeAutoLog()
	Local cTxtAux := ""

	If ValType( cTxtLog ) == 'C'

		cTxtAux 	:= Memoread( cTxtLog )

		conout(cTxtAux)

		cTxtAux     := StrTran(cTxtAux,ENTER," ")

		// Remove os espacos em Branco desnecessarios
		While AT(DOISES, cTxtAux ) > 0
			cTxtAux := StrTran(cTxtAux,DOISES," ")
		EndDo

		cTxtAux 	:= "MSExecAuto: MATA120: " + Substr(cTxtAux,1,150) + "..."
	EndIf

Return(cTxtAux)
*******************************************************************************
Static Function SToV(cString)//| Converte String para Number
*******************************************************************************
Local nVal := 0

nVal := Val(StrTran(cString,",","."	))

Return(nVal)
*******************************************************************************
Static Function RetProd(CProdFor)//| Retorno de Ocorrencia do Recebimento do Pedido
*******************************************************************************
	Local cProduto

	cProduto := Alltrim( Posicione("SA5",14,xFilial("SA5")+"AS005201"+CProdFor,"A5_PRODUTO"))

Return(cProduto)
*******************************************************************************
Static Function GetCond(cCond)//| Retorno de Ocorrencia do Recebimento do Pedido
*******************************************************************************

Local cSql := "select e4_Codigo from se4010 where e4_cond = '"+Alltrim(cCond)+"' and e4_tipo = '1' and Substr(e4_Codigo,1,1) = '6' and Rownum = 1 and d_e_l_e_t_ = ' '"


	If( Select("TACP") <> 0 )
		DbSelectArea("TACP");DbCloseArea()
	EndIf

	TCQUERY cSql NEW ALIAS TACP

	cCond := TACP->E4_CODIGO

	DbSelectArea("TACP");DbCloseArea()

Return(cCond)