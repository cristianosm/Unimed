Local oWSDL
Local lOk, cResp, aElem, nPos

oWSDL := tWSDLManager():New()

// Seta o modo de trabalho da classe para "verbose"
oWSDL:lVerbose := .T.

// Primeiro faz o parser do WSDL a partir da URL
lOk := oWsdl:ParseURL( "http://www.webservicex.net/CurrencyConvertor.asmx?WSDL" )
if !lOk
 MsgStop( oWsdl:cError , "ParseURL() ERROR")
 Return
endif

// Seta a operação a ser utilizada
lOk := oWsdl:SetOperation( "ConversionRate" )
if !lOk
 MsgStop( oWsdl:cError , "SetOperation(ConversionRate) ERROR")
 Return
endif

// Setar um valor para conversão

lOk := oWsdl:SetFirst('FromCurrency','BRL')
if !lOk
 MsgStop( oWsdl:cError , "SetFirst(FromCurrency) ERROR")
 Return
endif

lOk := oWsdl:SetFirst('ToCurrency','USD')
if !lOk
 MsgStop( oWsdl:cError , "SetFirst (ToCurrency) ERROR")
 Return
endif/

// Faz a requisição ao WebService
lOk := oWsdl:SendSoapMsg()
if !lOk
 MsgStop( oWsdl:cError , "SendSoapMsg() ERROR")
 Return
endif

// Recupera os elementos de retorno, já parseados
cResp := oWsdl:GetParsedResponse()

// Monta um array com a resposta parseada, considerando
// as quebras de linha ( LF == Chr(10) )
aElem := StrTokArr(cResp,chr(10))

nPos := ascan(aElem,{|x| left(x,21) == 'ConversionRateResult:'})
If nPos > 0
 nFator := val( substr(aElem[nPos],22) )
 MsgStop("Fator de conversão: "+cValToChar(nFator),"Requisição Ok")
 MsgStop("Por exemplo, 100 reais compram "+cValToChar(100 * nFator )+" Dólares Americanos.")
Else
 MsgStop("Resposta não encontrada ou inválida.")
Endif

Return