#Include "PROTHEUS.CH"

//------------------------------------------------------------
/*/{Protheus.doc} TGCVA100
Rotina de liberação de contratos em lote
@author Thiago Vitor
@since 03/01/2019
@version 1.0
/*/
//------------------------------------------------------------

User function ATGCTPHW()

	Local nCont			:= 0	//Armazena o contador para MsgInfo
	Local aCodUsr		:= {}	//array para o código do usuário
	Local cUser			:= ""	//recebe o nome de usuário
	Local cPerg			:= Padr("ATGCTPHW",10)
	Local cQry			:= ""
	Local cAliasQry		:= GetNextAlias()
	Local cUsr			:= SuperGetMV("AT_USRPHW",,"008464")
	Local cUserName		:= __CUSERID //Recebe o id do usuário logado (variável padrão do sistema)
	
	//Parâmetro para validação de acesso a rotina
	If UPPER(cUserName) $ cUsr

	// -- Pergunta atualização
	putSx1(cPerg,"01","Usuário","Usuário","Usuário","mv_ch1","G",6,0,0,"C","","US2","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")
	
	lContinua 	:= Pergunte(cPerg,.t.)
	
	// -- validação de dados
	If !lContinua .or. (Empty(mv_par01))
		If Empty(mv_par01)
			MsgAlert("Favor informar um usuário válido!","Atenção!")
			Return()
		Else
			MsgAlert("Processo cancelado","Atencão")
			Return()
		EndIf
	EndIf
	
	// -- Carrega variável com o usuário digitado 
	cUser 	:= mv_par01
	
	//Query para localização dos contratos com base no id do usuário
	
	cQry :="SELECT PHW.R_E_C_N_O_ AS PHWREC "
	cQry +="FROM PHW000 PHW "
	cQry +="WHERE PHW_FILIAL =' ' "
	cQry +="AND PHW.D_E_L_E_T_=' ' "
	cQry +="AND PHW.PHW_CUSER = '" + cUser + "' "
	cQry +="AND PHW.PHW_STATUS ='1'"
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
		If (cAliasQry)->(! Eof())
			aCodUsr := {}
			While (cAliasQry)->(! Eof())
	
				PHW->(DbGoto((cAliasQry)->PHWREC))
				PHW->(Reclock("PHW",.F.))
				PHW->PHW_STATUS ='2'
				PHW->(MsUnlock())
				
				nCont := nCont++
		
				(cAliasQry)->(DbSkip())
			EndDo
		
			MsgInfo("Foram liberados " + cValToChar(nCont) + " Contratos!","Aviso")
		
		Else 
			MsgAlert("Não existe(m) contrato(s) bloqueados por este usuário","Atenção!")	
		EndIf
	
		If Select((cAliasQry)) > 0
		
			(cAliasQry)->(DbCloseArea())
		
		Endif
	Else
	
		MsgAlert("O usuário " + UPPER(cUsername) + " não Possui acesso a rotina!")
	
	EndIf 	

Return Nil 

User Function TGCVA100()
FWMsgRun(, {|oSay| U_ATGCTPHW(osay) }, "Aguarde", "Processando a rotina...")
Return