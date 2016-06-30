/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110VLD  �Autor  �Microsiga           � Data �  08/20/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Localizado na Solicita��o de Compras, este ponto de entrada���
���			 � � respons�vel em validar o registro posicionado da         ���
���			 � Solicita��o de Compras antes de executar as opera��es de   ���
���			 � inclus�o, altera��o, exclus�o e c�pia. Se retornar .T.,    ���
���			 � deve executar as opera��es de inclus�o, altera��o, exclus�o���
���			 � e c�pia ou .F. para interromper o processo.                ���
���          �                                                            ���
���          �															  ���
���          � Obs: Bloquear Altera��o/Exclus�o da SC caso esteja em      ���
���          � Aprova��o												  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#include "RWMAKE.CH"
User Function MT110VLD()
Local ExpN1    := Paramixb[1]
Local ExpL1    := .T.

//| Valida se � uma Solicitacao Sys-On ja Transmitida , neste caso n�o pode alterar|
If !(ValSysOn(Paramixb[1]))
	Return(.F.)
EndIf


cBanAnt := alias()
//Valida��es do Cliente
//3- Inclus�o, 4- Altera��o, 8- Copia, 6- Exclus�o.
If ExpN1 == 4 .or. ExpN1 == 6
	cUsuAdm := Posicione("Z48",1,xFilial("Z48")+RetCodUsr(),"Z48_USUADM")
	DbSelectArea("Z50")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(SC1->C1_FILIAL+SC1->C1_NUM) //TRA->Z50_FILIAL
		If val(Z50->Z50_LIBERA) == 1 .or. val(Z50->Z50_LIBERA) == 5  //Somente permite altera��o para SC com status "incluida" ou "negada"
			If Z50->Z50_CODSOL == RetCodUsr() .or. cUsuAdm == "1" //eh o pr�prio solicitante  ou algum solicitante administrador.
				ExpL1    := .T.
	    	Else
				ExpL1    := .F.
				MsgBox("Nao � poss�vel executar opera��o, Usuario nao autorizado!","Atencao","ERROR")
			EndIf
		ElseIf cUsuAdm <> "1" //Somente usu�rio administrador pode excluir SC.
			ExpL1 := .F.
			MsgBox("Nao � poss�vel executar opera��o, SC em aprova��o/Aprovada!","Atencao","ERROR")
		EndIf
	ElseIf SC1->C1_APROV <> "B"
		ExpL1 := .F.
		MsgBox("Nao � poss�vel executar opera��o, SC em aprova��o/Aprovada!","Atencao","ERROR")
	ElseIf cUsuAdm <> "1"
		ExpL1 := .F.
		MsgBox("Nao � poss�vel executar opera��o, Usuario nao autorizado!","Atencao","ERROR")
	EndIf
EndIf
DbSelectArea(cBanAnt)
Return ExpL1

*******************************************************************************
Static Function ValSysOn(nOpcao)//| Valida se � uma Solicitacao Sys-On ja Transmitida , neste caso n�o pode alterar|
*******************************************************************************
	Local lRet := .T.
//3- Inclus�o, 4- Altera��o, 8- Copia, 6- Exclus�o.

	If nOpcao == 4 // Altera��o

		If SC1->C1_INTWSO == 'S' .And. C1_TX == 'TR'
		 	Iw_MsgBox("Esta Solicitacao ja foi Transmitida ao Sys-On. N�o pode ser Alterada. ","Aten��o","ALERT")
		 	lRet := .F.
		EndIf

	EndIf

Return(lRet)