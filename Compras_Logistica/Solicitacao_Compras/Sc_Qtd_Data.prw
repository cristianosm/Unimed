#include 'protheus.ch'
#include 'parmtype.ch'

// Posicao dos campos no aHeader Solicitacao de compras Padrao
#Define P_ITEM 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_ITEM'})
#Define P_PRODUTO 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_PRODUTO'})
#Define P_CLVL 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_CLVL'})
#Define P_QUANT 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_QUANT'})
#Define P_DATPRF 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_DATPRF'})
#Define P_CC 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_CC'})
#Define P_OBS 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_OBS'})
#Define P_YJUSTIF 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_YJUSTIF'})


/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : Sc_Qtd_Data| AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Este Programa tem o Objetivo de abrir uma Tela Atraves da Tecla**
**          : de atalho F4. Quando Posicionado em modo Edicao no Campo       **
**          : C1_QUANT na Solicitacao de Compras. Para Facilicar a           **
**          : distribuicao de um determidado produto                         **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS                            **
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
User function Sc_Qtd_Data()
	*******************************************************************************
	Private nQtdRet := 0
	Private nOri	:= N

	If Valida()//| Valida se esta Posicionado na Solicitacoa de Compras em mode de Edicao de Quantidade...

		TelaQtdData()

	EndIf

	Return(nQtdRet)
	*******************************************************************************
Static Function Valida()//| Valida se esta Posicionado na Solicitacoa de Compras em mode de Edicao de Quantidade...
	*******************************************************************************
	Local lReturn 	:= .F.
	Local bVProd	:= 0
	local bVCamp	:= 0

	If __ReadVar == "M->C1_QUANT" .And. xFilial("SC1") == "13" // Apenas disponivel para o Hospital Unimed

		lReturn := .T.

	EndIf

	Return(lReturn)
	*******************************************************************************
Static Function TelaQtdData()// Montagem da Tela Necessidade
	*******************************************************************************

	Local aAltCpo 	:= {"C1_QUANT","C1_DATPRF" } 	//Variavel contendo o campo editavel no Grid
	Local aBotoes	:= {}         					//Variavel onde sera incluido o botao para a legenda

	Local  aHeaderN := {}        				 	//Variavel que montara o aHeader do Grid
	Local  aColsN 	:= {}        					//Variavel que recebera os dados do Acols

	Private  oBrowseN := Nil     					//Declarando o objeto do browser Necessidade

	DEFINE MSDIALOG oDlgNes TITLE "Distribuicao da Necessidade" FROM 000, 000  TO 250, 250  PIXEL

	//| Funcao que cria a estrutura do aHeader e Acols
	IniCabec(@aHeaderN)
	IniaColsN(@aColsN, aHeaderN)

	//Monta o browser com inclusao, remocao e atualizacao
	oBrowseN := MsNewGetDados():New( 010,010,180,095,(GD_INSERT+GD_DELETE+GD_UPDATE),'AllwaysTrue()','AllwaysTrue()','', aAltCpo ,000,999,'AllwaysTrue()','','AllwaysTrue()',oDlgNes,aHeaderN,aColsN )

	//Alinho o grid para ocupar todo o meu formulario
	oBrowseN:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Ao abrir a janela o cursor esta posicionado no meu objeto
	oBrowseN:oBrowse:SetFocus()

	EnchoiceBar(oDlgNes,{||MontaLins(),oDlgNes:End()},{||oDlgNes:End()},Nil,aBotoes,Nil,Nil,.F.,.F.,.F.,.T.,.F.,Nil)

	ACTIVATE MSDIALOG oDlgNes CENTERED

	Return
	*******************************************************************************
Static Function MontaLins()//| Monta Linhas para serem incluidas na Solicitacao
	*******************************************************************************

	Local aColsLOri := aClone(Acols[N]) // Recebe uma copia da Linha Atual do Acols.

	For nL := 1 To Len( oBrowseN:Acols) // Percurre todas as Linhas do AcolsN

		If nL > 1
			//| Ajustes Necessarios no Browse Padrao ao incluir uma linha na Solcitacao de Compras
			AjustBrowse()
		EndIf

		//| Tratamento Campo C1_PRODUTO
		__ReadVar 	:= "M->C1_PRODUTO"
		xVar :=  aColsLOri[P_PRODUTO]
		GDFieldPut( "C1_PRODUTO", xVar, N )
		aCols[ N, GDFieldPos( "C1_PRODUTO" ) ] := xVar
		M->C1_PRODUTO       := xVar
		xVar := Nil
		lOk := CheckSX3('C1_PRODUTO',M->C1_PRODUTO)
		RunTrigger(2,n,"",,PADR('C1_PRODUTO',10))

		//| Tratamento Campo C1_CLVL
		__ReadVar 	:= "M->C1_CLVL"
		xVar :=  aColsLOri[P_CLVL]
		GDFieldPut( "C1_CLVL", xVar, N )
		aCols[ N, GDFieldPos( "C1_CLVL" ) ] := xVar
		M->C1_CLVL       := xVar
		xVar := Nil
		lOk := CheckSX3('C1_CLVL',M->C1_CLVL)
		RunTrigger(2,n,"",,PADR('C1_CLVL',10))

		//| Tratamento Campo C1_QUANT
		xVar :=  oBrowseN:Acols[nL][1]
		GDFieldPut( "C1_QUANT", xVar, N )
		aCols[ N, GDFieldPos( "C1_QUANT" ) ] := xVar
		M->C1_QUANT       := xVar
		xVar := Nil

		//| Tratamento Campo C1_DATPRF
		xVar := oBrowseN:Acols[nL][2]
		GDFieldPut( "C1_DATPRF", xVar, N )
		aCols[ N, GDFieldPos( "C1_DATPRF" ) ] := xVar
		M->C1_DATPRF       := xVar
		xVar := Nil

		//| Tratamento Campo C1_CC
		xVar :=  aColsLOri[P_CC]
		GDFieldPut( "C1_CC", xVar, N )
		aCols[ N, GDFieldPos( "C1_CC" ) ] := xVar
		M->C1_CC       := xVar
		xVar := Nil

		//| Tratamento Campo C1_OBS
		xVar :=  aColsLOri[P_OBS]
		GDFieldPut( "C1_OBS", xVar, N )
		aCols[ N, GDFieldPos( "C1_OBS" ) ] := xVar
		M->C1_OBS       := xVar
		xVar := Nil

		//| Tratamento Campo C1_YJUSTIF
		xVar :=  aColsLOri[P_YJUSTIF]
		GDFieldPut( "C1_YJUSTIF", xVar, N )
		aCols[ N, GDFieldPos( "C1_YJUSTIF" ) ] := xVar
		M->C1_YJUSTIF       := xVar
		xVar := Nil

	Next

	// Retorna ao Campo Inicial e o alimenta Com a  Quantidade Correta
	RestQtdOri()

	Return()
	*******************************************************************************
Static Function RestQtdOri()// Retorna ao Campo Inicial e o alimenta Com a  Quantidade Correta
	*******************************************************************************

	o:nat := N := nOri
	__ReadVar :=  "M->C1_QUANT"
	xVar :=  oBrowseN:Acols[1][1]
	GDFieldPut( "C1_QUANT", xVar, N )
	aCols[ N, GDFieldPos( "C1_QUANT" ) ] := nQtdRet := xVar
	M->C1_QUANT       := xVar
	xVar := Nil

	Return()
	*******************************************************************************
Static Function AjustBrowse() //| Ajustes Necessarios no Browse Padrao da Solcitacao de Compras
	*******************************************************************************

	eVal( o:bGoTFocus )
	eVal( o:bAdd )
	o:oMother:aLastEdit 	:=  {n}
	o:oMother:lNewLine		:= .F.
	o:oMother:lChgField		:= .T.
	o:Refresh()

	Return()
	*******************************************************************************
Static Function IniCabec(aHeaderN) //| Funcao que cria a estrutura do aHeader
	*******************************************************************************

	Aadd( aHeaderN, X3CpoHeader("C1_QUANT"))
	Aadd( aHeaderN, X3CpoHeader("C1_DATPRF"))

	Return()
	*******************************************************************************
Static Function IniaColsN(aColsN, aHeaderN) //| Funcao que cria a estrutura Acols e o Inicializa
	*******************************************************************************
	Local nCpo 	 := 0
	Local nTHead := Len(aHeaderN)

	aColsN := { Array(nTHead + 1) }

	aColsN[1][1] :=  aCols[ N, GDFieldPos( "C1_QUANT" ) ]
	aColsN[1][2] :=  aCols[ N, GDFieldPos( "C1_DATPRF" ) ]
	aColsN[1][nTHead + 1] := .F.

	Return()
	*******************************************************************************
Static Function X3CpoHeader(cCampo)// Obtem estrutura do Header baseado no campo informado.
	*******************************************************************************
	Local aAreaAnt := GetArea()
	Local aAreaSx3 := SX3->( GetArea() )
	Local aAuxiliar := {}

	DbSelectArea("SX3");DbSetOrder(2)

	If DbSeek(cCampo,.F.)
		aAuxiliar := { Trim(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, x3_f3, x3_context }
	EndIf

	RestArea(aAreaSx3)
	RestArea(aAreaAnt)

Return(aAuxiliar)