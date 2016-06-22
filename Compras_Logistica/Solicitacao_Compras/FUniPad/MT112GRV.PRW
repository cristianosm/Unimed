#include "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110GRV  ºAutor  ³Microsiga           º Data ³  08/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LOCALIZAÇÃO : Function A110GRAVA - Função da Solicitação deº±±
±±º          ³ Compras responsavel pela gravação das SCs.                 º±±
±±º          ³ EM QUE PONTO : No laco de gravação dos itens da SC na      º±±
±±º          ³ função A110GRAVA, executado após gravar o item da SC,      º±±
±±º          ³ a cada item gravado da SC o ponto é executado.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

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