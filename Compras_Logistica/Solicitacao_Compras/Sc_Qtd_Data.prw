#include 'protheus.ch'
#include 'parmtype.ch'



#Define P_ITEM 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_ITEM'})
#Define P_PRODUTO 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_PRODUTO'})
#Define P_CLVL 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_CLVL'})
#Define P_QUANT 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_QUANT'})
#Define P_DATPRF 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_DATPRF'})
#Define P_CC 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_CC'})
#Define P_OBS 		aScan(aHeader, {|x| AllTrim(x[2])=='C1_OBS'})
#Define P_YJUSTIF 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_YJUSTIF'})
#Define P_CONTA 	aScan(aHeader, {|x| AllTrim(x[2])=='C1_CONTA'})

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : Mt110Tel   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO:    Este ponto tem a finalidade de manipular o cabecalho da     **
**          : Solicitao de Compras permitindo a inclusco e alteracco de      **
**          : campos.                                                        **
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
If Valida()//| Valida se esta Posicionado na Solicitacoa de Compras...

	TelaQtdData()

EndIf

Return(nQtdRet)
*******************************************************************************
Static Function Valida()//| Valida se esta Posicionado na Solicitacoa de Compras...
*******************************************************************************
Local lReturn 		:= .F.

Local bVProd	:= 0
local bVCamp	:= 0

	If __ReadVar == "M->C1_QUANT" .And. xFilial("SC1") == "13"

		lReturn := .T.

	EndIf

Return(lReturn)
*******************************************************************************
Static Function TelaQtdData()
*******************************************************************************

    Local aAltCpo 	:= {"C1_QUANT","C1_DATPRF" } //Variavel contendo o campo editavel no Grid
    Local aBotoes	:= {}         //Variavel onde sera incluido o botao para a legenda


    Local  aHeader2 := {}         //Variavel que montara o aHeader2 do grid
    Local  aCols2 	:= {}         //Variavel que recebera os dados

    Private  oBrowseB := Nil               //Declarando o objeto do browser
    //Private aColsC1 	:= aClone(aCols)

    //Declarando os objetos de cores para usar na coluna de status do grid
    //Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
    //Private oAzul  	:= LoadBitmap( GetResources(), "BR_AZUL")
    //Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
    //Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")

    DEFINE MSDIALOG oDlgNes TITLE "Distribuicao da Necessidade" FROM 000, 000  TO 250, 300  PIXEL

        //| Funcao que cria a estrutura do aHeader e Acols
        IniCabec(@aHeader2)
        IniaCols2(@aCols2, aHeader2)

        //Monta o browser com inclusao, remocao e atualizacao
        oBrowseB := MsNewGetDados():New( 010,010,180,095,(GD_INSERT+GD_DELETE+GD_UPDATE),'AllwaysTrue()','AllwaysTrue()','', aAltCpo ,000,999,'AllwaysTrue()','','AllwaysTrue()',oDlgNes,aHeader2,aCols2 )

        //Alinho o grid para ocupar todo o meu formulario
        oBrowseB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

       // Ao abrir a janela o cursor esta posicionado no meu objeto
        oBrowseB:oBrowse:SetFocus()

        EnchoiceBar(oDlgNes, {|| MontaLins(), oDlgNes:End() }, {|| oDlgNes:End() },,aBotoes)

    ACTIVATE MSDIALOG oDlgNes CENTERED

Return
*******************************************************************************
Static Function MontaLins()//| Monta Linhas para serem incluidas na Solicitação
*******************************************************************************

Local aColsLOri := aClone(Acols[N])


For nL := 1 To Len( oBrowseB:Acols)

	If nL > 1

		//o:nAt 	:= n := nOri + nL - 1
		eVal( o:bGoTFocus )
		eVal( o:bAdd ) //| ADICIONA UMA LINHA NA GETDADOS AUTOMATICAMENTE
		o:oMother:aLastEdit 	:=  {n}
		o:oMother:lNewLine		:= .F.
		o:oMother:lChgField		:= .T.
		o:Refresh()

		__ReadVar 	:= "M->C1_PRODUTO"
		xVar :=  aColsLOri[P_PRODUTO]
		GDFieldPut( "C1_PRODUTO", xVar, N )
		aCols[ N, GDFieldPos( "C1_PRODUTO" ) ] := xVar
		M->C1_PRODUTO       := xVar
		xVar := Nil
		lOk := CheckSX3('C1_PRODUTO',M->C1_PRODUTO)
		RunTrigger(2,n,"",,PADR('C1_PRODUTO',10))

		__ReadVar 	:= "M->C1_CLVL"
		xVar :=  aColsLOri[P_CLVL]
		GDFieldPut( "C1_CLVL", xVar, N )
		aCols[ N, GDFieldPos( "C1_CLVL" ) ] := xVar
		M->C1_CLVL       := xVar
		xVar := Nil
			lOk := CheckSX3('C1_CLVL',M->C1_CLVL)
		RunTrigger(2,n,"",,PADR('C1_CLVL',10))

		xVar :=  oBrowseB:Acols[nL][1]
		GDFieldPut( "C1_QUANT", xVar, N )
		aCols[ N, GDFieldPos( "C1_QUANT" ) ] := xVar
		M->C1_QUANT       := xVar
		xVar := Nil

		xVar := oBrowseB:Acols[nL][2]
		GDFieldPut( "C1_DATPRF", xVar, N )
		aCols[ N, GDFieldPos( "C1_DATPRF" ) ] := xVar
		M->C1_DATPRF       := xVar
		xVar := Nil


		xVar :=  aColsLOri[P_CC]
		GDFieldPut( "C1_CC", xVar, N )
		aCols[ N, GDFieldPos( "C1_CC" ) ] := xVar
		M->C1_CC       := xVar
		xVar := Nil


		xVar :=  aColsLOri[P_OBS]
		GDFieldPut( "C1_OBS", xVar, N )
		aCols[ N, GDFieldPos( "C1_OBS" ) ] := xVar
		M->C1_OBS       := xVar
		xVar := Nil

		xVar :=  aColsLOri[P_YJUSTIF]
		GDFieldPut( "C1_YJUSTIF", xVar, N )
		aCols[ N, GDFieldPos( "C1_YJUSTIF" ) ] := xVar
		M->C1_YJUSTIF       := xVar
		xVar := Nil



/*		Alert("Add Line")
		aColsLOri[P_ITEM]  	:= StrZero(o:nat,4)
		aColsLOri[P_QUANT]  := oBrowseB:Acols[nL][1]
		aColsLOri[P_DATPRF] := oBrowseB:Acols[nL][2]

		ACols[o:nat] := aColsLOri
*/
		o:Refresh()
	//	Alert("Atu acols n:"+cValToChar(n))
		//RunTrigger(2,n,"",,)
		//Alert("Triger")

		//Alert("oMother")




	EndIf

Next
__ReadVar :=  "M->C1_QUANT"
o:nat := N := nOri

//ACols[o:nat][P_QUANT] 	:= oBrowseB:Acols[1][1]
//ACols[o:nat][P_DATPRF] 	:= oBrowseB:Acols[1][2]

///RunTrigger(2,n,"",,)

Return()
*******************************************************************************
Static Function IniCabec(aHeader2) //| Funcao que cria a estrutura do aHeader
*******************************************************************************

  Aadd( aHeader2, X3CpoHeader("C1_QUANT"))
  Aadd( aHeader2, X3CpoHeader("C1_DATPRF"))

Return()
*******************************************************************************
Static Function IniaCols2(aCols2, aHeader2) //| Funcao que cria a estrutura Acols
*******************************************************************************
Local nCpo 	 := 0
Local nTHead := Len(aHeader2)

aCols2 := { Array(nTHead + 1) }

For nCpo := 1 To nTHead

	aCols2[1][nCpo] := CriaVar( aHeader2[nCpo][2] )

Next

aCols2[1][nTHead + 1] := .F.

Return()
*******************************************************************************
Static Function X3CpoHeader(cCampo)
*******************************************************************************
Local aAreaAnt := GetArea()
Local aAreaSx3 := SX3->( GetArea() )
Local aAuxiliar := {}

DbSelectArea("SX3");DbSetOrder(2)

If DbSeek(cCampo,.F.)
	aAuxiliar := { Trim(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context }
EndIf

RestArea(aAreaSx3)
RestArea(aAreaAnt)

Return(aAuxiliar)