#Include "PROTHEUS.CH"

User Function TCRMTSPC()
 
// define a quantidade de caracteres do campo
Local cGet := Space(10)
 
// Cria diálogo
Local oDlg := MSDialog():New(500,180,550,700,'Dados Usuário',,,,,,,,,.T.)
 
	oTButton1 := TButton():New( 08, 080, "Suspects",oDlg,{||U_TCRMXSPP}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton2 := TButton():New( 08, 130, "Prospects",oDlg,{||U_TCRMXPPC)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
 
// Ativa diálogo
oDlg:Activate()
Return

//------------------------------------------------------------

User Function TCRMXSPP()
FWMsgRun(, {|oSay| U_CRMXSPP(osay) }, "Aguarde", "Processando a rotina...")
Return

User Function TCRMXPPC()
FWMsgRun(, {|oSay| U_CRMXPPC(osay) }, "Aguarde", "Processando a rotina...")
Return

//------------------------------------------------------------
/*/{Protheus.doc} CRMXSPP
Ajuste de base de suspect já convertidos par prospect
@author Thiago Vitor / Fabiano Dantas 
@since 27/11/2018
@version 1.0
/*/
//------------------------------------------------------------

User function CRMXSPP()

Local nI			:= 0
Local aCodQua 		:= {}
Local cStatus 		:= "6"
Local cDtConv		:= CTOD("28/11/2018")
Local cHrConv		:= "11:00:00"
Local cDtAtu		:= " "
Local cHrAtu		:= " "
Local cLojPro		:= "00"
Local cObs			:= "XCRMX"
Local cQry			:= " "
Local cAliasQry		:= GetNextAlias()


cQry := "SELECT DISTINCT SUS.US_COD AS CODCLI, SUS.US_CGC AS CODCGC "
cQry += "FROM " +RetSqlName("ACH")+ " ACH " 
cQry += "INNER JOIN " +RetsqlName("SUS")+ " SUS ON "
cQry += "SUS.US_FILIAL = '" + xFilial("SUS") + "' "
cQry += "AND SUS.D_E_L_E_T_ = ' ' "
cQry += "AND SUS.US_CGC = ACH.ACH_CGC "
cQry += "WHERE "
cQry += "ACH_FILIAL ='" + xFilial("ACH") + "' "
cQry += "AND ACH.D_E_L_E_T_ = ' ' "
cQry += "AND ACH_CGC NOT IN (' ','1','0') "
cQry += "AND (ACH_STATUS <> '6' OR ACH_CODPRO = ' ' OR ACH_DTCONV = ' ' OR ACH_HRCONV = ' ' ) "
cQry += "AND ACH_CODIGO = 'AADVGN'"

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)

If (cAliasQry)->(! Eof())
	aCodQua := {}
	While (cAliasQry)->(! Eof())
		Aadd(aCodQua,{(cAliasQry)->CODCLI,(cAliasQry)->CODCGC})
		(cAliasQry)->(DbSkip())

	EndDo
EndIf	

//-------------------------------------

DbSelectArea("ACH")
dbSetOrder(2)      //ACH_FILIAL + ACH_CGC	
	
For nI:= 1 to len(aCodQua)
	If Len(aCodQua[nI,2]) <> 14 .AND. Len(aCodQua[nI,2]) <> 11 
		MsgAlert("O CPF/CNPJ do " + (cAliasQry)->CODCLI + "é inválido ","Atenção!")
		
	ElseIf DbSeek(xFilial("ACH")+ aCodQua[nI,2])
	
		RECLOCK("ACH", .F.)
		
		ACH->ACH_STATUS 	:= cStatus
		ACH->ACH_CODPRO 	:= aCodQua[nI,1]
		ACH->ACH_LOJPRO		:= cLojPro
		ACH->ACH_XGRBEM		:= cObs		
		
		cDtAtu := DTOC(ACH->ACH_DTCONV)
		cHrAtu := ACH->ACH_HRCONV
				
		If 	cDtAtu == "  /  /    " .AND. cHrAtu == "        " 
		
			ACH->ACH_DTCONV := cDtConv
			ACH->ACH_HRCONV	:= cHrConv
			
		ElseIf cDtAtu == "  /  /    "
			
			ACH->ACH_DTCONV := DTOC(cDtConv)
			
		ElseIf cHrAtu == "        " 
			
			ACH->ACH_HRCONV	:= cHrConv
			
		EndIf
		
		MSUNLOCK()
		

	EndIf
		
Next

	MsgAlert("A base de suspects foi atualizada com sucesso!","Atenção!")	

Return

//------------------------------------------------------------
/*/{Protheus.doc} CRMXPPC
Ajuste de base de prospect já convertidos para clientes
@author Thiago Vitor / Fabiano Dantas 
@since 27/11/2018
@version 1.0
/*/
//------------------------------------------------------------

User function CRMXPPC()

Local nI			:= 0
Local aCodQua 		:= {}
//Local aCgcQua		:= {}
Local cStatus 		:= "6"
Local cDtConv		:= CTOD("28/11/2018")
Local cHrConv		:= "11:00:00"
Local cDtAtu		:= " "
Local cHrAtu		:= " "
Local cLojPro		:= "00"
Local cObs			:= "XCRMX"
Local cQry			:= " "
Local cAliasQry		:= GetNextAlias()


cQry := "SELECT DISTINCT SA1.A1_COD AS CODCLI, SA1.A1_CGC AS CODCGC "
cQry += "FROM " +RetSqlName("SUS")+ " SUS " 
cQry += "INNER JOIN " +RetsqlName("SA1")+ " SA1 ON "
cQry += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQry += "AND SA1.D_E_L_E_T_ = ' ' "
cQry += "AND SA1.A1_CGC = SUS.US_CGC "
cQry += "WHERE "
cQry += "US_FILIAL ='" + xFilial("SUS") + "' "
cQry += "AND SUS.D_E_L_E_T_ = ' ' "
cQry += "AND US_CGC NOT IN (' ','1','0') "
cQry += "AND (US_STATUS <> '6' OR US_CODCLI = ' ' OR US_DTCONV = ' ' OR US_HRCONV = ' ' )"

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)

If (cAliasQry)->(! Eof())
	aCodQua := {}
	While (cAliasQry)->(! Eof())
		Aadd(aCodQua,{(cAliasQry)->CODCLI,(cAliasQry)->CODCGC})
		(cAliasQry)->(DbSkip())

	EndDo
EndIf	

//-------------------------------------

DbSelectArea("SUS")
dbSetOrder(4)      //ACH_FILIAL + ACH_CGC	
	
For nI:= 1 to len(aCodQua)
	If Len(aCodQua[nI,2]) <> 14 .AND. Len(aCodQua[nI,2]) <> 11 
		MsgAlert("O CPF/CNPJ do " + (cAliasQry)->CODCLI + "é inválido ","Atenção!")
		
	ElseIf DbSeek(xFilial("SUS")+ aCodQua[nI,2])
	
		RECLOCK("SUS", .F.)
		
		SUS->US_STATUS 	:= cStatus
		SUS->US_CODCLI 	:= aCodQua[nI,1]
		SUS->US_LOJACLI	:= cLojPro
		SUS->US_XCODMNE	:= cObs		
		
		cDtAtu := DTOC(SUS->US_DTCONV)
		cHrAtu := SUS->US_HRCONV
				
		If 	cDtAtu == "  /  /    " .AND. cHrAtu == "        " 
		
			SUS->US_DTCONV := cDtConv
			SUS->US_HRCONV	:= cHrConv
			
		ElseIf cDtAtu == "  /  /    "
			
			SUS->US_DTCONV := DTOC(cDtConv)
			
		ElseIf cHrAtu == "        " 
			
			SUS->US_HRCONV	:= cHrConv
			
		EndIf
		
		MSUNLOCK()
		

	EndIf
		
Next

	MsgAlert("A base de prospects foi atualizada com sucesso!","Atenção!")	

Return