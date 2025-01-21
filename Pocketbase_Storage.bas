B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private m_Pocketbase As Pocketbase
	
	Type PocketbaseRangeDownloadTracker (CurrentLength As Long, TotalLength As Long, Completed As Boolean, Cancel As Boolean)
	
	Public Tag As Object

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(ThisPocketbase As Pocketbase)
	m_Pocketbase = ThisPocketbase
End Sub

'Uploads a file to an existing bucket.
'<code>
'	Dim UploadFile As Pocketbase_StorageFile = xPocketbase.Storage.UploadFile("Avatar","test.png")
'	UploadFile.FileBody(xPocketbase.Storage.ConvertFile2Binary(File.DirAssets,"test.jpg"))
'	Wait For (UploadFile.Execute) Complete (StorageFile As PocketbaseStorageFile)
'	If StorageFile.Error.Success Then
'		Log($"File ${"test.jpg"} successfully uploaded "$)
'	Else
'		Log("Error: " & StorageFile.Error.ErrorMessage)
'	End If
'</code>
Public Sub UploadFile(CollectionName As String,RecordId As String,FileData As MultipartFileData) As ResumableSub
			
	Dim UpdateRecord As Pocketbase_DatabaseUpdate = m_Pocketbase.Database.UpdateData.Collection(CollectionName)
	'UpdateRecord.Parameter_Fields(FileData.KeyName)
	UpdateRecord.Parameter_Files(Array(FileData))
	Wait For (UpdateRecord.Execute(RecordId)) Complete (DatabaseResult As PocketbaseDatabaseResult)
	Return DatabaseResult
	
End Sub

#Region RangeDownloader

'Public Sub RangeDownloader_CreateTracker As PocketbaseRangeDownloadTracker
'	Dim t As PocketbaseRangeDownloadTracker
'	t.Initialize
'	Return t
'End Sub
'
'Public Sub RangeDownloader_Download (Dir As String, FileName As String, URL As String, Tracker As PocketbaseRangeDownloadTracker) As ResumableSub
'	
'	Dim StorageFile As PocketbaseStorageFile
'	StorageFile.Initialize
'	Dim DatabaseError As PocketbaseError
'	DatabaseError.Initialize
'	
'	Dim head As HttpJob
'	head.Initialize("", Me)
'	head.Head(URL)
'	head.GetRequest.SetHeader("apikey",m_Pocketbase.ApiKey)
'	head.GetRequest.SetHeader("Authorization","Bearer " & m_Pocketbase.Auth.TokenInformations.AccessToken)
'	Wait For (head) JobDone (head As HttpJob)
'	'Log(head.ErrorMessage)
'	head.Release 'the actual content is not needed
'	DatabaseError.Success = head.Success
'	If head.Success Then
'		Tracker.TotalLength = head.Response.ContentLength
'		If Tracker.TotalLength = 0 Then Tracker.TotalLength = RangeDownloader_GetCaseInsensitiveHeaderValue(head, "content-length", "0")
''		Log(head.Response.GetHeaders.As(JSON).ToString)
'		If RangeDownloader_GetCaseInsensitiveHeaderValue(head, "Accept-Ranges", "").As(String) <> "bytes" Then
'			Log("PocketbaseStorage: accept ranges not supported")
'			Tracker.Completed = True
'			DatabaseError.StatusCode = 400
'			DatabaseError.ErrorMessage = "accept ranges not supported"
'			Return StorageFile
'		End If
'	Else
'		DatabaseError.StatusCode = head.Response.StatusCode
'		DatabaseError.ErrorMessage = head.ErrorMessage
'		Tracker.Completed = True
'		Return StorageFile
'	End If
'	
'	'Log("Total length: " & NumberFormat(Tracker.TotalLength, 0, 0))
'	If File.Exists(Dir, FileName) Then
'		Tracker.CurrentLength = File.Size(Dir, FileName)
'	End If
'	Dim out As OutputStream = File.OpenOutput(Dir, FileName, True) 'append = true
'	Do While Tracker.CurrentLength < Tracker.TotalLength
'		Dim j As HttpJob
'		j.Initialize("", Me)
'		j.Download(URL)
'		Dim range As String = $"bytes=${Tracker.CurrentLength}-${(Min(Tracker.TotalLength, Tracker.CurrentLength + 300 * 1024) - 1).As(Int)}"$
'		'Log(range)
'		j.GetRequest.SetHeader("apikey",m_Pocketbase.ApiKey)
'		j.GetRequest.SetHeader("Authorization","Bearer " & m_Pocketbase.Auth.TokenInformations.AccessToken)
'		j.GetRequest.SetHeader("Range", range)
'		Wait For (j) JobDone (j As HttpJob)
'		DatabaseError.Success = j.Success
'		Dim good As Boolean = j.Success
'		If j.Success Then
'			Wait For (File.Copy2Async(j.GetInputStream, out)) Complete (Success As Boolean)
'			
'			#if B4A or B4J
'			out.Flush
'			#end if
'			good = good
'		
'			Tracker.CurrentLength = File.Size(Dir, FileName)
'
'		Else
'			DatabaseError.StatusCode = j.Response.StatusCode
'			DatabaseError.ErrorMessage = j.ErrorMessage
'
'		End If
'		j.Release
'		If good = False Or Tracker.Cancel = True Then
'			Tracker.Completed = True
'			Return StorageFile
'		End If
'	Loop
'	out.Close
'	Tracker.Completed = True
'	
'	StorageFile.FileBody = File.ReadBytes(Dir,FileName)
'	StorageFile.Error = DatabaseError
'	Return StorageFile
'End Sub
'
'Private Sub RangeDownloader_GetCaseInsensitiveHeaderValue (job As HttpJob, Key As String, DefaultValue As String) As String
'	Dim headers As Map = job.Response.GetHeaders
'	For Each k As String In headers.Keys
'		If K.EqualsIgnoreCase(Key) Then
'			Return headers.Get(k).As(String).Replace("[", "").Replace("]", "").Trim
'		End If
'	Next
'	Return DefaultValue
'End Sub

#End Region

#Region Functions

Public Sub ConvertFile2Binary(Dir As String, FileName As String) As Byte()
	Return Bit.InputStreamToBytes(File.OpenInput(Dir, FileName))
End Sub

#If B4A OR B4I OR UI
Public Sub BytesToImage(bytes() As Byte) As B4XBitmap
	Dim In As InputStream
	In.InitializeFromBytesArray(bytes, 0, bytes.Length)
#if B4A or B4i
   Dim bmp As Bitmap
   bmp.Initialize2(In)
   Return bmp
#else
	Dim bmp As Image
	bmp.Initialize2(In)
	Return bmp
#end if
End Sub

#End Region
#End If
