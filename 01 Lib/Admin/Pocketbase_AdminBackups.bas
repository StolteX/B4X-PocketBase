B4J=true
Group=Admin
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private m_Pocketbase As Pocketbase
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(ThisPocketbase As Pocketbase)
	m_Pocketbase = ThisPocketbase
End Sub

'https://pocketbase.io/docs/api-backups/

'Returns list with all available backup files.
'Only superusers can perform this action.
'<code>	Wait For (xPocketbase.Database.SelectData.Collection("dt_Task").GetFullList("-Task_Name")) Complete (DatabaseResult As PocketbaseDatabaseResult)
'	xPocketbase.Database.PrintTable(DatabaseResult)</code>
Public Sub GetFullList(Fields As String) As ResumableSub
	
	Dim AdminRequest As Pocketbase_DatabaseSelect = m_Pocketbase.Database.SelectData.Collection("")
	CallSub2(AdminRequest,"SetApiEndpoint","backups")

	If Fields <> "" Then AdminRequest.Parameter_Fields(Fields)

	Wait For (AdminRequest.GetCustom) Complete (DatabaseResult As PocketbaseDatabaseResult)
	Return DatabaseResult
	
End Sub

'Create

'Upload

'Delete

'Restore

'Download