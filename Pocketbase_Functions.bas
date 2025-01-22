B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
'Static code module
Sub Process_Globals
	
End Sub

#Region PublicFunctions

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
#End If

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

'If you leave ContentType empty then the content type itself is determined using the file extension
Public Sub CreateMultipartFileData(Dir As String,FileName As String,KeyName As String,ContentType As String) As MultipartFileData
	Dim FileData As MultipartFileData
	FileData.Initialize
	FileData.Dir = Dir
	FileData.FileName = FileName
	FileData.KeyName = KeyName
	FileData.ContentType = IIf(ContentType <> "",ContentType,GetMimeTypeByExtension(GetFileExt(FileName)))
	Return FileData
End Sub

Public Sub GetFilename(fullpath As String) As String
	Return fullpath.SubString(fullpath.LastIndexOf("/") + 1)
End Sub

'ISO8601UTC
Public Sub GetISO8601UTC(Ticks As Long) As String
	
	Dim prevDateFormat As String = DateTime.DateFormat
	Dim prevTimeFormat As String = DateTime.TimeFormat
	
	Dim prevTimeZone As Int = DateTime.GetTimeZoneOffsetAt(Ticks)
	DateTime.SetTimeZone(0)
    
	Dim utcTimestamp As Long = Ticks

	DateTime.DateFormat = "yyyy-MM-dd"
	DateTime.TimeFormat = "HH:mm:ss"

	Dim formattedDate As String = DateTime.Date(utcTimestamp) & "T" & DateTime.Time(utcTimestamp) & ".000Z"

	DateTime.SetTimeZone(prevTimeZone)
	DateTime.DateFormat = prevDateFormat
	DateTime.TimeFormat = prevTimeFormat

	Return formattedDate
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

#End Region
