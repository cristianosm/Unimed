#include 'protheus.ch'
#include 'parmtype.ch'

#Define AC_NUM      	1
#Define AC_EMISSAO		2
#Define AC_FORNECE		3
#Define AC_LOJA			4
#Define AC_COND			5
#Define AC_CONTATO		6
#Define AC_FILENT		7

#Define AD_ITEM			1
#Define AD_PRODUTO		2
#Define AD_QUANT		3
#Define AD_PRECO		4
#Define AD_TOTAL		5
#Define AD_DATPRF		6
#Define AD_TES			7
#Define AD_FLUXO		8
#Define AD_LOCAL		9
#Define AD_CODRDA		10
#Define AD_LOTPLS		11
#Define AD_VLDESC		12

*******************************************************************************
User function Exemplo_SC7_Auto(_aCab,_aDet)
*******************************************************************************


	_aCab[ACNUM] := GetSX8Num("SC7","C7_NUM")

	aCab := {{"C7_NUM"			,_aCab[ACNUM]	,nil},;
			 {"C7_EMISSAO"		,_aCab[ACNUM]	,nil},;
			 {"C7_FORNECE"		,_aCab[ACNUM]	,nil},;
			 {"C7_LOJA"			,_aCab[ACNUM]	,nil},;
			 {"C7_COND"    		,_aCab[ACNUM]   ,nil},;
			 {"C7_CONTATO"   	,_aCab[ACNUM]   ,nil},;
			 {"C7_FILENT"  		,_aCab[ACNUM]	,Nil}} // Filial Entrega

	For nD := 1 to len(_aDet)

		aadd(aItens,{{"C7_ITEM"   	,_aDet[nD][AD_ITEM]		,nil},;
					 {"C7_PRODUTO"	,_aDet[nD][AD_PRODUTO]	,nil},;
					 {"C7_QUANT"  	,_aDet[nD][AD_QUANT]	,nil},;
					 {"C7_PRECO"  	,_aDet[nD][AD_PRECO]	,nil},;
					 {"C7_TOTAL"  	,_aDet[nD][AD_TOTAL]	,nil},;
					 {"C7_DATPRF"	,_aDet[nD][AD_DATPRF]	,nil},;
					 {"C7_TES"    	,_aDet[nD][AD_TES]		,nil},;
					 {"C7_FLUXO"  	,_aDet[nD][AD_FLUXO]	,nil},;
					 {"C7_LOCAL"	,_aDet[nD][AD_LOCAL]	,nil},;
					 {"C7_CODRDA"   ,_aDet[nD][AD_CODRDA]	,nil},;
					 {"C7_LOTPLS"   ,_aDet[nD][AD_LOTPLS]	,nil},;
					 {"C7_VLDESC"   ,_aDet[nD][AD_VLDESC]   ,nil}})

	Next i

	If Len(aItens) > 0

	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	MsExecAuto({|X,Y,Z,W| MATA120(X,Y,Z,W)},1, aCab, aItens, 3)
	SC7->(ConfirmSX8())

	IF lMsErroAuto //SE NAO HOUVE ERRO
	lOK:=.F.
	MostraErro()
	ENDIF

Return()