#Include "Protheus.ch"
#Include "FWMVCDEF.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXSCT
Rotina para exclus�o de Metas

@author     Thiao Vitor
@since      30/01/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXSCT()
Local cPerg			:= Padr("SCTMETA",10)					//Nome do grupo do Pergunte
Local cAliasQry		:= GetNextAlias()						//Vari�vel para receber dados da tabela tempor�ria
Local lRet 			:= .F.									//Vari�vel usada no la�o para n�o fechar a tela de perguntes ap�s ser barrado por alguma valida��o
Local cUsr			:= SuperGetMV("AT_USRSCT",,"008464")	//Par�metro com usu�rios que ter�o acesso a rotina
Local cUserId		:= __CUSERID 							//Recebe o id do usu�rio logado (vari�vel padr�o do sistema)
Private lRetSoma	:= .F.									//Vari�vel usada para validar se foi conferida a meta atrav�s da soma
Private cCadastro 	:= "Exclus�o de Metas"					//T�tulo do Browse
Private cSomaMeta	:= ""									//Vari�vel que receber� o valor total das metas para valida��o
Private aRotina 	:= MenuDef()							//Vari�vel para recebimento do menu
Private cExprFilTop := ""									//Vari�vel que receber� o filtro para abertura no BROWSE

//Par�metro para valida��o de acesso a rotina
If cUserId $ cUsr
		
// -- La�o para valida��o dos campos	
	While lRet == .F.
		lRetSoma	:= .F.	
	
		//-------------------------------------------------------------------//
		//				Cria��o de Perguntas - SX1							 //
		//-------------------------------------------------------------------// 
	
		// -- C�digo Vendedor - CT_VEND
		PutSx1(cPerg,"01","Esn De: ","Esn De: ","Esn De: ","mv_ch1","G",6,0,0,"C","","SA3","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"02","Esn At�: ","Esn De: ","Esn De: ","mv_ch2","G",6,0,0,"C","","SA3","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Data - CT_DATA
		PutSx1(cPerg,"03","Data De: ","Data De: ","Data De: ","mv_ch3","D",8,0,0,"C","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"04","Data At�: ","Data At�: ","Data At�: ","mv_ch4","D",8,0,0,"C","","","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Segmento da - CT_XCODSEG
		PutSx1(cPerg,"05","Seg. De: ","Seg. De: ","Seg. De: ","mv_ch5","G",6,0,0,"C","","AOV","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"06","Seg. At�: ","Seg. At�: ","Seg. At�: ","mv_ch6","G",6,0,0,"C","","AOV","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Agrupador/PicPad - CT_XAGRUP
		PutSx1(cPerg,"07","PicPad. De: ","PicPad. De: ","PicPad. De: ","mv_ch7","G",4,0,0,"C","","","","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"08","PicPad. At�: ","PicPad. At�: ","PicPad. At�: ","mv_ch8","G",4,0,0,"C","","","","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Superior - CT_XCODSUP
		PutSx1(cPerg,"09","Superior De: ","Superior De: ","Superior De: ","mv_ch9","G",6,0,0,"C","","SA3","","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"10","Superior At�: ","Superior At�: ","Superior At�: ","mv_cha","G",6,0,0,"C","","SA3","","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","")
		// -- Unidade - CT_XUNIDAD
		PutSx1(cPerg,"11","Unid. De: ","Unid. De: ","Unid. De: ","mv_chb","G",6,0,0,"G","","ADK","","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","")
		PutSx1(cPerg,"12","Unid. At�: ","Unid. At�: ","Unid. At�: ","mv_chc","G",6,0,0,"G","","ADK","","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","")
		
		// -- Valida��o do pergunte	
		lContinua 	:= Pergunte(cPerg,.t.)
		
		// -- valida��o de dados
		If !lContinua //Valida se foi pressionado Ok ou Cancelar 
			Return
		Else
		
		/* -- Alterado por: Thiago Vitor em 11/04/2019	
		   -- Ajuste das valida��es para permitir a consulta de vendedores em branco*/
					
			If Empty(mv_par03) .or. Empty(mv_par04)
				MsgAlert("Favor informar uma Data V�lida!","Aten��o!")
			ElseIf Empty(mv_par06) 
				MsgAlert("Favor informar o Segmento!","Aten��o!")
			ElseIf Empty(mv_par08)
				MsgAlert("Favor informar o Agrupador!","Aten��o!")
			ElseIf Empty(mv_par12)
				MsgAlert("Favor informar a Unidade!","Aten��o!")
			Else
				lRet := .T.
		
				// -- Carrega o par�metro de filtro	
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
			
			// -- Atribui o total das metas a vari�vel cSomaMeta
			cSomaMeta := cValToChar(aValMeta[1])
						
			// -- Cria o MBROWSE 
			oBrowse := fwmbrowse():new()
			oBrowse:setalias('SCT')
			oBrowse:SetFilterDefault('@' + cExprFilTop)
			oBrowse:Activate()
			
			EndIf
			
	EndDo
	
Else
	MsgAlert("O usu�rio " + CUSERNAME + " N�o possui acesso a rotina!",'Acesso negado!')

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
//			Fun��o para exibi��o do valor total da Meta				 //
//-------------------------------------------------------------------//

User Function TCRMSCTS()
	
	MsgInfo("O total da meta � " + cSomaMeta,"Aviso.")
	lRetSoma := .T.
	
Return

//-------------------------------------------------------------------//
//					Fun��o para exclus�o da Meta					 //
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
	
		MsgAlert("Antes de Excluir as metas � necess�rio realizar a soma para confer�ncia!","Aten��o!")
	
	Else									
	
		If MSGYESNO( "Confirma a Exclus�o das Metas? (Essa a��o n�o pode ser desfeita!)", "Aten��o!" )
		
			/*-- Alterado por Thiago Vitor em 22/03/2019 adicionando o Parambox
			  -- com a informa��o de motivo que ser� preenchido no campo CT_XMOTIVO*/ 
			  
			//-------------------------------------------------------------------//
			//				Cria��o do Parambox para receber o Motivo			 //
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
					
						MsgInfo("Metas Exclu�das com Sucesso!","Aviso")
						lRetSoma := .F.
					
					Else 
						MsgAlert("N�o existem metas para excluir!","Aten��o!")	
					EndIf
					
				
					If Select((cAliasQry)) > 0
					
						(cAliasQry)->(DbCloseArea())
					
					Endif
			Else
				// Quando o processo for cancelado apenas fecha a tela
			EndIf
		
		Else 
	  	 
	  		MsgInfo("Exclus�o de Metas Cancelada","Aviso")
		
		EndIf
	
	EndIf

Return

//-------------------------------------------------------------------//
//		Fun��o para aplica��o da janela de processamento			 //
//-------------------------------------------------------------------//

User Function TSCTRUN(nBut)
  
	If nBut == 1	
		FWMsgRun(, {|| U_TCRMSCTD() }, "Aguarde", "Processando a rotina...")
	Else 
		FWMsgRun(, {|| U_TCRMSCTS() }, "Aguarde", "Processando a rotina...")
	Endif
  
return

