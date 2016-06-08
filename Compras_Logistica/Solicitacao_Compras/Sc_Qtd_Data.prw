#include 'protheus.ch'
#include 'parmtype.ch'


/*/
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : Mt110Tel   | AUTOR : Cristiano Machado  | DATA : 14/12/2015    **
**---------------------------------------------------------------------------**
** DESCRICAO:    Este ponto tem a finalidade de manipular o cabecalho da     **
**          : Solicitao de Compras permitindo a inclusco e alteracco de      **
**          : campos.                                                        **
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
User function Sc_Qtd_Data()
*******************************************************************************
Local nQtdRet := 0
//Valida se esta Posicionado na Solicitacccco de Compras...


If Valida()

	TelaQtdData()

EndIf

Return(nQtdRet)
*******************************************************************************
Static Function Valida() //| Valida |
*******************************************************************************
Local lReturn 		:= .F.

Local bVProd	:= 0
local bVCamp	:= 0



	If __ReadVar == "M->C1_QUANT" .And. xFilial("SC1") == "  "

		lReturn := .T.

	EndIf

Return(lReturn)
*******************************************************************************
Static Function TelaQtdData()
*******************************************************************************

    Local aACampos  	:= { {"C1_QUANT"},{"C1_DATPRF"} } //Variavel contendo o campo editavel no Grid
    Local aBotoes		:= {}         //Variavel onde sera incluido o botao para a legenda

    Local  aHeader  	:= {}         //Variavel que montara o aHeader do grid

    Private oLista                    //Declarando o objeto do browser
    Private aColsEx 	:= {}         //Variavel que recebera os dados

    //Declarando os objetos de cores para usar na coluna de status do grid
    //Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
    //Private oAzul  	:= LoadBitmap( GetResources(), "BR_AZUL")
    //Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
    //Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")

    DEFINE MSDIALOG oDlg TITLE "TITULO" FROM 000, 000  TO 300, 700  PIXEL

        //chamar a funcao que cria a estrutura do aHeader
        CriaCabec(@aHeader)

        //Monta o browser com inclusao, remocao e atualizacao
        oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,0, 100, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aColsEx)

        //Carregar os itens que irao compor o conteudo do grid
        //Carregar()

        //Alinho o grid para ocupar todo o meu formulario
        oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

       // Ao abrir a janela o cursor esta posicionado no meu objeto
        oLista:oBrowse:SetFocus()

        //Crio o menu que ira aparece no botao Acoes relacionadas
        aadd(aBotoes,{"NG_ICO_LEGENDA", {||Alert("Legenda")},"Legenda","Legenda"})

        EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBotoes)

    ACTIVATE MSDIALOG oDlg CENTERED

Return
*******************************************************************************
Static Function CriaCabec(aHeader)
*******************************************************************************

   Aadd(aHeader, {;
                  "Quantidade",			; // X3Titulo()
                  "C1_QUANT",			; // X3_CAMPO
                  "@E 999999999.9999",	; // X3_PICTURE
                  12,					; // X3_TAMANHO
                  2,					; // X3_DECIMAL
                  ".T.",				; // X3_VALID
                  "",					; // X3_USADO
                  "N",					; // X3_TIPO
                  "",					; // X3_F3
                  "R",					; // X3_CONTEXT
                  "",					; // X3_CBOX
                  "",					; // X3_RELACAO
                  "",					; // X3_WHEN
                  "V"})			  //


   Aadd(aHeader, {;
                  "Necessidade",	; // X3Titulo()
                  "C1_DATPRF",	; // X3_CAMPO
                  "",			; // X3_PICTURE
                  8,			; // X3_TAMANHO
                  0,			; // X3_DECIMAL
                  ".T.",		; // X3_VALID
                  "",			; // X3_USADO
                  "D",			; // X3_TIPO
                  "",			; // X3_F3
                  "R",			; // X3_CONTEXT
                  "",			; // X3_CBOX
                  "",			; // X3_RELACAO
                  "",			; // X3_WHEN
                  "V"})			  //

Return()
