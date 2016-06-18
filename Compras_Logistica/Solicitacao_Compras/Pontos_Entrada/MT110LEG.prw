#include 'protheus.ch'
#include 'parmtype.ch'

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110ROT   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Função da dialog de legendas da mbrowse da Solicitação de      **
**          : Compras. Após a montagem do Array contendo as legendas da      **
**          : tabela SC1 e antes da execução da função Brwlegenda que monta a**
**          : dialog com as legendas, utilizado para adicionar legendas na   **
**          : dialog.   Deve ser usado em conjunto com o ponto MT110COR.     **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS. Utilizado para Montar a   **
**          : Legenda das Sc's integradas ao Sys-On                          **
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
User function MT110LEG()
*******************************************************************************
// aCores     = Array contendo as Legendas para a apresentação das cores do status da SC na mbrowse.
// lGspInUseM = Indica se há integração com o modulo GSP

Local aLegOrigi := aClone(PARAMIXB[1])  // aCores
Local aLegSysOn := {}

aAdd(aLegSysOn,{ "BR_CINZA_OCEAN.BMP" 	, "Sys-on: Bloqueada" 	} )
aAdd(aLegSysOn,{ "BR_MARRON_OCEAN.BMP"	, "Sys-on: Aguardando" } )
aAdd(aLegSysOn,{ "BR_AZUL_OCEAN.BMP"   	, "Sys-on: Transmitida"} )
aAdd(aLegSysOn,{ "BR_VIOLETA.PNG" 		, "Sys-on: Atendida" 	} )

//| Para que as Legendas do Sys-on tenha Preferencia no Filtro|
For nA := 1 To Len(aLegOrigi)
	aAdd(aLegSysOn, aLegOrigi[nA])
Next

Return (aLegSysOn)