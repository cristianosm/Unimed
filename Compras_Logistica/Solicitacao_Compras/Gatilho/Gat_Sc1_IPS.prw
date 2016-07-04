#include 'protheus.ch'
#include 'parmtype.ch'

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : Gat_Sc1_IPS| AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Este programa deve ser usado em conjunto com o cadastro de     **
**          : de gatilho. Serve para Alimentar de forma automatica o centro  **
**          : de Custo e Classe de Valor, Baseada no Cadastro da Tabela      **
**          : SX5-XX. Os cadastro deve serguir a logica [Tipo+Filial+Estoque]**
**          : Exemplo: Tipo = CC -> Centro de Custo, CV -> Classe de Valor   **
**          :          Filial = Filial correspondente. 13 -> Hospital Unimed **
**          :          Estoque = B1_LOCPAD do Produto.                       **
**          : Baseado nestas Informações deve ser definida qual CC e CV vão  **
**          : Ser utilizados na Solicitacao de compras.                      **
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
User Function Gat_Sc1_IPS(cQuem)
*******************************************************************************

	Local cTab 	:= "XX"
	Local cFil	:= xFilial("SC1")
	Local cLoP	:= SB1->B1_LOCPAD
	Local cRet	:= ""

	If !Empty(cQuem) .And. ( cQuem == "CC" .oR. cQuem == "CV") //| Centro de Custo ou Classe de Valor
		cRet := Alltrim(Posicione("SX5",1,XFilial("Sx5")+cTab+cQuem+cFil+cLoP,"X5_DESCRI"))
	EndIf

Return(cRet)