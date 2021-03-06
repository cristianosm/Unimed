#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "TbiConn.ch"
#Include "TopConn.ch"

// Parametros AutoExec
#Define PEDCOMPRA	1
#Define INCLUI		3
#Define DOISES		"  "

#Define _CNPJ		18 // Posicao a do CNPJ no retorno da funcao FWArrFilAtu

#Define _ENTER		CHR(13)+CHR(10)

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO    :Rec_PedCom    | AUTOR : Cristiano Machado  | DATA : 18/02/2016 **
**---------------------------------------------------------------------------**
** DESCRICAO : Processa o Pedido de compra Recebido pelo WS_PedCom, Com      **
**           : validacoes e caso OK. Executo a Inclusao por MSAutoExec       **
**---------------------------------------------------------------------------**
** USO       : Especifico para o cliente Unimed Vale do Sinos                **
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
User Function Rec_PedCom(Pedido,lMsErroAuto)
*******************************************************************************

	PrepVareAmb() //| Prepara as Variaveis,Tabelas e Ambiente Utilizado...

	If Valida(@Pedido,@lMsErroAuto)//| Valida o Pedido Recebido

		Estrutura(@aCab, @adet) // Monta a Estrutura de Arrays para o AutoExec

		Begin Transaction
			ExecAuto(@aCab, @adet,@lMsErroAuto)//| Executa o MSExecAuto de Inclusao do pedido de compras
		End Transaction

	Else
		lMsErroAuto := .T.
	EndIf

	SC7->(ConfirmSX8())

	Return(cRetorno )// Ajusta o Limite do Retorno
*******************************************************************************
Static Function PrepVareAmb()//| Prepara as Variaveis,Tabelas e Ambiente Utilizado...
*******************************************************************************

	DbSelectArea("SC1");DbSetOrder(1)
	DbSelectArea("SA2");DbSetOrder(3)

	_SetOwnerPrvt( 'cFornece'		, "AS0052" 				)//Codigo Unimed Centtral [AS0052][01] |
	_SetOwnerPrvt( 'cLoja'			, "01" 					)//Loja Unimed Centtral [AS0052][01] |
	_SetOwnerPrvt( 'cFilHom'		, SuperGetMv("UM_FILHOMS",.F.,"13"))// Filial Homologada a Receber Enviar Solicitacao e Receber Pedidos Sys-ON 					)//Filial Homologada a Receber Enviar Solicitacao e Receber Pedidos Sys-ON
	_SetOwnerPrvt( 'cRetorno'		, "" 					)//Variavel de Retorno de Erro e Validacao
	_SetOwnerPrvt( 'lRpcSet'		, .F. 					)//Variavel de Retorno da Montagem do Ambiente
	_SetOwnerPrvt( 'aCab'			, {} 					)//Variavel a ser utilizada no Cabecalho do MSExecAuto
	_SetOwnerPrvt( 'aDet'			, {} 					)//Variavel a ser utilizada no Detalhe do MSExecAuto
	_SetOwnerPrvt( 'oItem'			, WSClassNew("N_ITEM")	)//oItem Auxiliar para receber os dados do WS
	_SetOwnerPrvt( 'cNumSc7'		, ""					)// Armazena o Numero de Pedido Obtido..
	_SetOwnerPrvt( 'cCondPag'		, ""					)// Armazena o Numero de Pedido Obtido..
	_SetOwnerPrvt( 'cItAjust'		, ""					)// Armazena informacoes sobre o item ajustado
	_SetOwnerPrvt( 'cFilSA2'		, ""					)// Armazena informacoes sobre o item ajustado

	cFilAnt			:= cFilHom
	cFilSA2			:= "A2_MSBLQL = ' ' .Or. A2_MSBLQL = '2'"
	SA2->( dbSetFilter ( {|| &cFilSA2 },cFilSA2) ) // Remove os Fornecedores Bloqueados...

	RpcSetType( 3 )

	lRpcSet :=  RpcSetEnv("01",cFilAnt,Nil,Nil,"COM","MATA120", {"SX6","SB1","SC1","SC7"} )

	cNumSc7 := GetSX8Num("SC7","C7_NUM") //"A12875"

	Return()
*******************************************************************************
Static Function Valida(Pedido,lMsErroAuto)//| Valida o Pedido Recebido
*******************************************************************************
	Local aAreAux := Nil
	Local lRet	  := .T.

	If !lRpcSet
		cRetorno := "Nao Foi Possivel inicializar o ambinete (RpcSetEnv) com a Filial: "+cFilAnt
		Return(.F.)
	Endif

	// Valida se existe Cadastro de Comprador Syson
	aAreAux := SY1->(GetArea())
	DbSelectArea("SY1");DbSetOrder(1)
	If !(DbSeek(xFilial("SY1")+"000",.F. ))
		cRetorno := "Nao Localizado o Cadastro do Comprador SysOn. Codigo '000' Tabela SY1"
		RestArea(aAreAux)
		Return(.F.)
	EndIf
	RestArea(aAreAux)

	// Valida se o Fornecedor Existe no cadastro da Unimed-VS
	cAuxCnpj := StrZero(Pedido:Cabecalho:Fornecedor,14)
	If !(SA2->(DbSeek(xFilial("SA2")+cAuxCnpj,.F.)))
		cRetorno := "Fornecedor Nao localizado no Cadastro de Fornecedores. CNPJ:"+Transform(cAuxCnpj,"@R 99.999.999/9999-99")+""
		Return(.F.)
	Else

		cFornece := SA2->A2_COD
		cLoja	 := SA2->A2_LOJA

		// Valida se Fornecedor Retornou apenas uma loja apartir do CNJ.
		nF := 0
		While cAuxCnpj == SA2->A2_CGC .And. !Eof() // Valida se Fornecedor Retornou apenas uma loja
			nF += 1 ; SA2->( DbSkip() )
		EndDo
		If nF > 1
			cRetorno := "Fornecedor Possui mais de um Cadastro com o mesmo CNPJ:"+Transform(cAuxCnpj,"@R 99.999.999/9999-99")+". Deve ser Corrigido."
			Return(.F.)
		EndIf

	EndIF

	// Valida se Fornecedor esta bloqueado
	//If SA2->(DbSeek(xFilial("SA2")+cAuxCnpj,.F.)) .And. SA2->A2_MSBLQL == "1" //Bloqueado
	//	cRetorno := "Este Fornecedor esta com o Cadastro Bloqueado. CNPJ:"+Transform(cAuxCnpj,"@R 99.999.999/9999-99")+""
	//	Return(.F.)
	//EndIF

	// Validar Unidade Solicitante
	aDadosFil := FWArrFilAtu("01",cFilHom)
	If aDadosFil[_CNPJ] <>  StrZero(Pedido:Cabecalho:UnidadeSol,14)
		cRetorno := "O Solicitante do Pedido nao esta Homologado a Receber Pedidos Sys-On. CNPJ:"+Transform( StrZero(Pedido:Cabecalho:UnidadeSol,14),"@R 99.999.999/9999-99")+""
		Return(.F.)
	EndIF

	// Validar condicao de Pagto
	cCondPag := Alltrim( GetCond( Pedido:Cabecalho:CondPag ) )
	If Empty(cCondPag)
		cRetorno := "Condicao de Pagamento nao Localizada no Protheus. ["+Pedido:Cabecalho:CondPag+" Dias]..."
		Return(.F.)
	EndIf

	//| Valida se a Solicitacao eh Sys-ON, Estah Liberada e jah Foi Transmitida. Deve Estar POSICIONADO no SC1
	For nPC := 1 to len(Pedido:Detalhes)
		cNSol := StrZero(Pedido:Detalhes[nPC]:NumSC,6)
		cNIte := StrZero(Pedido:Detalhes[nPC]:ItemSC,4)
		
		DbSelectArea("SC1")
		If SC1->(DbSeek(xFilial("SC1")+cNSol+cNIte,.F.))
		
			If SC1->C1_INTWSO <> "S"  // Sys-On
				cRetorno += "A Solicitacao " + cNSol + " item "+ cNIte +", nao eh uma Solicitacao Sys-On...  "
				lRet := .F.
				Exit
			ElseIf SC1->C1_APROV <> "L" // Aprovada
				cRetorno += "A Solicitacao " + cNSol + " nao esta APROVADA... "
				lRet := .F.
				Exit
			ElseIf SC1->C1_TX <> "TR" // Ja Transmitida
				cRetorno += "A Solicitacao " + cNSol + " nao foi Transmitida ao Sys-on... "
				lRet := .F.
				Exit
			EndIf
		Else
			cRetorno += "A Solicitacao " + cNSol + " item "+cNIte+" nao foi encontrada....  "
			lRet := .F.
			Exit
		EndIf
	Next
	If !lRet
		Return(.F.)
	Else

		// Validar Cadastro de Prod x For
		For nPC := 1 to len(Pedido:Detalhes)
			cProd := RetProd(Pedido:Detalhes[nPC]:ProdFor)
			If Empty(cProd)
				cRetorno += "O Item " + cValToChar(Pedido:Detalhes[nPC]:Item) + " Produto: "+Alltrim(Pedido:Detalhes[nPC]:ProdFor)+" nao possui cadastro de Produto x Fornecedor ("+cFornece+cLoja+")"
				lRet := .F.
			Else // Aproveita e Alimenta o Codigo de Produto Unimed-SV e Corrige o Item cao seja envia fora de ordem, para ser utilizado na Inclusao do Pedido
				Pedido:Detalhes[nPC]:Produto := cProd
				Pedido:Detalhes[nPC]:Item := nPC
			EndIf
		Next

		If !lRet
			Return(.F.)
		Else

			// Valida se Quantidade disponivel na Solicitacao Atende o Item do Pedido e verifica se eh o mesmo Produto da Solicitacao
			For nPC := 1 to len(Pedido:Detalhes)

				cNSol := StrZero(Pedido:Detalhes[nPC]:NumSC,6)
				cNIte := StrZero(Pedido:Detalhes[nPC]:ItemSC,4)
				nQtd  := SToV(Pedido:Detalhes[nPC]:Quantidade)
				If SldDispSC(cNSol,cNIte,nQtd) < 0
					cRetorno += "A Solicitacao " + cNSol + " Item "+cNIte+" Nao possui saldo para atender o " + Alltrim(Pedido:Detalhes[nPC]:obs)+" . "
					lRet := .F.
				ElseIf Alltrim(Pedido:Detalhes[nPC]:Produto) <> Alltrim(SC1->C1_PRODUTO)
					cRetorno += "O Produto "+Alltrim(Pedido:Detalhes[nPC]:Produto)+" no pedido nao correponde ao Solicitado "+Alltrim(SC1->C1_PRODUTO)+". " + Alltrim(Pedido:Detalhes[nPC]:obs) + " . "
					lRet := .F.
				EndIf

			Next
			If !lRet
				Return(.F.)
			EndIF
		EndIf
	EndIf

	SA2->( DbClearFilter() )

	Return(lRet)
*******************************************************************************
Static Function Estrutura(Cab,adet)// Monta a Estrutura de Arrays para o AutoExec
*******************************************************************************

	MaCab(@aCab)//| Alimenta o Array do Cabecalho do Pedido para o MSAutoExec

	MDet(@adet)//| Alimenta o Array dos detalhes do Pedido para o MSAutoExec

	Return()
*******************************************************************************
Static Function MaCab(Cab)//| Alimenta o Array do Cabecalho do Pedido para o MSAutoExec
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
Static Function MDet(adet)//| Alimenta o Array dos detalhes do Pedido para o MSAutoExec
*******************************************************************************

	For nPC := 1 to len(Pedido:Detalhes)

		oItem := Pedido:Detalhes[nPC]

		TratamentoUM(@oItem) // Verifica a necessidade do tratamento de Conversao de unidade, Para ajustar Quantiade e PrUnit.

		aadd(aDet,{	{"C7_ITEM"   	,StrZero(oItem:Item,4)		,nil},;
		{"C7_PRODUTO"	,RetProd(oItem:ProdFor)		,nil},;
		{"C7_CLVL"		,"0900001"					,nil},; // pegar da Solicitacao
		{"C7_QUANT"  	,SToV(oItem:Quantidade)		,nil},;
		{"C7_PRECO"  	,SToV(oItem:PrcUnit	 )		,nil},;
		{"C7_TOTAL"  	,SToV(oItem:Total	 )		,nil},;
		{"C7_DATPRF"	,StoD(oItem:DataEntr)		,nil},;
		{"C7_OBS"    	,GetObs(oItem)    		    ,nil},; // ESTOU RECEBENDO DO SYSON| pegar da Solicitacao
		{"C7_NUMSC"   	,StrZero(oItem:NumSC,6)		,nil},;
		{"C7_ITEMSC"  	,StrZero(oItem:ItemSC,4)	,nil},;
		{"C7_QTDSOL"  	,SToV(oItem:Quantidade)		,nil},;
		{"C7_CC"    	,"11813"					,nil},; // pegar da Solicitacao
		{"C7_LOCAL"  	,"02"						,nil},; // pegar da Solicitacao
		{"C7_JUST"  	,"Justificativa"			,nil}}) // pegar da Solicitacao

	Next nPC

	Return()
*******************************************************************************
Static Function TratamentoUM(oItem)// Verifica a necessidade do tratamento de Conversao de unidade, Para ajustar Quantiade e PrUnit.
*******************************************************************************
Local cNumSol := StrZero(oItem:NumSC,6)  // Numero Informado da Solicitacao
Local cIteSol := StrZero(oItem:ItemSC,4) // Item da Solicitacao
Local nQtdPed := SToV(oItem:Quantidade)  // Quantidade Recebida para utilizar no Pedido
Local nPrUPed := SToV(oItem:PrcUnit	 )	// Preco unitario Recebida para utilizar Pedido
Local nTotPed := SToV(oItem:Total	 )	// Valor Total Item Recebido para utilizar Pedido

If DbSeek(xFilial("SC1")+cNumSol+cIteSol,.F.)

	If SC1->C1_QTSEGUM > 0 // Solicitacao Utilizou Segunda Unidade

		oItem:Quantidade := VToS(	ConvUM(nQtdPed, SC1->C1_PRODUTO, 'SP') )
		oItem:PrcUnit	 := VToS(	ConvUM(nPrUPed, SC1->C1_PRODUTO, 'PS') ) // No Valor a Conversao deve ser sempre de PS.
		oItem:Total		 := VToS(	SToV(oItem:Quantidade) * SToV(oItem:PrcUnit) )

	EndIf

EndIf
*******************************************************************************
Static Function ExecAuto(aCab, adet ,lMsErroAuto)//| Executa o MSExecAuto de Inclusao do pedido de compras
*******************************************************************************

	If Len( aCab ) > 0 .And. Len( aDet ) > 0

		MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)},PEDCOMPRA, aCab, aDet, INCLUI, .F. )

		If lMsErroAuto
			cRetorno := AjusRet()//| Trata a String de Retorno para ficar mais legivel ao devolver ao WS-Syson
			Disarmtransaction()
		Else
			cRetorno := cNumSc7 +_ENTER +_ENTER +cItAjust
		EndIf

	Else
		lMsErroAuto := .T.
		cRetorno := "Nao Foi Possivel Montar o Cabecalho e/ou Itens do Pedido.. MSExecAuto ! "
	EndIF

	Return()
*******************************************************************************
Static Function AjusRet()//| Trata a String de Retorno para ficar mais legivel ao devolver ao WS-Syson
*******************************************************************************

	Local cTxtLog := NomeAutoLog()
	Local cTxtAux := ""

	If ValType( cTxtLog ) == 'C'

		cTxtAux 	:= Memoread( cTxtLog )

		conout(cTxtAux)

		cTxtAux     := StrTran(cTxtAux,_ENTER," ")

		// Remove os espacos em Branco desnecessarios
		While AT(DOISES, cTxtAux ) > 0
			cTxtAux := StrTran(cTxtAux,DOISES," ")
		EndDo

		cTxtAux 	:= "MSExecAuto: MATA120: " + Substr(cTxtAux,1,150) + "..."
	EndIf

	Return(cTxtAux)
*******************************************************************************
Static Function SToV(cString)//| Converte Char para Number
*******************************************************************************
	Local nVal := 0

	nVal := Val(StrTran(cString, "," , "."	))

	Return(nVal)
*******************************************************************************
Static Function VToS(nVal)//| Converte Number para Char
*******************************************************************************
	Local cVal := cValToChar(nVal)

	cVal := StrTran(cVal, "." , ","	)

	Return(cVal)
*******************************************************************************
Static Function RetProd(CProdFor)//| Retorna o Produto x Fornecedor referente a UnimedCentral, necessario para a integracao
*******************************************************************************
	Local cProduto

	cProduto := Alltrim( Posicione("SA5",14,xFilial("SA5")+"AS005201"+CProdFor,"A5_PRODUTO"))

	Return(cProduto)
*******************************************************************************
Static Function GetCond(cCond)//| Obtem a Condicao de Pagamento, conforme o informado no Pedido pelo Ws-Syson
*******************************************************************************

	Local cSql := "select e4_Codigo from se4010 where e4_cond = '"+Alltrim(cCond)+"' and e4_tipo = '1' and Substr(e4_Codigo,1,1) = '8' and Rownum = 1 and d_e_l_e_t_ = ' '"

	If( Select("TACP") <> 0 )
		DbSelectArea("TACP");DbCloseArea()
	EndIf

	TCQUERY cSql NEW ALIAS TACP

	cCond := TACP->E4_CODIGO

	DbSelectArea("TACP");DbCloseArea()

	Return(cCond)
*******************************************************************************
Static Function SldDispSC(cSol, cItem, nQuant)//Verifica o saldo disponivel na SC relacionada ao pedido.
*******************************************************************************
	Local nSaldo := -1

	DbSelectArea("SC1")
	If DbSeek(xFilial("SC1")+cSol+cItem,.F.)

		If SC1->C1_QTSEGUM > 0 // Verifica necessidade de Conversao
			nQuant := ConvUM(nQuant, SC1->C1_PRODUTO, 'SP') // Converte a Unidade de Medida se o Cadastro do Produto tiver a conversao informada.
		EndIf
		nSaldo := SC1->C1_QUANT - SC1->C1_QUJE - nQuant


		// No caso de ajuste de quantidade, quando ha algum saldo disponivel, mas este saldo nao atende por completo, a SC pode ser ajustada para comportar o pedido.
		If (SC1->C1_QUANT - SC1->C1_QUJE) > 0 .And. nSaldo < 0

			cItAjust += "O Item "+cItem+" da Solicitacao "+cSol+" foi Reajustado para Receber o Pedido. Quantidade Disponivel:"+cValToChar(SC1->C1_QUANT-SC1->C1_QUJE)+"   Quantidade Recebida: "+cValToChar(nQuant)+"." + _ENTER

			RecLock("SC1",.F.)
			SC1->C1_QUANT := SC1->C1_QUJE + nQuant
			If SC1->C1_QTSEGUM > 0
				SC1->C1_QTSEGUM := ConvUM(SC1->C1_QUJE + nQuant, SC1->C1_PRODUTO, 'PS')
			EndIF
			MsUnlock()

			nSaldo := SC1->C1_QUANT - SC1->C1_QUJE - nQuant

	EndIf
	Else
		cItAjust += "O Item "+cItem+" da Solicitacao "+cSol+" nao foi encontrado para Receber o Pedido. " + _ENTER
		nSaldo := ( nQuant * -1 )
	EndIf

Return(nSaldo)
*******************************************************************************
Static Function ConvUM(nQuant, cProduto, cDePara)  // Converte a Unidade de Medida se o Cadastro do Produto tiver a conversao informada.
*******************************************************************************

Local nFator := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CONV")
Local cTConv := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_TIPCONV")
Local nQConv := 0 // Quantidade Convertida

If cDePara == "SP" // Converte da Segunda para Primeira Unidade

	If cTConv == "M" // Multiplicador
		nQConv := nQuant / nFator
	ElseIf cTConv == "D" // Divisor
		nQConv := nQuant * nFator
	EndIF

ElseIf cDePara == "PS" // Converte da Primeira para Segunda Unidade

	If cTConv == "M" // Multiplicador
		nQConv := nQuant * nFator
	ElseIf cTConv == "D" // Divisor
		nQConv := nQuant / nFator
	EndIF

EndIF

Return(nQConv)
*******************************************************************************
Static Function GetObs(oItem) //Tratamento e Ajuste da Obs recebido pelo Sys-On
*******************************************************************************
Local cObs := ""

cObs += "P.SysOn [" + Substr( oItem:Obs , At(" ",oItem:Obs) + 1 , 10 )+"] "
cObs += Alltrim( Posicione("SC1",1,xFilial("SC1") + StrZero(oItem:NumSC,6) + StrZero(oItem:ItemSC,4) ,"C1_OBS") )

Return(cObs)

