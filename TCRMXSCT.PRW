#Include "Protheus.ch"
#Include "FWMVCDEF.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXSCT
Rotina para exclusão de Metas

@author     Thiao Vitor
@since      30/01/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXSCT()
Local cPerg			:= Padr("SCTMETA",10)					//Nome do grupo do Pergunte
Local cAliasQry		:= GetNextAlias()						//Variável para receber dados da tabela temporária
Local lRet 			:= .F.									//Variável usada no laço para não fechar a tela de perguntes após ser barrado por alguma validação
Local cUsr			:= SuperGetMV("AT_USRSCT",,"008464")	//Parâmetro com usuários que terão acesso a rotina
Local cUserId		:= __CUSERID 							//Recebe o id do usuário logado (variável padrão do sistema)
Private lRetSoma	:= .F.									//Variável usada para validar se foi conferida a meta através da soma
Private cCadastro 	:= "Exclusão de Metas"					//Título do Browse
Private cSomaMeta	:= ""									//Variável que receberá o valor total das metas para validação
Private aRotina 	:= MenuDef()							//Variável para recebimento do menu
Private cExprFilTop := ""									//Variável que receberá o filtro para abertura no BROWSE

//Parâmetro para validação de acesso a rotina
If cUserId $ cUsr
		
// -- Laço para validação dos campos	
	While lRet == .F.
		lRetSoma	:= .F.	
	
		//-------------------------------------------------------------------//
		//				Criação de Perguntas - SX1							 //
		//-------------------------------------------------------------------// 
	
		// -- Código Vendedor - CT_VEND
		PutSx1(cPerg,"01","Esn De: ","Esn De: ","Esn De: ","mv_ch1","G",6,0,0,"C","","SA3","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"02","Esn Até: ","Esn De: ","Esn De: ","mv_ch2","G",6,0,0,"C","","SA3","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Data - CT_DATA
		PutSx1(cPerg,"03","Data De: ","Data De: ","Data De: ","mv_ch3","D",8,0,0,"C","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"04","Data Até: ","Data Até: ","Data Até: ","mv_ch4","D",8,0,0,"C","","","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Segmento da - CT_XCODSEG
		PutSx1(cPerg,"05","Seg. De: ","Seg. De: ","Seg. De: ","mv_ch5","G",6,0,0,"C","","AOV","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"06","Seg. Até: ","Seg. Até: ","Seg. Até: ","mv_ch6","G",6,0,0,"C","","AOV","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Agrupador/PicPad - CT_XAGRUP
		PutSx1(cPerg,"07","PicPad. De: ","PicPad. De: ","PicPad. De: ","mv_ch7","G",4,0,0,"C","","","","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"08","PicPad. Até: ","PicPad. Até: ","PicPad. Até: ","mv_ch8","G",4,0,0,"C","","","","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Superior - CT_XCODSUP
		PutSx1(cPerg,"09","Superior De: ","Superior De: ","Superior De: ","mv_ch9","G",6,0,0,"C","","SA3","","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"10","Superior Até: ","Superior Até: ","Superior Até: ","mv_cha","G",6,0,0,"C","","SA3","","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Unidade - CT_XUNIDAD
		PutSx1(cPerg,"11","Unid. De: ","Unid. De: ","Unid. De: ","mv_chb","G",6,0,0,"G","","ADK","","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"12","Unid. Até: ","Unid. Até: ","Unid. Até: ","mv_chc","G",6,0,0,"G","","ADK","","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","")
		
		// -- Validação do pergunte	
		lContinua 	:= Pergunte(cPerg,.t.)
		
		// -- validação de dados
		If !lContinua //Valida se foi pressionado Ok ou Cancelar 
			Return
		Else
		
		/* -- Alterado por: Thiago Vitor em 11/04/2019	
		   -- Ajuste das validações para permitir a consulta de vendedores em branco*/
					
			If Empty(mv_par03) .or. Empty(mv_par04)
				MsgAlert("Favor informar uma Data Válida!","Atenção!")
			ElseIf Empty(mv_par06) 
				MsgAlert("Favor informar o Segmento!","Atenção!")
			ElseIf Empty(mv_par08)
				MsgAlert("Favor informar o Agrupador!","Atenção!")
			ElseIf Empty(mv_par12)
				MsgAlert("Favor informar a Unidade!","Atenção!")
			Else
				lRet := .T.
		
				// -- Carrega o parâmetro de filtro	
				cExprFilTop := " CT_VEND BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
				cExprFilTop += " AND CT_DATA BETWEEN '" + DToS(mv_par03) + "' AND '" + DToS(mv_par04) + "'"
				cExprFilTop += " AND CT_XCODSEG BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
				cExprFilTop += " AND CT_XAGRUP BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
				cExprFilTop += " AND CT_XCODSUP BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
				cExprFilTop += " AND CT_XUNIDAD BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
				
				// -- Query a partir do filtro criado para soma da meta
				cQry := "SELECT SUM(SCT.CT_VALOR) VALMETA "
				cQry += "FROM SCT000 SCT "
				cQry += "WHERE SCT.D_E_L_E_T_ = ' ' "
				cQry += "AND SCT.CT_FILIAL = ' ' "
				cQry += "AND " + cExprFilTop
			
			EndIf
				
			// -- Recebimento dos valores para soma do total da meta
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
				If (cAliasQry)->(! Eof())
					aValMeta := {}
					While (cAliasQry)->(! Eof())
						Aadd(aValMeta,(cAliasQry)->VALMETA)
						(cAliasQry)->(DbSkip())
					EndDo
				EndIf
			(cAliasQry)->(DbCloseArea())
			
			// -- Atribui o total das metas a variável cSomaMeta
			cSomaMeta := cValToChar(aValMeta[1])
						
			// -- Cria o MBROWSE 
			oBrowse := fwmbrowse():new()
			oBrowse:setalias('SCT')
			oBrowse:SetFilterDefault('@' + cExprFilTop)
			oBrowse:Activate()
			
			EndIf
			
	EndDo
	
Else
	MsgAlert("O usuário " + CUSERNAME + " Não possui acesso a rotina!",'Acesso negado!')

EndIf

Return

//-------------------------------------------------------------------//
//				Montagem do menu chamado no browse					 //
//-------------------------------------------------------------------//

Static Function MenuDef
Local aRotina:={}

	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "AxVisual" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Somar Meta" 	ACTION "U_TSCTRUN(2)" 	OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "U_TSCTRUN(1)" 	OPERATION 6 ACCESS 0

Return aRotina

//-------------------------------------------------------------------//
//			Função para exibição do valor total da Meta				 //
//-------------------------------------------------------------------//

User Function TCRMSCTS()
	
	MsgInfo("O total da meta é " + cSomaMeta,"Aviso.")
	lRetSoma := .T.
	
Return

//-------------------------------------------------------------------//
//					Função para exclusão da Meta					 //
//-------------------------------------------------------------------//

User Function TCRMSCTD()

Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Local dDate			:= Date()
Local cLog			:= "Excl. " + CUSERNAME + " - " + DToc(dDate)
Local cMotivo		:= ""
Local aPergs 		:= {}
Local aRet 			:= {}

	If lRetSoma == .F.
	
		MsgAlert("Antes de Excluir as metas é necessário realizar a soma para conferência!","Atenção!")
	
	Else									
	
		If MSGYESNO( "Confirma a Exclusão das Metas? (Essa ação não pode ser desfeita!)", "Atenção!" )
		
			/*-- Alterado por Thiago Vitor em 22/03/2019 adicionando o Parambox
			  -- com a informação de motivo que será preenchido no campo CT_XMOTIVO*/ 
			  
			//-------------------------------------------------------------------//
			//				Criação do Parambox para receber o Motivo			 //
			//-------------------------------------------------------------------// 
		
			aAdd( aPergs ,{1,"Motivo: ",Space(TAMSX3("CT_XMOTIVO")[1]),"","","","",110,.T.})
			
			// -- Valida se o parambox
			If ParamBox(aPergs ,"Parametros",aRet)
			
			cMotivo := Padr(AllTrim( aRet[1] ),TAMSX3("CT_XMOTIVO")[1]," ")
			   
				// -- Query para filtro dos dados
				cQry :="SELECT SCT.R_E_C_N_O_ AS SCTREC "
				cQry +="FROM SCT000 SCT "
				cQry +="WHERE SCT.CT_FILIAL =' ' "
				cQry +="AND SCT.D_E_L_E_T_=' ' "
				cQry +="AND "  + cExprFilTop
				
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
					If (cAliasQry)->(! Eof())
				
						While (cAliasQry)->(! Eof())
				
							SCT->(DbGoto((cAliasQry)->SCTREC))
							SCT->(Reclock("SCT",.F.))
							SCT->CT_DESCRI := cLog
							SCT->CT_XMOTIVO := cMotivo 
							SCT->(DbDelete())
							SCT->(MsUnlock())
							(cAliasQry)->(DbSkip())
						EndDo
					
						MsgInfo("Metas Excluídas com Sucesso!","Aviso")
						lRetSoma := .F.
					
					Else 
						MsgAlert("Não existem metas para excluir!","Atenção!")	
					EndIf
					
				
					If Select((cAliasQry)) > 0
					
						(cAliasQry)->(DbCloseArea())
					
					Endif
			Else
				// Quando o processo for cancelado apenas fecha a tela
			EndIf
		
		Else 
	  	 
	  		MsgInfo("Exclusão de Metas Cancelada","Aviso")
		
		EndIf
	
	EndIf

Return

//-------------------------------------------------------------------//
//		Função para aplicação da janela de processamento			 //
//-------------------------------------------------------------------//

User Function TSCTRUN(nBut)
  
	If nBut == 1	
		FWMsgRun(, {|| U_TCRMSCTD() }, "Aguarde", "Processando a rotina...")
	Else 
		FWMsgRun(, {|| U_TCRMSCTS() }, "Aguarde", "Processando a rotina...")
	Endif
  
return

