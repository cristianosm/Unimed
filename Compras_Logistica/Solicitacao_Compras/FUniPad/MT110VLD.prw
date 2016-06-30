/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110VLD  ºAutor  ³Microsiga           º Data ³  08/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localizado na Solicitação de Compras, este ponto de entradaº±±
±±º			 ³ é responsável em validar o registro posicionado da         º±±
±±º			 ³ Solicitação de Compras antes de executar as operações de   º±±
±±º			 ³ inclusão, alteração, exclusão e cópia. Se retornar .T.,    º±±
±±º			 ³ deve executar as operações de inclusão, alteração, exclusãoº±±
±±º			 ³ e cópia ou .F. para interromper o processo.                º±±
±±º          ³                                                            º±±
±±º          ³															  º±±
±±º          ³ Obs: Bloquear Alteração/Exclusão da SC caso esteja em      º±±
±±º          ³ Aprovação												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "RWMAKE.CH"
User Function MT110VLD()
Local ExpN1    := Paramixb[1]
Local ExpL1    := .T.

//| Valida se é uma Solicitacao Sys-On ja Transmitida , neste caso não pode alterar|
If !(ValSysOn(Paramixb[1]))
	Return(.F.)
EndIf


cBanAnt := alias()
//Validações do Cliente
//3- Inclusão, 4- Alteração, 8- Copia, 6- Exclusão.
If ExpN1 == 4 .or. ExpN1 == 6
	cUsuAdm := Posicione("Z48",1,xFilial("Z48")+RetCodUsr(),"Z48_USUADM")
	DbSelectArea("Z50")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(SC1->C1_FILIAL+SC1->C1_NUM) //TRA->Z50_FILIAL
		If val(Z50->Z50_LIBERA) == 1 .or. val(Z50->Z50_LIBERA) == 5  //Somente permite alteração para SC com status "incluida" ou "negada"
			If Z50->Z50_CODSOL == RetCodUsr() .or. cUsuAdm == "1" //eh o próprio solicitante  ou algum solicitante administrador.
				ExpL1    := .T.
	    	Else
				ExpL1    := .F.
				MsgBox("Nao é possível executar operação, Usuario nao autorizado!","Atencao","ERROR")
			EndIf
		ElseIf cUsuAdm <> "1" //Somente usuário administrador pode excluir SC.
			ExpL1 := .F.
			MsgBox("Nao é possível executar operação, SC em aprovação/Aprovada!","Atencao","ERROR")
		EndIf
	ElseIf SC1->C1_APROV <> "B"
		ExpL1 := .F.
		MsgBox("Nao é possível executar operação, SC em aprovação/Aprovada!","Atencao","ERROR")
	ElseIf cUsuAdm <> "1"
		ExpL1 := .F.
		MsgBox("Nao é possível executar operação, Usuario nao autorizado!","Atencao","ERROR")
	EndIf
EndIf
DbSelectArea(cBanAnt)
Return ExpL1

*******************************************************************************
Static Function ValSysOn(nOpcao)//| Valida se é uma Solicitacao Sys-On ja Transmitida , neste caso não pode alterar|
*******************************************************************************
	Local lRet := .T.
//3- Inclusão, 4- Alteração, 8- Copia, 6- Exclusão.

	If nOpcao == 4 // Alteração

		If SC1->C1_INTWSO == 'S' .And. C1_TX == 'TR'
		 	Iw_MsgBox("Esta Solicitacao ja foi Transmitida ao Sys-On. Não pode ser Alterada. ","Atenção","ALERT")
		 	lRet := .F.
		EndIf

	EndIf

Return(lRet)