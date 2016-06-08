#include "RWMAKE.CH"
#include "AP5MAIL.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuPrcPC  ºAutor  ³Cristiano Machado   º Data ³  08/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Pedido de Compras Conforme Parametros do usuario  º±±
±±º          ³e de acordo com os precos contidos na Tabela de Precos do   º±±
±±º          ³ Fornecedor (SZ5 - SZ6)                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 Imdepa Rolamentos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
User Function AtuPrcPC()
*********************************************************************
Private cGrupo := "TPFORN"
Private aCab   := {}
Private aItem  := {}
Private aItens := {}
Private cNumPc := Space(6)
Private	lMsHelpAuto := .T.	//Se .T. direciona as mensagens de help para o arq. de log
Private	lMsErroAuto := .F.	//Sera atualizado quando houver alguma incosistencia nos parametros

//| Cria Grupo de Perguntas ...
CriaPerg()

Pergunte(cGrupo,.T.)

//| Executa Query com o Filtros Necessarios
RodaQuery()

//| Atualiza Precos nos PC
Processa( {||AtuPedidos()}, "Aguarde...","Atualizando Pedido: "+cNumPc )

APC->( DbCloseArea() )

MsgBox("Concluído com Sucesso !!!")

Return()
*********************************************************************
Static Function RodaQuery()
*********************************************************************
Local cQuery 	:= ""
Local cAlias	:= "APC"

cQuery += "SELECT C7_FILIAL, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_COND, C7_CONTATO, C7_NUM, C7_FILENT, C7_ITEM "
cQuery += "FROM  SC7010 SC7 INNER JOIN SB1010 SB1 "
cQuery += "ON	  C7_FILIAL  = B1_FILIAL "
cQuery += "AND	  C7_PRODUTO = B1_COD "
cQuery += "WHERE C7_FILIAL  = '"+xFilial("SC7")+"' "
cQuery += "AND	  C7_NUM     BETWEEN '"+MV_PAR01+"'          AND '"+MV_PAR02+"' "
cQuery += "AND	  C7_FORNECE BETWEEN '"+MV_PAR03+"'          AND '"+MV_PAR04+"' "
cQuery += "AND	  C7_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"'        AND '"+DtoS(MV_PAR06)+"' "
cQuery += "AND	  C7_PRODUTO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cQuery += "AND    C7_QUJE < C7_QUANT "
cQuery += "AND	  SC7.D_E_L_E_T_ = ' ' "
cQuery += "AND   B1_CURVA   BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
cQuery += "AND   B1_GRUPO   BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' "
cQuery += "AND	  SB1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY C7_FILIAL, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_COND, C7_CONTATO, C7_NUM, C7_FILENT, C7_ITEM "
cQuery += "ORDER BY C7_NUM, C7_ITEM "

TCQUERY cQuery NEW ALIAS "APC"

Return()
*********************************************************************
Static Function AtuPedidos()
*********************************************************************
Local lAltera	:= .F.    
Local nPrcAtu	:= 0
ProcRegua(0)
DbSelectArea("APC");DbGotop()

While !Eof()
	
	cNumPc := APC->C7_NUM
	
	Aadd(aCab,{'C7_FILIAL' 	, APC->C7_FILIAL   	, Nil	})
	Aadd(aCab,{'C7_EMISSAO'	, APC->C7_EMISSAO  	, Nil	})
	Aadd(aCab,{'C7_FORNECE'	, APC->C7_FORNECE  	, Nil	})
	Aadd(aCab,{'C7_LOJA' 	, APC->C7_LOJA   	, Nil	})
	Aadd(aCab,{'C7_COND' 	, APC->C7_COND   	, Nil	})
	Aadd(aCab,{'C7_CONTATO'	, APC->C7_CONTATO  	, Nil	})
	Aadd(aCab,{'C7_NUM' 	, APC->C7_NUM   	, Nil	})
	Aadd(aCab,{'C7_FILENT'	, APC->C7_FILENT   	, Nil	})
	
	SC7->(DbSeek(xFilial("SC7") + APC->C7_NUM,.F.))
	
	While !EOF() .and. cNumPc == APC->C7_NUM //|Itens do Pedido de Venda
		
		
		If SC7->C7_ITEM == APC->C7_ITEM
			
			lAltera := .T.
			
			nPrcAtu := VerTabPrc()
			
			If nPrcAtu > 0
				nPreco := nPrcAtu
			Else
				nPreco := SC7->C7_PRECO
			Endif
			
			IncProc()
			DbSelectArea("APC")
			DbSkip()
		Else
			nPreco := SC7->C7_PRECO
		Endif
		
		If lAltera
			
			Aadd(aItem,{"LINPOS"		,"C7_ITEM"			, SC7->C7_ITEM 	})
			Aadd(aItem,{'C7_ITEM' 		, SC7->C7_ITEM   	, Nil 	})
			Aadd(aItem,{'C7_PRODUTO'   	, SC7->C7_PRODUTO	, Nil 	})
			Aadd(aItem,{'C7_UM'        	, SC7->C7_UM     	, Nil 	})
			Aadd(aItem,{'C7_QUANT'     	, SC7->C7_QUANT  	, Nil 	})
			Aadd(aItem,{'C7_PRECO'     	, nPreco         	, Nil	})
			Aadd(aItem,{'C7_DATPRF'    	, SC7->C7_DATPRF 	, Nil	})
			Aadd(aItem,{'C7_QUJE'      	, SC7->C7_QUJE   	, Nil	})
			Aadd(aItem,{'C7_TES'       	, SC7->C7_TES		, Nil 	})
			
			//
			//					{'C7_LOCAL'     , SC7->C7_LOCAL  	, },;
			//					{'C7_NUMSC'     , SC7->C7_NUMSC  	, },;
			//					{'C7_ITEMSC'    , SC7->C7_ITEMSC 	, },;
			
			aAdd(aItens,aItem )
			
		Endif
		
		aItem 	:= {}
		lAltera := .F.
		nPrcAtu	:= 0 
		
		Incproc()
		DbSelectArea("SC7")
		DbSkip()
		
	EndDo
	
	MSExecAuto({|W,X,Y,Z| Mata120(W,X,Y,Z)},1,aCab,aItens,4)
	
	If lMsErroAuto
		U_Mensagem("Não foi possível ALTERAR o PC "+cNumPc+" . Por favor, Verifique o LOG.")
		Mostraerro()
		lRet := .F.
	Endif
	
	//Reinicializa as Variaveis
	cNumPc :=  APC->C7_NUM
	aCab   := {}
	aItem  := {}
	
	DbSelectArea("APC")
	
Enddo


Return()
*********************************************************************
Static Function VerTabPrc()//|Obtem preco para o item em posicionado
*********************************************************************
Local cCodTab 	:= ""
Local nPreco	:= 0
DbSelectArea("SZY");DbSetOrder(1)
DbSelectarea("SZ6");DbSetOrder(1)
DbSelectarea("SZ5");DbSetOrder(2)

If SZ5->(DbSeek(xFilial("SZ5") + 'S' + SC7->C7_FORNECE + SC7->C7_LOJA,.F.))
	cCodTab :=   SZ5->Z5_CODTAB
ElseIf SZ5->(DbSeek(xFilial("SZ5") + 'S' + SC7->C7_FORNECE,.F.))
	cCodTab :=   SZ5->Z5_CODTAB
Endif

If !Empty(cCodTab) .And. SZ5->Z5_CODTAB >= MV_PAR11 .And. SZ5->Z5_CODTAB <= MV_PAR12 .And. SZ6->(DbSeek(xFilial("SZ6") + cCodTab + SC7->C7_PRODUTO,.F.))
	
	If SimbToMoeda( SZ6->Z6_MOEDA ) <> SC7->C7_MOEDA
		
		// converter moeda( preco moeda tab, converte moeda tab p/num, num moeda pedido, data )
		nPreco := xMoeda( SZ6->Z6_PRECO, SimbToMoeda( SZ6->Z6_MOEDA ), SC7->C7_MOEDA, dDataBase )
	Else
		nPreco := SZ6->Z6_PRECO
	EndIf
	// aplica desconto da tabela...
	//nPreco := nPreco * ( 1 - ( SZ5->Z5_DESCON / 100 ) )
	nPreco := Round( nPreco * ( 1 - ( SZ5->Z5_DESCON / 100 ) ), SZ5->Z5_NUMDEC )
	
	// aplica desconto por filial...
	If SZY->(DbSeek( xFilial('SZY') + SZ5->Z5_CODTAB + cFilAnt, .F. ) )

		nPreco := Round( nPreco * ( 1 - ( SZY->ZY_DESCON / 100 ) ), SZ5->Z5_NUMDEC )

	EndIf
	
Endif

Return(nPreco)
*********************************************************************
Static Function CriaPerg()
*********************************************************************
aPerg := {}

//AADD( APERG , {"X1_GRUPO","X1_ORDEM","X1_PERGUNT"          , "X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC"  ,"X1_VAR01","X1_DEF01    ","X1_DEF02     ","X1_DEF03    " ,"X1_DEF04  ","X1_F3"})
AADD( aPerg , {"X1_GRUPO","X1_ORDEM","X1_PERGUNT"           , "X1_VARIAVL" ,"X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC"  ,"X1_VAR01","X1_DEF01"    ,"X1_DEF02"   ,"X1_DEF03"     ,"X1_DEF04"  ,"X1_F3"} )
AADD( aPerg , { cGrupo   , "01"     , "Nº Pedido  De:     " , "MV_CH1"     , "C"     ,  06        , 0          ,     0     ,   "G"    ,"MV_PAR01","            ","           ","            " ,"          ","SC7"  } )
AADD( aPerg , { cGrupo   , "02"     , "Nº Pedido Ate:     " , "MV_CH2"     , "C"     ,  06        , 0          ,     0     ,   "G"    ,"MV_PAR02","            ","           ","            " ,"          ","SC7"  } )
AADD( aPerg , { cGrupo   , "03"     , "Fornecedor  De:    " , "MV_CH3"     , "C"     ,  06        , 0          ,     0     ,   "G"    ,"MV_PAR03","            ","           ","            " ,"          ","SA2"  } )
AADD( aPerg , { cGrupo   , "04"     , "Fornecedor  Ate:   " , "MV_CH4"     , "C"     ,  06        , 0          ,     0     ,   "G"    ,"MV_PAR04","            ","           ","            " ,"          ","SA2"  } )
AADD( aPerg , { cGrupo   , "05"     , "Data Emissão  De:  " , "MV_CH5"     , "D"     ,  08        , 0          ,     0     ,   "G"    ,"MV_PAR05","            ","           ","            " ,"          ","   "  } )
AADD( aPerg , { cGrupo   , "06"     , "Data Emissão Até:  " , "MV_CH6"     , "D"     ,  08        , 0          ,     0     ,   "G"    ,"MV_PAR06","            ","           ","            " ,"          ","   "  } )
AADD( aPerg , { cGrupo   , "07"     , "Produto  De:       " , "MV_CH7"     , "C"     ,  15        , 0          ,     0     ,   "G"    ,"MV_PAR07","            ","           ","            " ,"          ","SB1"  } )
AADD( aPerg , { cGrupo   , "08"     , "Produto Até:       " , "MV_CH8"     , "C"     ,  15        , 0          ,     0     ,   "G"    ,"MV_PAR08","            ","           ","            " ,"          ","SB1"  } )
AADD( aPerg , { cGrupo   , "09"     , "Curva Imdepa De:   " , "MV_CH9"     , "C"     ,  04        , 0          ,     0     ,   "G"    ,"MV_PAR09","            ","           ","            " ,"          ","IM1"  } )
AADD( aPerg , { cGrupo   , "10"     , "Curva Imdepa Até   " , "MV_CHA"     , "C"     ,  04        , 0          ,     0     ,   "G"    ,"MV_PAR10","            ","           ","            " ,"          ","IM1"  } )
AADD( aPerg , { cGrupo   , "11"     , "Tab Preço For.  De:" , "MV_CHB"     , "C"     ,  03        , 0          ,     0     ,   "G"    ,"MV_PAR11","            ","           ","            " ,"          ","SZ5"  } )
AADD( aPerg , { cGrupo   , "12"     , "Tab Preço For. Até:" , "MV_CHC"     , "C"     ,  03        , 0          ,     0     ,   "G"    ,"MV_PAR12","            ","           ","            " ,"          ","SZ5"  } )
AADD( aPerg , { cGrupo   , "13"     , "Grupo Produto  De: " , "MV_CHD"     , "C"     ,  04        , 0          ,     0     ,   "G"    ,"MV_PAR13","            ","           ","            " ,"          ","SBM"  } )
AADD( aPerg , { cGrupo   , "14"     , "Grupo Produto Até: " , "MV_CHE"     , "C"     ,  04        , 0          ,     0     ,   "G"    ,"MV_PAR14","            ","           ","            " ,"          ","SBM"  } )

nCol	:=	15
//cGrupo := PADR(cGrupo,10)   // AJUMP10

Store 0 To i,j,c

Dbselectarea("sx1")
aStruct := {}
aStruct := Dbstruct()

For i:=1 To Len(aPerg)
	Iif(i==1,i+=1,i:=i)
	If !Dbseek(cGrupo + aPerg[i,2])
		RecLock("sx1",.t.)
		For j:=1 To Len(Astruct)
			Iif(j==1,c:=j,c:=c)
			If Astruct[j,1] == aPerg[1,c]
				FieldPut(j,aPerg[i,c])
				If (c+=1) > nCol // ncol = numero de colunas do arrey
					Exit
				Endif
			Endif
		Next
		MsUnlock()
	Endif
Next

Return()