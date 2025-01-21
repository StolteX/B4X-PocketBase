B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private m_Pocketbase As Pocketbase
	
	Private m_TableName As String
	Private m_ColumnValue As Map
	Private m_CustomParameters As String = ""
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(ThisPocketbase As Pocketbase)
	m_Pocketbase = ThisPocketbase
	
End Sub

Public Sub Collection(TableName As String) As Pocketbase_DatabaseUpdate
	m_TableName = TableName
	Return Me
End Sub

Public Sub Update(ColumnValue As Map) As Pocketbase_DatabaseUpdate
	m_ColumnValue = ColumnValue
	Return Me
End Sub

#Region CustomParameters

'Auto expand record relations.
Public Sub Parameter_Expand(Expand As String) As Pocketbase_DatabaseUpdate
	m_CustomParameters = m_CustomParameters & $"&expand=${Expand}"$
	Return Me
End Sub

'Comma separated string of the fields to return in the JSON response (by default returns all fields).
'<code>CustomQuery.Parameter_Fields("Task_Name,Task_CompletedAt")</code>
Public Sub Parameter_Fields(Fields As String) As Pocketbase_DatabaseUpdate
	m_CustomParameters = m_CustomParameters & $"&fields=${Fields}"$
	Return Me
End Sub

#End Region

Public Sub Execute(RecordId As String) As ResumableSub
	
	Dim DatabaseResult As PocketbaseDatabaseResult
	DatabaseResult.Initialize
	DatabaseResult.Columns.Initialize
	DatabaseResult.Rows.Initialize
	Dim DatabaseError As PocketbaseError
	DatabaseError.Initialize
	
	Wait For (m_Pocketbase.Auth.GetAccessToken) Complete (AccessToken As String)
	If AccessToken = "" Then
		DatabaseError.StatusCode = 401
		DatabaseError.ErrorMessage = "Unauthorized"
		DatabaseResult.Error = DatabaseError
		Return DatabaseResult
	End If
	
	Dim url As String = ""
	If m_CustomParameters.StartsWith("&") Then m_CustomParameters = "?" & m_CustomParameters.SubString(1)
	url = url & $"${m_Pocketbase.URL}/${m_TableName}/records/${RecordId}${m_CustomParameters}"$

	Dim jsn As JSONGenerator
	jsn.Initialize(m_ColumnValue)
	'Log(jsn.ToString)
	Log(url)
	Dim j As HttpJob : j.Initialize("",Me)
	j.PatchString(url,jsn.ToString)
	j.GetRequest.SetContentType("application/json")
	j.GetRequest.SetHeader("Authorization","Bearer " & AccessToken)
	
	Wait For (j) JobDone(j As HttpJob)

	DatabaseError.Success = j.Success

	If j.Success Then
			
		DatabaseResult = Pocketbase_Functions.CreateDatabaseResult(j.GetString)
			
	Else
		DatabaseError.StatusCode = j.Response.StatusCode
		DatabaseError.ErrorMessage = j.ErrorMessage
	End If

	DatabaseResult.Error = DatabaseError
	Return DatabaseResult
	
End Sub