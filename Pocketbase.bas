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

#Event: AuthStateChange(StateType As String)
#Event: RangeDownloadTracker(Tracker As PocketbaseRangeDownloadTracker)

Sub Class_Globals
	Private m_POCKETBASE_URL As String
	
	Type PocketbaseUser(Id As String,Email As String,isAnonymous As Boolean,EmailConfirmed As Boolean,CreatedAt As Long,UpdatedAt As Long,OptionalFields As Map,json As JSON,Error As PocketbaseError)
	Type PocketbaseDatabaseResult(Tag As Object,Columns As Map,Rows As List,Error As PocketbaseError)
	'Type PocketbaseRpcResult(Tag As Object,Data As Object,Error As PocketbaseError)
	Type PocketbaseError(Success As Boolean,StatusCode As Int,ErrorMessage As String,Data As Map)
	
	Type PocketbaseStorageFile(FileBody() As Byte,Error As PocketbaseError)
	
	'Type PocketbaseRealtime_Data(Schema As String,CommitTimestamp As Long,Columns As List,Records As Map,OldRecord As Map,EventType As String,DatabaseError As PocketbaseError,Table As String)
	'Type PocketbaseRealtime_BroadcastData(Event As String,Payload As Map,DatabaseError As PocketbaseError)
	'Type PocketbaseRealtime_PresenceData(Event As String,Joins As Map,Leaves As Map,DatabaseError As PocketbaseError)
	
	Private m_Authentication As Pocketbase_Authentication
	Private m_Database As Pocketbase_Database
	Private m_Storage As Pocketbase_Storage
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private m_LogEvents As Boolean = False
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(URL As String)
	m_POCKETBASE_URL = URL & "/api/collections"
	
	m_Authentication.Initialize(Me,"Pocketbase")
	m_Database.Initialize(Me)
	m_Storage.Initialize(Me)

End Sub

Public Sub InitializeEvents(Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

Public Sub setLogEvents(Enabled As Boolean)
	m_LogEvents = Enabled
End Sub

Public Sub getLogEvents As Boolean
	Return m_LogEvents
End Sub

Public Sub getURL As String
	Return m_POCKETBASE_URL
End Sub

Public Sub getAuth As Pocketbase_Authentication
	Return m_Authentication
End Sub

Public Sub getDatabase As Pocketbase_Database
	Return m_Database
End Sub

Public Sub getStorage As Pocketbase_Storage
	Return m_Storage
End Sub

#Region Events

Private Sub Pocketbase_AuthStateChange(StateType As String)
	If Pocketbase_Functions.SubExists2(mCallBack,mEventName & "_AuthStateChange",1) Then
		CallSub2(mCallBack,mEventName & "_AuthStateChange",StateType)
	End If
End Sub

#End Region