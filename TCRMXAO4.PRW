#Include "PROTHEUS.CH"

//------------------------------------------------------------
/*/{Protheus.doc} TCRMAO4
Reprocessamento de privilégios das oportunidades a partir do código do vendedor
@author Thiago Vitor
@since 11/07/2018
@version 1.0
/*/
//------------------------------------------------------------

/* ---Atualização---
@author Thiago Vitor
@since 21/12/2018
- Inserção da função de processamento FWMsgRun
- Correção da Mensagem ao clicar no botão Cancelar
*/ 

User function TCRMAO4()

Local aCodOport		:= {}		 //array de oportunidades
Local nNVESTN		:= 0		 //nivel de estrutura 
Local nI			:= 0
Local cVend			:= ""		 //codigo vendedor
Local cEsq			:= "           "
Local cDir			:= "             "
Local cENTIDA		:= "AD1"
Local cCODUSR		:= ""
Local cIDESTN		:= ""
Local CTRLTT		:= .T.
Local PROPRI		:= .T.
Local cUSRPAP		:= ""
Local TPACES		:= "1"
Local PRIORI		:= "0"
Local cPerg			:= Padr("AO4OPORT",10)
Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()

// -- Pergunta atualização
putSx1(cPerg,"01","Cod. Executivo","Cod. Executivo","Cod. Executivo","mv_ch1","G",6,0,0,"C","","SA3","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","")

lContinua 	:= Pergunte(cPerg,.t.) //.or. ! Empty(mv_par01)

// -- validação de dados
If !lContinua .or. (Empty(mv_par01))
	If Empty(mv_par01)
		MsgAlert("Processo encerrado por falta de dados","Atenção!")
		Return()
	Else
		MsgAlert("Processo cancelado","Atencão")
		Return()
	EndIf
EndIf

// -- Carrega variaveis 
cVend 	:= mv_par01

// -- carrega dados do vendedor 
DbSelectArea("AZS")
DbSetOrder(4)		// -- AZS_FILIAL + AZS_VEND
If dbSeek(xFilial("AZS")+cVend)
	cCODUSR	:= AZS->AZS_CODUSR
	cIDESTN	:= AZS->AZS_IDESTN
	nNVESTN	:= AZS->AZS_NVESTN
	cUSRPAP	:= AZS->AZS_SEQUEN+AZS->AZS_PAPEL
Else 
	MsgAlert("Vendedor não localizado no cadastro de vendedor!","Atenção")
	Return()
Endif

// Query que verifica as contas da carteira do vendedor digitado e suas oportunidades da empresa logada

cQry :="SELECT AD1.AD1_NROPOR AS NROPORT "
cQry +="FROM " +RetSqlName("SA1")+ " SA1 "
cQry +="INNER JOIN " +RetSqlName("AD1")+ " AD1 ON "
cQry +="	AD1.AD1_FILIAL = '" + xFilial("AD1")+"'"
cQry +="	AND AD1.D_E_L_E_T_ = ' '"
cQry +="	AND AD1.AD1_CODCLI = SA1.A1_COD "
cQry +="WHERE "
cQry +="	SA1.A1_FILIAL = '" +xFilial("SA1") + "'"
cQry +=" 	AND SA1.D_E_L_E_T_ =  ' '"
cQry +="	AND SA1.A1_VEND = '"  + cVend + "'"
cQry += " UNION ALL "
cQry +="SELECT AD1.AD1_NROPOR AS NROPORT "
cQry +="FROM " +RetSqlName("SUS")+ " SUS "
cQry +="INNER JOIN " +RetSqlName("AD1")+ " AD1 ON "
cQry +="	AD1.AD1_FILIAL = '" + xFilial("AD1")+"'"
cQry +="	AND AD1.D_E_L_E_T_ = ' '"
cQry +="	AND AD1.AD1_PROSPE = SUS.US_COD "
cQry +="WHERE "
cQry +="	SUS.US_FILIAL = '" +xFilial("SUS") + "'"
cQry +=" 	AND SUS.D_E_L_E_T_ =  ' '"
cQry +="	AND SUS.US_VEND = '"  + cVend + "'"

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
If (cAliasQry)->(! Eof())
	aCodOport := {}
	While (cAliasQry)->(! Eof())
		Aadd(aCodOport,(cAliasQry)->NROPORT)	
		(cAliasQry)->(DbSkip())
	EndDo
	
EndIf
(cAliasQry)->(DbCloseArea())

// -- verifica se ja existe privilegios e atualiza de acordo com os dados da AZS, caso não exista inclui o registro.
DbSelectArea("AO4")
dbSetOrder(2)      //AO4_FILIA + AO4_CODUSR + AO4_ENTIDA + AO4_CHVREG

For nI := 1 to Len(aCodOport)
	
	If Len(aCodOport[nI]) <> 6

		MsgAlert("Verifique a numeração da oportunidade "+aCodOport[nI]+ " ","Oportunidade não encontrada!")
	
	ElseIf dbSeek(xFilial("AO4") + cCODUSR + cENTIDA + cEsq+aCodOport[nI]+cDir )    // -- Avalia o retorno da pesquisa realizada
     
		RECLOCK("AO4", .F.)
		
		AZS->AZS_IDESTN := cIDESTN
		AO4->AO4_NVESTN	:= nNVESTN
		AO4->AO4_CTRLTT	:= CTRLTT
 
		MSUNLOCK()     // Destrava o registro
     
	Else

		RECLOCK("AO4",.T.) 
	
		AO4->AO4_FILIAL := xFilial("AO4")
		AO4->AO4_ENTIDA	:= cENTIDA
		AO4->AO4_CHVREG	:= cEsq+aCodOport[nI]+cDir
		AO4->AO4_CTRLTT	:= CTRLTT
		AO4->AO4_CODUSR	:= cCODUSR
		AO4->AO4_IDESTN	:= cIDESTN
		AO4->AO4_NVESTN	:= nNVESTN
		AO4->AO4_PROPRI := PROPRI
		AO4->AO4_XTPCOM := "C"
		AO4->AO4_USRPAP := cUSRPAP
		AO4->AO4_TPACES	:= TPACES
		AO4->AO4_PRIORI := PRIORI
	
		MSUNLOCK()
	EndIf

Next
DbCloseArea()

MsgAlert("Registros incluidos com Sucesso!","Privilégios")

Return()

User Function TCRMxAO4()
FWMsgRun(, {|oSay| U_TCRMAO4(osay) }, "Aguarde", "Processando a rotina...")
Return