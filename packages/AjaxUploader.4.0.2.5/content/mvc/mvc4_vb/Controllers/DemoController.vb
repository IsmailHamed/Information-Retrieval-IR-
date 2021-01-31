Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Web
Imports System.Web.Mvc

Namespace mvc_vb.Controllers
	Public Class DemoController
		Inherits Controller
		Public Function Index() As ActionResult
			Return View()
		End Function

		Public Function simple_upload(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"

				uploader.InsertText = "Select a file to upload"

				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function selecting_multiple_files(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				'allow select multiple files
				uploader.MultipleFilesUpload = True
				'tell uploader attach a button
				uploader.InsertButtonID = "uploadbutton"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()
				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					Dim processedfiles As New List(Of String)()
					'for multiple files , the value is string : guid/guid/guid 
					For Each strguid As String In myuploader.Split("/"c)
						Dim fileguid As New Guid(strguid)
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
						If file IsNot Nothing Then
							'you should validate it here:
							'now the file is in temporary directory, you need move it to target location
							'file.MoveTo("~/myfolder/" + file.FileName);
							processedfiles.Add(file.FileName)
						End If
					Next
					If processedfiles.Count > 0 Then
						ViewData("UploadedMessage") = String.Join(",", processedfiles.ToArray()) + " have been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function simple_upload_UI(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"

				uploader.InsertText = "Select a file to upload"
				uploader.InsertButtonID = "Uploader1Insert"
				uploader.ProgressCtrlID = "Uploader1Progress"
				uploader.ProgressTextID = "Uploader1ProgressText"
				uploader.CancelButtonID = "Uploader1Cancel"

				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function simple_upload_Validation(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "jpeg,jpg,gif,png"
				uploader.MaxSizeKB = 100
				uploader.InsertText = "Select a file to upload"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function multiple_files_upload(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				'allow select multiple files
				uploader.MultipleFilesUpload = True
				'tell uploader attach a button
				uploader.InsertButtonID = "uploadbutton"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()
				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					Dim processedfiles As New List(Of String)()
					'for multiple files , the value is string : guid/guid/guid 
					For Each strguid As String In myuploader.Split("/"c)
						Dim fileguid As New Guid(strguid)
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
						If file IsNot Nothing Then
							'you should validate it here:
							'now the file is in temporary directory, you need move it to target location
							'file.MoveTo("~/myfolder/" + file.FileName);
							processedfiles.Add(file.FileName)
						End If
					Next
					If processedfiles.Count > 0 Then
						ViewData("UploadedMessage") = String.Join(",", processedfiles.ToArray()) + " have been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function Large_File_Upload(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar,*.txt,*.exe,*.doc,*.docx,*.pdf"
				uploader.InsertText = "Select a file to upload"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()
				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function Persist_upload_file(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				uploader.MaxSizeKB = 10240
				'tell uploader attach a button
				uploader.InsertText = "Upload File"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()
				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					Dim processedfiles As New List(Of String)()
					'for multiple files , the value is string : guid/guid/guid 
					For Each strguid As String In myuploader.Split("/"c)
						Dim fileguid As New Guid(strguid)
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
						If file IsNot Nothing Then
							processedfiles.Add(file.FileName)
						End If
					Next
					If processedfiles.Count > 0 Then
						ViewData("UploadedMessage") = String.Join(",", processedfiles.ToArray()) + " have been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function multiple_files_upload_control_file_number(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				uploader.MaxSizeKB = 10240
				uploader.MultipleFilesUpload = True
				'tell uploader attach a button
				uploader.InsertButtonID = "uploadbutton"
				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()
			End Using
			Return View()
		End Function

		Public Function Start_uploading_manually(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				uploader.MaxSizeKB = 1024
				uploader.ManualStartUpload = True
				uploader.InsertText = "Browse Files (Max 1M)"

				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function Drag_drop_file(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"
				uploader.MaxSizeKB = 1024
				uploader.ManualStartUpload = True
				uploader.InsertText = "Browse Files (Max 1M)"

				uploader.MultipleFilesUpload = True
				uploader.InsertButtonID = "InsertButton"
				uploader.QueuePanelID = "QueuePanel"
                uploader.DropZoneID = "DropPanel"

                'prepair html code for the view
                ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					Dim msgs As String = ""
					For Each guidstr As String In myuploader.Split("/".ToCharArray())
						'for single file , the value is guid string
						Dim fileguid As New Guid(guidstr)
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
						If file IsNot Nothing Then
							'you should validate it here:
							'now the file is in temporary directory, you need move it to target location
							'file.MoveTo("~/myfolder/" + file.FileName);
							'set the output message
							msgs += "The file " + file.FileName + " has been processed." + Chr(13)
						End If
					Next
					ViewData("UploadedMessage") = msgs
				End If
			End Using
			Return View()
		End Function

		Public Function Customize_Progress_Bar(myuploader As String) As ActionResult
			Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
				uploader.UploadUrl = Response.ApplyAppPathModifier("~/UploadHandler.ashx")
				'the data of the uploader will render as <input type='hidden' name='myuploader'> 
				uploader.Name = "myuploader"
				uploader.AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar"

				uploader.InsertText = "Select a file to upload"

				'prepair html code for the view
				ViewData("uploaderhtml") = uploader.Render()

				'if it's HTTP POST:
				If Not String.IsNullOrEmpty(myuploader) Then
					'for single file , the value is guid string
					Dim fileguid As New Guid(myuploader)
					Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(fileguid)
					If file IsNot Nothing Then
						'you should validate it here:
						'now the file is in temporary directory, you need move it to target location
						'file.MoveTo("~/myfolder/" + file.FileName);
						'set the output message
						ViewData("UploadedMessage") = "The file " + file.FileName + " has been processed."
					End If
				End If
			End Using
			Return View()
		End Function

		Public Function FileUploadAjaxWithoutSave(guidlist As String, limitcount As String, hascount As String) As ActionResult
			Dim items As New List(Of FileManagerJsonItem)()
			Dim maxcount As Integer = 0
			Dim existcount As Integer = 0
			Integer.TryParse(hascount, existcount)
			Integer.TryParse(limitcount, maxcount)
			If Not String.IsNullOrEmpty(guidlist) Then
				Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
					Dim ix As Integer = 0
					For Each strguid As String In guidlist.Split("/"c)
						If maxcount > 0 AndAlso ix + hascount >= maxcount Then
							Exit For
						End If
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(New Guid(strguid))
						If file Is Nothing Then
							Continue For
						End If
						ix += 1
						Dim item As New FileManagerJsonItem()
						item.FileID = file.FileGuid.ToString()
						item.FileName = file.FileName
						item.FileSize = file.FileSize
						items.Add(item)
					Next
				End Using
			End If
			Dim json As New JsonResult()
			json.Data = items
			Return json
		End Function

		Public Function FilesUploadAjax(guidlist As String, deleteid As String) As ActionResult
			Dim manager As New FileManagerProvider()
			Dim username As String = GetCurrentUserName()

			If Not String.IsNullOrEmpty(guidlist) Then
				Using uploader As New CuteWebUI.MvcUploader(System.Web.HttpContext.Current)
					For Each strguid As String In guidlist.Split("/"c)
						Dim file As CuteWebUI.MvcUploadFile = uploader.GetUploadedFile(New Guid(strguid))
						If file Is Nothing Then
							Continue For
						End If
						'savefile here
						manager.MoveFile(username, file.GetTempFilePath(), file.FileName, Nothing)
					Next
				End Using
			End If

			If Not String.IsNullOrEmpty(deleteid) Then
				Dim file As FileItem = manager.GetFileByID(username, deleteid)
				If file IsNot Nothing Then
					file.Delete()
				End If
			End If

			Dim files As FileItem() = manager.GetFiles(username)
			Array.Reverse(files)
			Dim items As FileManagerJsonItem() = New FileManagerJsonItem(files.Length - 1) {}
			Dim baseurl As String = Response.ApplyAppPathModifier("~/FileManagerDownload.ashx?user=" + username + "&file=")
			For i As Integer = 0 To files.Length - 1
				Dim file As FileItem = files(i)
				Dim item As New FileManagerJsonItem()
				item.FileID = file.FileID
				item.FileName = file.FileName
				item.Description = file.Description
				item.UploadTime = file.UploadTime.ToString("yyyy-MM-dd HH:mm:ss")
				item.FileSize = file.FileSize
				item.FileUrl = baseurl + file.FileID
				items(i) = item
			Next
			Dim json As New JsonResult()
			json.Data = items
			Return json
		End Function

		Protected Function GetCurrentUserName() As String
			Return "Guest"
		End Function
	End Class


	Public Class SampleTempJsonItem
		Public FileGuid As String
		Public FileName As String
		Public FileSize As Integer
		Public Exists As Boolean
		Public [Error] As String
	End Class

	Public Class FileManagerJsonItem
		Public FileID As String
		Public FileName As String
		Public FileSize As Integer
		Public Description As String
		Public UploadTime As String
		Public FileUrl As String
	End Class
End Namespace
