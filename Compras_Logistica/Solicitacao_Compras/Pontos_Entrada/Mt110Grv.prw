#Include 'Protheus.ch'
/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110GRV   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Fun��o na SC responsavel pela grava��o das SCs.                **
**          : No la�o de grava��o dos itens da SC na fun��o A110GRAVA,       **
**          : executado ap�s gravar o item da SC, a cada item gravado da SC  **
**          :  o ponto � executado..                                         **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS. Salva o Conteudo do Campo **
**          : C1_INTWSO - Integra��o Sys-on Atrav�s da Variavel cIntWSo      **
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function MT110GRV()
*******************************************************************************
//Caso PARAMIXB == .T.(Copia da solicitao de compras esta ativa), se .F.(Copia no esta ativa)
lExp1 :=  PARAMIXB[1]

//| Salva o Conteudo da Variavel cIntWSo Que existe no Cab. da Sol de Compras na Tebla SC1
SvCpoISo()

Return()
*******************************************************************************
Static Function SvCpoISo()//| Salva o Conteudo da Variavel cIntWSo Que existe no Cab. da Sol de Compras na Tebla SC1
*******************************************************************************

RecLock("SC1",.F.)
SC1->C1_INTWSO := cIntWSo
If cIntWSo == "S" .And. SC1->C1_TX == "  " //| Solicita��o Sys-On
	SC1->C1_TX := "AG"
EndIf
MsUnlock()





Return()