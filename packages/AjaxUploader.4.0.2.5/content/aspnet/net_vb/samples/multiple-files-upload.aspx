<%@ Page Language="vb" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Uploading multiple files like GMail</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
        Private Sub InsertMsg(ByVal msg As String)
            ListBoxEvents.Items.Insert(0, msg)
            ListBoxEvents.SelectedIndex = 0
        End Sub
		
        Private Sub Attachments1_AttachmentAdded(ByVal sender As Object, ByVal args As AttachmentItemEventArgs)
            InsertMsg(args.Item.FileName + " has been uploaded.")
        End Sub

        Private Sub ButtonDeleteAll_Click(ByVal sender As Object, ByVal e As EventArgs)
            InsertMsg("Attachments1.DeleteAllAttachments();")
            Attachments1.DeleteAllAttachments()
        End Sub

        Private Sub ButtonTellme_Click(ByVal sender As Object, ByVal e As EventArgs)
            ListBoxEvents.Items.Clear()
            For Each item As AttachmentItem In Attachments1.Items
                InsertMsg(item.FileName & ", " & item.FileSize & " bytes.")
                'Copies the uploaded file to a new location.
                'item.CopyTo("c:\\temp\\"& args.FileName)
                'You can also open the uploaded file's data stream.
                'System.IO.Stream data = item.OpenStream()
            Next
        End Sub

    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Uploading multiple files like GMail</h2>
            <p>
                Google's GMail has a nice way of allowing you to upload multiple files. Rather than
                showing you 10 file upload boxes at once, the user attaches a file, you can click
                a button to add another attachment.
            </p>
            <CuteWebUI:UploadAttachments InsertText="Upload Multiple files Now" runat="server"
                ID="Attachments1" MultipleFilesUpload="true" OnAttachmentAdded="Attachments1_AttachmentAdded">
                <InsertButtonStyle />
            </CuteWebUI:UploadAttachments>
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
