<%@ Page Language="c#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Simple Upload (Customizing the UI) </title>
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
                Simple Upload (Customizing the UI)
            </h2>
            <p>
                A sample demonstrating how to customize the look and feel of file upload controls.
                (Maximum file size: 10M).
            </p>
            <asp:Image runat="server" ID="Uploader1Insert" AlternateText="Upload File" ImageUrl="http://ajaxuploader.com/sampleimages/upload.png" />
            <asp:Panel runat="server" ID="Uploader1Progress" BorderColor="Orange" BorderStyle="dashed"
                BorderWidth="2" Style="padding:4px">
                <asp:Label ID="Uploader1ProgressText" runat="server" ForeColor="Firebrick"></asp:Label>
            </asp:Panel>
            <asp:Image runat="server" ID="Uploader1Cancel" AlternateText="Cancel" ImageUrl="http://ajaxuploader.com/sampleimages/cancel_button.gif" />
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertButtonID='Uploader1Insert'
                ProgressCtrlID='Uploader1Progress' ProgressTextID='Uploader1ProgressText' CancelButtonID='Uploader1Cancel'
                OnFileUploaded="Uploader_FileUploaded">
                <ValidateOption MaxSizeKB="10240" />
            </CuteWebUI:Uploader>
            <p>
                Server Trace:
                <br/>
                <br/>
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </p>
            <asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />
        </div>
    </form>
</body>
</html>
