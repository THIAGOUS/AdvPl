#Include "Totvs.Ch"
#Include "FWMVCDef.Ch"
#INCLUDE "FILEIO.CH"   

User Function XPIR( )
Local lRet       := .T. 
Local aParam1 	 := {}
Local aRetP1	 := {}
Local cObs       := space(100) 
Local nI		 := 0
Local nPontos    := 0 
Local oDlg       := Nil    
Local nOpc       := 2 
Local cNomeArq   := '' 
//Local cLocDest   := "C:\teste\"//&(GetMv("MV_CFDSMAR"))+ "\RecibosXml\"//nome de pasta chumbado ocnforme solicitado

If MsgYesNo ("pir ?","pir ?")

	cObs := cGetFile("Arquivos CSV|*.CSV|","Arquivo",0,,.T.,GETF_ONLYSERVER+GETF_LOCALFLOPPY  )
	
	If !Empty(cObs)
		nOpc := 1
	EndIf
	
	If nOpc == 1 
		cObs := Alltrim(cObs)	
		If Empty( cObs ) 
			lRet := .F.
		Endif
			
		If !File(  (cObs)  )
			Alert ("Este archivo no existe: " + cObs)
			lRet := .F.
		EndIf
		
		If lRet 
			For ni := 1 to Len(cObs) 
				If substr(cObs,ni,1) == "\"
					nPontos := ni + 1
				EndIf 
			Next
			If nPontos > 0 
				cNomeArq := substr(cObs, nPontos, Len(cObs))
			EndIf
			
			Processa( {|| AJUSTPROD(cObs) }, "Aguarde...", "Processando ...",.F.)
		EndIf
	EndIf

EndIf

Alert("Finalizado")

Return()


Static function AJUSTPROD(cArqRet)
Local cBuffer  := ""
Local nCpos
Local cString := ""
Local aCampos := {}
Local nHandler
Local lPrimeiro := .T.
Local ni
Local cQry 
Private __cLog103 := "\temp\PROD_SEM_PIR" + DtoS(dDataBase) + "_" + StrTran(TIME(),":","") +  ".TXT" 	//Arquivo de log de processamento
Private cQryUpd 

cQryUpd := " UPDATE "+ RetSQLName( 'SB1' ) +" SB1 "
cQryUpd += " SET SB1.B1_XCLOUD  = '2'  "
cQryUpd += " WHERE SB1.B1_FILIAL = '" + FwxFilial('SB1')+ "' "
cQryUpd += " AND SB1.D_E_L_E_T_ = ' '  AND SB1.B1_XCLOUD  <> '1'  "
		
If TcSQLExec( cQryUpd ) == 0
 	TcSQLExec( 'COMMIT' )
EndIf	
	

nHandler := fOpen(cArqRet,68)
	
FT_FUSE(cArqRet)
FT_FGOTOP()
U_xAcaLog(__cLog103,"DATA " + dtos(DATE()) + ", HORA " + TIME()) 

While !FT_FEOF()
	
	IncProc( "Processando arquivo... "  )
	/*If lPrimeiro
		lPrimeiro := .F.
		FT_FSKIP()
		Loop
	EndIf*/
	
	cBuffer := FT_FReadLn()
	
	aCampos := {}
	cString := "" 
	
	For nCpos := 1 to Len(cBuffer)
		cString += IIf( Substr(cBuffer,nCpos,1) != ";", Substr(cBuffer,nCpos,1), "")

		If Substr(cBuffer,nCpos,1) == ";"
			aAdd(aCampos, Upper(cString))
			cString := ""
		Endif
	Next
	
	If !Empty(cString)
		aAdd(aCampos, Upper(cString))
	EndIf
		
	If Len(aCampos) > 0
	  
	  cQryUpd := " UPDATE "+ RetSQLName( 'SB1' ) +" SB1 "
	  cQryUpd += " SET SB1.B1_XCLOUD  = '1'  "
	  cQryUpd += " WHERE SB1.B1_FILIAL = '" + FwxFilial('SB1')+ "' "
	  cQryUpd += " AND SB1.B1_COD      = '" + aCampos[1]      + "' "
	  cQryUpd += " AND SB1.D_E_L_E_T_ = ' ' "
		
	  If TcSQLExec( cQryUpd ) == 0
	  	TcSQLExec( 'COMMIT' )
	  EndIf	
	  	  
	  cQry := GetNextAlias()
	  
	  BeginSql Alias cQry
				SELECT   PIR.* FROM   
				         %table:PIR% PIR
			       WHERE PIR.PIR_FILIAL    = %Exp:(FwxFilial("PIR"))%
					AND  PIR.PIR_PRODUT    = %Exp:(aCampos[1]  )%    
					AND  PIR.%NotDel%     
	  EndSql 
		
	  If (cQry)->(Eof())
	    U_xAcaLog(__cLog103,aCampos[1] + ";"  )
	    
	    Dbselectarea("SB1")
	    DbSetOrder(1)
	    If SB1->(dbSeek(FWxFilial("SB1") + aCampos[1]  ))
	    	reclock('PIR',.T.)
		    PIR->PIR_FILIAL := Fwxfilial('PIR')
		    PIR->PIR_PRODUT := SB1->B1_COD
		    PIR->PIR_DESC := SB1->B1_DESC 
		    PIR->PIR_ATIVO := 'S' 
		    PIR->PIR_UM := SB1->B1_UM
		    
		    msUnLock()
	    EndIf
	    
	   	(cQry)->(DBSkip())
	  EndIf
		
	  (cQry)->(DbCloseArea())
	EndIf
		
	FT_FSKIP()
EndDo

FT_FUSE()

FCLOSE(nHandler)

Alert ('Processo finalizado')

return


