#Include "Protheus.ch"

#Define _LIN_  1
#Define _COL_  2

#Define _VISUALIZAR		2
#Define _INCLUIR    	3
#Define _ALTERAR		4
#Define _EXCLUIR 		6

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNO   : Mt110Tel    | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRIO:    Este ponto tem a finalidade de manipular o cabecalho da       **
**          : Solicitao de Compras permitindo a inclusao o e alteracao de         **
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
User function Mt110Tel()
*******************************************************************************

	// Analista: Cristiano Machado | Projeto: Integracao Syson WebService | Data: 12/2015
	IntSysWeb(PARAMIXB)


Return()
*******************************************************************************
Static Function IntSysWeb(PARAMIXB)
*******************************************************************************

	//| Variavaies PARAMIXB |
	Local 	oParDialog := PARAMIXB[1]		//| Janela Principal da Solicitacao |
	Local 	aPosGet    := PARAMIXB[2] 	//| 2-Visualizar, 3-Incluir, 4-Alterar e Copia, 6-excluir Posicao dos Gets no Cab da Solcitacao |
	Local 	nOpcx      := PARAMIXB[3] 	//| Opacao que esta sendo utilizada|
	Local	nReg       := PARAMIXB[4] 	//| Numero do Registro... |

	//| Variaveis Integracao |
	Local 	aPosLabel	:= { 31 , aPosGet[2,7] } //| { Linha , Coluna } |
	Local 	aPosCombo	:= { 32 , aPosGet[2,8] } //| { Linha , Coluna } |
	Local 	aIntWSo		:= StrTokArr(SX3->(POSICIONE("SX3",2,"C1_INTWSO","X3_CBOX")),";")
	Local 	cDescISo	:= SX3->(POSICIONE("SX3",2,"C1_INTWSO","X3_TITULO"))

	//| Variavel Que deve ser utilizada para armazenar o conteudo do Campo C1_INTWSO utilizada no Cabecalho da Sol. Comp.|
	If Type("cIntWSo") == "U" //| Variavel n o Declarada ...|
		Public cIntWSo := CriaVar("C1_INTWSO")
	Else
		cIntWSo := CriaVar("C1_INTWSO")
	EndIf

	//| Verifica qual eh a Operao ??? Para o correto Tratamento...|
	If ( nOpcx == _INCLUIR )

		cIntWSo := CriaVar("C1_INTWSO")

	ElseIf (nOpcx == _VISUALIZAR) .Or. (nOpcx == _ALTERAR) .Or. (nOpcx == _EXCLUIR )

		cIntWSo := SC1->C1_INTWSO

	EndIf

	//| Monta no Cabecalho da Solicitao de Compras o Campo Customizado|
	@ aPosLabel[_LIN_],aPosLabel[_COL_] SAY cDescISo PIXEL SIZE 80,20 Of oParDialog
  	@ aPosCombo[_LIN_],aPosCombo[_COL_] MSCOMBOBOX oComboBo VAR cIntWSo ITEMS aIntWSo SIZE 038, 010 OF oParDialog COLORS 0, 16777215 PIXEL

Return()