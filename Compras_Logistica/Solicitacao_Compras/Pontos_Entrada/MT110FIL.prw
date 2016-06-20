#include 'protheus.ch'
#include 'parmtype.ch'

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110FIL   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Comp�e uma string para ser passada para MBrowse                **
**          : Antes da apresenta�ao da interface da Mbrowse no inicio da     **
**          : rotina, possibilita compor um string contendo uma express�o de **
**          : Filtro da tabela SC1 para ser passada para MBrowse.            **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS para habilitar o uso da    **
**          : tecla de atalho F4 na Solicita��o de Compras e Distribuir as   **
**          : Necessidades. Utilizado pela Logistica Hospital Unimed         **
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function MT110FIL()
*******************************************************************************

SetKey( VK_F4, { || U_Sc_Qtd_Data()  } )

Return ("")