<%@ Page Language="vb" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Simple Upload with Progress (Custom Validation) </title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
        Private Sub InsertMsg(ByVal msg As String)
            ListBoxEvents.Items.Insert(0, msg)
            ListBoxEvents.SelectedIndex = 0
        End Sub
  
        Private Sub ButtonPostBack_Click(ByVal sender As Object, ByVal e As EventArgs)
            InsertMsg("You clicked a PostBack Button.")
        End Sub

        Private Sub Uploader_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
            InsertMsg("File uploaded! " & args.FileName & ", " & args.FileSize & " bytes.")
            'Copies the uploaded file to a new location.
            'args.CopyTo("c:\\temp\\"& args.FileName)
            'You can also open the uploaded file's data stream.
            'System.IO.Stream data = args.OpenStream()
        End Sub
    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Simple Upload with Progress (Custom Validation)
            </h2>
            <p>
                A sample demonstrating how to create user-defined validation functions for an upload
                control. In this example, we defined two validation rules:</p>
            <ul>
                <li>Maximum file size: 100K</li>
                <li>Allowed file types: jpeg, jpg, gif,png </li>
            </ul>
            <p>
                Click the following button to upload.
            </p>
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Upload" OnFileUploaded="Uploader_FileUploaded">
                <ValidateOption AllowedFileExtensions="jpeg,jpg,gif,png" MaxSizeKB="100" />
            </CuteWebUI:Uploader>
            <br />
            <br />
            <div>
                Server Trace:
                <br />
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </div>
            <br />
            <br />
            <asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />
        </div>
    </form>
</body>
</html>
