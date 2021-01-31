<%@ Page Language="C#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<%@ Register Src="~/Controls/SelectMyFile.ascx" TagName="SelectMyFile" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
 
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        SampleUtil.SetPageCache();
        SelectMyFile1.SelectedFileChanged += new EventHandler(SelectMyFile1_SelectedFileChanged);
    }

    void SelectMyFile1_SelectedFileChanged(object sender, EventArgs e)
    {
        int filesize = (int)SelectMyFile1.SelectedFile["FileSize"];
        string filename = (string)SelectMyFile1.SelectedFile["FileName"];
        string tempname = (string)SelectMyFile1.SelectedFile["TempFileName"];
        string filedir = SampleUtil.GetFileDirectory();
        string tempfilepath = Path.Combine(filedir, tempname);
        using (FileStream stream = new FileStream(tempfilepath, FileMode.Open, FileAccess.Read, FileShare.Read))
        {
            TopicFiles.Items.Add(filesize, filename, stream);
        }
    }

    protected void SendTopic_Click(object sender, EventArgs e)
    {
        bool valid = true;

        TopicTitle.BackColor = System.Drawing.Color.Empty;

        string title = TopicTitle.Text.Trim();

        if (string.IsNullOrEmpty(title))
        {
            TopicTitle.BackColor = System.Drawing.Color.Yellow;
            valid = false;
        }

        string body = TopicBody.Text;

        if (!valid) return;

        DataRow currentUser = SampleDB.GetCurentUserRow();
        int senderId = (int)currentUser["UserId"];
        string senderName = (string)currentUser["UserName"];

        string dir = SampleUtil.GetFileDirectory();
        List<FileItem> files = new List<FileItem>();

        //use to array so the Delete action will not break the foreach.
        foreach (AttachmentItem attitem in TopicFiles.Items.ToArray())
        {
            if (attitem.Checked)
            {
                string newfilename = "topic." + attitem.FileGuid + "." + attitem.FileSize + "." + attitem.FileName + ".resx";
                FileItem fileitem = new FileItem(dir, attitem);
                fileitem.TempFileName = newfilename;
                attitem.CopyTo(fileitem.TempFilePath);
                files.Add(fileitem);
                attitem.Delete();
            }
        }

        int topicid = SampleDB.SendTopic(senderId, senderName, title, body, files.ToArray());

        SampleDB.ExecuteNonQuery("UPDATE UploaderTopics SET IPAddress={1} WHERE TopicId={0}", topicid, Context.Request.UserHostAddress);

        Response.Redirect("ReadTopic.aspx?TopicId=" + topicid);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Ajax based Forum application</title>
        <link rel="stylesheet" href="demo.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="content">
            <h2>
                Ajax based Forum application</h2>
            <p>
                This example shows you how to use Ajax Uploader create a forum application. It shows
                how to allow users upload attachments to their posts and manage personal files.
                It puts the profile example, multiple files example and personal file storage together.
            </p>
            <span style="float: right"><a href="Ajax-based-File-Forum.aspx">Forum Home</a></span>
            <h3>
                Send Topic</h3>
            <table style="font: normal 12px Tahoma; width: 98%">
                <tr>
                    <td>
                        Subject
                    </td>
                    <td>
                        <asp:TextBox ID="TopicTitle" runat="server" Width="400px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        Files
                    </td>
                    <td>
                        <CuteWebUI:UploadAttachments runat="server" ID="TopicFiles">
                            <ValidateOption AllowedFileExtensions="jpeg, jpg, gif, zip, doc, pdf" MaxSizeKB="10240" />
                        </CuteWebUI:UploadAttachments>
                        <span style="margin-left: 10px; font: normal 11px Tahoma;">(Maximum file size: 10M,
                            Allowed file types: jpeg, jpg, gif, zip, doc, pdf) </span>
                    </td>
                </tr>
                <tr>
                    <td>
                    </td>
                    <td>
                        <uc1:SelectMyFile ID="SelectMyFile1" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        Message
                    </td>
                    <td>
                        <asp:TextBox ID="TopicBody" runat="server" Height="133px" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                    </td>
                    <td>
                        <asp:Button ID="SendTopic" runat="server" Text="Post" OnClick="SendTopic_Click" /></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
