<%@ Page Language="C#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<%@ Register Src="~/Controls/SelectMyFile.ascx" TagName="SelectMyFile" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
 
    class TopicAttachmentProvider : CuteWebUI.IAttachmentProvider
    {
        class FileItem : global::FileItem
        {
            public FileItem(int topicid, Guid guid)
                : base(SampleUtil.GetFileDirectory())
            {
                _topicid = topicid;
                FileGuid = guid;
            }

            int _topicid;
            DataRow attrow;
            public void Prepair()
            {
                attrow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderTopicAttachments WHERE TopicId={0} AND FileGuid={1}", _topicid, FileGuid);
                if (attrow != null)
                {
                    this.FileSize = (int)attrow["FileSize"];
                    this.FileName = (string)attrow["FileName"];
                    this.TempFileName = (string)attrow["TempFileName"];
                }

            }

            bool _deleted = false;
            public bool Exists
            {
                get
                {
                    if (_deleted) return false;
                    if (attrow == null) return false;
                    return true;
                }
            }
        }

        int _topicid;
        public TopicAttachmentProvider(int topicid)
        {
            _topicid = topicid;
        }

        public object OpenQuery(Guid guid)
        {
            FileItem item = new FileItem(_topicid, guid);
            item.Prepair();
            return item;
        }

        public void CloseQuery(object cookie)
        {

        }

        public bool FileExists(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            return item.Exists;
        }

        public int GetFileSize(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            return item.FileSize;
        }

        public string GetFileName(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            return item.FileName;
        }

        public Stream OpenFileStream(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            if (!item.Exists)
                throw (new Exception("File not exists"));
            return new FileStream(item.TempFilePath, FileMode.Open, FileAccess.Read, FileShare.Read);
        }

        public string HasTempPath(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            return item.TempFilePath;
        }

        public void DeleteFile(Guid guid, object cookie)
        {
            FileItem item = (FileItem)cookie;
            if (!item.Exists) return;

            File.Delete(item.TempFilePath);
            SampleDB.ExecuteNonQuery("DELETE UploaderTopicAttachments WHERE FileGuid={0}", item.FileGuid);
        }

    }

    public int TopicId
    {
        get
        {
            return int.Parse(Request.QueryString["TopicId"]);
        }
    }

    DataRow row;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        SampleUtil.SetPageCache();
        row = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId);

        int userid = (int)row["UserId"];
        if (SampleUtil.IsAdministratorIP || userid == SampleDB.GetCurrentUserId())
        {
            //OK
        }
        else
        {
            throw (new Exception("INVALID OWNER"));
        }

        TopicFiles.CustomProvider = new TopicAttachmentProvider(TopicId);

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

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            TopicTitle.Text = (string)row["Title"];
            TopicBody.Text = (string)row["TopicBody"];
            DataTable table = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId);
            foreach (DataRow attrow in table.Rows)
            {
                TopicFiles.AddCustomAttachment((Guid)attrow["FileGuid"]);
            }
        }
    }

    protected void SaveTopic_Click(object sender, EventArgs e)
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

        string dir = SampleUtil.GetFileDirectory();
        List<FileItem> files = new List<FileItem>();
        List<Guid> removes = new List<Guid>();

        //use to array so the Delete action will not break the foreach.
        foreach (AttachmentItem attitem in TopicFiles.Items.ToArray())
        {
            if (attitem.IsCustom)
            {
                //remove exists item..
                if (!attitem.Checked)
                {
                    removes.Add(attitem.FileGuid);
                    attitem.Delete();
                }
            }
            else if (attitem.Checked)
            {
                string newfilename = "topic." + attitem.FileGuid + "." + attitem.FileSize + "." + attitem.FileName + ".resx";
                FileItem fileitem = new FileItem(dir, attitem);
                fileitem.TempFileName = newfilename;
                attitem.CopyTo(fileitem.TempFilePath);
                files.Add(fileitem);
                attitem.Delete();
            }
        }

        SampleDB.ExecuteNonQuery("UPDATE UploaderTopics SET Title={1},TopicBody={2},IPAddress={3} WHERE TopicId={0}", TopicId, title, body, Context.Request.UserHostAddress);
        foreach (FileItem fileitem in files)
        {
            SampleDB.ExecuteNonQuery("INSERT UploaderTopicAttachments (TopicId,FileGuid,FileSize,FileName,TempFileName) VALUES ({0},{1},{2},{3},{4})"
                , TopicId, fileitem.FileGuid, fileitem.FileSize, fileitem.FileName, fileitem.TempFileName);
        }

        Response.Redirect("ReadTopic.aspx?TopicId=" + TopicId);
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
                Edit Topic</h3>
            <table width="100%" border="0" style="font: normal 12px Tahoma;" cellpadding="2"
                cellspacing="1">
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
                        <asp:Button ID="SaveTopic" runat="server" Text="Save Change" OnClick="SaveTopic_Click" /></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
