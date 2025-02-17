B4J=true
Group=Admin
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private m_Pocketbase As Pocketbase
End Sub

'Only superusers have access to these features
Public Sub Initialize(ThisPocketbase As Pocketbase)
	m_Pocketbase = ThisPocketbase
End Sub

Public Sub AuthWithPassword(Email As String,Password As String) As ResumableSub
	
	Dim AdminRequest As Pocketbase_Authentication = m_Pocketbase.Auth
	AdminRequest.UserCollectionName = "_superusers"
	Wait For (AdminRequest.AuthWithPassword(Email,Password)) Complete (User As PocketbaseUser)
	Return User
	
End Sub

Public Sub Backups As Pocketbase_AdminBackups
	
	Dim AdminBackups As Pocketbase_AdminBackups
	AdminBackups.Initialize(m_Pocketbase)
	Return AdminBackups
	
End Sub
