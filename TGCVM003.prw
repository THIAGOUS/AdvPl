#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TGCVM003
Programa para exclus�o de C�lculos do corporativo

@author     Thiago Vitor
@since      02/02/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TGCVM003()
Local cPerg				:= Padr("EXCLCALC",10)
Local lRet 				:= .F.
Local cUsr				:= SuperGetMV("AT_USRPH0",,"008464")
Local cUserId			:= __CUSERID //Recebe o id do usu�rio logado (vari�vel padr�o do sistema)
Private cCadastro 		:= "Exclus�o de C�lculo do Corporativo"
Private aRotina 		:= {}
Private cFilTop1 		:= ""
Private cFilTop2		:= ""

//Par�metro para valida��o de acesso a rotina
If cUserId $ cUsr

// -- La�o para valida��o dos campos	
	While lRet == .F.
	
	// -- Cria��o de Perguntas - SX1
	
		PutSx1(cPerg,"01","Contrato","Contrato","Contrato","mv_ch1","G",9,0,0,"C","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"02","Revis�o","Revis�o","Revis�o","mv_ch2","G",6,0,0,"C","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"03","Proposta","Proposta","Proposta","mv_ch3","G",6,0,0,"C","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","")
		
		// -- Valida��o do pergunte	
		lContinua 	:= Pergunte(cPerg,.t.)
		
		// -- valida��o de dados
			
		If !lContinua //Valida se foi selecionado Ok ou Cancelar 
			Return
		Else
			If (Empty(mv_par01)) .or. (Empty(mv_par02))
			
				If Empty(mv_par01)
					MsgAlert("Favor informar o Contrato!","Aten��o!")
				ElseIf Empty(mv_par02)
					MsgAlert("Favor informar a Revis�o!","Aten��o!")
				Else
					lRet := .T.
				EndIf
			
			Else
			
				// -- Carrega o par�metro de filtro
				cFilTop1 := " D_E_L_E_T_ = ' '"	
				cFilTop1 += " AND PH0_CONTRA = '" + mv_par01 + "'"
				cFilTop1 += " AND PH0_VERATU = '" + mv_par02 + "'"
				cFilTop1 += " AND PH0_PROPOS = '" + mv_par03 + "'"
				
				// -- Carrega o par�metro de filtro para exclus�o
				cFilTop2 += " PH0.PH0_CONTRA = '" + mv_par01 + "'"
				cFilTop2 += " AND PH0.PH0_VERATU = '" + mv_par02 + "'"
				cFilTop2 += " AND PH0.PH0_PROPOS = '" + mv_par03 + "'"
				
				// -- Adicionar os bot�es do MBROWSE		
				AADD(aRotina,{"Visualizar", "AxVisual",0,2})
				AADD(aRotina,{"Excluir", "U_TGCVM03E()",0,5})

				// -- Cria o MBROWSE 
				MBrowse( 6 , 1 , 22 , 75 , "PH0" , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cFilTop1 )
			EndIf
		EndIf	
	EndDo

Else
	MsgAlert("O usu�rio " + CUSERNAME + " N�o possui acesso a rotina!",'Acesso negado!')
EndIf

Return

//-------------------------------------------------------------------
/*TGCV102D
-- Fun��o que executa a exclus�o do C�lculo

@author     Thiao Vitor
@since      02/02/2019
@version    P12
*/
//-------------------------------------------------------------------

User Function TGCVM03D()

Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Local cLog			:= "DEL" + __CUSERID

	// -- Confirma��o da exclus�o do C�lculo
	If MSGYESNO( "Confirma a Exclus�o do C�lculo? (Essa a��o n�o pode ser desfeita!)", "Aten��o!" )
	   
		// -- Query para filtro dos dados
		cQry :=" SELECT PH0.R_E_C_N_O_ AS PH0REC"
		cQry +=" ,PH1.R_E_C_N_O_ AS PH1REC"
		cQry +=" ,PH2.R_E_C_N_O_ AS PH2REC"
		cQry +=" FROM PH0000 PH0"
		cQry +=" INNER JOIN PH1000 PH1 ON PH1.PH1_FILIAL = ' '"
		cQry +=" AND PH1.D_E_L_E_T_ = ' ' "
		cQry +=" AND PH1.PH1_CODIGO = PH0.PH0_CODIGO"
		cQry +=" INNER JOIN PH2000 PH2 ON PH2.PH2_FILIAL = ' '"
		cQry +=" AND PH2.D_E_L_E_T_ = ' '"
		cqry +=" AND PH2.PH2_CODIGO = PH0.PH0_CODIGO"
		cQry +=" WHERE PH0.PH0_FILIAL = ' '"
		cQry +=" AND PH0.D_E_L_E_T_= ' '"
		cQry +=" AND "  + cFilTop2
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
			If (cAliasQry)->(! Eof())
				
				//La�o para exclus�o dos dados PH0/PH1/PH2
				While (cAliasQry)->(! Eof())
					//Execu��o na tabela PH0
					PH0->(DbGoto((cAliasQry)->PH0REC))
					PH0->(Reclock("PH0",.F.))
					PH0->PH0_FILIAL := cLog 
					PH0->(DbDelete())
					PH0->(MsUnlock())
					
					//Execu��o na tabela PH1					
					PH1->(DbGoto((cAliasQry)->PH1REC))
					PH1->(Reclock("PH1",.F.))
					PH1->PH1_FILIAL := cLog 
					PH1->(DbDelete())
					PH1->(MsUnlock())
					
					//Execu��o na tabela PH2				
					PH2->(DbGoto((cAliasQry)->PH2REC))
					PH2->(Reclock("PH2",.F.))
					PH2->PH2_FILIAL := cLog 
					PH2->(DbDelete())
					PH2->(MsUnlock())
					
					(cAliasQry)->(DbSkip())
				EndDo
				
				MsgInfo("C�lculo Exclu�do com Sucesso!","Aviso")
			
			Else 
				MsgAlert("N�o existem C�lculos com os dados informados nesse contrato!","Aten��o!")	
			EndIf
			
			// -- Fechamento da �rea
		If Select((cAliasQry)) > 0
		
			(cAliasQry)->(DbCloseArea())
		
		Endif
		
	Else 
	   MsgInfo("Exclus�o de C�lculos Cancelado","Aviso")
	endif

Return

// -------------------------------------------------------------------
// Processamento da rotina

User Function TGCVM03E()
FWMsgRun(, {|oSay| U_TGCVM03D(osay) }, "Aguarde", "Processando a rotina...")
Return
