#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCRMXZX5
Rotina de manutenção da ZX5

@author     Thiao Vitor
@since      26/02/2019
@version    P12
/*/
//-------------------------------------------------------------------

User Function TCRMXZX5()
Local cAlias 		:= "ZX5"
Local cUserId		:= __CUSERID //Recebe o id do usuário logado (variável padrão do sistema)
Local cUsr			:= SuperGetMV("AT_USRZX5",,"000000") //Parâmetro com os grupos que acessam a rotina
Local cGrupo		:= ""
Local aGrupo		:= {}
Local nI			:= 0
Local lRet			:= .F. //Variável para validação do alert para usuários sem permissão
Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Private cCadastro 	:= "Manutenção de dados ZX5"
Private aRotina 	:= {}

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
			lRet := .T.

// -- Adição dos botões do MBRWOSE
			AADD(aRotina,{"Pesquisar"	, 	"AxPesqui",0,1})
			AADD(aRotina,{"Visualizar"	, 	"AxVisual",0,2})
			AADD(aRotina,{"Incluir"		, 	"AxInclui",0,3})
			AADD(aRotina,{"Alterar"		, 	"AxAltera",0,4})
			AADD(aRotina,{"Excluir"		, 	"AxDeleta",0,5})

// -- Abertura da Area + Índice + Criação do MBROWSE			
			dbSelectArea(cAlias)
			dbSetOrder(1)
			mBrowse(6,1,22,75,cAlias)
	
	
		Else
	
		EndIf
	Next

// -- Condição para validação do acesso para axibição do alert	
	If lRet <> .T.
	
		MsgAlert("O usuário " + CUSERNAME + " Não possui acesso a rotina!",'Acesso negado!')
	Else
	
	EndIf
		
Return