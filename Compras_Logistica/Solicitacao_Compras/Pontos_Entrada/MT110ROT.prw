#include 'protheus.ch'
#include 'parmtype.ch'
/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110ROT   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Adiciona mais opções no aRotina                                **
**          : No inico da rotina e antes da execução da Mbrowse da SC,       **
**          : utilizado para adicionar mais opções no aRotina.               **
**          :                                                                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS. Utilizado para Transmição **
**          : das Solicitações Integradas ao Sys-On                          **
**          :                                                                **
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function MT110ROT()
*******************************************************************************

//Define Array contendo as Rotinas a executar do programa
// ----------- Elementos contidos por dimensao ------------
// 1. Nome a aparecer no cabecalho
// 2. Nome da Rotina associada
// 3. Usado pela rotina
// 4. Tipo de Transa‡„o a ser efetuada
 //    1 - Pesquisa e Posiciona em um Banco de Dados
 //    2 - Simplesmente Mostra os Campos
 //    3 - Inclui registros no Bancos de Dados
 //    4 - Altera o registro corrente
 //    5 - Remove o registro corrente do Banco de Dados
 //    6 - Altera determinados campos sem incluir novos Regs

 AAdd( aRotina, { "Transmição Sys-On", 'Alert("Enviar ao Sys-On")', 0, 4 } )

Return aRotina


