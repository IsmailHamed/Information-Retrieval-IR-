<%@ Page Language="c#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Uploading multiple files (Limit the maximum number of files allowed to upload)</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
		
        void InsertMsg(string msg)
        {
            ListBoxEvents.Items.Insert(0, msg);
            ListBoxEvents.SelectedIndex = 0;
        }

        protected override void OnInit(EventArgs e)
        {

            Attachments1.InsertButton.Style["display"] = "none";
        }
        void Attachments1_AttachmentAdded(object sender, AttachmentItemEventArgs args)
        {
            InsertMsg(args.Item.FileName + " has been uploaded.");
        }
        void ButtonDeleteAll_Click(object sender, EventArgs e)
        {
            InsertMsg("Attachments1.DeleteAllAttachments();");
            Attachments1.DeleteAllAttachments();
        }
        void ButtonTellme_Click(object sender, EventArgs e)
        {
            ListBoxEvents.Items.Clear();
            foreach (AttachmentItem item in Attachments1.Items)
            {
                InsertMsg(item.FileName + ", " + item.FileSize + " bytes.");

                //Copies the uploaded file to a new location.
                //item.CopyTo("c:\\temp\\"+args.FileName);
                //You can also open the uploaded file's data stream.
                //System.IO.Stream data = args.OpenStream();
            }
        }

        void Uploader_FileUploaded(object sender, UploaderEventArgs args)
        {
            if (GetVisibleItemCount() >= 3)
                return;
            using (System.IO.Stream stream = args.OpenStream())
            {
                Attachments1.Upload(args.FileSize, "ChangeName-" + args.FileName, stream);
            }
        }
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (GetVisibleItemCount() >= 3)
            {
                Uploader1.InsertButton.Enabled = false;
            }
            else
            {
                Uploader1.InsertButton.Enabled = true;
            }
        }
        int GetVisibleItemCount()
        {
            int count = 0;
            foreach (AttachmentItem item in Attachments1.Items)
            {
                if (item.Visible)
                    count++;
            }
            return count;
        }
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
