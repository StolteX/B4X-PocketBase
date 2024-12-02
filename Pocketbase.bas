B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.45
@EndOfDesignText@
#If Documentation
Updates
V1.00
	-Release
#End IF

Sub Class_Globals
	Private m_POCKETBASE_URL As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(URL As String)
	m_POCKETBASE_URL = URL
	
'	m_Authentication.Initialize(Me,"Supabase")
'	m_Database.Initialize(Me)
'	m_Storage.Initialize(Me)

End Sub