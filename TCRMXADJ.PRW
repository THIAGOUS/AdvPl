#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXADJ
Rotina de alteração de agrupador de Oportunidades de vendas que possuam proposta criada

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXADJ()

Local cGrupo		:= ""									//Variável que recebe o grupo válido do array aGrupo
Local aGrupo		:= {}									//Array para preenhimento de todos os grupos do usuário
Local nI			:= 0									//Variável do contador dos grupos de acesso
Local lUsrRet		:= .F. 									//Variável para validação do alert para usuários sem permissão
Local aRet 			:= {}									//Variável para validação do PARAMBOX 
Local aPergs 		:= {}									//Array para montagem dos campos
Local cUsr			:= SuperGetMV("AT_GRPADJ",,"000000") 	//Parâmetro com os grupos que acessam a rotina
Private cNivNeg		:= SuperGetMV("AT_NIVNEG",,"0302") 		//Parâmetro Utilizado para negar alteração de agrupador
Private cAgrCorp	:= SuperGetMV("TI_AGPCORP",,"0033") 	//Parâmetro que armazena agrupadores do corporativo
Private cUserId		:= __CUSERID 							//Recebe o id do usuário logado (variável padrão do sistema)
Private cQry		:= ""									//Armazena a Query
Private cAliasQry	:= GetNextAlias()						//Recebe dados da tabela temporária
Private cOport		:= ""									//Receber o número da oportunidade
Private cCadastro 	:= "Altera Agrupador"					//Título do Browse
Private lRet		:= .F.									//Variável lógica para validação dos campos do parambox
Private lRet2		:= .F.									//Variável lógica para o laço do parambox
Private cAgrup		:= "000112"								//Armazena o Agrupador padrão de vendas
Private cTabela		:= "CRM024"								//Armazena a tabela padrão para localizar a descrição do Tipo de Venda
Private cRet 		:= ''									//Armazena o retorno da função para validações do PARAMBOX

	//-------------------------------------------------------------------//
	//					Validação de acesso a rotina					 //
	//-------------------------------------------------------------------// 
	
	// -- Validação de acesso a rotina
	cQry := " SELECT USR_GRUPO AS GRUPO"
	cQry += " FROM SYS_USR_GROUPS GRP"
	cQry += " WHERE  USR_ID = '" + cUserId + "'"
	cQry += " AND GRP.D_E_L_E_T_ = ' '"
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)

	// -- Prenchimento do array com os grupos de acesso encontrados para o usuário logado 
	If (cAliasQry)->(! Eof())
		aGrupo := {}
		While (cAliasQry)->(! Eof())
			Aadd(aGrupo,(cAliasQry)->GRUPO)
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	
	EndIf

	// -- Laço para verificar cada grupo de acesso e se tem acesso a rotina
	For nI = 1 To Len(aGrupo)
		
		cGrupo := aGrupo[nI]

		// -- Condição para acesso a rotina		
		If cGrupo $ cUsr
			lUsrRet := .T.
		
			//-------------------------------------------------------------------//
			//			Criação do Parambox para receber os Dados				 //
			//-------------------------------------------------------------------// 
		
			//Perguntas e validações iniciais do Parambox
			aAdd( aPergs ,{1,"Oportunidade: "	,Space(TAMSX3("AD1_NROPOR")[1]),"","lRet:= .F.,MV_PAR02:=U_TCRMPADJ('2'), MV_PAR03:=U_TCRMPADJ('3'), MV_PAR04:=U_TCRMPADJ('4'),MV_PAR05:=U_TCRMPADJ('5'),,MV_PAR06:=U_TCRMPADJ('7')"	,"",".T."													,70,.T.})
			aAdd( aPergs ,{1,"Revisa: "			,Space(TAMSX3("AD1_REVISA")[1]),"","" 																																					,"",".F."													,70,.T.})
			aAdd( aPergs ,{1,"Agrup: "			,Space(TAMSX3("ADJ_CODNIV")[1]),"","MV_PAR05:=U_TCRMPADJ('6'),MV_PAR06:=U_TCRMPADJ('7')"																								,"","IIF(MV_PAR01 <> '      ' .AND. lRet == .F.,.T.,.F.)"	,70,.T.})
			aAdd( aPergs ,{1,"Niv. Ref: "		,Space(TAMSX3("ADJ_XNVREF")[1]),"",""																																					,"","IIF(MV_PAR03=='0009',.T.,(MV_PAR04 := '    ',.F.))" 	,70,.F.})
			aAdd( aPergs ,{1,"Tipo de Venda: "	,Space(TAMSX3("PKG_TPVEND")[1]),"","" 																																					,"",".F."													,70,.T.})
			aAdd( aPergs ,{1,"Desncrição : "	,Space(TAMSX3("ZX5_DESCRI")[1]),"","" 																																					,"",".F."													,70,.T.})
		
			//Laço para manter o PARAMBOX aberto até a finalização do processo
			While lRet2 == .F.		
				
				// -- Valida o parambox OK/Cancelar
				If ParamBox(aPergs ,"Parametros",aRet)
			
					//Solicita a confirmação do processo
					If MSGYESNO( "Confirma a alteração do agrupador? Essa ação não pode ser desfeita!", "Atenção!" )
				
							If MV_PAR01 = ' '  .OR. MV_PAR02 = ' '  .OR. MV_PAR03 = ' ' .OR. (MV_PAR03 = '0009' .AND. MV_PAR04 = '    ') .OR. MV_PAR05 = ' '  .OR. MV_PAR06 = ' ' 
							
								MsgAlert("Dados inválidos, o processo não será executado!","Atenção!")
							
							Else 
								
								//Chamada da rotina de validação dos dados para alteração da Oportunidade
								FWMsgRun(, {|oSay| U_TCRMAADJ(osay) }, "Aguarde", "Validando dados...")
								
							EndIf
					
					Else
					
						MsgInfo("Processo Cancelado!","Aviso")
					
					EndIf
				
				Else
						
					lRet2:= .T.	//Quando clicar em cancelar apenas fecha a tela
					
				EndIf
				
			EndDo //Encerra o laço que mantém o parambox aberto
		
		EndIf
		
	Next

	// -- Condição para validação do acesso para axibição do alert	
	If lUsrRet <> .T.
	
		MsgAlert("O usuário " + CUSERNAME + " Não possui acesso a rotina!",'Acesso negado!')
	Else
	
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMPADJ
Rotina de pesquisa dos dados e validação dos dados do PARAMBOX		

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMPADJ(cOpc)

//Recebendo o número da Oportunidade
cOport 	:= MV_PAR01
	
	//-------------------------------------------------------------------//
	//		Condições de Validação dos dados e retorno para o PARAMBOX	 //
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
							
								MsgAlert("Preencha o agrupador!","Atenção!")
								
							Else
						    	
						    	MsgAlert("Agrupador Não possui tipo de venda cadastrado, verifique!","Atenção!")
						     	MV_PAR03 := "    "
						     	MV_PAR05 := "    "
							
							EndIf
						     	
						DbCloseArea() //Fecha a área da PKG
					     	
					CASE  cOpc == '7'
					     	
						DbSelectArea("ZX5")
						dbSetOrder(1)//ZX5_FILIAL+ZX5_TABELA+ZX5_CHAVE+ZX5_CHAVE2                                                                                                                      
					     	
						    If dbSeek(xFilial("ZX5") + cTabela + MV_PAR05)
						    	
						    	cRet := ZX5->ZX5_DESCRI
						     	
							Else
								
								cRet := " "
							
							EndIf
	
						DbCloseArea() //Fecha a área da ZX5
					     	
					ENDCASE
				
					(cAliasQry)->(DbSkip())
					
				Else
				
					//Se for fim do arquivo não executa nenhum processo
					
				EndIf
			
				(cAliasQry)->(DbCloseArea())//Fecha a área da tabela temporária
			
		Else
		
			If lRet = .F.
		
				MsgAlert("Oportunidade sem proposta, utilize rotina de oportunidades.","Atenção!")
				lRet := .T.
		
			Else

			EndIf
		
		End If

		DBCloseArea() //Fecha a área da ADY
		
	Else
		
		If lRet = .F.
			
			MsgAlert("Oportunidade não Encontrada!","Atenção!")
			
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
Função para validações dos dados conforme preenchimento do parambox				

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMAADJ()

Private cOportuI	:= "" 	//Armazena o número da Oportunidade			- AD1_NROPOR
Private cRevOpI		:= ""	//Armazena a revisão atual da Oportunidade	- AD1_REVISA
Private cPropI		:= ""	//Armazena o número da proposta				- ADY_PROPOS
Private cRevPropI	:= ""	//Armazena a Revisão da proposta			- ADY_PREVIS
Private cTpVend		:= ""	//Armazena o Tupo de Venda 					- ADY_XTPVEN
Private cModalI		:= ""	//Armazena a modalidade 					- ADY_XMODAL
Private cNegI		:= ""	//Armazena o Cód. do Negócio				- ADY_XNEGOC
Private cModrefI	:= ""	//Armazena o Nív. Ref. da ADY				- ADY_XCODNV
Private cNivAdjI	:= ""	//Armazena o Nív. Agrup. da ADJ				- ADJ_CODNIV
Private cNivRAdjI	:= ""	//Armazena o Nív. Ref. da ADJ				- ADJ_XNVREF
Private cIdInt		:= ""	//Armazena o Código Inteligete				- ADJ_IDINT
Private cHistor		:= ""	//Armazena o registro historico				- ADJ_HISTOR

	//-------------------------------------------------------------------//
	//		Carregando as variáveis para preparar a alteração			 //
	//-------------------------------------------------------------------// 

	// Abrindo a área da AD1 
	DbSelectArea("AD1")
	dbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA 
	
		//Preenchimento das variáveis com Oportunidade/Revisão
		If DbSeek(xFilial("AD1") + MV_PAR01)// -- Avalia o retorno da pesquisa da Oportunidade
			
			If AD1->AD1_STATUS = '1'
				
				cOportuI 	:= AD1->AD1_NROPOR
				cRevOpI		:= AD1->AD1_REVISA
				
				//Abrindo a área da AD2
				DbSelectArea("AD2")
				dbSetOrder(1)//AD2_FILIAL+AD2_NROPOR+AD2_REVISA+AD2_VEND
				
					If dbSeek(xFilial("AD2") + cOport + cRevOpI)// -- Avalia se existe time de vendas na oportunidade
				
						//Abrindo a área da ADJ 
						DbSelectArea("ADJ")
						dbSetOrder(1)//ADJ_FILIAL + ADJ_NROPOR + ADJ_REVISA
						
							If dbSeek(xFilial("ADJ") + cOport + cRevOpI)// -- Avalia o retorno da pesquisa da Oportunidade
								
								cNivAdjI	:= ADJ->ADJ_CODNIV
								cNivRAdjI	:= ADJ->ADJ_XNVREF
								cHistor		:= ADJ->ADJ_HISTOR
								
								//Abrindo a área da ADY 
								DbSelectArea("ADY")
								dbSetOrder(2)//ADY_FILIAL+ADY_OPORTU+ADY_REVISA+ADY_PROPOS                                                                                                                       	
									
									If dbSeek(xFilial("ADY") + cOport + cRevOpI)// -- Avalia se a oportunidade possui proposta
									
										//Verifica se a proposta está em aberto para preencher as variáveis
										If ADY->ADY_STATUS = 'A'
											
											cPropI		:= ADY->ADY_PROPOS
											cRevPropI	:= ADY->ADY_PREVIS
											cTpVend		:= ADY->ADY_XTPVEN
											cModalI		:= ADY->ADY_XMODAL
											cNegI		:= ADY->ADY_XNEGOC
											cModrefI	:= ADY->ADY_XCODNV
											
											//Validação para negar alteração em oportunidades com agrupadores específicos.
											If (ADY->ADY_XMODAL $ cNivNeg) .OR. (ADY->ADY_XCODNV $ cNivNeg) .OR. (MV_PAR03 $ cNivNeg) .OR. (MV_PAR04 $ cNivNeg)
											
												MsgAlert("Não é permitido a alterar ou inclusão de agrupadores cadastrados no parâmetro AT_NIVNEG.","Atenção!")
												
											Else
											
												//Verificação de alteração nas informações do PARAMBOX
												If cNivAdjI = MV_PAR03 .AND. cNivRAdjI = MV_PAR04 .AND. cTpVend = MV_PAR05
														
													MsgAlert("Nenhum dado alterado, processo cancelado!","Atenção!")
													
													//Pergunta para verificar se o usuário quer continuar na tela para novas alterações
													If MSGYESNO( "Deseja Alterar outra Oportunidade?","Atenção!")
												
														lRet2 := .F.
														
													Else
												
														lRet2 := .T.
														
													EndIf
												
												Else
		
													//Abrindo a área da AOM
													DbSelectArea("AOM")
													dbSetOrder(1)//AOM_FILIAL+AOM_CODAGR+AOM_CODNIV  
																					                                                                                                                                
														If dbSeek(xFilial("AOM") + cAgrup + MV_PAR03)//Verifica se o nível principal existe na tabela AOM
														
															If AOM->AOM_MSBLQL <> '1'//Verifica se o nível principal está bloqueado
															
																cIdInt	:= AOM->AOM_IDINT
																cNegI	:= AOM->AOM_NIVPAI
																
																If (MV_PAR03 = '0009' .AND. (MV_PAR04 <> "    " .AND. MV_PAR04 <> "0009"))//Valida o preenchimento correto para troca de licença
																
																	If dbSeek(xFilial("AOM") + cAgrup + MV_PAR04)//Verifica se o nível referência existe na tabela AOM
																		
																		If AOM->AOM_MSBLQL <> '1'//Verifica se o nível referência está bloqueado
																															
																				//Chamada da rotina para execução do processo de Alteração
																				FWMsgRun(, {|oSay| U_TCRMBADJ(osay) }, "Aguarde", "Alterando dados...")
																		
																		Else
																		
																			MsgAlert("O nível de referência selecionado está bloqueado e não pode ser usado!","Atenção!")
																		
																		EndIf
																	
																	Else
				
																		MsgAlert("O nível de referência não foi localizado!","Atenção!")									
																	
																	EndIf
				
																						
																ElseIf (MV_PAR03 <> '0009' .AND. MV_PAR04 = "    ")//Avalia para alteração de propostas que nao sejam de troca de licença
																	
																	//Chamada da rotina para execução do processo de Alteração
																	FWMsgRun(, {|oSay| U_TCRMBADJ(osay) }, "Aguarde", "Alterando dados...")
																
																Else
														
																	MsgAlert("Para Propostas de troca de licença, preencha um nível de Referência válido!.","Atenção!")
														
																EndIf
															
															Else
															
																MsgAlert("O nível selecionado está bloqueado e não pode ser usado!","Atenção!")
															
															EndIf
																 
														Else
														
															MsgAlert("O nível do agrupador não foi localizado!","Atenção!")
														
														EndIf
													
													DbCloseArea() //Fecha a área da AOM
													
												EndIf
												
											EndIf	
												
										Else
										
											MsgAlert("A proposta não aberta, alteração não permitida!","Atenção!")
										
										EndIf
								
									Else
									
										MsgAlert("Oportunidade sem proposta. Altere pela rotina dentro do CRM.","Atenção!")
									
									EndIf
							
								DbCloseArea() //Fecha a área da ADY
								
							Else
									
								MsgAlert("Oportunidade não encontrada na ADJ!","Atenção!")
								
							EndIf
						
						DbCloseArea() //Fecha a área da ADJ
						
					Else
						
						MsgAlert("Oportunidade não encontrada na AD2!","Atenção!")
					
					EndIf
					
				DbCloseArea() //Fecha a área da AD2
				
			Else
			
				MsgAlert("Não é permitido alterar oportunidades encerradas!","Atenção!")
			
			EndIf
			
		Else
		
			MsgAlert("Oportunidade não encontrada na AD1!","Atenção!")
		
		EndIf
	
	DbCloseArea() //Fecha a área da AD1

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMBADJ
Função para Alteração dos dados conforme preenchimento do parambox					

@author     Thiago Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMBADJ()

Local cQry2			:= ""					//Armazena a Query para Time de vendas
Local cQry3			:= ""					//Armazena a Query para propostas da oportunidade
Local cQry4			:= ""					//Armazena a Query para informações da ZAV
Local cAliasQry2	:= GetNextAlias()		//Recebe dados da tabela temporária do Time de vendas
Local cAliasQry3	:= GetNextAlias()		//Recebe dados da tabela temporária das propostas da Oportunidade
Local cAliasQry4	:= GetNextAlias()		//Recebe dados da tabela temporária dos dados da ZAV
Local cRevInc		:= SOMA1(cRevOpI)		//Incremento da revisão atual da Oportunidade
Local aGrupo 		:= {}					//Array para preenchimento dos dados da AD2
Local aPropos 		:= {}					//Array para ajuste das propostas
Local aDadosZav		:= {}					//Array para ajuste da ZAV
	
		//-------------------------------------------------------------------//
		//							Atualização da AD2					 	 //
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
		
		// Preenchendo a tabela temporária
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cAliasQry2,.T.,.F.)
		
			If (cAliasQry2)->(! Eof())
				
				aGrupo := {}
				
				//Laço para atualização da AD2
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
				//				Atualização da revisão atual da AD2				 	 //
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
			//					Criação da nova revisão da AD2				 	 //
			//-------------------------------------------------------------------// 
		
			//Laço para criação da AD2 para a nova revisão
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
			//				Atualização da revisão atual da ADJ				 	 //
			//-------------------------------------------------------------------// 
			
			//Adicionando o usuário que realizou o processo ao campo filial da revisão atual na tabela ADJ
			RECLOCK("ADJ",.F.)// Lock no registro
			ADJ->ADJ_FILIAL := "ALT" + cUserId
			MSUNLOCK()// Libera o registro 
			
			//-------------------------------------------------------------------//
			//					Criação da nova revisão da ADJ				 	 //
			//-------------------------------------------------------------------// 
			
			//Atualização da ADJ
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
			//					Atualização da revisão na AD1				 	 //
			//-------------------------------------------------------------------// 
			
			//Atualização da AD1
			RECLOCK("AD1",.F.)// Lock no registro
			AD1->AD1_REVISA := cRevInc//cRevOpI
			AD1->AD1_XTPVEN	:= MV_PAR05
			MSUNLOCK()// Libera o registro
			
			//-------------------------------------------------------------------//
			//						Atualização da ADY						 	 //
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
			
					//Laço Preenchimento das propostas da oportunidade
					While (cAliasQry3)->(! Eof())
					
						Aadd(aPropos,(cAliasQry3)->NPROPOS)
					
					(cAliasQry3)->(DbSkip())
			
					EndDo
					
					(cAliasQry3)->(DbCloseArea())
					
				Else
				
					(cAliasQry3)->(DbCloseArea())
				
				EndIf
				
				//Laço para atualização da ADY para a nova revisão
				For n := 1 to Len(aPropos)
										
					//ADY->(DbGoto((cAliasQry3)->NPROPOS))
					ADY->(DbGoto( aPropos[n] ))
					RECLOCK("ADY",.F.)// Lock no registro para alteração
					ADY->ADY_XTPVEN := MV_PAR05
					ADY->ADY_XMODAL := MV_PAR03
					ADY->ADY_XNEGOC := cNegI
					ADY->ADY_XCODNV := MV_PAR04
					ADY->ADY_REVISA	:= cRevInc //cRevOpI
					MSUNLOCK()// Libera o registro
					
				Next
					
				//-------------------------------------------------------------------//
				//						Atualização da ZAV						 	 //
				//-------------------------------------------------------------------// 

				//Avaliando se é uma proposta corporativa
				If ADY->ADY_XMODAL $ cAgrCorp .OR. ADY->ADY_XCODNV $ cAgrCorp
				
					//Verifica se existe e Atualiza a ZAV
					DbSelectArea("ZAV")
					dbSetOrder(4)//ZAV_FILIAL+ZAV_OPORTU+ZAV_REVISA+ZAV_CGCPRI+ZAV_CGCAGR
					
					//If dbSeek(xFilial("ZAV") + cPropI + cRevPropI)// -- Avalia se existe métricas para a proposta
					If dbSeek(xFilial("ZAV")+ cOportuI + cRevOpI)// -- Avalia se existe métricas para a Oportunidade
						
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
								
								//Atualização do registro atual para gravação de Log na ZAV.
								For n := 1 to Len(aDadosZav)
									
									ZAV->(DbGoto( aDadosZav[n,1] ))
									RECLOCK("ZAV",.F.)
									ZAV->ZAV_FILIAL := "ALT" + cUserId
									MSUNLOCK()
								
								Next
								
								//Laço para criação da ZAV para a nova revisão
								For n := 1 to Len(aDadosZav)
				
									// Criação da nova versão da ZAV
									RECLOCK("ZAV",.T.)// Lock no registro para alteração
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
					
						MsgInfo("Agrupador alterado para corporativo, acesse a proposta e inclua as métricas!","AVISO!")
						//não haverá ação
					EndIf
	
					DbCloseArea() //Fecha a área da ZAV
				
				EndIf  
			
		// -- Fechamento da área
		If Select((cAliasQry2)) > 0
		
			(cAliasQry2)->(DbCloseArea())
		
		Endif
	
	//Pergunta para verificar se o usuário quer continuar na tela para novas alterações
	If MSGYESNO( "Alteração realizada com Sucesso! Deseja Alterar outra Oportunidade?","Atenção!")
	
		lRet2 := .F.
		
	Else
	
		lRet2 := .T.
		
	EndIf
							
Return