<%@ Page Language="C#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        SampleUtil.SetPageCache();

    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            GridView1.DataBind();
        }
    }

    public int PageNumber
    {
        get
        {
            int pagenum = 1;
            string page = Context.Request.QueryString["Page"];
            if (!string.IsNullOrEmpty(page))
            {
                if (!int.TryParse(page, out pagenum))
                    pagenum = 1;
            }
            if (pagenum < 1)
                pagenum = 1;
            return pagenum;
        }
    }

    protected void GridView1_DataBinding(object sender, EventArgs e)
    {
        int pageIndex = (PageNumber - 1);
        int count = 10;
        int start = pageIndex * count;
        int total;
        DataTable table = SampleDB.Create(SampleDB.GetCurrentUserId()).Select("*").From("UploaderFiles").Where("UserId={0}").OrderBy("FileId DESC").Range(start, count).GetTotalCount(out total);
        GridView1.DataSource = table;

        int pagecount = total / count;
        if ((total % count) != 0)
            pagecount++;
        if (pagecount == 0)
            pagecount = 1;

        LinkFirst.Enabled = LinkPrev.Enabled = pageIndex > 0;
        LinkLast.Enabled = LinkNext.Enabled = pageIndex < pagecount - 1;

        SetLink(LinkFirst, 0);
        SetLink(LinkPrev, pageIndex - 1);
        SetLink(LinkNext, pageIndex + 1);
        SetLink(LinkLast, pagecount - 1);
        LabelPage.Text = string.Format("[ {0} ]", pageIndex + 1);
    }
    void SetLink(HyperLink link, int pageIndex)
    {
        int num = pageIndex + 1;
        link.NavigateUrl = "Ajax-based-File-storage.aspx?Page=" + num;
    }

    protected void Uploader1_FileUploaded(object sender, UploaderEventArgs args)
    {


        string newname = "myfile." + args.FileGuid + "." + args.FileName + ".resx";
        SampleDB.ExecuteNonQuery("INSERT UploaderFiles (UserId,UploadTime,FileGuid,FileSize,FileName,TempFileName,IPAddress) VALUES ({0},{1},{2},{3},{4},{5},{6})"
                            , SampleDB.GetCurrentUserId(), DateTime.Now, args.FileGuid, args.FileSize, args.FileName, newname, Context.Request.UserHostAddress);

        args.CopyTo(Path.Combine(SampleUtil.GetFileDirectory(), newname));


        GridView1.DataBind();
    }

    protected void ButtonDelete_Click(object sender, EventArgs e)
    {
        List<int> fileids = new List<int>();
        foreach (GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.FindControl("CheckBoxSelect");
                if (cb != null && !cb.Checked)
                {
                    try
                    {
                        int fileid = (int)GridView1.DataKeys[row.RowIndex].Value;

                        fileids.Add(fileid);

                    }
                    catch
                    {
                        cb.Checked = true;

                    }
                }
            }
        }

        if (fileids.Count == 0)
            return;

        string filedir = SampleUtil.GetFileDirectory();

        //check the userid , dont trust the viewstate
        int userid = SampleDB.GetCurrentUserId();

        foreach (int fileid in fileids)
        {
            DataRow row = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE FileId={0} AND UserId={1}", fileid, userid);
            if (row != null && userid.Equals(row["UserId"]))
            {
                SampleDB.ExecuteNonQuery("DELETE UploaderFiles WHERE FileId={0} AND UserId={1}", fileid, userid);
                File.Delete(Path.Combine(filedir, (string)row["TempFileName"]));
            }
        }

        GridView1.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>File storage application powered by Ajax</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="content">
            <h2>
                File storage application powered by Ajax Uploader
            </h2>
            <p>
                This example shows you how to use Ajax Uploader create an online file storage application.
                Make your file upload page more user friendly!
            </p>
            <div>
                <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Add files (Max 100MB)"
                    OnFileUploaded="Uploader1_FileUploaded" MultipleFilesUpload="true">
                    <ValidateOption AllowedFileExtensions="jpeg, jpg, gif, png, zip, doc, rtf, pdf" MaxSizeKB="102400" />
                </CuteWebUI:Uploader>
                <ul>
                    <li>Allowed file types: jpeg, jpg, gif, png, zip, doc, rtf, pdf</li>
                    <li>You can select multiple files and upload them at once.</li>
                </ul>
            </div>
            <div>
                <asp:GridView ID="GridView1" Font-Size="11px" Font-Names="Tahoma" runat="server"
                    DataKeyNames="FileId" AutoGenerateColumns="False" CellPadding="2" ForeColor="#333333"
                    Width="600px" OnDataBinding="GridView1_DataBinding">
                    <FooterStyle BackColor="#5D7B9D" Font-Bold="True" Font-Size="11px" Font-Names="Tahoma"
                        ForeColor="White" />
                    <Columns>
                        <asp:TemplateField>
                            <ItemStyle Width="24px" />
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="CheckBoxSelect" Checked="true" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="FileId" HeaderText="Id">
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:BoundField>
                        <asp:HyperLinkField HeaderText="File Name" DataTextField="FileName" DataTextFormatString="{0}"
                            DataNavigateUrlFields="FileId" DataNavigateUrlFormatString="DownloadFile.Ashx?FileId={0}"
                            Target="_blank"></asp:HyperLinkField>
                        <asp:BoundField DataField="FileSize" HeaderText="Size">
                            <HeaderStyle Width="60px" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Upload">
                            <HeaderStyle Width="120px" />
                            <ItemTemplate>
                                <%# SampleUtil.ToUserLocalTime((DateTime)Eval("UploadTime")).ToString("MM-dd") %>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" Width="120px" />
                        </asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="FileId" DataNavigateUrlFormatString="DownloadFile.Ashx?FileId={0}"
                            Text="Download" Target="_blank" />
                    </Columns>
                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                    <EditRowStyle BackColor="#999999" />
                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                    <EmptyDataTemplate>
                        No files yet.
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
            <br />
            <div style="font: normal 11px Tahoma;">
                <asp:HyperLink ID="LinkFirst" runat="server" Text="FIRST"></asp:HyperLink>
                <asp:HyperLink ID="LinkPrev" runat="server" Text="PREV"></asp:HyperLink>
                <asp:Label ID="LabelPage" Font-Bold="true" Font-Underline="true" ForeColor="firebrick"
                    runat="server"></asp:Label>
                <asp:HyperLink ID="LinkNext" runat="server" Text="NEXT"></asp:HyperLink>
                <asp:HyperLink ID="LinkLast" runat="server" Text="LAST"></asp:HyperLink>
            </div>
            <br />
            <asp:Button runat="server" Text="Remove Unchecked" ID="ButtonDelete" OnClick="ButtonDelete_Click" />
            <br />
        </div>
    </form>
</body>
</html>
