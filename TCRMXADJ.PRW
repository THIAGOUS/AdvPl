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
	//			Criação do Parambox para receber o Oportunidade			 //
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
								FWMsgRun(, {|oSay| U_TCRMAADJ(osay) }, "Aguarde", "Processando a rotina...")
								
							EndIf
					
					Else
					
						MsgInfo("Processo Cancelado!","Aviso")
					
					EndIf
				
				Else
						
					lRet2:= .T.	//Quando clicar em cancelar apenas fecha a tela
					
				EndIf
				
			EndDo //Encerra o laço que mantém o parambox aberto
		Else
		
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
	
	DbSelectArea("AD1")
	dbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA                                                                                                                                
	
	If dbSeek(xFilial("AD1") + cOport)    // -- Avalia o retorno da pesquisa da Oportunidade
		
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
						     						     				     	     	
							Elseif MV_PAR03 = MV_PAR03 := "    "
							
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

	//Carregando as variáveis para preparar a alteração
	// Abrindo a área da AD1 
	DbSelectArea("AD1")
	dbSetOrder(1)//AD1_FILIAL+AD1_NROPOR+AD1_REVISA 
	
		// Preenchimento das variáveis com Oportunidade/Revisão
		If DbSeek(xFilial("AD1") + MV_PAR01)// -- Avalia o retorno da pesquisa da Oportunidade
			
			If AD1->AD1_STATUS = '1'
				
				cOportuI 	:= AD1->AD1_NROPOR
				cRevOpI		:= AD1->AD1_REVISA
				
				//Abrindo a área da ADJ 
				DbSelectArea("ADJ")
				dbSetOrder(1)//ADJ_FILIAL + ADJ_NROPOR + ADJ_REVISA
				
					If dbSeek(xFilial("ADJ") + cOport + cRevOpI)// -- Avalia o retorno da pesquisa da Oportunidade
						
						cNivAdjI	:= ADJ->ADJ_CODNIV
						cNivRAdjI	:= ADJ->ADJ_XNVREF
						cHistor		:= ADJ->ADJ_HISTOR
						
						//Abrindo a área da ADY 
						DbSelectArea("ADY")
						dbSetOrder(2)      //ADY_FILIAL+ADY_OPORTU+ADY_REVISA+ADY_PROPOS                                                                                                                       	
							
							If dbSeek(xFilial("ADY") + cOport + cRevOpI)// -- Avalia se a oportunidade possui proposta
							
								//Verifica se a proposta está em abertto para preencher as variáveis
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
									
										//Verificação se houve alteração nas informações do PARAMBOX
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
															
															If (MV_PAR03 = '0009' .AND. MV_PAR04 <> "    ")//Valida o preenchimento correto para troca de licença
															
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
													
																MsgAlert("Para Propostas de troca de licença, preencha o nível de Referência!.","Atenção!")
													
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
	
	//Atualizando a ADJ
	//Adicionando o usuário que realizou o processo ao campo filial da revisão atual na tabela ADJ
	RECLOCK("ADJ",.F.)// Lock no registro
	ADJ->ADJ_FILIAL := "ALT" + cUserId
	MSUNLOCK()// Libera o registro 
	
	//Gerando a nova linha com nova revisão e alterando os dados na tabela ADJ
	//Atualização da ADJ
	RECLOCK("ADJ",.T.)// Lock no registro
	ADJ->ADJ_NROPOR := MV_PAR01
	ADJ->ADJ_REVISA := SOMA1(cRevOpI)
	ADJ->ADJ_HISTOR := cHistor
	ADJ->ADJ_CODAGR := cAgrup
	ADJ->ADJ_CODNIV := MV_PAR03
	ADJ->ADJ_FCAST	:= "1"
	ADJ->ADJ_IDINT	:= cIdInt
	ADJ->ADJ_XNVREF := MV_PAR04
	cRevOpI			:= ADJ->ADJ_REVISA
	MSUNLOCK()// Libera o registro
	
	//Atualização da AD1
	RECLOCK("AD1",.F.)// Lock no registro
	AD1->AD1_REVISA := cRevOpI
	AD1->AD1_XTPVEN	:= MV_PAR05
	MSUNLOCK()// Libera o registro
	
	// Atualização da ADY
	RECLOCK("ADY",.F.)// Lock no registro para alteração
	ADY->ADY_XTPVEN := MV_PAR05
	ADY->ADY_XMODAL := MV_PAR03
	ADY->ADY_XNEGOC := cNegI
	ADY->ADY_XCODNV := MV_PAR04
	ADY->ADY_REVISA	:= cRevOpI
	MSUNLOCK()// Libera o registro
	
	//Verifica se existe e Atualiza a ZAV
	DbSelectArea("ZAV")
	dbSetOrder(1)//ZAV_FILIAL+ZAV_CODIGO+ZAV_VERSAO+ZAV_CGCPRI+ZAV_CGCAGR
	
		If dbSeek(xFilial("ZAV") + cPropI + cRevPropI)// -- Avalia se existe métricas para a proposta 
			
			RECLOCK("ZAV",.F.)
			ZAV->ZAV_REVISA := cRevOpI
			MSUNLOCK()
		
		Else
			//não haverá ação
		EndIf
		
	DbCloseArea() //Fecha a área da ZAV
	
	//Pergunta para verificar se o usuário quer continuar na tela para novas alterações
	If MSGYESNO( "Alteração realizada com Sucesso! Deseja Alterar outra Oportunidade?","Atenção!")
	
		lRet2 := .F.
		
	Else
	
		lRet2 := .T.
		
	EndIf
							
Return