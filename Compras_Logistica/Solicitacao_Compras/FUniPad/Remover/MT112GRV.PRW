#include "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110GRV  �Autor  �Microsiga           � Data �  08/20/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � LOCALIZA��O : Function A110GRAVA - Fun��o da Solicita��o de���
���          � Compras responsavel pela grava��o das SCs.                 ���
���          � EM QUE PONTO : No laco de grava��o dos itens da SC na      ���
���          � fun��o A110GRAVA, executado ap�s gravar o item da SC,      ���
���          � a cada item gravado da SC o ponto � executado.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// Descontinuado


User Function MT110GRV()
Local ExpN1    := Paramixb[1]
Local ExpL1    := .T.

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

Return ExpL1