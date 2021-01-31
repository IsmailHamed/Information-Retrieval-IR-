<%@ WebHandler Language="vb" Class="TheUploadHandler" %>

Imports System
Imports System.IO
Imports System.Web
Imports CuteWebUI

Public Class TheUploadHandler
	Inherits CuteWebUI.MvcHandler
	Public Overrides Function GetValidateOption() As UploaderValidateOption
		Dim [option] As CuteWebUI.UploaderValidateOption = New UploaderValidateOption()
		[option].MaxSizeKB = 100 * 1024
		[option].AllowedFileExtensions = "*.jpg,*.gif,*.png,*.bmp,*.zip,*.rar,*.txt,*.exe,*.doc,*.docx,*.pdf"
		Return [option]
	End Function

	Public Overrides Sub OnFileUploaded(file As MvcUploadFile)
		If String.Equals(Path.GetExtension(file.FileName), ".bmp", StringComparison.OrdinalIgnoreCase) Then
			file.Delete()
			Throw (New Exception("My custom validation error : do not upload bmp"))
		End If

		Me.SetServerData("this value will pass to javascript api as item.ServerData")

		'  TODO:use methods
		'  to move the file to somewhere
		'file.MoveTo("~/newfolder/" + file.FileName);

		'  or move to somewhere
		'file.CopyTo("~/newfolder/" + file.FileName);

		'  or delete it
		'file.Delete()

		'get the file properties
		'file.FileGuid
		'file.FileSize
		'file.FileName

		'use this method to open an file stream
		'file.OpenStream

	End Sub

	Public Overrides Sub OnUploaderInit(uploader As MvcUploader)

	End Sub
End Class