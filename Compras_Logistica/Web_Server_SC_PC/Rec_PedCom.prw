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

	Return(Substr(cRetorno,1,177))// Ajusta o Limite do Retorno
*******************************************************************************
Static Function PrepVareAmb()//| Prepara as Variaveis,Tabelas e Ambiente Utilizado...
*******************************************************************************

	DbSelectArea("SC1");DbSetOrder(1)
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

		// Valida se Fornecedor Retornou apenas uma loja apartir do CNJ.
		nF := 0
		While cAuxCnpj == SA2->A2_CGC .And. !Eof() // Valida se Fornecedor Retornou apenas uma loja
			nF += 1 ; SA2->( DbSkip() )
		EndDo
		If nF > 1
			cRetorno := "Fornecedor Possui mais de um Cadastro com o mesmo CNPJ:"+Transform(cAuxCnpj,"@R 99.999.999/9999-99")+". Deve ser Corrigido."
			Return(.F.)
		EndIf

		cFornece := SA2->A2_COD
		cLoja	 := SA2->A2_LOJA

	EndIF

	// Valida se Fornecedor esta bloqueado
	If SA2->A2_MSBLQL == "1" //Bloqueado
		cRetorno := "Este Fornecedor esta com o Cadastro Bloqueado. CNPJ:"+Transform(cAuxCnpj,"@R 99.999.999/9999-99")+""
		Return(.F.)
	EndIF

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

	// Validar Cadastro de Prod x For
	For nPC := 1 to len(Pedido:Detalhes)
		cProd := RetProd(Pedido:Detalhes[nPC]:ProdFor)
		If Empty(cProd)
			cRetorno += "O Item " + cValToChar(Pedido:Detalhes[nPC]:Item) + " Produto: "+Alltrim(Pedido:Detalhes[nPC]:ProdFor)+" nao possui cadastro de Produto x Fornecedor ("+cForeLj+")"
			lRet := .F.
		Else // Aproveita e Alimenta o Codigo de Produto Unimed-SV e Corrige o Item cao seja envia fora de ordem, para ser utilizado na Inclusao do Pedido
			Pedido:Detalhes[nPC]:Produto := cProd
			Pedido:Detalhes[nPC]:Item := nPC
		EndIf
	Next
	If !lRet
		Return(.F.)
	Else

		// Valida se Quantidade disponivel na Solicitacao Atende o Item do Pedido e se nao e o mesmo Produto da Solicitacao
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
		Else

			//| Valida se a Solicitacao eh Sys-ON, Esta Libera e ja Foi Transmitida. Deve Estar POSICIONADO no SC1
			For nPC := 1 to len(Pedido:Detalhes)

				If SC1->C1_INTWSO <> "S"  // Sys-On
					cRetorno += "A Solicitacao " + cNSol + " nao e uma Solicitacao Sys-On...  "
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

			Next

			If !lRet
				Return(.F.)
			EndIf
		EndIf
	EndIf

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
Static Function ExecAuto(aCab, adet ,lMsErroAuto)//| Executa o MSExecAuto de Inclusao do pedido de compras
	*******************************************************************************

	If Len( aCab ) > 0 .And. Len( aDet ) > 0

		MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)},PEDCOMPRA, aCab, aDet, INCLUI, .F. )

		If lMsErroAuto
			cRetorno := AjusRet()//| Trata a String de Retorno para ficar mais legivel ao devolver ao WS-Syson
			Disarmtransaction()
		Else
			cRetorno := cNumSc7
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

	nVal := Val(StrTran(cString,",","."	))

	Return(nVal)
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
		nSaldo := SC1->C1_QUANT - SC1->C1_QUJE - nQuant
	EndIf

Return(nSaldo)
*******************************************************************************
Static Function GetObs(oItem) //Tratamento e Ajuste da Obs recebido pelo Sys-On
*******************************************************************************
Local cObs := ""

cObs += "P.SysOn [" + Substr( oItem:Obs , At(" ",oItem:Obs) + 1 , 10 )+"] "
cObs += Alltrim( Posicione("SC1",1,xFilial("SC1") + StrZero(oItem:NumSC,6) + StrZero(oItem:ItemSC,4) ,"C1_OBS") )

Return(cObs)