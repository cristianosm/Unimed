#include "rwmake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE 'tbiconn.ch'
#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MT110TOK  �Autor  �Microsiga           � Data �  08/19/10    ���
��������������������������������������������������������������������������͹��
���Desc.     � LOCALIZA��O : Function A110TudOk() respons�vel pela valida��o��
���			 � da GetDados da Solicita��o de Compras .                      ��
���			 � EM QUE PONTO : O ponto se encontra no final da fun��o e deve ��
���			 � ser utilizado para valida��es especificas do usuario onde    ��
���			 � ser� controlada pelo retorno do ponto de entrada o qual se   ��
���			 � for .F. o processo ser� interrompido e se .T. ser� validado. ��
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

User Function MT110TOK()     
Local nTotSol, nPosCta, cChave
Local cArea := GetArea()
Local lResult  	:= .F.
Local cMsg:= "A rotina n�o poder� prosseguir. Os Campos a seguir n�o est�o dispon�veis para voc�. Informe-os para Administrador do sistema:" + CHR(13)+CHR(10)
Local lReturn := .T.

Private cHtml 	  := ""

/*
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.
*/


MontaHtml(CA110NUM, RetCodUsr(), UsrRetName(RetCodUsr()))

lExp1 :=  PARAMIXB[1]

nTotSol := 0

IF GDFieldPos("C1_YPRECO") == 0
	cMsg += "C1_YPRECO"+ CHR(13)+CHR(10)
	lReturn := .F.
ENDIF
IF GDFieldPos("C1_YJUSTIF") == 0
	cMsg += "C1_YJUSTIF"+ CHR(13)+CHR(10)
	lReturn := .F.
ENDIF	
IF 	GDFieldPos("C1_ITEM") == 0 .OR. ;
	GDFieldPos("C1_PRODUTO") == 0 .OR. ;
	GDFieldPos("C1_UM") == 0 .OR. ;
	GDFieldPos("C1_QUANT") == 0 .OR. ;
	GDFieldPos("C1_DESCRI") == 0 .OR. ;
	GDFieldPos("C1_QUANT") == 0 .OR. ;
	GDFieldPos("C1_CC") == 0 
	
	cMsg += "campos padr�es -> C1_ITEM, C1_PRODUTO, C1_UM, C1_QUANT, C1_DESCRI, C1_CC"
	lReturn := .F.
ENDIF
IF !lReturn
	IW_MSGBOX(cMsg,"Inconsist�ncia!","INFO" )
	Return lReturn
ENDIF	


For nContad := 1 To Len(aCols)
	If !aCols[nContad, Len(aHeader)+1] //Nao deletado
		nTotSol += GDFieldGet("C1_YPRECO",nContad) * GDFieldGet("C1_QUANT",nContad)
		MontaItem(	GDFieldGet("C1_ITEM",nContad),;
					GDFieldGet("C1_PRODUTO",nContad)	,;
					GDFieldGet("C1_UM",nContad)	   		,;
					GDFieldGet("C1_QUANT",nContad) 		,;
					GDFieldGet("C1_DESCRI",nContad)		,;
					GDFieldGet("C1_YPRECO",nContad)		,; //, nContad)
					GDFieldGet("C1_YJUSTIF",nContad) 	,;
	    			GDFieldGet("C1_CC",nContad) + " - "+Posicione("CTT",1,xFilial("CTT") + GDFieldGet("C1_CC",nContad) ,"CTT_DESC01"),;	
					nContad)
	EndIf
Next	

MontaRodape(nTotSol)
EnviaMail()

DbSelectArea("Z50")
If MsSeek(xFilial("Z50")+CA110NUM)
	RecLock("Z50",.F.)
	Z50_LIBERA := "1"
	Z50_STATUS := "SC incluida"	
	Z50_VLRTOT := nTotSol
	Z50->(MsUnlock())
Else
	RecLock("Z50",.T.)
	Z50_FILIAL := xfilial("SC1")
	Z50_NUMSC := CA110NUM
	Z50_CODSOL := RetCodUsr()
	Z50_NOMSOL := UsrRetName(RetCodUsr())
	Z50_VLRTOT := nTotSol
	Z50_LIBERA := "1"
	Z50_STATUS := "SC incluida"	
	Z50_DATA   := date()
	Z50->(MsUnlock())
EndIf	
Z50->(DbCloseArea())
RestArea(cArea)
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110TOK  �Autor  �Microsiga           � Data �  08/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gerencia e envia os e-mails                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EnviaMail()
Local cServer 	:= GetMV("MV_RELSERV" )
Local cAccount 	:= Alltrim(GETMV("MV_RELACNT"))
Local cPassword := Alltrim(GETMV("MV_RELPSW"))
Local lAuth 	:= Getmv("MV_RELAUTH")
Local cAssunto 	:= "Solicita��o Compra " + "-  Data de Gera��o : " + DTOC(date())
Local cEmailTo 	:= Getmv("UN_EMASC")
Local cEmailBcc	:= " "
Local lResult  	:= .F.
Local cError 	:= ""
Local cBody     := ""

cBody := cHtml
cAnexo:= " "

// conectando-se com o servidor de e-mail
Conout("SC - Conectando com o Servidor de Email")
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lResult .And. lAuth
	lResult :=   MailAuth(cAccount,cPassword)
	FOR Z :=1 TO 5
		sleep(1000)
		If !lResult
			Conout("SC -  Tentando Autentica��o " + Transform(Z,'@E 99') + " de 5" )
			lResult := MailAuth(cAccount,cPassword) .or. QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		ELSE
			exit
		ENDIF
	NEXT Z
	
	If !lResult
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Conout("SC - Erro de Autenticacao, conta " + cAccount + ", Erro: " + cError)
		//			MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
		Return Nil
	Endif
Else
	If !lResult
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Conout("SC - Erro de Conexao" + cError)
		//			MsgInfo(cError,OemToAnsi("Erro de Conexao"))
		Return Nil
	Endif
EndIf

// enviando e-mail
If lResult
	Conout("SC - Enviando Email")
	SEND MAIL FROM cAccount ;
	TO	cEmailTo ;
	CC     		cEmailBcc ;
	SUBJECT 	cAssunto ;
	BODY    	cBody ;
	ATTACHMENT  cAnexo ;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		Conout("SC - Nao Enviou Email - " + cError)
	EndIf
	//		DISCONNECT SMTP SERVER
Endif
Conout("SC - Email enviado para " + cEmailTo + " e c�pia para " + cEmailBcc )
DISCONNECT SMTP SERVER
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110TOK  �Autor  �Microsiga           � Data �  08/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o HTML que ir� ser enviado no corpo do e-mail        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MontaHtml(NumSC, CodSol, Solici)
cHtml := " "

cHtml += '<html> '
cHtml += '<head> '
cHtml += '<meta http-equiv="Content-Type" '
cHtml += 'content="text/html; charset=iso-8859-1"> '
cHtml += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"> '
cHtml += '<title>Solicita��o de Compra</title> '
cHtml += '</head> '
cHtml += '<body bgcolor="#FFFFFF"> '
cHtml += '<table width="80%" border="0" bordercolordark="#404040" bgcolor="#FFFFFF"> '
cHtml += '      <tbody> '
cHtml += '	  <tr> '
cHtml += '	  <td width="180"><img src="http://201.20.146.31/Web/sac/imagens/logos/logo_verde_180x50.gif" alt="" /></td> '
cHtml += '    <td > '
cHtml += '	<h2><font color="#666666" face="Verdana"><b>Aprova��o de '
cHtml += '    Solicita��o de Compra</b></font></h2></td> '
cHtml += '    <table border="1" width="845"> '
cHtml += '        <tr> '
cHtml += '            <td width="100" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Numero SC</b></font></td> '
cHtml += '            <td width="460" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Solicitante</b></font></td> '
cHtml += '        </tr> '
cHtml += '        <tr> '
cHtml += '            <td width="100"><font size="2" face="Arial">'+NumSC+'</font></td> '
cHtml += '            <td width="460"><font size="2" face="Arial">'+CodSol+' - '+Solici+'</font></td> '
cHtml += '        </tr> '
cHtml += '    </table> '
cHtml += '    <p><font color="#666666" face="Verdana"><b>Itens</b></font></p> '
cHtml += '    <table border="1" width="846"> '
cHtml += '        <tr> '
cHtml += '            <td width="65" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Item da SC</b></font></td> '
cHtml += '            <td width="222" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Descri��o</b></font></td> '
cHtml += '            <td width="15" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Qtd</b></font></td> '
cHtml += '            <td width="32" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Unid</b></font></td> '
cHtml += '            <td width="99" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Pre�o Unit�rio</b></font></td> '
cHtml += '            <td width="43" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Total</b></font></td> '
cHtml += '            <td nowrap bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Desc. Centro de Custo</b></font></td> '
cHtml += '            <td width="43" bgcolor="#C0C0C0"><font size="2" '
cHtml += '            face="Verdana"><b>Justificativa</b></font></td> '
cHtml += '        </tr> '


/*cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'
cHtml += '<head>'
cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
cHtml += '<title>Untitled Document</title>'
cHtml += '<style type="text/css">'
cHtml += '<!--'
cHtml += '.style2 {	font-size: 36px'
cHtml += '}'
cHtml += '.style1 {	font-family: Arial, Helvetica, sans-serif;'
cHtml += '	font-weight: bold;'
cHtml += '}'
cHtml += '-->'
cHtml += '</style>'
cHtml += '<link href="file://///172.22.0.35/Web/sac/estilos.css" rel="stylesheet" type="text/css" />'
cHtml += '</head>'
cHtml += ''
cHtml += '<body>'
cHtml += '<table width="98%" border="0">'
cHtml += '  <tr>'
cHtml += '    <th scope="col"><table width="80%" border="0" bordercolordark="#404040" bgcolor="#FFFFFF">'
cHtml += '      <tbody>'
cHtml += '        <tr>'
cHtml += '          <td width="180"><img src="http://201.20.146.31/Web/sac/imagens/logos/logo_verde_180x50.gif" alt="" /></td>'
cHtml += '          <td width="668" valign="top"><div align="left"><strong class="style2"><font color="#666666"><font face="Arial">Solicita��o de Compra</font></font></strong></div></td>'
cHtml += '        </tr>'
cHtml += '      </tbody>'
cHtml += '    </table>'
cHtml += '    <br />'
cHtml += '    <br /></th>'
cHtml += '  </tr>'
cHtml += '  <tr>'
cHtml += '    <th scope="col"><table width="80%" border="1" bordercolordark="#404040" bgcolor="#FFFFFF">'
cHtml += '      <tr>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Num. SC</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Solicitante</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Item</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Cod Produto</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Un. Medida</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Quantidade</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Desc. Produto</font></span></td>'
cHtml += '        <td class="txt006"><span class="style1"><font color="#666666">Pre�o</font></span></td>'
cHtml += '      </tr>' */
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110TOK  �Autor  �Microsiga           � Data �  08/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Montagem do Rodap� do HTLM do corpo do E-mail              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MontaRodape(nTotSol)

cHtml += '    </table> '
cHtml += '    <table border="1" width="275"> '
cHtml += '        <tr> '
cHtml += '            <td width="155" bgcolor="#808080"><font size="2" face="Verdana"><b>Valor Total</b></font></td> '
cHtml += '            <td width="32"><font size="2" face="Arial">'+Transform(nTotSol, "@E 9,999,999.99")+'</font></td> '
cHtml += '        </tr> '
cHtml += '    </table> '
cHtml += '</body> '
cHtml += '</html> '
/*
cHtml += '    </table>'
cHtml += '      <br />'
cHtml += '      <br />  '
cHtml += '      <table width="60%" border="0">'
cHtml += '        <tr>'
cHtml += '          <th scope="col">&nbsp;</th>'
cHtml += '        </tr>'
cHtml += '      </table>      <p>&nbsp;</p></th>'
cHtml += '  </tr>'
cHtml += '  <tr>'
cHtml += '    <th scope="col"><div align="left" ><strong><font color="#666666">Portal Nacional de Sa�de - Unimed Brasil</font></strong><a href="http://www.ans.gov.br/" title="Visitar o site da ANS" rel="external"><img src="http://www.unimed.com.br/pct/layout/2009-corporativo/imagens/rodape_logo_ans.jpg" alt="Ag�ncia Nacional de Sa�de Suplementar" /></a> </div></th>'
cHtml += '  </tr>'
cHtml += '</table>'
cHtml += '</body>'
cHtml += '</html>'
cHtml +=  CRLF + CRLF	+ "UGPER001 - Este relat�rio informa quando os filhos dos colaboradores completam/completaram 6, 18 e 24 anos de idade."
*/
Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110TOK  �Autor  �Microsiga           � Data �  08/25/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para constru��o dos itens da SC no corpo do e-mail  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MontaItem(cItem,cProduto,cUm,cQuant,cDescri,cPreco,cJustif,cCenCusto,nContad) //cJustif,

fundo="#E4EFEC"
If (nContad % 2) = 0
	cor="#FCFCFC"
Else
	cor="#F3F3F3"
EndIf
cSimpl := "'"
cHtml += '<tr bgcolor='+cSimpl+cor+cSimpl+' OnMouseOver="javascript:this.style.backgroundColor='+cSimpl+fundo+cSimpl+'" onMouseOut="javascript:this.style.backgroundColor='+cSimpl+cor+cSimpl+'">'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + cItem + '</font></td>'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + cProduto + ' - ' + cDescri + '</font></td>'
cHtml += '<td width="15"><font size="2" color="#666666" face="Arial"> ' + str(cQuant) + '</font></td>'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + cUm + '</font></td>'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + Transform(cPreco, "@E 9,999,999.99") + '</font></td>'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + Transform(cQuant*cPreco, "@E 9,999,999.99") +'</font></td>'
cHtml += '<td nowrap><font size="2" color="#666666" face="Arial"> ' + cCenCusto +'</font></td>'
cHtml += '<td width="50"><font size="2" color="#666666" face="Arial"> ' + cJustif +'</font></td>'
cHtml += '</tr> '

/*cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + cItem + '</font></span></td>'
cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + cProduto + '</font></span></td>'
cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + cUm + '</font></span></td>'
cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + str(cQuant) + '</font></span></td>'
cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + cDescri + '</font></span></td>'
cHtml += '<td class="txt006"><span class="style1"><font color="#666666">' + str(cPreco) + '</font></span></td>'
cHtml += '</tr>*/

Return
