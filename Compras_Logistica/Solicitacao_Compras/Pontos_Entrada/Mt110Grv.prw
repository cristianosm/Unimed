#Include 'Protheus.ch'
/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO : MT110GRV | AUTOR : Cristiano Machado | DATA : 14/12/2015 **
**---------------------------------------------------------------------------**
** DESCRICAO: Funcao na SC responsavel pela gravacao das SCs. **
** : No lao de gravacao dos itens da SC na funcao A110GRAVA, **
** : executado aps gravar o item da SC, a cada item gravado da SC **
** : o ponto executado.. **
**---------------------------------------------------------------------------**
** USO : Especifico para o cliente Unimed-VS. Salva o Conteudo do Campo **
** : C1_INTWSO - Integracao Sys-on Atravs da Variavel cIntWSo **
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
** | | **
** | | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function MT110GRV()
	*******************************************************************************
	//Caso PARAMIXB == .T.(Copia da solicitao de compras esta ativa), se .F.(Copia no esta ativa)
	lExp1 := PARAMIXB[1]

	//| Salva o Conteudo da Variavel cIntWSo Que existe no Cab. da Sol de Compras na Tebla SC1
	SvCpoISo()

	//| Customizacao que ja existia no Fonte da Unimed MT112GRV. Deve ser Substituido por este.
	CustomUni()

	Return()
	*******************************************************************************
Static Function SvCpoISo()//| Salva o Conteudo da Variavel cIntWSo Que existe no Cab. da Sol de Compras na Tebla SC1
	*******************************************************************************

	RecLock("SC1",.F.)
	SC1->C1_INTWSO := cIntWSo
	If cIntWSo == "S" //.And. Empty(SC1->C1_TX) //| Solicitacao Sys-On
		SC1->C1_TX := "AG"
	EndIf
	MsUnlock()

	// So envia o email uma vez o email ....
	If Type('cLastSendSc') == 'U'
		Public cLastSendSc := ""
	Endif
	If cLastSendSc <> SC1->C1_NUM .and. cIntWSo == "S"
		U_SMProxSys( SC1->C1_NUM , "Solicitacao Sys-On "+SC1->C1_NUM+", aguardando Liberacao.", "Incluida SC Sys-On","C" )

		cLastSendSc := SC1->C1_NUM
	EndIF

	Return()
	*******************************************************************************
Static Function CustomUni()//| Customizacao que ja existia no Fonte da Unimed MT112GRV. Deve ser Substituido por este.
	*******************************************************************************

	Local cClasVal := ""
	Local cTProd := ""
	Local cDifClas := AllTrim(Getmv("MV_DIFCLAS"))//0900001
	Local cTipProd := AllTrim(Getmv("MV_TIPPRO"))//ME#MC#DE

	cClasVal := AllTrim(aCols[1][aScan(aHeader, {|x| AllTrim(x[2]) == "C1_CLVL"})])
	cTProd := Alltrim(Posicione("SB1",1,xFilial("SB1")+AllTrim(aCols[1][aScan(aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})]),"B1_TIPO"))

	If cClasVal $ cDifClas .and. cTProd $ cTipProd
		SC1->(dbSetOrder(1))
		If SC1->(MsSeek(xFilial("SC1")+cA110Num))
			While xFilial("SC1")+cA110Num == SC1->(C1_FILIAL+C1_NUM)
				SC1->(RecLock("SC1",.F.))
				SC1->C1_APROV := "L"
				SC1->(MsUnlock())
				SC1->(dbSkip())
			EndDo
		EndIf
	EndIF

Return()