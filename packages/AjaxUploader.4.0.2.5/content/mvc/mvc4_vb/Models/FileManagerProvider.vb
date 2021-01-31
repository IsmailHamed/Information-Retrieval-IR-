Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Web
Imports System.Text
Imports System.IO
Imports System.Xml

Namespace mvc_vb
	Public Class FileManagerProvider
		Private _context As HttpContext
		Public Sub New()
			_context = HttpContext.Current
		End Sub

		Protected Function GetUserDirectory(username As String, autocreate As Boolean) As String
			If String.IsNullOrEmpty(username) Then
				Throw (New ArgumentNullException("username"))
			End If
			Dim sb As New StringBuilder()
			For Each c As Char In username
				If Char.IsLetterOrDigit(c) Then
					sb.Append(c)
				Else
					sb.Append("_").Append(Convert.ToInt32(c))
				End If
			Next

			Dim virpath As String = _context.Response.ApplyAppPathModifier("~/FileManagerFolder/" + sb.ToString())
			Dim phypath As String = _context.Server.MapPath(virpath)
			If autocreate Then
				If Not Directory.Exists(phypath) Then
					Directory.CreateDirectory(phypath)
				End If
			End If
			Return phypath
		End Function

		Public Function GetFiles(username As String) As FileItem()
			Dim folder As String = GetUserDirectory(username, False)
			If Not Directory.Exists(folder) Then
				Return New FileItem(-1) {}
			End If
			Dim files As String() = Directory.GetFiles(folder, "*.resx")
			Array.Sort(files)
			Dim items As FileItem() = New FileItem(files.Length - 1) {}
			For i As Integer = 0 To files.Length - 1
				items(i) = New FileItem(files(i))
			Next
			Return items
		End Function

		Public Function GetFileByID(username As String, fileid As String) As FileItem
			Dim guid As New Guid(fileid)
			Dim folder As String = GetUserDirectory(username, False)
			If Not Directory.Exists(folder) Then
				Return Nothing
			End If
			Dim files As String() = Directory.GetFiles(folder, "*." + guid.ToString() + ".resx")
			If files.Length = 0 Then
				Return Nothing
			End If
			Return New FileItem(files(0))
		End Function

		Public Function MoveFile(username As String, srcpath As String, filename As String, description As String) As FileItem
			If String.IsNullOrEmpty("srcpath") Then
				Throw (New ArgumentNullException("srcpath"))
			End If
			If String.IsNullOrEmpty("filename") Then
				Throw (New ArgumentNullException("filename"))
			End If
			If Not File.Exists(srcpath) Then
				Throw (New Exception("srcpath not exists!"))
			End If

			Dim folder As String = GetUserDirectory(username, True)
			Dim basename As String = DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss") + "." + Guid.NewGuid().ToString()
			Dim resxpath As String = Path.Combine(folder, basename + ".resx")
			Dim confpath As String = Path.Combine(folder, basename + ".config")

			Dim doc As New XmlDocument()
			doc.LoadXml("<file/>")
			doc.DocumentElement.SetAttribute("name", filename)
			If description IsNot Nothing Then
				doc.DocumentElement.SetAttribute("comment", description)
			End If

			File.Move(srcpath, resxpath)
			doc.Save(confpath)

			Return New FileItem(resxpath)
		End Function

	End Class

	Public Class FileItem
		Private _configpath As String
		Private _doc As XmlDocument

		Private _filepath As String
		Private _fileid As String
		Private _filetime As DateTime = DateTime.MinValue
		Private _filename As String
		Private _filedesc As String

		Friend Sub New(filepath As String)
			_filepath = filepath
		End Sub
		Friend Sub New(filepath As String, configpath As String, doc As XmlDocument)
			_filepath = filepath
			_configpath = configpath
			_doc = doc
		End Sub

		Public ReadOnly Property FilePath() As String
			Get
				Return _filepath
			End Get
		End Property

		Public ReadOnly Property FileID() As String
			Get
				If _fileid Is Nothing Then
					Dim name As String = Path.GetFileName(_filepath)
					_fileid = name.Split("."C)(1)
				End If
				Return _fileid
			End Get
		End Property

		Public ReadOnly Property UploadTime() As DateTime
			Get
				If _filetime = DateTime.MinValue Then
					Dim name As String = Path.GetFileName(_filepath)
					_filetime = DateTime.ParseExact(name.Split("."C)(0), "yyyy-MM-dd HH-mm-ss", Nothing)
				End If
				Return _filetime
			End Get
		End Property

		Private Sub LoadConfig()
			If _doc IsNot Nothing Then
				Return
			End If

			_configpath = _filepath.Remove(_filepath.Length - 5) + ".config"
			Dim doc As New XmlDocument()
			doc.Load(_configpath)

			_filename = doc.DocumentElement.GetAttribute("name")
			_filedesc = doc.DocumentElement.GetAttribute("comment")

			_doc = doc
		End Sub

		Public ReadOnly Property FileSize() As Integer
			Get
				Return CInt(New FileInfo(_filepath).Length)
			End Get
		End Property

		Public Property FileName() As String
			Get
				LoadConfig()
				Return _filename
			End Get
			Set
				If String.IsNullOrEmpty(value) Then
					Throw (New ArgumentNullException("value"))
				End If

				LoadConfig()
				_filename = value
				_doc.DocumentElement.SetAttribute("name", value)
				_doc.Save(_configpath)
			End Set
		End Property

		Public Property Description() As String
			Get
				LoadConfig()
				Return _filedesc
			End Get
			Set
				LoadConfig()
				_filedesc = value
				If value IsNot Nothing Then
					_doc.DocumentElement.SetAttribute("comment", value)
				Else
					_doc.DocumentElement.RemoveAttribute("comment")
				End If
				_doc.Save(_configpath)
			End Set
		End Property

		Public Sub Delete()
			LoadConfig()
			File.Delete(_filepath)
			File.Delete(_configpath)
		End Sub

	End Class
End Namespace