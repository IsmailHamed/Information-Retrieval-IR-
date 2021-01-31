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
        DataTable table = SampleDB.Create().Select("*").From("UploaderTopics").OrderBy("UpdateTime DESC").Range(start, count).GetTotalCount(out total);
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
        link.NavigateUrl = "Default.aspx?Page=" + num;
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
                  <h2>Ajax based Forum application</h2>
    <p>This example shows you how to use Ajax Uploader create a forum application. It shows how to allow users upload attachments to their posts and manage personal files. It puts the profile example, multiple files example and personal file storage together.
    </p>
    <h4>
        <a href="Write.aspx">Write a New Post</a>
    </h4>
    <div>
        <asp:GridView ID="GridView1" runat="server" Font-Size="11px" Font-Names="Tahoma" AutoGenerateColumns="False" CellPadding="3"
            ForeColor="#333333" Width="600px" OnDataBinding="GridView1_DataBinding">
            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <Columns>
                <asp:BoundField DataField="TopicId" HeaderText="Id">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="Title">
                    <ItemTemplate>
                        <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# Eval("TopicId", "ReadTopic.aspx?TopicId={0}") %>'
                            Text='<%# HttpUtility.HtmlEncode((string)Eval("Title")) %>'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:HyperLinkField DataTextField="UserName"  DataNavigateUrlFormatString="../SiteMail/Write.aspx?Target={0}"
                    HeaderText="Author">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:HyperLinkField>
                <asp:TemplateField HeaderText="R/V">
                    <ItemTemplate>
                        <%#Eval("ReplyCount")+"/"+Eval("ViewCount") %>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:BoundField DataField="FileCount" HeaderText="Files">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle Width="40px" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="Update">
                    <HeaderStyle Width="40px" />
                    <ItemTemplate>
                        <%# SampleUtil.ToUserLocalTime((DateTime)Eval("UpdateTime")).ToString("HH:mm") %>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Post">
                    <HeaderStyle Width="80px" />
                    <ItemTemplate>
                        <%# SampleUtil.ToUserLocalTime((DateTime)Eval("CreateTime")).ToString("yy-MM-dd HH:mm") %>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
            </Columns>
            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
            <EditRowStyle BackColor="#999999" />
            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
            <EmptyDataTemplate>
                No Post Yet.
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
        <br />
        <div style="font:normal 11px Tahoma;">
            <asp:HyperLink ID="LinkFirst" runat="server" Text="FIRST"></asp:HyperLink>
            <asp:HyperLink ID="LinkPrev" runat="server" Text="PREV"></asp:HyperLink>
            <asp:Label ID="LabelPage" Font-Bold="true" Font-Underline="true" ForeColor="firebrick"
                runat="server"></asp:Label>
            <asp:HyperLink ID="LinkNext" runat="server" Text="NEXT"></asp:HyperLink>
            <asp:HyperLink ID="LinkLast" runat="server" Text="LAST"></asp:HyperLink>
        </div>
                  
             
          
        </div>
    </form>
</body>
</html>
