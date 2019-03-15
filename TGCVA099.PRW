#INCLUDE 'TOTVS.CH'
/*-------------------------------------------------------------------
Reabertura de competência
@author  Quaresma	
@version P12 
@since  01/07/2018
----------------------------------------------------------------------*/

/* ---Atualização 10/01/2019---
- Inserção de validação de acesso a rotina via parãmetro
*/ 

User Function TGCVA099()
//Variáveis
Local oDlg       := FWDialogModal():New() //Variavel oDlg que irá instanciar a classe para exibir a tela
Local oPanel	 := NIL	
Local oTFont     := TFont():New(,,-16,.T.)	//Instancia a classe TFont	
Local cLoja      := space(02)
Local cContrato  := space(09)
Local bAltera
Local bClose 	 := {||oDlg:Deactivate()}
Local cUsr		 := SuperGetMV("AT_USRCNB",,"008464")

If __CUSERID $ cUsr

	bAltera := {||ListComp(cContrato)} //Botão que irá chamar a função para listar os itens do contrato
	
	// Propriedades da classe FWDialogModal
	oDlg:SetTitle('Reabertura de competência')
	oDlg:SetBackground(.T.)
	oDlg:SetSize(200,300)
	oDlg:EnableFormBar(.T.)
	oDlg:CreateDialog() 
	oDlg:CreateFormBar()
	oPanel := oDlg:GetPanelMain()
	oDlg:addCloseButton(bClose)
	oDlg:AddButton("Alterar",bAltera,"Alterar", , .T., .F., .T., ) 
	
	
	//Componentes texto da janela	
	@ 06, 10  SAY "Contrato"  SIZE  150, 10 PIXEL OF oPanel FONT oTFont
	@ 06, 130 SAY "Loja"        SIZE  65, 10 PIXEL OF oPanel FONT oTFont
	
	//Componentes de entrada dos dados
	@ 06, 50 MSGET cContrato      SIZE 50,10 PIXEL OF oPanel
	@ 06, 150 MSGET cLoja          SIZE 50,10 PIXEL OF oPanel
	
	oDlg:Activate()	

Else
	
	MsgAlert("O usuário " + UPPER(CUSERNAME) + " não Possui acesso a rotina!")
	
EndIf 

Return

/*-------------------------------------------------------------------
Tela para Listar os produtos
@author  Quaresma	
@version P12 
@since  05/07/2018
@param   cContrato
----------------------------------------------------------------------*/
Static function ListComp(cContrato)

Local oDlg2 	:= FWDialogModal():New()
Local oPanel	:= NIL
Local oBrw  	:= NIL
Local aCabec 	:= { 'Filial','Contrato','Revisao','Numero', 'Item ', 'Produto', 'Descricao','Competência', 'Proposta'}
Local aConteudo := {}
Local cAliasQry	:= GetNextAlias() 			      //Alias da Query Temp
Local exp1		:= " "	
Local aCopia	:= {} //Array utilzido para copiar estado original da CNB e posteriromente garvar o log e comparar o XCOMPE 
Local cRevisa 	
Local bConfirma := {||gravaComp(aConteudo,aCopia,cContrato,cRevisa)}
Local bClose 	:= {||oDlg2:Deactivate()}
Local lOk := .F.

//rotina que irá validar a revisão do contrato
validaRevisao(cContrato,@cRevisa,@lOk)

//Valida se retornou a revisão do contrato para pooder posicionar os registros
If (lOk)	
	
	exp1 := "%AND CNB.CNB_CONTRA = '"+ cContrato + "' AND CNB.CNB_REVISA ='"+ cRevisa +"'%" //Adiciona condição da data na query	
	
	//Query para montar os dados do contrato
    BeginSql Alias cAliasQry 
	SELECT 
		CNB.CNB_FILIAL  AS FILIAL,
		CNB.CNB_CONTRA AS CONTRA,
		CNB.CNB_REVISA AS REVISA,
		CNB.CNB_NUMERO AS NUMERO,
		CNB.CNB_ITEM AS ITEM,
		CNB.CNB_PRODUT AS PRODUT,
		CNB.CNB_DESCRI AS DESCRI,
		CNB.CNB_XCOMPE AS XCOMPE,	
		CNB.CNB_PROPOS AS PROPOS						
		FROM %table:CNB% CNB
		WHERE 
		CNB.%notDel%
		AND CNB.CNB_FILIAL = %xFilial:CNB%
		AND CNB.CNB_SITUAC IN ('A','G','M','P','S')
		%exp:exp1%
		ORDER BY 	
		CNB.CNB_FILIAL,	
		CNB.CNB_CONTRA,
		CNB.CNB_REVISA,
		CNB.CNB_NUMERO,	
		CNB.CNB_ITEM,
		CNB.CNB_PROPOS
	EndSQL                  
	                                                              
	//Vai ao topo da tabela temporária
	(cAliasQry)->(dbGoTop())
	
	//inicial o laço onde vão ser adicionadas as linhas por coluna
	While(! (cAliasQry)->(EOF()))
	
		Aadd(aConteudo,{(cAliasQry)->FILIAL,(cAliasQry)->CONTRA,(cAliasQry)->REVISA,(cAliasQry)->NUMERO,(cAliasQry)->ITEM,(cAliasQry)->PRODUT,(cAliasQry)->DESCRI,(cAliasQry)->XCOMPE, (cAliasQry)->PROPOS})
		//Com o aCopia eu tenho uma copia dos dados da CNB para o futuro log
		Aadd(aCopia,{(cAliasQry)->FILIAL,(cAliasQry)->CONTRA,(cAliasQry)->REVISA,(cAliasQry)->NUMERO,(cAliasQry)->ITEM,(cAliasQry)->PRODUT,(cAliasQry)->DESCRI,(cAliasQry)->XCOMPE, (cAliasQry)->PROPOS})
		
		(cAliasQry)->(dbSkip())
	
	EndDo	
	
	// Propriedades da classe FWDialogModal
	oDlg2:SetTitle('Reabertura de competência')
	oDlg2:SetBackground(.T.)
	oDlg2:SetSize(300,400)
	oDlg2:EnableFormBar(.T.)
	oDlg2:CreateDialog() 
	oDlg2:CreateFormBar()
	oPanel2 := oDlg2:GetPanelMain()
	oDlg2:AddButton("Confirmar",bConfirma,"Confirmar", , .T., .F., .T., ) 
	oDlg2:addCloseButton(bClose)
	// TWBROWSE Para listar as planilhas do contrato
	oBrw := TWBrowse():New( 0,0,100,100,,aCabec,,oPanel2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oBrw:SetArray(aConteudo)
	oBrw:bLine	:= {|| {	aConteudo[oBrw:nAt,1],;		
							aConteudo[oBrw:nAt,2],;
							aConteudo[oBrw:nAt,3],;			
							aConteudo[oBrw:nAt,4],;		
							aConteudo[oBrw:nAt,5],;	
							aConteudo[oBrw:nAt,6],;	
							aConteudo[oBrw:nAt,7],;	
							aConteudo[oBrw:nAt,8],;
							aConteudo[oBrw:nAt,9]}}			
	oBrw:bLDblClick := {||editaComp(@aConteudo,oBrw)}
		
	// Ajusta alinhamento do TWBrowse para pegar o dialogo inteiro
	oBrw:Align := CONTROL_ALIGN_ALLCLIENT
	oDlg2:Activate()
	
EndIf
	
Return  
/*-------------------------------------------------------------------
Validar a revisão do contrato
@author  Quaresma	
@version P12 a
@since  05/07/2018
@param   cContrato,@cRevisa
----------------------------------------------------------------------*/
Static Function validaRevisao(cContrato,cRevisa,lOk)

// Posiciona na CN9 para identificar a revisão atual do contrato
DbSelectArea("CN9")
DbSetOrder(8) //INDICE DE PESQUISA DE ACORDO COM O SIX CN9_FILIAL+CN9_NUMERO+CN9_REVATU    
DbGoTop()                                                                                                                          
If DbSeek("           "+cContrato+"      ",.T.)	

	@cRevisa := CN9->CN9_REVISA
	@lOk := .T.
Else	
	alert("não foi possóvel identificar a revisão do contrato")
	@lOk := .F.
EndIf

DbcloseArea()

Return 

/*-------------------------------------------------------------------
Editar as linhas
@author  Quaresma	
@version P12 
@since  20/07/2018
@param aConteudo,oBrw
----------------------------------------------------------------------*/
Static Function editaComp(aConteudo,oBrw)
//Editar as linhas do contrato
lEditCell(@aConteudo,oBrw,PesqPict("CNB","CNB_XCOMPE"),8)

Return .T.


/*-------------------------------------------------------------------
Gravar a nova competêmcia
@author  Quaresma	
@version P12 
@since  23/07/2018
@param aConteudo,aCopia,cContrato,cRevisa
----------------------------------------------------------------------*/
Static Function gravaComp(aConteudo,aCopia,cContrato,cRevisa)

// Variáveis que irão receber o conteudo do ARRAY com a inoformação antiga e nova do contrato
Local cCompAnt  
Local cCompNov
Local cNumero
Local cItem
Local nCont := 0 
Local xFil := (aConteudo[1][1])
Local lAlterado := .F.


IF !(validaLock(xFil,cContrato)) //Valida o lock do contrato
	DbSelectArea('CNB')   
	DbSetOrder(1)//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM 
	For nCont := 1 to Len(aConteudo) Step 1
		//DBSEEK UTILIZANDO O INDICE 1
		If DbSeek((aConteudo[nCont][1])+(aConteudo[nCont][2])+(aConteudo[nCont][3])+(aConteudo[nCont][4])+(aConteudo[nCont][5]))
			Reclock("CNB",.F.) //Lock no registro para alteração
			//atualiza o XCOMPE	
			CNB->CNB_XCOMPE := (aConteudo[nCont][8]) 
			
			//Nesse if eu valido se o foi alterada a competência comparando com o acopia para poder limpar o primed apenas dos itens alterados
			If (aConteudo[nCont][8]) != (aCopia[nCont][8])
				
				CNB->CNB_PRIMED := CTOD("") 
				
				//Aqui eu vou chamar a rotina para gravar o log apenas para os com competência alterada
				cCompAnt := (aCopia[nCont][8])
				cCompNov := (aConteudo[nCont][8])
				cNumero  := (aCopia[nCont][4])
				cItem    := (aConteudo[nCont][5])
				//COMENTADA A LINHA QUE GRAVA O LOG				
				//gravaLog(cCompAnt,cCompNov,cNumero,cItem,cContrato,cRevisa)
				lAlterado := .T.
				
			EndIf
								
			MsUnLock()	
		EndIf
			
	Next nCont
	
	DbCloseArea()
		If (lAlterado)
		
			Alert("Competências alteradas com sucesso! É necessário gerar o cronograma financeiro.")
		Else
			Alert("Nenhuma competência Alterada")
		EndIf

EndIf                                                                                                                                                                                                  

Return 

/*-------------------------------------------------------------------
Valida o lock do contrato
@author  Quaresma	
@version P12 
@since  25/07/2018
@param cContra,cFil
----------------------------------------------------------------------*/
Static Function validaLock(xFil,cContrato)

Local lTrava //Variavel logica para retornar se o contrato está em lock ou nao

DbSelectArea("PHW")
DbSetOrder(2) //PHW_FILIAL+PHW_STATUS+PHW_CHAVE
DbGoTop()
If DbSeek(xFil+"1"+"CN9"+xFil+ cContrato)

	alert("Contrato sendo utilizado por outro usuário")
	lTrava := .T.
Else
	lTrava := .F.
	
EndIf
DbCloseArea()


Return lTrava


/*-------------------------------------------------------------------
Grava o log de alteração na planilha
@author  Quaresma	
@version P12 
@since  02/08/2018
@param cCompAnt,cCompNov,cNumero,cItem,cContrato,cRevisa
----------------------------------------------------------------------*/

Static Function gravaLog(cCompAnt,cCompNov,cNumero,cItem,cContrato,cRevisa)

Local cNamUser := RetCodUsr()//Retorna o codigo do usuario 
Local cSequen := GETSXENUM("ZZP", "ZZP_ID")
LOCAL aAreaAnt := GETAREA()
CHKFILE("ZZP")
DbSelectArea("ZZP")
DbSetOrder(1)
DbGotop()

Reclock("ZZP",.T.) 

	ZZP->ZZP_CAMPO  := "CNB_XCOMPE"
	ZZP->ZZP_CONANT := cCompAnt
	ZZP->ZZP_CONNOV := cCompNov
	ZZP->ZZP_USUARI := cNamUser
	ZZP->ZZP_DATA   := DATE()
	ZZP->ZZP_OBS    := "CompetEncia alterada pela rotina U_TGCVA099"
	ZZP->ZZP_ROTINA := "U_TGCVA099"
	ZZP->ZZP_ID		:= cSequen   
	ZZP->ZZP_CHAVE  := cContrato+cRevisa+cNumero+cItem	
			
MsUnLock()


DbCloseArea()	

RESTAREA(aAreaAnt)	

Return