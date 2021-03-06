#include "protheus.ch"
 
//------------------------------------------------------------
/*/{Protheus.doc} TIUSR001
ATUALIZA��O DO CAMPO USR_CARGO ATRAV�S DE ARQUIVO CSV UTILIZANDO COMO FILTRO O CAMPO USR_ID
@author Thiago Vitor
@since 13/11/2018
@version 1.0
/*/
//------------------------------------------------------------
 
User Function TGCTU001()
 
Local cArq    := ""
Local cLinha  := "" // coloca os dados em uma �nica linha separado por ";"
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {} //recebe os dados do CSV
Local cDir	  := ""
Local cTitulo := ""
Local aSay    := {}
Local aButton := {}
Local cDesc1  := "Rotina para atualiza��o de usu�rios atrav�s de importa��o CSV."
Local cDesc2  := "� obrigat�rio escolher o arquivo no bot�o [Parametros]."
Local i

//vari�veis novas para update
//Local cDBOra  	:= "ORACLE/DEV13TOTVS12" // alterar o alias/dsn para o banco/conex�o que est� utilizando
//Local cSrvOra  	:= "172.24.28.191" // alterar para o ip do DbAccess
//Local nHwnd 	:= TCLink(cDBOra, cSrvOra, 7901)

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )

aAdd( aButton, { 5, .T., {|| cArq := SelArq()    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

FormBatch( cTitulo, aSay, aButton )
 
If !File(cDir+cArq)
	MsgStop("O arquivo " +cDir+cArq + " n�o foi encontrado. Importa��o abortada","[TIUSR001] - ATENCAO")
	Return
EndIf
 
FT_FUSE(cDir+cArq) 			//Abre e fecha um arquivo texto para disponibilizar �s fun��es FT_F
ProcRegua(FT_FLASTREC())    //FT_FLASTREC - L� e retorna o n�mero total de linhas do arquivo texto aberto pela fun��o FT_FUse()
						    //ProcRegua - utilizada para definir o valor m�ximo da r�gua de progress�o criada atrav�s da fun��o Processa()
FT_FGOTOP() 				//Posiciona no in�cio (primeiro caracter da primeira linha) do arquivo texto aberto pela fun��o FT_FUse()
While !FT_FEOF() 			//Enquanto o ponteiro n�o est� posicionado no fim do arquivo texto
 
	IncProc("Lendo arquivo texto...") //� utilizada para incrementar valores na r�gua de progress�o, criada atrav�s da fun��o ProcRegua()
 
	cLinha := FT_FREADLN() //L� e retorna uma linha de texto do arquivo aberto pela fun��o FT_FUse(). As linhas do texto, s�o delimitadas pela sequ�ncia de caracteres
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP() //Move o ponteiro, do arquivo texto aberto pela fun��o FT_FUse(), para uma nova posi��o
EndDo

	ProcRegua(Len(aDados))
			IncProc("Importando dados...") 
	 
//TESTE DE CONEX�O COM O BANCO
//  if nHwnd >= 0

//ATUALIZANDO OS REGISTROS
	
	For i:=1 to Len(aDados)
				cUpdate := " UPDATE SYS_USR"   
				cUpdate += " SET "
				cUpdate += "USR_CARGO = '" + aDados[i,2] + "' "
				cUpdate += "WHERE "
				cUpdate += "USR_ID = '" + aDados[i,1] + "' "
				cUpdate += "AND D_E_L_E_T_ = ' ' "
	
	
	nStatus := TCSQLExec( cUpdate )
	
	//VERIFICA��O DO UPDATE
	�if�(nStatus < 0)
����conout("TCSQLError() "�+ TCSQLError())
	��endif 
		
	Next i

//TCUnlink() 

ApMsgInfo("Importa��o conclu�da com sucesso!","[TIUSR001] - AVISO")
 
//ELSE

//ALERT("CONEX�O COM O BANCO FALHOU") 

//endif
 
Return

Static Function SelArq()

Private _cExtens := "Separado por ponto e v�rgula (*.CSV) |*.CSV|"
Return AllTrim(cGetFile(_cExtens,"Selecione o Arquivo",,,.F.,GETF_NETWORKDRIVE+GETF_LOCALFLOPPY+GETF_LOCALHARD))
