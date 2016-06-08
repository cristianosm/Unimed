#include 'protheus.ch'
#include 'parmtype.ch'

user function MTA110MNU()

	SetKey( VK_F4, { || U_Sc_Qtd_Data()  } )


	ALERT("PASSOU MTA110MNU...E SETOU F4")

return