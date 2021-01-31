<%@ Page Language="vb" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<%@ Import Namespace="System.IO" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Simulate File Upload</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
        Private Sub InsertMsg(ByVal msg As String)
            ListBoxEvents.Items.Insert(0, msg)
            ListBoxEvents.SelectedIndex = 0
        End Sub

   
        Private Sub Uploader1_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
            InsertMsg("Uploader1 received a new file and passed it to Attachments1.")
            
            Dim stream As System.IO.Stream = args.OpenStream()
            Try
                Attachments1.Upload(args.FileSize, args.FileName, stream)
            Finally
                stream.Close()
            End Try
        End Sub

        Private Sub Attachments1_AttachmentAdded(ByVal sender As Object, ByVal args As AttachmentItemEventArgs)
            InsertMsg("Attachments1 has been added a new item.")
        End Sub
    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Simulate File Upload</h2>
            <p>
                A sample demonstrating how to use .Upload method to simulate a file upload event.
                The files uploaded by <span style="color: red">Uploader1</span> will be passed to
                <span style="color: red">Attachments1</span>.</p>
            <p>
                Click the following button to upload.
            </p>
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Uploader1 (Max 10M)"
                OnFileUploaded="Uploader1_FileUploaded">
                <ValidateOption MaxSizeKB="10240" />
            </CuteWebUI:Uploader>
            <p>
                You can hide the insert button of Attachments1.</p>
            <CuteWebUI:UploadAttachments runat="server" ID="Attachments1" InsertText="Attachments1"
                OnAttachmentAdded="Attachments1_AttachmentAdded">
            </CuteWebUI:UploadAttachments>
            <p>
                Server Trace:
                <br />
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </p>
        </div>
    </form>
</body>
</html>
