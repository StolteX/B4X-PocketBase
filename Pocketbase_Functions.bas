B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
'Static code module
Sub Process_Globals
	
End Sub

Public Sub SubExists2(Target As Object,TargetSub As String,NumbersOfParameters As Int) As Boolean
	#IF B4I
	Return SubExists(Target,TargetSub,NumbersOfParameters)
	#Else
	Return SubExists(Target,TargetSub)
	#End If
End Sub

'https://www.b4x.com/android/forum/threads/b4x-get-mime-type-by-extension.150330/
Public Sub GetMimeTypeByExtension(Extension As String) As String
	Extension = Extension.Replace(".","").ToLowerCase
	Select Extension
		Case "jpg","png","gif","bmp","ico","svg","webp"
			Return "image/" & Extension
		Case "mp4", "avi", "mpeg", "wmv", "mov", "flv", "webm", "mkv"
			Return "video/" & Extension
		Case "mp3", "wav", "ogg", "m4a", "aac", "flac", "wma", "aiff"
			Return "audio/" & Extension
		Case Else
			Log("PocketbaseFunctions: unknown mime type")
			Return ""
	End Select
End Sub

Public Sub GetFilename(fullpath As String) As String
	Return fullpath.SubString(fullpath.LastIndexOf("/") + 1)
End Sub

Public Sub ParseDateTime(DateString As String) As Long
	If DateString = "" Or DateString = "null" Or DateString = Null Then Return 0
	DateString=DateString.Replace("T"," ")
    #if B4J
	DateString=DateString.SubString2(0, DateString.LastIndexOf(".")+4)
	DateString=$"${DateString}Z"$
    #End If
	Dim OldDateFormat As String = DateTime.DateFormat
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss"
	DateString = Regex.Split("\.",DateString)(0)
	Dim Result As Long = DateTime.DateParse(DateString)
	
	DateTime.DateFormat = OldDateFormat
	
	Log(Result)   '1692729675569
	Log(DateUtils.TicksToString(Result))
	
	Return Result
End Sub

Public Sub GetFileExt(FileName As String) As String
	Return FileName.SubString2(FileName.LastIndexof("."), FileName.Length)
End Sub

Public Sub GetJWTPayload(Token As String) As Map
	Dim su As StringUtils
	Dim parts() As String = Regex.Split("\.", Token)
	Dim b() As Byte = su.DecodeBase64(IIf(parts(1).Contains("="),parts(1),parts(1) & "="))	
	Return BytesToString(b, 0, b.Length, "UTF-8").As(JSON).ToMap
End Sub

Public Sub GenerateResult(j As HttpJob) As Map
	Dim response As String = ""
	If j.Success Then
		response = j.GetString
		#If Debug
		Log("PocketbaseFunctions: " & j.GetString)
		#End If
	Else
		response = j.ErrorMessage
	End If
	
	Dim tmp_result As Map
	
	Try
		If response <> "" Then
			Dim parser As JSONParser
			parser.Initialize(response)
			tmp_result = UnReadOnlyMap(parser.NextObject)
		Else
			tmp_result.Initialize
		End If
		tmp_result.Put("success",j.Success)
	
	Catch
		Log("Pocketbase_Functions: " & LastException)
		tmp_result.Initialize
		tmp_result.Put("success",False)
	End Try
	
	j.Release
	Return tmp_result
End Sub

Public Sub CreateDatabaseResult(JsonString As String) As PocketbaseDatabaseResult

	Dim DatabaseResult As PocketbaseDatabaseResult
	DatabaseResult.Initialize
	DatabaseResult.Columns.Initialize
	DatabaseResult.Rows.Initialize

	If JsonString.StartsWith("[") = False Then
		JsonString = "[" & JsonString & "]"
	End If
	'Log(JsonString)
	Dim parser As JSONParser
	parser.Initialize(JsonString)
	Dim jRoot As List = parser.NextArray
			
	Dim FirstTime As Boolean = True
			
	Dim NewColjRoot As Map = jRoot.Get(0)
	If NewColjRoot.ContainsKey("items") Then
		jRoot = NewColjRoot.Get("items")
	End If
			
	For Each coljRoot As Map In jRoot
			
		Dim NewRow As Map
		NewRow.Initialize
		For Each k As String In coljRoot.Keys
			If coljRoot.Get(k) Is Map Then
				Dim JoinMap As Map = coljRoot.Get(k)
				For Each join As String In JoinMap.Keys
					If FirstTime = True Then DatabaseResult.Columns.Put(k & "." & join,"")
					NewRow.Put(k & "." & join,JoinMap.Get(join))
				Next
			else if  coljRoot.Get(k) Is List Then
				If FirstTime = True Then DatabaseResult.Columns.Put(k,"")
				Dim gen As JSONGenerator
				gen.Initialize2(coljRoot.Get(k))
				NewRow.Put(k,gen.ToString)
			Else
				If FirstTime = True Then DatabaseResult.Columns.Put(k,"")
				NewRow.Put(k,coljRoot.Get(k))
			End If
				
		Next

		DatabaseResult.Rows.Add(NewRow)
				
		FirstTime = False
	Next
	
	Return DatabaseResult
	
End Sub

PRivate Sub UnReadOnlyMap(sourceMap As Map) As Map
	' copy a map to a new map to make it IsReadOnly = False
	#If B4I
	If sourceMap.IsReadOnly = False Then Return sourceMap	
	' the map is readonly, convert it
	Dim newMap As Map
	newMap.Initialize
	' copy each map item
	For Each key As String In sourceMap.Keys
		Dim val As Object = sourceMap.Get(key)
		newMap.Put(key,val)
	Next
	Return newMap
	#Else
	Return sourceMap
	#End If
End Sub

#Region Errors
'code: 400
Public Sub getErrorCode(root As Map) As Int
	If root.ContainsKey("error") Then
		Dim error As Map = root.Get("error")
		Return error.Get("code")
	End If
	Return ""
End Sub

'message: EMAIL_NOT_FOUND
Public Sub getErrorMessage(root As Map) As String
	If root.ContainsKey("error") Then
		Dim error As Map = root.Get("error")
		Return error.Get("message")
	End If
	Return ""
End Sub

'reason: invalid
'domain: global
'message: EMAIL_NOT_FOUND
Public Sub getErrorMap(root As Map) As Map
	Dim error As Map = root.Get("error")
	Dim errors As List = error.Get("errors")
	Dim tmp_result As Map : tmp_result.Initialize
	
	For Each colerrors As Map In errors
		tmp_result = CreateMap("reason":colerrors.Get("reason"),"domain":colerrors.Get("domain"),"message":colerrors.Get("message"))
	Next
	Return tmp_result
End Sub

#End Region