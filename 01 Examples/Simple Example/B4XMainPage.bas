B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private xPocketbase As Pocketbase
End Sub

Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("frm_main")
	
	B4XPages.SetTitle(Me,"Pocketbase Simple Example")
	
#If B4J
	xPocketbase.Initialize("http://127.0.0.1:8090") 'Localhost -> B4J only
#Else
	xPocketbase.Initialize("http://192.168.188.142:8090") 'IP of your PC
#End If

	xPocketbase.InitializeEvents(Me,"Pocketbase")
	xPocketbase.LogEvents = True
	
End Sub
