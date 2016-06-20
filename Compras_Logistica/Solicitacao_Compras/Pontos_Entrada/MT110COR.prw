#include 'protheus.ch'
#include 'parmtype.ch'
/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110ROT   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO:  No inicio da rotina MATA110 e antes da execução da Mbrowse da **
**          : SC, utilizado para manipular o Array com as regras para        **
**          : apresentação das cores dos estatus na Mbrowse.                 **
**          :                                                                **
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
user function MT110COR()
*******************************************************************************

Local aCorOrigi := aClone(PARAMIXB[1])  // aCores
Local aCorSysOn := {}

aAdd(aCorSysOn,{ "C1_APROV=='B' .And. C1_INTWSO == 'S' .And. C1_TX == 'AG' .And. C1_QUJE == 0" 		, "BR_CINZA_OCEAN.BMP"	})  //-- Sys-on: Bloqueada.
aAdd(aCorSysOn,{ "C1_APROV<>'B' .And. C1_INTWSO == 'S' .And. C1_TX == 'AG' .And. C1_QUJE == 0" 		, "BR_MARRON_OCEAN.BMP"	})  //-- Sys-on: Aguardando.
aAdd(aCorSysOn,{ "C1_APROV<>'B' .And. C1_INTWSO == 'S' .And. C1_TX == 'TR' .And. C1_QUJE == 0" 		, "BR_AZUL_OCEAN.BMP"	})  //-- Sys-on: Transmitida.
aAdd(aCorSysOn,{ "C1_APROV<>'B' .And. C1_INTWSO == 'S' .And. C1_TX == '  ' .And. C1_QUJE>=C1_QUANT" , "BR_VIOLETA.PNG"		})  //-- Sys-on: Atendida.

//| Para que as Legendas do Sys-on tenha Preferencia no Filtro|
For nA := 1 To Len(aCorOrigi)
	aAdd(aCorSysOn, aCorOrigi[nA])
Next

Return (aCorSysOn)