#Include 'Protheus.ch'
/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110GRV   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Função na SC responsavel pela gravação das SCs.                **
**          : No laço de gravação dos itens da SC na função A110GRAVA,       **
**          : executado após gravar o item da SC, a cada item gravado da SC  **
**          :  o ponto é executado..                                         **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS. Salva o Conteudo do Campo **
**          : C1_INTWSO - Integração Sys-on Através da Variavel cIntWSo      **
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

//| Customizacao que já existia no Fonte da Unimed MT112GRV. Deve ser Substituido por este.
CustomUni()

Return()
*******************************************************************************
Static Function SvCpoISo()//| Salva o Conteudo da Variavel cIntWSo Que existe no Cab. da Sol de Compras na Tebla SC1
*******************************************************************************


RecLock("SC1",.F.)
SC1->C1_INTWSO := cIntWSo
If cIntWSo == "S" .And. SC1->C1_TX == "  " //| Solicitação Sys-On
	SC1->C1_TX := "AG"
EndIf
MsUnlock()

 // So envia o email uma vez o email ....
If Type('cLastSendSc') == 'U'
	Public cLastSendSc := ""
Endif
If cLastSendSc <> SC1->C1_NUM
	U_SMProxSys( SC1->C1_NUM , "Solicitacao Sys-On "+SC1->C1_NUM+", aguardando Liberacao.", "Incluida SC Sys-On","C" )

	cLastSendSc := SC1->C1_NUM
EndIF

Return()
*******************************************************************************
Static Function CustomUni()//| Customizacao que já existia no Fonte da Unimed MT112GRV. Deve ser Substituido por este.
*******************************************************************************

If !INCLUI .and. !ALTERA
	If Z51->(MsSeek(SC1->(C1_FILIAL + C1_NUM)))
		While !Z51->(Eof()) .and. SC1->(C1_FILIAL + C1_NUM) == Z51->(Z51_FILIAL + Z51_NUMSC)
			Z51->(RecLock("Z51",.F.))
			Z51->(DbDelete())
			Z51->(Msunlock())
			Z51->(DbSkip(1))
		EndDo
	EndIf
	If Z50->(MsSeek(SC1->(C1_FILIAL + C1_NUM)))
		While !Z50->(Eof()) .and. SC1->(C1_FILIAL + C1_NUM) == Z50->(Z50_FILIAL + Z50_NUMSC)
			Z50->(RecLock("Z50",.F.))
			Z50->(DbDelete())
			Z50->(Msunlock())
			Z50->(DbSkip(1))
		EndDo
	EndIf
Else
	If SC1->(!Eof())
	    RecLock("SC1",.F.)
		C1_APROV := "B"
		Msunlock()
	EndIf
EndIf

Return()