#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXADJ
Rotina de altera��o de agrupador de Oportunidades de vendas que possuam proposta criada

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXADJ()

Local cGrupo		:= ""									//Vari�vel que recebe o grupo v�lido do array aGrupo
Local aGrupo		:= {}									//Array para preenhimento de todos os grupos do usu�rio
Local nI			:= 0									//Vari�vel do contador dos grupos de acesso
Local lUsrRet		:= .F. 									//Vari�vel para valida��o do alert para usu�rios sem permiss�o
Local aRet 			:= {}									//Vari�vel para valida��o do PARAMBOX 
Local aPergs 		:= {}									//Array para montagem dos campos
Local cUsr			:= SuperGetMV("AT_GRPADJ",,"000000") 	//Par�metro com os grupos que acessam a rotina
Private cNivNeg		:= SuperGetMV("AT_NIVNEG",,"0302") 		//Par�metro Utilizado para negar altera��o de agrupador
Private cAgrCorp	:= SuperGetMV("TI_AGPCORP",,"0033") 	//Par�metro que armazena agrupadores do corporativo
Private cUserId		:= __CUSERID 							//Recebe o id do usu�rio logado (vari�vel padr�o do sistema)
Private cQry		:= ""									//Armazena a Query
Private cAliasQry	:= GetNextAlias()						//Recebe dados da tabela tempor�ria
Private cOport		:= ""									//Receber o n�mero da oportunidade
Private cCadastro 	:= "Altera Agrupador"					//T�tulo do Browse
Private lRet		:= .F.									//Vari�vel l�gica para valida��o dos campos do parambox
Private lRet2		:= .F.									//Vari�vel l�gica para o la�o do parambox
Private cAgrup		:= "000112"								//Armazena o Agrupador padr�o de vendas
Private cTabela		:= "CRM024"								//Armazena a tabela padr�o para localizar a descri��o do Tipo de Venda
Private cRet 		:= ''									//Armazena o retorno da fun��o para valida��es do PARAMBOX

	//-------------------------------------------------------------------//
	//					Valida��o de acesso a rotina					 //
	//-------------------------------------------------------------------// 
	
	// -- Valida��o de acesso a rotina
	cQry := " SELECT USR_GRUPO AS GRUPO"
	cQry += " FROM SYS_USR_GROUPS GRP"
	cQry += " WHERE  USR_ID = '" + cUserId + "'"
	cQry += " AND GRP.D_E_L_E_T_ = ' '"
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)

	// -- Prenchimento do array com os grupos de acesso encontrados para o usu�rio logado 
	If (cAliasQry)->(! Eof())
		aGrupo := {}
		While (cAliasQry)->(! Eof())
			Aadd(aGrupo,(cAliasQry)->GRUPO)
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	
	EndIf

	// -- La�o para verificar cada grupo de acesso e se tem acesso a rotina
	For nI = 1 To Len(aGrupo)
		
		cGrupo := aGrupo[nI]

		// -- Condi��o para acesso a rotina		
		If cGrupo $ cUsr
			lUsrRet := .T.
		
			//-------------------------------------------------------------------//
			//			Cria��o do Parambox para receber os Dados				 //
			//-------------------------------------------------------------------// 
		
			//Perguntas e valida��es iniciais do Parambox
			aAdd( aPergs ,{1,"Oportunidade: "	,Space(TAMSX3("AD1_NROPOR")[1]),"","lRet:= .F.,MV_PAR02:=U_TCRMPADJ('2'), MV_PAR03:=U_TCRMPADJ('3'), MV_PAR04:=U_TCRMPADJ('4'),MV_PAR05:=U_TCRMPADJ('5'),,MV_PAR06:=U_TCRMPADJ('7')"	,"",".T."													,70,.T.})
			aAdd( aPergs ,{1,"Revisa: "			,Space(TAMSX3("AD1_REVISA")[1]),"","" 																																					,"",".F."													,70,.T.})
			aAdd( aPergs ,{1,"Agrup: "			,Space(TAMSX3("ADJ_CODNIV")[1]),"","MV_PAR05:=U_TCRMPADJ('6'),MV_PAR06:=U_TCRMPADJ('7')"																								,"","IIF(MV_PAR01 <> '      ' .AND. lRet == .F.,.T.,.F.)"	,70,.T.})
			aAdd( aPergs ,{1,"Niv. Ref: "		,Space(TAMSX3("ADJ_XNVREF")[1]),"",""																																					,"","IIF(MV_PAR03=='0009',.T.,(MV_PAR04 := '    ',.F.))" 	,70,.F.})
			aAdd( aPergs ,{1,"Tipo de Venda: "	,Space(TAMSX3("PKG_TPVEND")[1]),"","" 																																					,"",".F."													,70,.T.})
			aAdd( aPergs ,{1,"Desncri��o : "	,Space(TAMSX3("ZX5_DESCRI")[1]),"","" 																																					,"",".F."													,70,.T.})
		
			//La�o para manter o PARAMBOX aberto at� a finaliza��o do processo
			While lRet2 == .F.		
				
				// -- Valida o parambox OK/Cancelar
				If ParamBox(aPergs ,"Parametros",aRet)
			
					//Solicita a confirma��o do processo
					If MSGYESNO( "Confirma a altera��o do agrupador? Essa a��o n�o pode ser desfeita!", "Aten��o!" )
				
							If MV_PAR01 = ' '  .OR. MV_PAR02 = ' '  .OR. MV_PAR03 = ' ' .OR. (MV_PAR03 = '0009' .AND. MV_PAR04 = '    ') .OR. MV_PAR05 = ' '  .OR. MV_PAR06 = ' ' 
							
								MsgAlert("Dados inv�lidos, o processo n�o ser� executado!","Aten��o!")
							
							Else 
								
								//Chamada da rotina de valida��o dos dados para altera��o da Oportunidade
								FWMsgRun(, {|oSay| U_TCRMAADJ(osay) }, "Aguarde", "Validando dados...")
								
							EndIf
					
					Else
					
						MsgInfo("Processo Cancelado!","Aviso")
					
					EndIf
				
				Else
						
					lRet2:= .T.	//Quando clicar em cancelar apenas fecha a tela
					
				EndIf
				
			EndDo //Encerra o la�o que mant�m o parambox aberto
		
		EndIf
		
	Next

	// -- Condi��o para valida��o do acesso para axibi��o do alert	
	If lUsrRet <> .T.
	
		MsgAlert("O usu�rio " + CUSERNAME + " N�o possui acesso a rotina!",'Acesso negado!')
	Else
	
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMPADJ
Rotina de pesquisa dos dados e valida��o dos dados do PARAMBOX		

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMPADJ(cOpc)

//Recebendo o n�mero da Oportunidade
cOport 	:= MV_PAR01
	
	//-------------------------------------------------------------------//
	//		Condi��es de Valida��o dos dados e retorno para o PARAMBOX	 //
	//-------------------------------------------------------------------// 
	
	DbSelectArea("AD1")
	dbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA                                                                                                                                
	
	If dbSeek(xFilial("AD1") + cOport)// -- Avalia o retorno da pesquisa da Oportunidade
		
		DbSelectArea("ADY")
		dbSetOrder(2)//ADY_FILIAL+ADY_OPORTU+ADY_REVISA+ADY_PROPOS      
		
		If dbSeek(xFilial("ADY") + cOport)    // -- Avalia o retorno da pesquisa da Proposta
		
				cQry := " SELECT AD1_NROPOR NROPOR"
				cQry += " ,AD1_REVISA REVISA"
				cQry += " ,ADJ_CODNIV CODNIV"
				cQry += " ,ADJ_XNVREF NVREF"
				cQry += " ,ADY_XTPVEN XTPVEN"
				cQry += " FROM AD1000 AD1"
				cQry += " INNER JOIN ADJ000 ADJ ON ADJ_FILIAL = ' '"
				cQry += " AND ADJ.D_E_L_E_T_ = ' '"
				cQry += " AND ADJ_NROPOR = AD1_NROPOR"
				cQry += " AND ADJ_REVISA = AD1_REVISA"
				cQry += " INNER JOIN ADY000 ADY ON ADY_FILIAL = ' '"
				cQry += " AND ADY.D_E_L_E_T_ = ' '"
				cQry += " AND ADY_OPORTU = AD1_NROPOR"
				cQry += " AND ADY_REVISA = AD1_REVISA"			
				cQry += " LEFT JOIN PKG000 PKG ON PKG_FILIAL = ' '"
				cQry += " AND PKG.D_E_L_E_T_ = ' '"
				cQry += " AND PKG_CODAGR = '000112'"
				cQry += " AND PKG_CODNIV = ADJ_CODNIV"
				cQry += " WHERE AD1_FILIAL = ' ' "
				cQry += " AND AD1.D_E_L_E_T_ = ' ' "
				cQry += " AND AD1_NROPOR = '" + cOport + "'"
			
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
					
				If (cAliasQry)->(! Eof())
				
					DO CASE
					CASE  cOpc == '2'
	
						cRet := (cAliasQry)->(REVISA)
	
					CASE  cOpc == '3'
	
						cRet := (cAliasQry)->(CODNIV)
	
					CASE  cOpc == '4'
	
						cRet := (cAliasQry)->(NVREF)
	
					CASE  cOpc == '5'
	
						cRet := (cAliasQry)->(XTPVEN)
						
					CASE  cOpc == '6'
					    
						DbSelectArea("PKG")
						dbSetOrder(1)//PKG_FILIAL+PKG_CODAGR+PKG_CODNIV
							 
					    	If dbSeek(xFilial("PKG") + cAgrup + MV_PAR03)
						    	
						    	cRet := PKG->PKG_TPVEND
						     						     				     	     	
							Elseif MV_PAR03 = "    "
							
								MsgAlert("Preencha o agrupador!","Aten��o!")
								
							Else
						    	
						    	MsgAlert("Agrupador N�o possui tipo de venda cadastrado, verifique!","Aten��o!")
						     	MV_PAR03 := "    "
						     	MV_PAR05 := "    "
							
							EndIf
						     	
						DbCloseArea() //Fecha a �rea da PKG
					     	
					CASE  cOpc == '7'
					     	
						DbSelectArea("ZX5")
						dbSetOrder(1)//ZX5_FILIAL+ZX5_TABELA+ZX5_CHAVE+ZX5_CHAVE2                                                                                                                      
					     	
						    If dbSeek(xFilial("ZX5") + cTabela + MV_PAR05)
						    	
						    	cRet := ZX5->ZX5_DESCRI
						     	
							Else
								
								cRet := " "
							
							EndIf
	
						DbCloseArea() //Fecha a �rea da ZX5
					     	
					ENDCASE
				
					(cAliasQry)->(DbSkip())
					
				Else
				
					//Se for fim do arquivo n�o executa nenhum processo
					
				EndIf
			
				(cAliasQry)->(DbCloseArea())//Fecha a �rea da tabela tempor�ria
			
		Else
		
			If lRet = .F.
		
				MsgAlert("Oportunidade sem proposta, utilize rotina de oportunidades.","Aten��o!")
				lRet := .T.
		
			Else

			EndIf
		
		End If

		DBCloseArea() //Fecha a �rea da ADY
		
	Else
		
		If lRet = .F.
			
			MsgAlert("Oportunidade n�o Encontrada!","Aten��o!")
			
			MV_PAR003 := " "
			MV_PAR005 := " "
			MV_PAR006 := " "
			
			lRet := .T.
			
			Return
		
		Else
			
		EndIf
	
	EndIf		
		
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMAADJ
Fun��o para valida��es dos dados conforme preenchimento do parambox				

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMAADJ()

Private cOportuI	:= "" 	//Armazena o n�mero da Oportunidade			- AD1_NROPOR
Private cRevOpI		:= ""	//Armazena a revis�o atual da Oportunidade	- AD1_REVISA
Private cPropI		:= ""	//Armazena o n�mero da proposta				- ADY_PROPOS
Private cRevPropI	:= ""	//Armazena a Revis�o da proposta			- ADY_PREVIS
Private cTpVend		:= ""	//Armazena o Tupo de Venda 					- ADY_XTPVEN
Private cModalI		:= ""	//Armazena a modalidade 					- ADY_XMODAL
Private cNegI		:= ""	//Armazena o C�d. do Neg�cio				- ADY_XNEGOC
Private cModrefI	:= ""	//Armazena o N�v. Ref. da ADY				- ADY_XCODNV
Private cNivAdjI	:= ""	//Armazena o N�v. Agrup. da ADJ				- ADJ_CODNIV
Private cNivRAdjI	:= ""	//Armazena o N�v. Ref. da ADJ				- ADJ_XNVREF
Private cIdInt		:= ""	//Armazena o C�digo Inteligete				- ADJ_IDINT
Private cHistor		:= ""	//Armazena o registro historico				- ADJ_HISTOR

	//-------------------------------------------------------------------//
	//		Carregando as vari�veis para preparar a altera��o			 //
	//-------------------------------------------------------------------// 

	// Abrindo a �rea da AD1 
	DbSelectArea("AD1")
	dbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA 
	
		//Preenchimento das vari�veis com Oportunidade/Revis�o
		If DbSeek(xFilial("AD1") + MV_PAR01)// -- Avalia o retorno da pesquisa da Oportunidade
			
			If AD1->AD1_STATUS = '1'
				
				cOportuI 	:= AD1->AD1_NROPOR
				cRevOpI		:= AD1->AD1_REVISA
				
				//Abrindo a �rea da AD2
				DbSelectArea("AD2")
				dbSetOrder(1)//AD2_FILIAL+AD2_NROPOR+AD2_REVISA+AD2_VEND
				
					If dbSeek(xFilial("AD2") + cOport + cRevOpI)// -- Avalia se existe time de vendas na oportunidade
				
						//Abrindo a �rea da ADJ 
						DbSelectArea("ADJ")
						dbSetOrder(1)//ADJ_FILIAL + ADJ_NROPOR + ADJ_REVISA
						
							If dbSeek(xFilial("ADJ") + cOport + cRevOpI)// -- Avalia o retorno da pesquisa da Oportunidade
								
								cNivAdjI	:= ADJ->ADJ_CODNIV
								cNivRAdjI	:= ADJ->ADJ_XNVREF
								cHistor		:= ADJ->ADJ_HISTOR
								
								//Abrindo a �rea da ADY 
								DbSelectArea("ADY")
								dbSetOrder(2)//ADY_FILIAL+ADY_OPORTU+ADY_REVISA+ADY_PROPOS                                                                                                                       	
									
									If dbSeek(xFilial("ADY") + cOport + cRevOpI)// -- Avalia se a oportunidade possui proposta
									
										//Verifica se a proposta est� em aberto para preencher as vari�veis
										If ADY->ADY_STATUS = 'A'
											
											cPropI		:= ADY->ADY_PROPOS
											cRevPropI	:= ADY->ADY_PREVIS
											cTpVend		:= ADY->ADY_XTPVEN
											cModalI		:= ADY->ADY_XMODAL
											cNegI		:= ADY->ADY_XNEGOC
											cModrefI	:= ADY->ADY_XCODNV
											
											//Valida��o para negar altera��o em oportunidades com agrupadores espec�ficos.
											If (ADY->ADY_XMODAL $ cNivNeg) .OR. (ADY->ADY_XCODNV $ cNivNeg) .OR. (MV_PAR03 $ cNivNeg) .OR. (MV_PAR04 $ cNivNeg)
											
												MsgAlert("N�o � permitido a alterar ou inclus�o de agrupadores cadastrados no par�metro AT_NIVNEG.","Aten��o!")
												
											Else
											
												//Verifica��o de altera��o nas informa��es do PARAMBOX
												If cNivAdjI = MV_PAR03 .AND. cNivRAdjI = MV_PAR04 .AND. cTpVend = MV_PAR05
														
													MsgAlert("Nenhum dado alterado, processo cancelado!","Aten��o!")
													
													//Pergunta para verificar se o usu�rio quer continuar na tela para novas altera��es
													If MSGYESNO( "Deseja Alterar outra Oportunidade?","Aten��o!")
												
														lRet2 := .F.
														
													Else
												
														lRet2 := .T.
														
													EndIf
												
												Else
		
													//Abrindo a �rea da AOM
													DbSelectArea("AOM")
													dbSetOrder(1)//AOM_FILIAL+AOM_CODAGR+AOM_CODNIV  
																					                                                                                                                                
														If dbSeek(xFilial("AOM") + cAgrup + MV_PAR03)//Verifica se o n�vel principal existe na tabela AOM
														
															If AOM->AOM_MSBLQL <> '1'//Verifica se o n�vel principal est� bloqueado
															
																cIdInt	:= AOM->AOM_IDINT
																cNegI	:= AOM->AOM_NIVPAI
																
																If (MV_PAR03 = '0009' .AND. (MV_PAR04 <> "    " .AND. MV_PAR04 <> "0009"))//Valida o preenchimento correto para troca de licen�a
																
																	If dbSeek(xFilial("AOM") + cAgrup + MV_PAR04)//Verifica se o n�vel refer�ncia existe na tabela AOM
																		
																		If AOM->AOM_MSBLQL <> '1'//Verifica se o n�vel refer�ncia est� bloqueado
																															
																				//Chamada da rotina para execu��o do processo de Altera��o
																				FWMsgRun(, {|oSay| U_TCRMBADJ(osay) }, "Aguarde", "Alterando dados...")
																		
																		Else
																		
																			MsgAlert("O n�vel de refer�ncia selecionado est� bloqueado e n�o pode ser usado!","Aten��o!")
																		
																		EndIf
																	
																	Else
				
																		MsgAlert("O n�vel de refer�ncia n�o foi localizado!","Aten��o!")									
																	
																	EndIf
				
																						
																ElseIf (MV_PAR03 <> '0009' .AND. MV_PAR04 = "    ")//Avalia para altera��o de propostas que nao sejam de troca de licen�a
																	
																	//Chamada da rotina para execu��o do processo de Altera��o
																	FWMsgRun(, {|oSay| U_TCRMBADJ(osay) }, "Aguarde", "Alterando dados...")
																
																Else
														
																	MsgAlert("Para Propostas de troca de licen�a, preencha um n�vel de Refer�ncia v�lido!.","Aten��o!")
														
																EndIf
															
															Else
															
																MsgAlert("O n�vel selecionado est� bloqueado e n�o pode ser usado!","Aten��o!")
															
															EndIf
																 
														Else
														
															MsgAlert("O n�vel do agrupador n�o foi localizado!","Aten��o!")
														
														EndIf
													
													DbCloseArea() //Fecha a �rea da AOM
													
												EndIf
												
											EndIf	
												
										Else
										
											MsgAlert("A proposta n�o aberta, altera��o n�o permitida!","Aten��o!")
										
										EndIf
								
									Else
									
										MsgAlert("Oportunidade sem proposta. Altere pela rotina dentro do CRM.","Aten��o!")
									
									EndIf
							
								DbCloseArea() //Fecha a �rea da ADY
								
							Else
									
								MsgAlert("Oportunidade n�o encontrada na ADJ!","Aten��o!")
								
							EndIf
						
						DbCloseArea() //Fecha a �rea da ADJ
						
					Else
						
						MsgAlert("Oportunidade n�o encontrada na AD2!","Aten��o!")
					
					EndIf
					
				DbCloseArea() //Fecha a �rea da AD2
				
			Else
			
				MsgAlert("N�o � permitido alterar oportunidades encerradas!","Aten��o!")
			
			EndIf
			
		Else
		
			MsgAlert("Oportunidade n�o encontrada na AD1!","Aten��o!")
		
		EndIf
	
	DbCloseArea() //Fecha a �rea da AD1

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMBADJ
Fun��o para Altera��o dos dados conforme preenchimento do parambox					

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMBADJ()

Local cQry2			:= ""					//Armazena a Query para Time de vendas
Local cQry3			:= ""					//Armazena a Query para propostas da oportunidade
Local cQry4			:= ""					//Armazena a Query para informa��es da ZAV
Local cAliasQry2	:= GetNextAlias()		//Recebe dados da tabela tempor�ria do Time de vendas
Local cAliasQry3	:= GetNextAlias()		//Recebe dados da tabela tempor�ria das propostas da Oportunidade
Local cAliasQry4	:= GetNextAlias()		//Recebe dados da tabela tempor�ria dos dados da ZAV
Local cRevInc		:= SOMA1(cRevOpI)		//Incremento da revis�o atual da Oportunidade
Local aGrupo 		:= {}					//Array para preenchimento dos dados da AD2
Local aPropos 		:= {}					//Array para ajuste das propostas
Local aDadosZav		:= {}					//Array para ajuste da ZAV
	
		//-------------------------------------------------------------------//
		//							Atualiza��o da AD2					 	 //
		//-------------------------------------------------------------------//
		 
		// -- Query para filtro dos dados
		cQry2 :=" SELECT AD2.R_E_C_N_O_ AS AD2REC"
		cQry2 +=" ,AD2_NROPOR AS NROPOR"
		cQry2 +=" ,AD2_REVISA AS REVISA"
		cQry2 +=" ,AD2_HISTOR AS HISTOR"
		cQry2 +=" ,AD2_VEND AS VEND"
		cQry2 +=" ,AD2_PERC AS PERC"
		cQry2 +=" ,AD2_CODCAR AS CODCAR"
		cQry2 +=" ,AD2_UNIDAD AS UNIDAD"
		cQry2 +=" ,AD2_RESPUN AS RESPUN"
		cQry2 +=" ,AD2_CODPAP AS CODPAP"
		cQry2 +=" ,AD2_XHUB AS XHUB"
		cQry2 +=" ,AD2_XCODUS AS XCODUS"
		cQry2 +=" ,AD2_XGAR AS XGAR"
		cQry2 +=" ,AD2_XGAR AS XDAR"
		cQry2 +=" ,AD2_XREGRA AS XREGRA"
		cQry2 +=" ,AD2_XCOMIS AS XCOMIS"
		cQry2 +=" ,AD2_XDATDE AS XDATDE"
		cQry2 +=" ,AD2_XDTATE AS XDTATE"
		cQry2 +=" ,AD2_XGO AS XGO"
		cQry2 +=" ,AD2_XVERCM AS XVERCM"
		cQry2 +=" ,AD2_XNMHUB AS XNMHUB"
		cQry2 +=" ,AD2_XHIST AS XHIST"		
		cQry2 +=" FROM AD2000 AD2"
		cQry2 +=" WHERE AD2.AD2_FILIAL = ' '"
		cQry2 +=" AND AD2.D_E_L_E_T_= ' '"
		cQry2 +=" AND AD2_NROPOR = '" + cOport + "'"
		cQry2 +=" AND AD2_REVISA = '" + cRevOpI + "'" 
		
		// Preenchendo a tabela tempor�ria
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cAliasQry2,.T.,.F.)
		
			If (cAliasQry2)->(! Eof())
				
				aGrupo := {}
				
				//La�o para atualiza��o da AD2
				While (cAliasQry2)->(! Eof())
				
					Aadd(aGrupo,;
					{(cAliasQry2)->AD2REC ,(cAliasQry2)->NROPOR,(cAliasQry2)->REVISA,(cAliasQry2)->HISTOR,(cAliasQry2)->VEND  ,;
					 (cAliasQry2)->PERC   ,(cAliasQry2)->CODCAR,(cAliasQry2)->UNIDAD,(cAliasQry2)->RESPUN,(cAliasQry2)->CODPAP,;
					 (cAliasQry2)->XHUB   ,(cAliasQry2)->XCODUS,(cAliasQry2)->XGAR  ,(cAliasQry2)->XDAR,(cAliasQry2)->XREGRA  ,;
					 (cAliasQry2)->XCOMIS ,(cAliasQry2)->XDATDE,(cAliasQry2)->XDTATE,(cAliasQry2)->XGO ,(cAliasQry2)->XVERCM  ,;
					 (cAliasQry2)->XNMHUB ,(cAliasQry2)->XHIST})
					
					(cAliasQry2)->(DbSkip())
				
				EndDo
				
				(cAliasQry2)->(DbCloseArea())
				
				//-------------------------------------------------------------------//
				//				Atualiza��o da revis�o atual da AD2				 	 //
				//-------------------------------------------------------------------// 
				
				//Preenchimento do Log em todos os registros referente ao time de vendas	
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cAliasQry2,.T.,.F.)
		
					If (cAliasQry2)->(! Eof())
						
						While (cAliasQry2)->(! Eof())
						
							AD2->(DbGoto((cAliasQry2)->AD2REC))
							RECLOCK("AD2",.F.)// Lock no registro
							AD2->AD2_FILIAL := "ALT" + cUserId
							MSUNLOCK()// Libera o registro
							(cAliasQry2)->(DbSkip())
						
						EndDo
					
					Else
						
						(cAliasQry2)->(DbCloseArea())
						
					EndIf
				
				(cAliasQry2)->(DbCloseArea())
				
			Else
			
				(cAliasQry2)->(DbCloseArea())
				
			EndIf
		
			//-------------------------------------------------------------------//
			//					Cria��o da nova revis�o da AD2				 	 //
			//-------------------------------------------------------------------// 
		
			//La�o para cria��o da AD2 para a nova revis�o
			For n := 1 to Len(aGrupo)
			
				//AD2->(DbGoto((cAliasQry2)->AD2REC))
				AD2->(Reclock("AD2",.T.))
				AD2->AD2_NROPOR 		:= aGrupo[n,2]
				AD2->AD2_REVISA		 	:= cRevInc 
				AD2->AD2_HISTOR			:= aGrupo[n,4]
				AD2->AD2_VEND			:= aGrupo[n,5]
				AD2->AD2_PERC			:= aGrupo[n,6]
				AD2->AD2_CODCAR			:= aGrupo[n,7]
				AD2->AD2_UNIDAD			:= aGrupo[n,8]
				AD2->AD2_RESPUN			:= aGrupo[n,9]
				AD2->AD2_CODPAP			:= aGrupo[n,10]
				AD2->AD2_XHUB			:= aGrupo[n,11]
				AD2->AD2_XCODUS			:= aGrupo[n,12]
				AD2->AD2_XGAR			:= aGrupo[n,13]
				AD2->AD2_XDAR			:= aGrupo[n,14]
				AD2->AD2_XREGRA			:= aGrupo[n,15]
				AD2->AD2_XCOMIS			:= aGrupo[n,16]
				AD2->AD2_XDATDE			:= SToD(aGrupo[n,17])
				AD2->AD2_XDTATE			:= SToD(aGrupo[n,18])
				AD2->AD2_XGO			:= aGrupo[n,19]
				AD2->AD2_XVERCM			:= aGrupo[n,20]
				AD2->AD2_XNMHUB			:= aGrupo[n,21]
				AD2->AD2_XHIST			:= aGrupo[n,22]
				AD2->(MsUnlock())
				
			Next
			
			//-------------------------------------------------------------------//
			//				Atualiza��o da revis�o atual da ADJ				 	 //
			//-------------------------------------------------------------------// 
			
			//Adicionando o usu�rio que realizou o processo ao campo filial da revis�o atual na tabela ADJ
			RECLOCK("ADJ",.F.)// Lock no registro
			ADJ->ADJ_FILIAL := "ALT" + cUserId
			MSUNLOCK()// Libera o registro 
			
			//-------------------------------------------------------------------//
			//					Cria��o da nova revis�o da ADJ				 	 //
			//-------------------------------------------------------------------// 
			
			//Atualiza��o da ADJ
			RECLOCK("ADJ",.T.)// Lock no registro
			ADJ->ADJ_NROPOR := MV_PAR01
			ADJ->ADJ_REVISA := cRevInc //cRevOpI
			ADJ->ADJ_HISTOR := cHistor
			ADJ->ADJ_CODAGR := cAgrup
			ADJ->ADJ_CODNIV := MV_PAR03
			ADJ->ADJ_FCAST	:= "1"
			ADJ->ADJ_IDINT	:= cIdInt
			ADJ->ADJ_XNVREF := MV_PAR04
			MSUNLOCK()// Libera o registro
			
			//-------------------------------------------------------------------//
			//					Atualiza��o da revis�o na AD1				 	 //
			//-------------------------------------------------------------------// 
			
			//Atualiza��o da AD1
			RECLOCK("AD1",.F.)// Lock no registro
			AD1->AD1_REVISA := cRevInc//cRevOpI
			AD1->AD1_XTPVEN	:= MV_PAR05
			MSUNLOCK()// Libera o registro
			
			//-------------------------------------------------------------------//
			//						Atualiza��o da ADY						 	 //
			//-------------------------------------------------------------------// 
			
			// -- Query para filtro dos dados
			cQry3 := " SELECT ADY.R_E_C_N_O_ AS NPROPOS"
			cQry3 += " FROM ADY000 ADY"
			cQry3 += " WHERE ADY_FILIAL = ' '"
			cQry3 += " AND ADY.D_E_L_E_T_ = ' '"
			cQry3 += " AND ADY_OPORTU = '" + MV_PAR01 + "'"
			
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),cAliasQry3,.T.,.F.)
	
				If (cAliasQry3)->(! Eof())
			
					aPropos := {}
			
					//La�o Preenchimento das propostas da oportunidade
					While (cAliasQry3)->(! Eof())
					
						Aadd(aPropos,(cAliasQry3)->NPROPOS)
					
					(cAliasQry3)->(DbSkip())
			
					EndDo
					
					(cAliasQry3)->(DbCloseArea())
					
				Else
				
					(cAliasQry3)->(DbCloseArea())
				
				EndIf
				
				//La�o para atualiza��o da ADY para a nova revis�o
				For n := 1 to Len(aPropos)
										
					//ADY->(DbGoto((cAliasQry3)->NPROPOS))
					ADY->(DbGoto( aPropos[n] ))
					RECLOCK("ADY",.F.)// Lock no registro para altera��o
					ADY->ADY_XTPVEN := MV_PAR05
					ADY->ADY_XMODAL := MV_PAR03
					ADY->ADY_XNEGOC := cNegI
					ADY->ADY_XCODNV := MV_PAR04
					ADY->ADY_REVISA	:= cRevInc //cRevOpI
					MSUNLOCK()// Libera o registro
					
				Next
					
				//-------------------------------------------------------------------//
				//						Atualiza��o da ZAV						 	 //
				//-------------------------------------------------------------------// 

				//Avaliando se � uma proposta corporativa
				If ADY->ADY_XMODAL $ cAgrCorp .OR. ADY->ADY_XCODNV $ cAgrCorp
				
					//Verifica se existe e Atualiza a ZAV
					DbSelectArea("ZAV")
					dbSetOrder(4)//ZAV_FILIAL+ZAV_OPORTU+ZAV_REVISA+ZAV_CGCPRI+ZAV_CGCAGR
					
					//If dbSeek(xFilial("ZAV") + cPropI + cRevPropI)// -- Avalia se existe m�tricas para a proposta
					If dbSeek(xFilial("ZAV")+ cOportuI + cRevOpI)// -- Avalia se existe m�tricas para a Oportunidade
						
						// -- Query para filtro dos dados da ZAV
						cQry4 :=" SELECT ZAV.R_E_C_N_O_ AS ZAVREC"
						cQry4 +=" ,ZAV_CODIGO AS ZAVCODIGO"
						cQry4 +=" ,ZAV_VERSAO AS ZAVVERSAO"
						cQry4 +=" ,ZAV_CGCPRI AS ZAVCGCPRI"
						cQry4 +=" ,ZAV_CGCAGR AS ZAVCGCAGR"
						cQry4 +=" ,ZAV_NOMAGR AS ZAVNOMEAGR"
						cQry4 +=" ,ZAV_DTCRIA AS ZAVDTCRIA"
						cQry4 +=" ,ZAV_ANO    AS ZAVANO"
						cQry4 +=" ,ZAV_SEGMEN AS ZAVSEGMEN"
						cQry4 +=" ,ZAV_METRIC AS ZAVMETRIC"
						cQry4 +=" ,ZAV_OPORTU AS ZAVOPORTU"
						cQry4 +=" ,ZAV_REVISA AS ZAVREVISA"
						cQry4 +=" ,ZAV_CATEG  AS ZAVCATEG"
						cQry4 +=" ,ZAV_TPCOMP AS ZAVTPCOMP"
						cQry4 +=" ,ZAV_ENTIDA AS ZAVENTIDA"
						cQry4 +=" ,ZAV_CODENT AS ZAVCODENT"
						cQry4 +=" ,ZAV_LOJENT AS ZAVLOJENT"
						cQry4 +=" ,ZAV_CODESN AS ZAVCODESN"
						cQry4 +=" ,ZAV_NOMESN AS ZAVNOMESN"
						cQry4 +=" ,ZAV_CODUND AS ZAVCODUND"
						cQry4 +=" ,ZAV_UNIDAD AS ZAVUNIDAD"
						cQry4 +=" ,ZAV_ORIGEM AS ZAVORIGEM"
						cQry4 +=" ,ZAV_TIPOID AS ZAVTIPOID"
						cQry4 +=" FROM ZAV000 ZAV"
						cQry4 +=" WHERE ZAV_FILIAL = ' '"
						cQry4 +=" AND ZAV.D_E_L_E_T_ = ' '"
						cQry4 +=" AND ZAV_CODIGO = '" + cPropI + "'"
						cQry4 +=" and ZAV_VERSAO = '" + cRevPropI + "'"
						
						DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry4),cAliasQry4,.T.,.F.)
		
							If (cAliasQry4)->(! Eof())
				
								aDadosZav := {}
							
								While (cAliasQry4)->(! Eof())
					
									Aadd(aDadosZav,;
									{(cAliasQry4)->ZAVREC, 	  (cAliasQry4)->ZAVCODIGO, (cAliasQry4)->ZAVVERSAO, (cAliasQry4)->ZAVCGCPRI,;
									 (cAliasQry4)->ZAVCGCAGR, (cAliasQry4)->ZAVNOMEAGR, (cAliasQry4)->ZAVDTCRIA,(cAliasQry4)->ZAVANO,;
									 (cAliasQry4)->ZAVSEGMEN, (cAliasQry4)->ZAVMETRIC, (cAliasQry4)->ZAVOPORTU, (cAliasQry4)->ZAVREVISA,;
									 (cAliasQry4)->ZAVCATEG,  (cAliasQry4)->ZAVTPCOMP, (cAliasQry4)->ZAVENTIDA, (cAliasQry4)->ZAVCODENT,;
									 (cAliasQry4)->ZAVLOJENT, (cAliasQry4)->ZAVCODESN, (cAliasQry4)->ZAVNOMESN, (cAliasQry4)->ZAVCODUND,;
									 (cAliasQry4)->ZAVUNIDAD, (cAliasQry4)->ZAVORIGEM, (cAliasQry4)->ZAVTIPOID})
									
									(cAliasQry4)->(DbSkip())
					
								EndDo
								
								(cAliasQry4)->(DbCloseArea())
								
								//Atualiza��o do registro atual para grava��o de Log na ZAV.
								For n := 1 to Len(aDadosZav)
									
									ZAV->(DbGoto( aDadosZav[n,1] ))
									RECLOCK("ZAV",.F.)
									ZAV->ZAV_FILIAL := "ALT" + cUserId
									MSUNLOCK()
								
								Next
								
								//La�o para cria��o da ZAV para a nova revis�o
								For n := 1 to Len(aDadosZav)
				
									// Cria��o da nova vers�o da ZAV
									RECLOCK("ZAV",.T.)// Lock no registro para altera��o
									ZAV->ZAV_CODIGO	:= aDadosZav[n,2]
									ZAV->ZAV_VERSAO	:= aDadosZav[n,3]
									ZAV->ZAV_CGCPRI	:= aDadosZav[n,4]
									ZAV->ZAV_CGCAGR	:= aDadosZav[n,5]
									ZAV->ZAV_NOMAGR	:= aDadosZav[n,6]
									ZAV->ZAV_DTCRIA	:= SToD(aDadosZav[n,7])
									ZAV->ZAV_ANO	:= aDadosZav[n,8]
									ZAV->ZAV_SEGMEN	:= aDadosZav[n,9]
									ZAV->ZAV_METRIC	:= aDadosZav[n,10]
									ZAV->ZAV_OPORTU	:= aDadosZav[n,11]
									ZAV->ZAV_REVISA	:= cRevInc
									ZAV->ZAV_CATEG	:= aDadosZav[n,13]
									ZAV->ZAV_TPCOMP	:= aDadosZav[n,14]
									ZAV->ZAV_ENTIDA	:= aDadosZav[n,15]
									ZAV->ZAV_CODENT	:= aDadosZav[n,16]
									ZAV->ZAV_LOJENT	:= aDadosZav[n,17]
									ZAV->ZAV_CODESN	:= aDadosZav[n,18]
									ZAV->ZAV_NOMESN	:= aDadosZav[n,19]
									ZAV->ZAV_CODUND	:= aDadosZav[n,20]
									ZAV->ZAV_UNIDAD	:= aDadosZav[n,21]
									ZAV->ZAV_ORIGEM	:= aDadosZav[n,22]
									ZAV->ZAV_TIPOID	:= aDadosZav[n,23]
					
								Next
								
							Else
							
								(cAliasQry4)->(DbCloseArea())
							
							EndIf
					
					Else
					
						MsgInfo("Agrupador alterado para corporativo, acesse a proposta e inclua as m�tricas!","AVISO!")
						//n�o haver� a��o
					EndIf
	
					DbCloseArea() //Fecha a �rea da ZAV
				
				EndIf  
			
		// -- Fechamento da �rea
		If Select((cAliasQry2)) > 0
		
			(cAliasQry2)->(DbCloseArea())
		
		Endif
	
	//Pergunta para verificar se o usu�rio quer continuar na tela para novas altera��es
	If MSGYESNO( "Altera��o realizada com Sucesso! Deseja Alterar outra Oportunidade?","Aten��o!")
	
		lRet2 := .F.
		
	Else
	
		lRet2 := .T.
		
	EndIf
							
Return