#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TGCVM003
Programa para exclusão de Cálculos do corporativo

@author     Thiago Vitor
@since      02/02/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TGCVM003()
Local cPerg				:= Padr("EXCLCALC",10)
Local lRet 				:= .F.
Local cUsr				:= SuperGetMV("AT_USRPH0",,"008464")
Local cUserId			:= __CUSERID //Recebe o id do usuário logado (variável padrão do sistema)
Private cCadastro 		:= "Exclusão de Cálculo do Corporativo"
Private aRotina 		:= {}
Private cFilTop1 		:= ""
Private cFilTop2		:= ""

//Parâmetro para validação de acesso a rotina
If cUserId $ cUsr

// -- Laço para validação dos campos	
	While lRet == .F.
	
	// -- Criação de Perguntas - SX1
	
		PutSx1(cPerg,"01","Contrato","Contrato","Contrato","mv_ch1","G",9,0,0,"C","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"02","Revisão","Revisão","Revisão","mv_ch2","G",6,0,0,"C","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"03","Proposta","Proposta","Proposta","mv_ch3","G",6,0,0,"C","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","")
		
		// -- Validação do pergunte	
		lContinua 	:= Pergunte(cPerg,.t.)
		
		// -- validação de dados
			
		If !lContinua //Valida se foi selecionado Ok ou Cancelar 
			Return
		Else
			If (Empty(mv_par01)) .or. (Empty(mv_par02))
			
				If Empty(mv_par01)
					MsgAlert("Favor informar o Contrato!","Atenção!")
				ElseIf Empty(mv_par02)
					MsgAlert("Favor informar a Revisão!","Atenção!")
				Else
					lRet := .T.
				EndIf
			
			Else
			
				// -- Carrega o parâmetro de filtro
				cFilTop1 := " D_E_L_E_T_ = ' '"	
				cFilTop1 += " AND PH0_CONTRA = '" + mv_par01 + "'"
				cFilTop1 += " AND PH0_VERATU = '" + mv_par02 + "'"
				cFilTop1 += " AND PH0_PROPOS = '" + mv_par03 + "'"
				
				// -- Carrega o parâmetro de filtro para exclusão
				cFilTop2 += " PH0.PH0_CONTRA = '" + mv_par01 + "'"
				cFilTop2 += " AND PH0.PH0_VERATU = '" + mv_par02 + "'"
				cFilTop2 += " AND PH0.PH0_PROPOS = '" + mv_par03 + "'"
				
				// -- Adicionar os botões do MBROWSE		
				AADD(aRotina,{"Visualizar", "AxVisual",0,2})
				AADD(aRotina,{"Excluir", "U_TGCVM03E()",0,5})

				// -- Cria o MBROWSE 
				MBrowse( 6 , 1 , 22 , 75 , "PH0" , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cFilTop1 )
			EndIf
		EndIf	
	EndDo

Else
	MsgAlert("O usuário " + CUSERNAME + " Não possui acesso a rotina!",'Acesso negado!')
EndIf

Return

//-------------------------------------------------------------------
/*TGCV102D
-- Função que executa a exclusão do Cálculo

@author     Thiao Vitor
@since      02/02/2019
@version    P12
*/
//-------------------------------------------------------------------

User Function TGCVM03D()

Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Local cLog			:= "DEL" + __CUSERID

	// -- Confirmação da exclusão do Cálculo
	If MSGYESNO( "Confirma a Exclusão do Cálculo? (Essa ação não pode ser desfeita!)", "Atenção!" )
	   
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
				
				//Laço para exclusão dos dados PH0/PH1/PH2
				While (cAliasQry)->(! Eof())
					//Execução na tabela PH0
					PH0->(DbGoto((cAliasQry)->PH0REC))
					PH0->(Reclock("PH0",.F.))
					PH0->PH0_FILIAL := cLog 
					PH0->(DbDelete())
					PH0->(MsUnlock())
					
					//Execução na tabela PH1					
					PH1->(DbGoto((cAliasQry)->PH1REC))
					PH1->(Reclock("PH1",.F.))
					PH1->PH1_FILIAL := cLog 
					PH1->(DbDelete())
					PH1->(MsUnlock())
					
					//Execução na tabela PH2				
					PH2->(DbGoto((cAliasQry)->PH2REC))
					PH2->(Reclock("PH2",.F.))
					PH2->PH2_FILIAL := cLog 
					PH2->(DbDelete())
					PH2->(MsUnlock())
					
					(cAliasQry)->(DbSkip())
				EndDo
				
				MsgInfo("Cálculo Excluído com Sucesso!","Aviso")
			
			Else 
				MsgAlert("Não existem Cálculos com os dados informados nesse contrato!","Atenção!")	
			EndIf
			
			// -- Fechamento da área
		If Select((cAliasQry)) > 0
		
			(cAliasQry)->(DbCloseArea())
		
		Endif
		
	Else 
	   MsgInfo("Exclusão de Cálculos Cancelado","Aviso")
	endif

Return

// -------------------------------------------------------------------
// Processamento da rotina

User Function TGCVM03E()
FWMsgRun(, {|oSay| U_TGCVM03D(osay) }, "Aguarde", "Processando a rotina...")
Return
