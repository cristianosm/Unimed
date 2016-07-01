#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "TRYEXCEPTION.CH"

/*/
WebService:	TblViewSample
Autor: 		Marinaldo de Jesus
Data: 		25/06/2011
Descricao:	Exemplo de Uso da Estrutura de WS TableView
Uso: 		WebServices
/*/

WSSERVICE TblViewSample DESCRIPTION "Exemplode Uso da Estrutura TableView" NAMESPACE "http://172.22.0.185:81/ws/"

	WSDATA Table	AS TableView
	WSDATA Alias	AS STRING
	WSDATA rInit	AS INTEGER
	WSDATA rEnd		AS INTEGER

	WSMETHOD GET 	DESCRIPTION "Exemplo de Uso da TableView: Get"

ENDWSSERVICE

/*/
WsMethod:	GET
Autor: 		Marinaldo de Jesus
Data: 		25/06/2011
Descricao:	Obtendo informacoes de uma tabela usando TableView
Uso: 		WebServices
/*/
WSMETHOD GET WSRECEIVE Alias , rInit , rEnd WSSEND Table WSSERVICE TblViewSample

	Local adbStruct

	Local cValue
	Local cDBSType

	Local lWsMethodRet		:= .T.

	Local nItem
	Local nRecno
	Local nField
	Local nFields

	Local oException

	Local uValue

	TRYEXCEPTION

	Self:Alias		:= Upper( Self:Alias )
	DEFAULT Alias	:= Self:Alias

	IF !ChkFile( Self:Alias )
		ExUserException( "Problema na abertura da Tabela: " + Self:Alias )
	EndIF

	Self:Table				:= WsClassNew( "TableView" )
	Self:Table:TableStruct	:= {}

	adbStruct				:= ( Self:Alias )->( dbStruct() )
	nFields					:= Len( adbStruct )

	For nField := 1 To nFields
		aAdd( Self:Table:TableStruct , WsClassNew( "FieldStruct" ) )
		Self:Table:TableStruct[ nField ]:FldName := adbStruct[ nField ][ DBS_NAME ]
		Self:Table:TableStruct[ nField ]:FldType := adbStruct[ nField ][ DBS_TYPE ]
		Self:Table:TableStruct[ nField ]:FldSize := adbStruct[ nField ][ DBS_LEN  ]
		Self:Table:TableStruct[ nField ]:FldDec  := adbStruct[ nField ][ DBS_DEC  ]
	Next nField

	Self:Table:TableData	:= {}

	nItem	:= 0

	For nRecno := Self:rInit To Self:rEnd
		( Self:Alias )->( dbGoto( nRecno ) )
		IF ( Self:Alias )->( Eof() .or. Bof() )
			Loop
		EndIF
		aAdd( Self:Table:TableData , WsClassNew( "FieldView" ) )
		++nItem
		Self:Table:TableData[ nItem ]:FldTag	:= Array( nFields )
		For nField := 1 To nFields
			cDBSType	:= adbStruct[ nField ][ DBS_TYPE ]
			uValue		:= ( Self:Alias )->( FieldGet( nField ) )
			Do Case
				Case ( cDBSType == "N" )
				cValue	:= Str( uValue , adbStruct[ nField ][ DBS_LEN ] , adbStruct[ nField , DBS_DEC ] )
				Case ( cDBSType == "D" )
				cValue	:= Dtos( uValue )
				Case ( cDBSType == "L" )
				cValue	:= IF( uValue , ".T." , ".F." )
				OtherWise
				cValue	:= uValue
			EndCase
			Self:Table:TableData[ nItem ]:FldTag[ nField ] := AllTrim( cValue )
		Next nField
	Next nLoop

	IF ( nItem == 0 )
		ExUserException( "Nao Existem Registros a Serem Apresentados para a Tabela: " + Self:Alias )
	EndIF

	CATCHEXCEPTION USING oException

	lWsMethodRet	:= .F.

	SetSoapFault( ProcName() , oException:Description )

	ENDEXCEPTION

Return( lWsMethodRet )