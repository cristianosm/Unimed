#Include "RWMAKE.CH"

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : MT110VLD   | AUTOR : Microsiga          | DATA : 08/20/2010    **
**---------------------------------------------------------------------------**
** DESCRICAO: Localizado na Solicitacao de Compras, este ponto de entrada    **
**          : e responsavel em validar o registro posicionado na             **
**          : Solicitacao de Compras antes de executar as operacoes de       **
**          : Inclusao, Alteracao, exclusao e copia. Se retornar .T.,        **
**          : deve executar as operacoes de Inclusao, Alteracao, exclusao    **
**          : e copia ou .F. para interromper o processo.                    **
**---------------------------------------------------------------------------**
** USO      : Obs: Bloquear Alteracao/Exclusao da SC caso esteja em          **
**          : aprovacao	                                                     **
**          :                                                                **
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**Cristiano Machado|23/03/2016| Bloquei de Alteracao de Solcitacao Sys-on    **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/

*******************************************************************************
User Function MT110VLD()
*******************************************************************************

	Local ExpN1    := Paramixb[1]
	Local ExpL1    := .T.

	//| Valida se é uma Solicitacao Sys-On ja Transmitida , neste caso nao pode alterar|
	If !(ValSysOn(Paramixb[1]))
		Return(.F.)
	EndIf

	cBanAnt := alias()
	//Validacoes do Cliente
	//3- Inclusao, 4- Alteracao, 8- Copia, 6- Exclusao.
	If ExpN1 == 4 .or. ExpN1 == 6
		cUsuAdm := Posicione("Z48",1,xFilial("Z48")+RetCodUsr(),"Z48_USUADM")
		DbSelectArea("Z50")
		dbSetOrder(1)
		dbGotop()

		If dbSeek(SC1->C1_FILIAL+SC1->C1_NUM) //TRA->Z50_FILIAL

			If val(Z50->Z50_LIBERA) == 1 .or. val(Z50->Z50_LIBERA) == 5  //Somente permite Alteracao para SC com status "incluida" ou "negada"

				If Z50->Z50_CODSOL == RetCodUsr() .or. cUsuAdm == "1" //eh o proprio solicitante  ou algum solicitante administrador.
					ExpL1    := .T.
				Else
					ExpL1    := .F.
					MsgBox("Nao e possivel executar operacao, Usuario nao autorizado!","Atencao","ERROR")
				EndIf

			ElseIf cUsuAdm <> "1" //Somente usuario administrador pode excluir SC.
				ExpL1 := .F.

				IIw_MsgBox( "Nao e possivel executar operacao, Sc em Aprovacao/Aprovada !","Atencao","ERROR")

			EndIf

		ElseIf SC1->C1_APROV <> "B"
			ExpL1 := .F.
			Iw_MsgBox( "Nao e possivel executar operacao, Sc em Aprovacao/Aprovada !","Atencao","ERROR")

		ElseIf cUsuAdm <> "1"
			ExpL1 := .F.
			Iw_MsgBox("Nao é possivel executar operacao, Usuario nao autorizado!","Atencao","ERROR")

		EndIf

	EndIf

	DbSelectArea(cBanAnt)

	Return ExpL1

*******************************************************************************
Static Function ValSysOn(nOpcao)//| Valida se é uma Solicitacao Sys-On ja Transmitida , neste caso nao pode alterar|
*******************************************************************************
	Local lRet := .T.
	//3- Inclusao, 4- Alteracao, 8- Copia, 6- Exclusao.

	If nOpcao == 4 // Alteracao

		If SC1->C1_INTWSO == 'S' .And. C1_TX == 'TR'
			Iw_MsgBox("Esta Solicitacao ja foi Transmitida ao Sys-On. nao pode ser Alterada. ","Atencao","ALERT")
			lRet := .F.
		EndIf

	EndIf

Return(lRet)