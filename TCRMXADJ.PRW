#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXADJ
Rotina Rotina de altera��o de agrupador de vendas

@author     Thiao Vitor
@since      26/03/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXADJ()

Local cUserId		:= __CUSERID 							//Recebe o id do usu�rio logado (vari�vel padr�o do sistema)
Local cUsr			:= SuperGetMV("AT_USRADJ",,"000000") 	//Par�metro com os grupos que acessam a rotina
Local aRet 			:= {}									//Vari�vel para valida��o do PARAMBOX 
Local aPergs 		:= {}									//Array para montagem dos campos
Private cQry		:= ""									//Vari�vel para receber dados da tabela tempor�ria
Private cAliasQry	:= GetNextAlias()						//Vari�vel para receber dados da tabela tempor�ria
Private cOport		:= ""
Private cCadastro 	:= "Altera Agrupador"					//T�tulo do Browse
Private lRet		:= .F.									//Vari�vel l�gica para valida��o e abertura dos campos do parambox
Private cAgrup		:= ""
Private cTabela		:= ""

	//-------------------------------------------------------------------//
	//			Cria��o do Parambox para receber o Oportunidade			 //
	//-------------------------------------------------------------------// 
	
	// adicionar um processo para limpar as vari�veis ap�s finalizar ou cancelar o processo 

	
	aAdd( aPergs ,{1,"Oportunidade: "	,Space(TAMSX3("AD1_NROPOR")[1]),"","lRet:= .F.,MV_PAR02:=U_TCRMPADJ('2'), MV_PAR03:=U_TCRMPADJ('3'), MV_PAR04:=U_TCRMPADJ('4'),MV_PAR05:=U_TCRMPADJ('5'),,MV_PAR06:=U_TCRMPADJ('7')"	,"",".T."													,70,.T.})
	aAdd( aPergs ,{1,"Revisa: "			,Space(TAMSX3("AD1_REVISA")[1]),"","" 																																					,"",".F."													,70,.T.})
	aAdd( aPergs ,{1,"Agrup: "			,Space(TAMSX3("ADJ_CODNIV")[1]),"","MV_PAR05:=U_TCRMPADJ('6'),MV_PAR06:=U_TCRMPADJ('7')"																								,"","IIF(MV_PAR01 <> '      ' .AND. lRet == .F.,.T.,.F.)"	,70,.T.})
	aAdd( aPergs ,{1,"Niv. Ref: "		,Space(TAMSX3("ADJ_XNVREF")[1]),"","MV_PAR05:=U_TCRMPADJ('8'),MV_PAR06:=U_TCRMPADJ('7')"																								,"","IIF(MV_PAR03=='0009',.T.,(MV_PAR04 := '    ',.F.))" 	,70,.T.})
	aAdd( aPergs ,{1,"Tipo de Venda: "	,Space(TAMSX3("PKG_TPVEND")[1]),"","" 																																					,"",".F."													,70,.T.})
	aAdd( aPergs ,{1,"Tipo de Venda: "	,Space(TAMSX3("ZX5_DESCRI")[1]),"","" 																																					,"",".F."													,70,.T.})
	
	// -- Valida o parambox
	
	If ParamBox(aPergs ,"Parametros",aRet)
	
		If !MV_PAR01 .OR. !MV_PAR02 .OR. !MV_PAR03 .OR. !MV_PAR05 .OR. !MV_PAR06
		
			MsgAlert("Dados inv�lidos, o processo n�o ser� executado!","Aten��o")
		
		Else 
		
		FWMsgRun(, {|oSay| U_TCRMAADJ(osay) }, "Aguarde", "Processando a rotina...")
		lRet := .T.
		
		EndIf
				
	Else
		MsgAlert("Cancelado","Alerta")	// Quando o processo for cancelado apenas fecha a tela
	EndIf
			
Return

//-------------------------------------------------------------------//
//	 Rotina de pesquisa dos dados e valida��o dos dados PARAMBOX	 //
//-------------------------------------------------------------------//

User Function TCRMPADJ(cOpc)
Local cRet := ''

	cOport 	:= MV_PAR01
	cAgrup	:= "000112"
	cTabela := "CRM024"
	
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
			cQry += " ,ADY_XMODAL XMODAL"
			cQry += " ,ADY_XNEGOC XNEGOC"
			cQry += " ,ADY_XCODNV XCODNV"
			cQry += " ,PKG_TPVEND TPVEND"
			
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
					     						     				     	     	
						Else
					    	MsgAlert("Agrupador inv�lido, por favor verifique!","Aten��o!")
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
				     	
				CASE  cOpc == '8'
				    
					DbSelectArea("PKG")
					dbSetOrder(1)//PKG_FILIAL+PKG_CODAGR+PKG_CODNIV
						 
				    	If dbSeek(xFilial("PKG") + cAgrup + MV_PAR04) .AND. MV_PAR04 <> '0009'
							cRet := PKG->PKG_TPVEND
					     						     				     	     	
						Else
							MsgAlert("Niv. Ref. inv�lido, por favor verifique!","Aten��o!")
							MV_PAR04 := "    "
							MV_PAR05 := "    "
							MV_PAR06 := "    "
						EndIf
					     	
					DbCloseArea() //Fecha a �rea da PKG
				     	
				ENDCASE
			
				(cAliasQry)->(DbSkip())
				
			Else
				
			EndIf
			
			(cAliasQry)->(DbCloseArea())
		
		Else
			If lRet = .F.
				MsgAlert("Oportunidade sem proposta, utilize rotina de oportunidades","Aten��o")
				lRet := .T.
			Else
			
			EndIf
		
		End If

		DBCloseArea() //Fecha a �rea da ADY
		
	Else
		If lRet = .F.
			MsgAlert("Oportunidade n�o Encontrada","Aten��o")
			lRet := .T.
			Return
		Else
			
		EndIf
	
	EndIf		
		
Return cRet

//-------------------------------------------------------------------//
//				Altera��o do agrupador								 //
//-------------------------------------------------------------------//

User Function TCRMAADJ()
Local cOportu	:= ""
Local cRevOp	:= ""
/*
	OK - SE N�O TIVER ADY INFORMA QUE N�O EXISTE PROPOSTA, QUE O PROCESSO DEVE SER EXECUTADO VIA ROTINA NORMAL DO CRM
	- SE O STATUS DA OPORTUNIDADE FOR DIFERENTE DE '1' OU DA PROPOSTA DIFERENTE DE 'A' N�O PODE FAZER ALTERA��O
	- PASSANDO PELAS VALIDA��ES ACIMA SEGUE CONFORME REGRAS ABAIXO
	
		- PESQUISA 
	ADJ_NROPOR = ADY_OPORTU ->
	ADJ_REVISA = ADY_REVISA
	
	*/

	//Carregando as vari�veis para preparar a altera��o

	DbSelectArea("AD1")
	dbSetOrder(1)      //AD1_FILIAL+AD1_NROPOR+AD1_REVISA                                                                                                                                

	DbSelectArea("ADJ")
	dbSetOrder(1)      //ADJ_FILIAL + ADJ_NROPOR + AD1_REVISA

	DbSelectArea("ADY")
	dbSetOrder(1)      //ADY_FILIAL + ADY_OPORTU + ADY_REVISA
	

	dbSeek(xFilial("AD1") + MV_PAR01)
		
		cOportu := AD1->AD1_NROPOR
		cRevOp	:= AD1->AD1_REVISA

	// ALTERA��O DE N�VEL AGRUPADOR
	RecLock("ADJ", .F.)
	ADJ->ADJ_CODNIV	:= MV_PAR03
	ADY->ADY_XMODAL := MV_PAR03
	ADY->ADY_XNEGOC := MV_PAR03
	
	// ALTERA��O DE N�VEL DE REFER�NCIA
	RecLock("ADY", .F.)
	ADJ->ADJ_XNVREF	:= MV_PAR04
	ADY->ADY_XCODNV := MV_PAR04
	
	// ALTERA��O DE Tipo de Venda
	ADY->ADY_XTPVEN := MV_PAR

	MsgInfo('Registro inserido com sucesso!','Inclus�o')

	MsUnLock() // Confirma e finaliza a opera��o

	DBCloseArea()
	
	DbCloseArea() //Fecha a �rea da AD1
	DbCloseArea() //Fecha a �rea da ADJ
	DbCloseArea() //Fecha a �rea da ADY
	
		
Return	