#include "protheus.ch"
 
//------------------------------------------------------------
/*/{Protheus.doc} TIUSR001
ATUALIZAÇÃO DO CAMPO USR_CARGO ATRAVÉS DE ARQUIVO CSV UTILIZANDO COMO FILTRO O CAMPO USR_ID
@author Thiago Vitor
@since 13/11/2018
@version 1.0
/*/
//------------------------------------------------------------
 
User Function TGCTU001()
 
Local cArq    := ""
Local cLinha  := "" // coloca os dados em uma única linha separado por ";"
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {} //recebe os dados do CSV
Local cDir	  := ""
Local cTitulo := ""
Local aSay    := {}
Local aButton := {}
Local cDesc1  := "Rotina para atualização de usuários através de importação CSV."
Local cDesc2  := "É obrigatório escolher o arquivo no botão [Parametros]."
Local i

//variáveis novas para update
//Local cDBOra  	:= "ORACLE/DEV13TOTVS12" // alterar o alias/dsn para o banco/conexão que está utilizando
//Local cSrvOra  	:= "172.24.28.191" // alterar para o ip do DbAccess
//Local nHwnd 	:= TCLink(cDBOra, cSrvOra, 7901)

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )

aAdd( aButton, { 5, .T., {|| cArq := SelArq()    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

FormBatch( cTitulo, aSay, aButton )
 
If !File(cDir+cArq)
	MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. Importação abortada","[TIUSR001] - ATENCAO")
	Return
EndIf
 
FT_FUSE(cDir+cArq) 			//Abre e fecha um arquivo texto para disponibilizar às funções FT_F
ProcRegua(FT_FLASTREC())    //FT_FLASTREC - Lê e retorna o número total de linhas do arquivo texto aberto pela função FT_FUse()
						    //ProcRegua - utilizada para definir o valor máximo da régua de progressão criada através da função Processa()
FT_FGOTOP() 				//Posiciona no início (primeiro caracter da primeira linha) do arquivo texto aberto pela função FT_FUse()
While !FT_FEOF() 			//Enquanto o ponteiro não está posicionado no fim do arquivo texto
 
	IncProc("Lendo arquivo texto...") //é utilizada para incrementar valores na régua de progressão, criada através da função ProcRegua()
 
	cLinha := FT_FREADLN() //Lê e retorna uma linha de texto do arquivo aberto pela função FT_FUse(). As linhas do texto, são delimitadas pela sequência de caracteres
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP() //Move o ponteiro, do arquivo texto aberto pela função FT_FUse(), para uma nova posição
EndDo

	ProcRegua(Len(aDados))
			IncProc("Importando dados...") 
	 
//TESTE DE CONEXÃO COM O BANCO
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
	
	//VERIFICAÇÃO DO UPDATE
	 if (nStatus < 0)
    conout("TCSQLError() " + TCSQLError())
	  endif 
		
	Next i

//TCUnlink() 

ApMsgInfo("Importação concluída com sucesso!","[TIUSR001] - AVISO")
 
//ELSE

//ALERT("CONEXÃO COM O BANCO FALHOU") 

//endif
 
Return

Static Function SelArq()

Private _cExtens := "Separado por ponto e vírgula (*.CSV) |*.CSV|"
Return AllTrim(cGetFile(_cExtens,"Selecione o Arquivo",,,.F.,GETF_NETWORKDRIVE+GETF_LOCALFLOPPY+GETF_LOCALHARD))
