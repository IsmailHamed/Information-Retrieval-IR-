<%@ Page Language="c#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Simple Upload with Progress</title>
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
                Simple Upload with Progress</h2>
            <p>A basic sample demonstrating the use of the Upload control. You can use .CopyTo or .MoveTo method to copy the temporary file to a permanent location.</p>
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Upload File (Max 10M)"
                OnFileUploaded="Uploader_FileUploaded">
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
