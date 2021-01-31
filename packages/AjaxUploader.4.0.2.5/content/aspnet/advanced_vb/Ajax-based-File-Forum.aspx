<%@ Page Language="VB" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
 Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
        MyBase.OnInit(e)
        SampleUtil.SetPageCache()
    End Sub
    Protected Overloads Overrides Sub OnLoad(ByVal e As EventArgs)
        MyBase.OnLoad(e)
    
        If Not IsPostBack Then
            GridView1.DataBind()
        End If
    End Sub
    Public ReadOnly Property PageNumber() As Integer
    
        Get
            Dim pagenum As Integer = 1
            Dim page As String = Context.Request.QueryString("Page")
            If Not String.IsNullOrEmpty(page) Then
                If Not Integer.TryParse(page, pagenum) Then
                    pagenum = 1
                End If
            End If
            If pagenum < 1 Then
                pagenum = 1
            End If
            Return pagenum
        End Get
    End Property

    Protected Sub GridView1_DataBinding(ByVal sender As Object, ByVal e As EventArgs)
        Dim pageIndex As Integer = (PageNumber - 1)
        Dim count As Integer = 10
        Dim start As Integer = pageIndex * count
        Dim total As Integer
        Dim table As DataTable = SampleDB.Create().[Select]("*").From("UploaderTopics").OrderBy("UpdateTime DESC").Range(start, count).GetTotalCount(total)
        GridView1.DataSource = table
    
        Dim pagecount As Integer = total / count
        If (total Mod count) <> 0 Then
            pagecount += 1
        End If
        If pagecount = 0 Then
            pagecount = 1
        End If
    
        LinkFirst.Enabled = LinkPrev.Enabled = pageIndex > 0
        LinkLast.Enabled = LinkNext.Enabled = pageIndex < pagecount - 1
    
        SetLink(LinkFirst, 0)
        SetLink(LinkPrev, pageIndex - 1)
        SetLink(LinkNext, pageIndex + 1)
        SetLink(LinkLast, pagecount - 1)
        LabelPage.Text = String.Format("[ {0} ]", pageIndex + 1)
    End Sub

    Private Sub SetLink(ByVal link As HyperLink, ByVal pageIndex As Integer)
        Dim num As Integer = pageIndex + 1
        link.NavigateUrl = "Ajax-based-File-Forum.aspx?Page=" & num.ToString()
    End Sub

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
                                Text='<%# HttpUtility.HtmlEncode(Convert.ToString(Eval("Title"))) %>'></asp:HyperLink>
                        </ItemTemplate>
                </asp:TemplateField>
                <asp:HyperLinkField DataTextField="UserName" DataNavigateUrlFormatString="../SiteMail/Write.aspx?Target={0}"
                    HeaderText="Author">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:HyperLinkField>
                <asp:TemplateField HeaderText="R/V">
                    <ItemTemplate>
                            <%#Eval("ReplyCount") & "/" & Eval("ViewCount")%>
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
                            <%#SampleUtil.ToUserLocalTime(Convert.ToDateTime(Eval("UpdateTime"))).ToString("HH:mm")%>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Post">
                    <HeaderStyle Width="80px" />
                    <ItemTemplate>
                            <%#SampleUtil.ToUserLocalTime(Convert.ToDateTime(Eval("CreateTime"))).ToString("yy-MM-dd HH:mm")%>
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
