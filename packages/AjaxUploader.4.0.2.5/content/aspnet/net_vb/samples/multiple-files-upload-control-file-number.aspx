<%@ Page Language="VB" %>

<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head runat="server">
    <title>Uploading multiple files (Limit the maximum number of files allowed to upload)</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
        Private Sub InsertMsg(ByVal msg As String)
            ListBoxEvents.Items.Insert(0, msg)
            ListBoxEvents.SelectedIndex = 0
        End Sub
        
        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            Attachments1.InsertButton.Style("display") = "none"
        End Sub
        
        Private Sub Attachments1_AttachmentAdded(ByVal sender As Object, ByVal args As AttachmentItemEventArgs)
            InsertMsg((args.Item.FileName + " has been uploaded."))
        End Sub
        
        Private Sub ButtonDeleteAll_Click(ByVal sender As Object, ByVal e As EventArgs)
            InsertMsg("Attachments1.DeleteAllAttachments();")
            Attachments1.DeleteAllAttachments()
        End Sub
      
        Private Sub ButtonTellme_Click(ByVal sender As Object, ByVal e As EventArgs)
            ListBoxEvents.Items.Clear()
            For Each item As AttachmentItem In Attachments1.Items
                InsertMsg((item.FileName + (", " _
                                + (item.FileSize + " bytes."))))
                'Copies the uploaded file to a new location.
                'item.CopyTo("c:\\temp\\"+args.FileName);
                'You can also open the uploaded file's data stream.
                'System.IO.Stream data = args.OpenStream();
            Next
        End Sub
        
        Private Sub Uploader_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
            If (GetVisibleItemCount() >= 3) Then
                Return
            End If
            Dim stream As System.IO.Stream = args.OpenStream
            Attachments1.Upload(args.FileSize, ("ChangeName-" + args.FileName), stream)
        End Sub
        
        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)
            MyBase.OnPreRender(e)
            If (GetVisibleItemCount() >= 3) Then
                Uploader1.InsertButton.Enabled = False
            Else
                Uploader1.InsertButton.Enabled = True
            End If
        End Sub
        
        Private Function GetVisibleItemCount() As Integer
            Dim count As Integer = 0
            For Each item As AttachmentItem In Attachments1.Items
                If item.Visible Then
                    count = (count + 1)
                End If
            Next
            Return count
        End Function
    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Uploading multiple files (Limit the maximum number of files allowed to upload)</h2>
            <p>
                This example shows you how to limit the maximum number of files allowed to upload.
                In the following example, you can only upload <span style="color: red">3</span>
                files.</p>
            <fieldset>
                <legend>
                    <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Upload Multiple files Now"
                        MultipleFilesUpload="true" OnFileUploaded="Uploader_FileUploaded">
                    </CuteWebUI:Uploader>
                </legend>
                <div>
                    <CuteWebUI:UploadAttachments runat="server" ID="Attachments1" OnAttachmentAdded="Attachments1_AttachmentAdded">
                    </CuteWebUI:UploadAttachments>
                </div>
            </fieldset>
            <p>
                <asp:Button ID="ButtonDeleteAll" runat="server" Text="Delete All" OnClick="ButtonDeleteAll_Click" />&nbsp;&nbsp;
                <asp:Button ID="ButtonTellme" runat="server" Text="Show Uploaded File Information"
                    OnClick="ButtonTellme_Click" />
            </p>
            <p>
                Server Trace:
                <br />
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </p>
        </div>
    </form>
</body>
</html>
