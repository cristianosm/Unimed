#include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Ap5Mail.ch"

/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : SMProxSys  | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO: Este Programa tem o Objetivo de abrir uma Tela Atraves da Tecla**
**          : de atalho F4. Quando Posicionado em modo Edicao no Campo       **
**          : C1_QUANT na Solicitacao de Compras. Para Facilicar a           **
**          : distribuicao de um determidado produto                         **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Unimed-VS                            **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function SMProxSys(cNumSol, cBody, cAssunto, cQuem) //| cQuem [S][C][T] Solicitante, Comprador, Todos
*******************************************************************************

Local aAreaAct := GetArea()
Local aAreaSC1 := SC1->(GetArea())
Local cEmailCo := "" //email comprador
Local cEmailSo := "" //email solicitante

If cQuem <> "S"
	cEmailCo := BuscaMComp(cNumSol) //| Busca o Email do Comprador |
EndIF

If cQuem <> "C"
	cEmailSo := BuscaMSolt(cNumSol) //| Busca o Email do Solicitante|
EndIf

SendMail(cEmailSo+";"+cEmailCo, cAssunto, cBody) //Envia o email...

RestArea(aAreaSC1)
RestArea(aAreaAct)

Return()
*******************************************************************************
Static Function BuscaMComp(cNumSol) //| Busca o Email do Comprador |
*******************************************************************************
Local cCodComp := ""
Local cEmailCo := ""

cCodComp := Posicione("SC1",1,xFilial("SC1")+cNumSol,"C1_CODCOMP")
cEmailCo := Posicione("SY1",1,xFilial("SY1")+cCodComp,"Y1_EMAIL")

Return(Alltrim(cEmailCo))
*******************************************************************************
Static Function BuscaMSolt(cNumSol) //| Busca o Email do Solicitante|
*******************************************************************************
Local cSolicit := ""
Local cEmailSo := "" //email solicitante

cSolicit := Posicione("SC1",1,xFilial("SC1")+cNumSol,"C1_SOLICIT")

PswOrder(2);PswSeek(cSolicit,.T.)

cEmailSo := SC1->(PswRet()[1][14])

Return(cEmailSo)
*******************************************************************************
Static Function SendMail(_cTo,_cSubject,_cBody)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
*******************************************************************************

	Local cServer 		:= SuperGetMv( "MV_RELSERV", .F., "mail.unimed-vs.localdomain" 	)
	Local cAccount 		:= SuperGetMv("MV_RELACNT"	,.F.,"protheus@vs.unimed.com.br"	)
	Local cPassword 	:= SuperGetMv("MV_RELPSW"	,.F.,"wf"						    )
	Local lAuth 		:= SuperGetMv("MV_RELAUTH"	,.F.,.F.							)
	Local lResult  		:= .T.
	Local cError	    := ''

	Private cFrom		:= "sys-on@vs.unimed.com.br"//Iif(empty(Alltrim(_cFrom)), cAccount, Alltrim(_cFrom))
	Private cTo			:= Alltrim(_cTo)
	Private cSubject	:= Alltrim(_cSubject)
	Private cBody		:= Alltrim(_cBody) + " " + Alltrim(_cTo)


	CONNECT SMTP SERVER Alltrim(cServer) ACCOUNT Alltrim(cAccount) PASSWORD Alltrim(cPassword) RESULT lResult

	If lAuth
		lResult := MailAuth(cAccount,cPassword)
	EndIF
	If lResult
		SEND MAIL FROM cFrom TO cTo /*cTo*/ CC "" SUBJECT cSubject BODY cBody ATTACHMENT "" RESULT lResult

		If !lResult
			GET MAIL ERROR cError
			IW_MsgBox("Email Não Enviado !!! cServer:"+cServer+" Conta:"+cAccount +" Pass: "+ cPassword+ " lResult: "+cValToChar(lResult) +" Erro: "+cError,"Atenção","ALERT")
		//Else
		//	IW_MsgBox("Email "+Alltrim(cSubject)+" . Enviado com Sucesso. Destinatarios:"+Alltrim(cTo),"Atenção","INFO")
		EndIf
		DISCONNECT SMTP SERVER

	EndIf

Return(cError)