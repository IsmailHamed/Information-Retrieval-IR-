<%@ Page Language="c#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Selecting multiple files for uploading</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">		
        void InsertMsg(string msg)
        {
            ListBoxEvents.Items.Insert(0, msg);
            ListBoxEvents.SelectedIndex = 0;
        }

        void ButtonPostBack_Click(object sender, EventArgs e)
        {
            InsertMsg("You clicked a PostBack Button.");
        }

        void Uploader_FileUploaded(object sender, UploaderEventArgs args)
        {
            InsertMsg("File uploaded! " + args.FileName + ", " + args.FileSize + " bytes.");

            //Copies the uploaded file to a new location.
            //args.CopyTo("c:\\temp\\"+args.FileName);
            //You can also open the uploaded file's data stream.
            //System.IO.Stream data = args.OpenStream();
        }
     
    </script>

</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Selecting multiple files for uploading</h2>
            <p>
                Select multiple files in the file browser dialog then upload them at once.</p>
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Upload Multiple Files (Max 10M)"
                MultipleFilesUpload="true" OnFileUploaded="Uploader_FileUploaded">
                <ValidateOption MaxSizeKB="10240" />
            </CuteWebUI:Uploader>
            <p>
                Server Trace:
                <br />
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </p>
            <asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />
        </div>
    </form>
</body>
</html>
