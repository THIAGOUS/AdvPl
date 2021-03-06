#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXZX5
Rotina de manuten��o da ZX5

@author     Thiao Vitor
@since      26/02/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXZX5()
Local cAlias 		:= "ZX5"
Local cUserId		:= __CUSERID //Recebe o id do usu�rio logado (vari�vel padr�o do sistema)
Local cUsr			:= SuperGetMV("AT_USRZX5",,"000000") //Par�metro com os grupos que acessam a rotina
Local cGrupo		:= ""
Local aGrupo		:= {}
Local nI			:= 0
Local lRet			:= .F. //Vari�vel para valida��o do alert para usu�rios sem permiss�o
Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Private cCadastro 	:= "Manuten��o de dados ZX5"
Private aRotina 	:= {}

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
			lRet := .T.

// -- Adi��o dos bot�es do MBRWOSE
			AADD(aRotina,{"Pesquisar"	, 	"AxPesqui",0,1})
			AADD(aRotina,{"Visualizar"	, 	"AxVisual",0,2})
			AADD(aRotina,{"Incluir"		, 	"AxInclui",0,3})
			AADD(aRotina,{"Alterar"		, 	"AxAltera",0,4})
			AADD(aRotina,{"Excluir"		, 	"AxDeleta",0,5})

// -- Abertura da Area + �ndice + Cria��o do MBROWSE			
			dbSelectArea(cAlias)
			dbSetOrder(1)
			mBrowse(6,1,22,75,cAlias)
	
	
		Else
	
		EndIf
	Next

// -- Condi��o para valida��o do acesso para axibi��o do alert	
	If lRet <> .T.
	
		MsgAlert("O usu�rio " + CUSERNAME + " N�o possui acesso a rotina!",'Acesso negado!')
	Else
	
	EndIf
		
Return