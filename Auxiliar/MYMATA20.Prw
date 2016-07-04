#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'TBICONN.CH'
#include "TbiCode.ch"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MYMATA20  ºAutor  ³Julio Jacovenko     º Data ³  12/29/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importação Pedido de Compra via Excel                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMDEPA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function IMDA721()
Public oButton1
Public oButton2
Public oGet1
Public cGet1 := Space(6)
Public oSay1
Public oSay2
Public oSay3
Public oGet2
Public cGet2 := Space(2)               
Public cFornec:=''
PUBLIC AFIL02:={}
PUBLIC AFIL04:={}
PUBLIC AFIL05:={}
PUBLIC AFIL07:={}
PUBLIC AFIL09:={}
PUBLIC AFIL10:={}
PUBLIC AFIL13:={}
PUBLIC LERROVAL:=.F.


Static oDlg

  DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 006, 005 SAY oSay1 PROMPT "Cod. Fornecedor:" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 048, 015 BUTTON oButton1 PROMPT "Importar" SIZE 037, 012 OF oDlg ACTION fImpDoc() PIXEL
    @ 005, 055 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg VALID ((!EMPTY(cget1) .or. EXISTCPO("SA2",cGet1,1)) .AND. FVALID(CGET1))  COLORS 0, 16777215 F3 "SA2" PIXEL
    @ 045, 177 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlg ACTION (oDLG:END())  PIXEL
    @ 006, 121 SAY oSay2 PROMPT "Loja:" SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 141 MSGET oGet2 VAR cGet2 SIZE 021, 010 OF oDlg  COLORS 0, 16777215 READONLY PIXEL
    @ 023, 005 SAY oSay3 PROMPT cFornec SIZE 239, 007 OF oDlg COLORS 0, 16777215 PIXEL
   //VALID (EMPTY(C_CLIENTE) .or. EXISTCPO("SA1",C_CLIENTE+C_LOJA,1))
   //Valid(LastKey()=13)
   
  ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)                                         



//valida entrada do codigo de fornecedor
Static Function fValid(cCod)
Local lret  := .F.
Local cLoja:=''   
IF EXISTCPO("SA2",cCod,1)
    cGet2:=SA2->A2_LOJA
    cFornec:=SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME
	@ 005, 141 MSGET oGet2 VAR cGet2 SIZE 021, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 023, 005 SAY oSay3 PROMPT cFornec SIZE 239, 007 OF oDlg COLORS 0, 16777215 PIXEL
	oGet2:Refresh()
	oSay3:Refresh()
	oButton1:SetFocus()
	oDlg:Refresh()        
    LRET:=.T.
ENDIF   

Return lret


//processa importacao do pedido de compra
Static Function fimpdoc()    
Local oProcess
Private oObj
	IF EXISTCPO("SA2",cGet1,1)
	   //TOCA A FICHA  
   		oProcess := MsNewProcess():New({|lEnd|CriaSC7(oProcess,cGet1+cGet2)},"Geração de Pedidos Compra","",.F.)
		oProcess:Activate()
		IF LERROVAL
		    MsgInfo("Foram encontrados valores zerados.Verifique o Pedido!","PROCESSO CONCLUÍDO!")
		ELSE
        	MsgInfo("Operação Realizada com Sucesso.","PROCESSO CONCLUÍDO!")
        ENDIF
       // LERRO:=CRIASC7(oObj,cGet1+cGet2)
       //StartJob("U_FEXECAUTO",GetEnvServer(),.T.,"01","02",CGET1+CGET2)
       //ODLG:END()
       //ALERT("TERMINOU IMPORTACAO DE PEDIDOS...")
	ELSE
	   RETURN   
	ENDIF
Return

//sai da importacao do pedido de compra
Static Function fsai()

Return




///exemplo dois
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para a criacao do pedido de compra via msexecauto no º±±
±±º          ³sistema.                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------*
Static Function CRIASC7(oObj,cFornec)
*-----------------------------------*
** Declara variaveis. ***/
Local aCab         := {}
Local aItens         := {}       
Local cFornecedor := ""
Local cNumPc := ""
Local cLoja       := ""
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private aPlanilha := {}
Private AARRAY:={}
                       
//ALERT('...CHEGOU AQUI...')


//RpcSetType(3)
//RpcSetEnv(_cEmpAtu,_cFilA,,,"COM")


SA2->(DbSetOrder(3))
// A2_FILIAL, A2_CGC
SA2->(DbSeek(xFilial("SA2")+cFornec)) 
cFornecedor := SUBSTR(cFornec,1,6)
cLoja       := SUBSTR(cFornec,7,2)


///LOOP PARA CADA FILIAL
///aqui começa a ler o arquivo excel....
LRET:=.T.
aPlanilha:=FleArquivo()

LERRO:=.F.

_cFilial:=XFILIAL('SC7')
//ALERT("VAI LER A FILIAL "+_cFilial)

IF _CFILIAL='02'
   //ACOPY(AFIL02,AARRAY)
   AARRAY:=ACLONE(AFIL02)
ELSEIF _CFILIAL='04'
   //ACOPY(AFIL04,AARRAY) 
   AARRAY:=ACLONE(AFIL04)
ELSEIF _CFILIAL='05'
   //ACOPY(AFIL05,AARRAY)
   AARRAY:=ACLONE(AFIL05)
ELSEIF _CFILIAL='07'
   //ACOPY(AFIL07,AARRAY)
   AARRAY:=ACLONE(AFIL07)
ELSEIF _CFILIAL='09'
   //ACOPY(AFIL04,AARRAY)
   AARRAY:=ACLONE(AFIL09)   
ELSEIF _CFILIAL='10'
   //ACOPY(AFIL04,AARRAY)
   AARRAY:=ACLONE(AFIL10)   
ELSEIF _CFILIAL='13'
   //ACOPY(AFIL13,AARRAY) 
   AARRAY:=ACLONE(AFIL13)
ENDIF            


oObj:SETREGUA1(0)      


IF LEN(AARRAY)>=1



//cEmpAnt (empresa)
//cFilAnt (filial)                

//RpcSetType(3)
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "COM"

//cNumero :=GetSXENum("SC7","C7_NUM")
//cCond   := Posicione("SA2",1,xFilial("SA2")+cFornecedor+cLoja,"A2_COND")

FOR NF:=1 TO LEN(AARRAY)
oObj:IncRegua1('AGUARDE! Gerando Pedido ...')
        nPreco:=JImdF160(cFornecedor,cLoja,AARRAY[NF][04])  

        if Npreco=0
           Npreco=0.01 
           LERROVAL:=.T.
        endif
        cItem:=STRZERO(NF,4)
		aadd(aItens,{{"C7_ITEM"	,cItem          ,Nil},; //Numero do Item
		{"C7_PRODUTO"			,AARRAY[NF][04]	,Nil},; //Codigo do Produto
    	{"C7_UM"     			,AARRAY[NF][05]	,Nil},; //Unidade de Medida AARRAY[NF][05]
		{"C7_QUANT"  			,AARRAY[NF][07] ,Nil},; //Quantidade
		{"C7_NUMSC"             ,AARRAY[NF][01] ,Nil},; //Numero da Solicitacao de compra
	    {"C7_ITEMSC"            ,AARRAY[NF][02] ,Nil},; //Item da Solicitacao de compra  AARRAY[NF][01]
	    {"C7_QTDSOL"            ,AARRAY[NF][07] ,Nil},; //06 Qtd da Solicitacao de compra, TEM QUE SER = QTDPED 
        {"C7_PRECO"  			,nPreco			,Nil},; //Preco
		{"C7_DATPRF" 			,AARRAY[NF][03]	,Nil},; //Data De Entrega
		{"C7_FLUXO"  			,"S"		 	,Nil}}) //Fluxo de Caixa (S/N) 
	
		//{"C7_LOCAL"  			,SB1->B1_LOCPAD	,Nil}}) //Localizacao
NEXT //PARA OS ITENS DA FILIAL 02

	//{"C7_ITEMSC"            ,AFIL02[NF][01] ,Nil},; //Item da Solicitacao de compra 
	//{"C7_QTDSOL"            ,AFIL02[NF][08] ,Nil},; //Qtd da Solicitacao de compra, TEM QUE SER = QTDPED 
    //{"C7_PRECO"  			,122.00			,Nil},; //Preco



cNumero :=GetSXENum("SC7","C7_NUM")
//ConfirmSX8()

/*    
    dbSelectArea("SC7")
	dbSetOrder(1)
	MsSeek(xFilial("SC7")+"zzzzzz",.T.)
	dbSkip(-1)
	cNumero := SC7->C7_NUM
	If Empty(cNumero)
		cNumero := StrZero(1,Len(SC7->C7_NUM))
	Else
		cNumero := Soma1(cNumero)
	EndIf
*/



	//cCond   := Posicione("SA2",1,xFilial("SA2")+cFornecedor+cLoja,"A2_COND")
	cCond   := '001'
	aCab:={{"C7_NUM"	,cNumero  	    	,Nil},; // Numero do Pedido
	{"C7_EMISSAO" 		,dDataBase  	    ,Nil},; // Data de Emissao
	{"C7_FORNECE" 		,cFornecedor     	,Nil},; // Fornecedor
	{"C7_LOJA"    		,cLoja	         	,Nil},; // Loja do Fornecedor
	{"C7_COND"    		,cCond		     	,Nil},; // Condicao de pagamento
	{"C7_CONTATO" 		,"               "	,Nil},; // Contato
	{"C7_FILENT"  		," "				,Nil}} // Filial Entrega
                               
lMsErroAuto := .F.                    

MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,aItens,3) //inclusao

//RPCSetEnv('01','02')
//StartJob("LjGrvBatch",GetEnvServer(),.F.,"01","01")
          
LERRO:=.F.
If lMsErroAuto
     Alert("Erro ao cadastrar pedido para filal "+_cFilial)
     //lErro := .T.
     RollBackSx8()
     MostraErro()
ELSE  
   ConfirmSX8()
   ALERT("Incluido com sucesso! Na Filial: "+_cFilial+" Pedido n: "+cNumero)    
   LERRO:=.F.
EndIf


ENDIF

///FIM DA FILIAL02

//RESET ENVIRONMENT               
Return LERRO




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  *FleArquivo  ºAutor  ³JJacovenko        º Data ³  01/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Le dados da Planilha e processa para a Base de Dados        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMDEPA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FleArquivo()
Local aPlanilha:={}
      ARQUIVO()
Return aPlanilha



/////////////////////////apartir daqui importa a planilha...

*********************************************************************
STATIC FUNCTION ARQUIVO()
*********************************************************************
PRIVATE CALIAS  	:= ALIAS()
PRIVATE CINDEXORD	:= INDEXORD()
PRIVATE CRECNO		:= RECNO()

PRIVATE NORDSB1	:= SB1->( INDEXORD() )
PRIVATE NRECSB1 := SB1->( RECNO() )
SB1->( DBSETORDER( 1 ) )

PRIVATE NORDSB2	:= SB2->( INDEXORD() )
PRIVATE NRECSB2 := SB2->( RECNO() )
SB2->( DBSETORDER( 1 ) )

//CONVARQ()

CTIPO := ""
CTIPO := CTIPO + "ARQUIVOS DE DADOS (*.CSV)  | *.CSV | "
CFILE := CGETFILE( CTIPO , "DIALOGO DE SELECAO DE ARQUIVOS /.CSV",,"C:\EXCEL") //,,GETF_MULTISELECT+GETF_LOCALHARD+GETF_NETWORKDRIVE ) //,.T.,GETF_NOCHANGEDIR+GETF_NETWORKDRIVE)//GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
CARQ  := ALLTRIM(CFILE)
               
IF !EMPTY(CARQ)
	PROCESSA( {|| CONVARQ() } , "MONTANDO TABELA TEMPORARIA" 		, "LENDO PLANILHA ... /AGUARDE... ", .T. )
	PROCESSA( {|| MIGRA() }   , "PREPARANDO FILIAIS" 	, "PREPARANDO FILIAIS ... /AGUARDE...  ", .T. )
ENDIF

DBSELECTAREA("SB1")
DBSETORDER(NORDSB1)
DBGOTO(NRECSB1)

DBSELECTAREA("SB2")
DBSETORDER(NORDSB2)
DBGOTO(NRECSB2)

DBSELECTAREA(CALIAS)
DBSETORDER(CINDEXORD)
DBGOTO(CRECNO)

RETURN()

*********************************************************************
STATIC FUNCTION CONVARQ()
*********************************************************************
//PRIVATE	CPATH 	:= "C:\EXCEL\PEDIDO.csv" 
PRIVATE	CPATH 	:= CARQ
PRIVATE ASTRU 	:= {}
PRIVATE NDEL 	:= 0
PRIVATE lPrim   := .F.
PRIVATE aDados  := {}
PRIVATE nCols   := 0
PRIVATE cCab    :=''
PRIVATE PUsaCab :=.F.
PRIVATE aCSV    := {}
PRIVATE I       := 0


IF !FILE(CPATH)
	ALERT("O Arquivo " + CPATH + " não existe !!!")
    RETURN()
ENDIF	

///CRIAMOS DBF PARA SER ALIMENTADO PELO ARQUIVO CSV
AADD(ASTRU,{"NUMSC"   , "C",06,00})
AADD(ASTRU,{"ITEMSC"  , "C",04,00})
AADD(ASTRU,{"PRODUTO" , "C",08,00})
AADD(ASTRU,{"UN"      , "C",02,00})
AADD(ASTRU,{"DATASOL" , "D",08,00})
AADD(ASTRU,{"QTDFIL02", "N",14,02})
AADD(ASTRU,{"QTDFIL04", "N",14,02})
AADD(ASTRU,{"QTDFIL05", "N",14,02})
AADD(ASTRU,{"QTDFIL07", "N",14,02})
AADD(ASTRU,{"QTDFIL09", "N",14,02})
AADD(ASTRU,{"QTDFIL10", "N",14,02})  
AADD(ASTRU,{"QTDFIL13", "N",14,02})
AADD(ASTRU,{"TOTALFIL", "N",14,02})
AADD(ASTRU,{"QUANTSOL", "N",14,02})

CARQ := CRIATRAB(ASTRU,.T.)

USE &CARQ EXCLUSIVE ALIAS TRAB NEW
INDEX ON  PRODUTO TAG 1 TO &CARQ

//ABRI ARQUIVO TEXTO
FT_FUSE(CPATH)
//PULA P/ LINHA 1
FT_FGOTOP()
                        


    aDados := {} //Array(0,16)

   //agora vamos alimentar o array
    FT_FGOTOP()          
    WHILE !FT_FEOF()//ENQUANTO NAO FOR O FIM DO ARQUIVO TEXTO
	
	CLINHA 	:= FT_FREADLN()//LE A LINHA DO ARQUIVO

 	IIF(AT(",",CLINHA) > 0, NDEL := AT(",",CLINHA), NDEL := AT(";",CLINHA) )	

	IF 	VAL(SUBSTR(CLINHA,NDEL+1,LEN(CLINHA))) > 0 .OR. !empty(STRZERO(VAL(SUBSTR(CLINHA,001,NDEL-1)),8))
			If lPrim
				aCampos := Separa(cLinha,";",.T.) //CABECALHO SE HOUVER
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf                                  
	ENDIF 
	
	FT_FSKIP()//PULA UMA LINHA NO ARQUIVO
	
    ENDDO 

FOR X:=1 TO LEN(ADADOS)

    //PARA PEGAR CORRETAMENTE OS DADOS DA SOLICITACAO
    //SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,C1_QUANT,C1_DATPRF,C1_LOCAL FROM SC1010
    //WHERE C1_NUM='163216' AND C1_PRODUTO='00052527'
    CQUERY:="SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,C1_QUANT,C1_DATPRF,C1_LOCAL FROM "+RetSqlName("SC1")+" "
    CQUERY+="WHERE C1_NUM='"+STRZERO(VAL(ADADOS[X][1]),6)+"' AND C1_PRODUTO='"+STRZERO(VAL(ADADOS[X][2]),8)+"' "
    CQUERY+="AND D_E_L_E_T_ =' ' "
    MEMOWRIT("C:\SQLSIGA\SOLSQL.TXT", cQUERY)
    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery NEW ALIAS "SOL"
    
    nQUANT:=0
    DbSelectArea("SOL")
    DbGoTop() 
    cITEMSC:='X'
    aLinha:={}
    Do While !Eof()  
      //TUDO DE SER UM ARRAY
      //AADD(aLinha,{SOL->C1_ITEM,SOL->C1_UM,SOL->C1_QUANT,SOL->C1_DATPRF,SOL->C1_LOCAL})
      cITEMSC :=SOL->C1_ITEM
      cUM     :=SOL->C1_UM
      nQuant  +=SOL->C1_QUANT
      dDataprf:=SOL->C1_DATPRF
      cLocal  :=SOL->C1_LOCAL
      SOL->(DbSkip())
    End
    DbCloseArea('SOL')
    DbSelectArea('TRAB')
        
        IF cITEMSC<>'X'
        //IF LEN(aLinha)>=1 
        //FOR XY:=1 TO LEN(aLinha)  
		RECLOCK("TRAB",.T.)  
		TRAB->DATASOL   := stod(dDataPrf)
		TRAB->ITEMSC 	:= cITEMSC //STRZERO(VAL(ADADOS[X][1]),4) 
		TRAB->NUMSC 	:= STRZERO(VAL(ADADOS[X][01]),6)
		TRAB->PRODUTO   := STRZERO(VAL(ADADOS[X][02]),8)
		TRAB->UN        := cUM //ADADOS[X][5]
		TRAB->QUANTSOL  := nQuant //VAL(ADADOS[X][6])
		TRAB->QTDFIL02  := VAL(ADADOS[X][03])
		TRAB->QTDFIL04  := VAL(ADADOS[X][04])		
		TRAB->QTDFIL05  := VAL(ADADOS[X][05])
		TRAB->QTDFIL07  := VAL(ADADOS[X][06])
		TRAB->QTDFIL09  := VAL(ADADOS[X][07])
		TRAB->QTDFIL10  := VAL(ADADOS[X][08])
		TRAB->QTDFIL13  := VAL(ADADOS[X][09])
 	    TRAB->TOTALFIL  := VAL(ADADOS[X][10])
 	    
		MSUNLOCK()             
		//NEXT //LEN(ALINHA)
		
		ENDIF            

NEXT


DBSELECTAREA("TRAB")
DBCLOSEAREA()

RETURN()

*********************************************************************
STATIC FUNCTION MIGRA()
*********************************************************************
LOCAL NREG  	:= 0
LOCAL NPRECO	:= 0
LOCAL NCOUNT  	:= 0
LOCAL LPOS  	:= .T.

IF EMPTY(CARQ)
	ALERT("SELECIONE UM ARQUIVO !!")
	RETURN()
ELSE

	
	USE &CARQ ALIAS TRB NEW
	CID       := RETCODUSR()
	CSOLICIT  := SUBSTR(CUSUARIO,7,14)
	                        
	
	TRB->(PROCREGUA(LASTREC()))
	TRB->(DBGOTOP())
	COPY TO '\data\teste.dtc'
    //ALERT('VAI ENTRAR NO EOF')
    DBSELECTAREA('TRB')
    DBGOTOP()
 
 DO WHILE !EOF()
    //ALIMENTA ARRAYS  

    IF TRB->QTDFIL02<>0 
       AADD(AFIL02,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,; 
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL02})
    ENDIF                
    IF TRB->QTDFIL04<>0
       AADD(AFIL04,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL04})
    ENDIF
    IF TRB->QTDFIL05<>0
       AADD(AFIL05,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL05})
    ENDIF
    IF TRB->QTDFIL07<>0     
       AADD(AFIL07,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL07})
    ENDIF
    IF TRB->QTDFIL09<>0
       AADD(AFIL09,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL09})
    ENDIF                            
    IF TRB->QTDFIL10<>0
       AADD(AFIL10,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL10})
    ENDIF                            
    IF TRB->QTDFIL13<>0
       AADD(AFIL13,{TRB->NUMSC  ,;
                    TRB->ITEMSC ,;
                    TRB->DATASOL,;
                    TRB->PRODUTO,;
                    TRB->UN,;
                    TRB->QUANTSOL,;
                    TRB->QTDFIL13})
    ENDIF
    TRB->(DBSKIP())                
 ENDDO	
ENDIF

TRB->(DBCLOSEAREA())

RETURN()



Static Function JImdF160(cForn,cLoja,cProduto)

Local cImdepa := GetMV('MV_IMDEPA')
Local lReturn := .t.
Local nOrd_SZ5, nRec_SZ5, nOrd_SZ6, nRec_SZ6, nOrd_SZY, nRec_SZY, nPreco
Local nPreco:=0
Local nMoedaPed:=1

If cImdepa <> cFORN
	nOrd_SZ5 := SZ5->( IndexOrd() )
	nRec_SZ5 := SZ5->( RecNo() )
	
	nOrd_SZ6 := SZ6->( IndexOrd() )
	nRec_SZ6 := SZ6->( RecNo() )
	
	nOrd_SZY := SZY->( IndexOrd() )
	nRec_SZY := SZY->( RecNo() )
	
	SZY->( dbSetOrder( 1 ) )
	SZ6->( dbSetOrder( 1 ) )
	SZ5->( dbSetOrder( 2 ) )
	
	SZ5->( dbSeek( xFilial( 'SZ5' ) + 'S' + cForn, .f. ) )
	
	// pesquisa todas as tabelas ativas do fornecedor...
	Do While SZ5->( !eof() ) .and. SZ5->Z5_FILIAL  == xFilial( 'SZ5' ) ;
		.and. SZ5->Z5_ATIVO   == 'S' ;
		.and. SZ5->Z5_FORNECE == cForn
		
		If !Empty( SZ5->Z5_LOJA ) .and. SZ5->Z5_LOJA <> cLoja
			
			SZ5->( dbSkip() )
			Loop
		EndIf
		
		// analisa o produto em questao...
		If SZ6->( dbSeek( xFilial( 'SZ6' ) + SZ5->Z5_CODTAB + cProduto, .f. ) )
			
					
			If SimbToMoeda( SZ6->Z6_MOEDA ) <> nMoedaPed
			
				
				// converter moeda( preco moeda tab, converte moeda tab p/num, num moeda pedido, data )
				nPreco := xMoeda( SZ6->Z6_PRECO, SimbToMoeda( SZ6->Z6_MOEDA ), nMoedaPed, dDataBase ) 
			Else
				nPreco := SZ6->Z6_PRECO
			EndIf
			// aplica desconto da tabela...
			//nPreco := nPreco * ( 1 - ( SZ5->Z5_DESCON / 100 ) )
			nPreco := Round( nPreco * ( 1 - ( SZ5->Z5_DESCON / 100 ) ), SZ5->Z5_NUMDEC )
			// aplica desconto por filial...
			If SZY->( dbSeek( xFilial( 'SZY' ) + SZ5->Z5_CODTAB + cFilAnt, .f. ) )
				nPreco := Round( nPreco * ( 1 - ( SZY->ZY_DESCON / 100 ) ), SZ5->Z5_NUMDEC )
			EndIf
			Exit
		EndIf
		
		SZ5->( dbSkip() )
	EndDo
	
	SZY->( dbSetOrder( nOrd_SZY ) )
	SZY->( dbGoTo( nRec_SZY ) )
	
	SZ6->( dbSetOrder( nOrd_SZ6 ) )
	SZ6->( dbGoTo( nRec_SZ6 ) )
	
	SZ5->( dbSetOrder( nOrd_SZ5 ) )
	SZ5->( dbGoTo( nRec_SZ5 ) )
EndIf

Return nPreco


USER FUNCTION FEXECAUTO(_cEmpAtu,_cFilAt,CFORNEC)
Local aCab         := {}
Local aItens         := {}       
Local cFornecedor := ""
Local cNumPc := ""
Local cLoja       := ""
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private aPlanilha := {}
                       
//ALERT('...CHEGOU AQUI...')
RpcSetType(3)
RpcSetEnv(_cEmpAtu,_cFilA,,,"COM")


SA2->(DbSetOrder(3))
// A2_FILIAL, A2_CGC
SA2->(DbSeek(xFilial("SA2")+cFornec)) 
cFornecedor := SUBSTR(cFornec,1,6)
cLoja       := SUBSTR(cFornec,7,2)


///LOOP PARA CADA FILIAL
///aqui começa a ler o arquivo excel....
LRET:=.T.
aPlanilha:=FleArquivo()

//PRIMEIRA VE DADOS PARA FILIAL 02 - AFIL02

LERRO:=.F.

IF LEN(AFIL02)>1

//ALERT("VAI LER A FILIAL 02")


//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "COM"
//cNumero :=GetSXENum("SC7","C7_NUM")

	//cCond   := Posicione("SA2",1,xFilial("SA2")+cFornecedor+cLoja,"A2_COND")
	/*
	cCond   := '001'
	aCab:={{"C7_NUM"	,cNumero  	    	,Nil},; // Numero do Pedido
	{"C7_EMISSAO" 		,dDataBase  	    ,Nil},; // Data de Emissao
	{"C7_FORNECE" 		,cFornecedor     	,Nil},; // Fornecedor
	{"C7_LOJA"    		,cLoja	         	,Nil},; // Loja do Fornecedor
	{"C7_COND"    		,cCond		     	,Nil},; // Condicao de pagamento
	{"C7_CONTATO" 		,"               "	,Nil},; // Contato
	{"C7_FILENT"  		," "				,Nil}} // Filial Entrega
    */
//ALERT('VAMO LER '+STR(LEN(AFIL02)))
FOR NF:=1 TO LEN(AFIL02)
        nPreco:=JImdF160(cFornecedor,cLoja,AFIL02[NF][03])  
        
        if Npreco=0
           Npreco=0.01
        endif
        cItem:=STRZERO(NF,4)
		aadd(aItens,{{"C7_ITEM"	,cItem          ,Nil},; //Numero do Item
		{"C7_PRODUTO"			,AFIL02[NF][03]	,Nil},; //Codigo do Produto
    	{"C7_UM"     			,AFIL02[NF][05]	,Nil},; //Unidade de Medida
		{"C7_QUANT"  			,AFIL02[NF][08] ,Nil},; //Quantidade
		{"C7_NUMSC"             ,AFIL02[NF][02] ,Nil},; //Numero da Solicitacao de compra
	    {"C7_ITEMSC"            ,AFIL02[NF][01] ,Nil},; //Item da Solicitacao de compra 
	    {"C7_QTDSOL"            ,AFIL02[NF][08] ,Nil},; //Qtd da Solicitacao de compra, TEM QUE SER = QTDPED 
        {"C7_PRECO"  			,nPreco			,Nil},; //Preco
		{"C7_DATPRF" 			,dDataBase		,Nil},; //Data De Entrega
		{"C7_FLUXO"  			,"S"		 	,Nil}}) //Fluxo de Caixa (S/N) 
	
		//{"C7_LOCAL"  			,SB1->B1_LOCPAD	,Nil}}) //Localizacao

NEXT //PARA OS ITENS DA FILIAL 02

	//{"C7_ITEMSC"            ,AFIL02[NF][01] ,Nil},; //Item da Solicitacao de compra 
	//{"C7_QTDSOL"            ,AFIL02[NF][08] ,Nil},; //Qtd da Solicitacao de compra, TEM QUE SER = QTDPED 
    //{"C7_PRECO"  			,122.00			,Nil},; //Preco


//ALERT('...VAI ENTRAR NO PREPARE ENVIRONMENT...')  
  
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "COM"
cNumero :=GetSXENum("SC7","C7_NUM")
	//cCond   := Posicione("SA2",1,xFilial("SA2")+cFornecedor+cLoja,"A2_COND")
	cCond   := '001'
	aCab:={{"C7_NUM"	,cNumero  	    	,Nil},; // Numero do Pedido
	{"C7_EMISSAO" 		,dDataBase  	    ,Nil},; // Data de Emissao
	{"C7_FORNECE" 		,cFornecedor     	,Nil},; // Fornecedor
	{"C7_LOJA"    		,cLoja	         	,Nil},; // Loja do Fornecedor
	{"C7_COND"    		,cCond		     	,Nil},; // Condicao de pagamento
	{"C7_CONTATO" 		,"               "	,Nil},; // Contato
	{"C7_FILENT"  		," "				,Nil}} // Filial Entrega
                               
lMsErroAuto := .F.                    

MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,aItens,3) //inclusao

RESET ENVIRONMENT 

//RPCSetEnv('01','02')
//StartJob("LjGrvBatch",GetEnvServer(),.F.,"01","01")
//ALERT('RESETOU O ENVIRONMENT')

//Alert("Gerado Pedido de Compra "+ cNumero,"Incluindo...")     
          
LERRO:=.F.
If lMsErroAuto
     Alert("Erro ao cadastrar pedido")
     lErro := .T.  
     RollBackSx8()
     MostraErro()
ELSE  
   ConfirmSX8()
   ALERT("Incluido com sucesso! Pedido n: "+cNumero)    
   LERRO:=.F.
EndIf


//RESET ENVIRONMENT

ENDIF

///FIM DA FILIAL02

RpcClearEnv()
RETURN NIL

