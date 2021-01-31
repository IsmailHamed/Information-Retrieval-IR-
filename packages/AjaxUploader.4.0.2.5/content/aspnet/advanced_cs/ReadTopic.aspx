<%@ Page Language="C#" %>

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
            LoadTopic();
        }
    }

    public int TopicId
    {
        get
        {
            return int.Parse(Request.QueryString["TopicId"]);
        }
    }

    void LoadTopic()
    {
        DataRow row = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId);
        if (row == null)
        {
            LabelTitle.Text = "Record Not Found";
            return;
        }

        int userid = (int)row["UserId"];
        if (SampleUtil.IsAdministratorIP || userid == SampleDB.GetCurrentUserId())
        {
            ManagePanel.Visible = true;
        }
        else
        {
            ManagePanel.Visible = false;
        }

        string sender = (string)row["UserName"];
        string title = (string)row["Title"];

        this.Title = title + " - " + sender;

        LabelTitle.Text = HttpUtility.HtmlEncode(title);
        LinkSender.Text = sender;

        ImageSender.ImageUrl = "UserPhoto.ashx?User=" + sender;

        StringBuilder sb = new StringBuilder();
        sb.Append(HttpUtility.HtmlEncode((string)row["TopicBody"]));
        sb.Replace("\r\n", "<br/>");

        DataTable table = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId);
        GridView1.DataSource = table;
        if (table.Rows.Count == 0)
            GridView1.Visible = false;
        else
            GridView1.Visible = true;
        GridView1.DataBind();

        foreach (DataRow attrow in table.Rows)
        {
            string attfilename = (string)attrow["FileName"];
            if (SampleUtil.GetMimeType(attfilename).StartsWith("image/"))
            {
                sb.Append("<div class='TopicPhotoFrame'>");
                sb.Append(HttpUtility.HtmlEncode((string)attrow["FileName"]));
                sb.Append("<br/>");
                sb.Append("<img src='TopicAttachment.ashx?AttachmentId=");
                sb.Append(attrow["AttachmentId"]);
                sb.Append("'/>");
                sb.Append("</div>");
            }
        }

        LabelBody.Text = sb.ToString();

        LabelSignature.Text = HttpUtility.HtmlEncode(Convert.ToString(GetUserRow(row["UserId"])["Signature"]));

        DateTime createTime = (DateTime)row["CreateTime"];
        LiteralBottom.Text = SampleUtil.ToUserLocalTime(createTime).ToString("yyyy-MM-dd HH:mm:ss");

        ReplyRepeater.DataBind();
    }


    Dictionary<int, DataRow> dictusers = new Dictionary<int, DataRow>();
    DataRow GetUserRow(object userid)
    {
        int id = Convert.ToInt32(userid);
        DataRow row;
        if (dictusers.TryGetValue(id, out row))
            return row;
        row = SampleDB.ExecuteDataRow("SELECT * FROM UploaderUsers WHERE UserId={0}", id);
        dictusers.Add(id, row);
        return row;
    }

    protected void ReplyRepeater_DataBinding(object sender, EventArgs e)
    {
        DataTable replyTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderReplys WHERE TopicId={0}", TopicId);
        ReplyRepeater.DataSource = replyTable;
        TopicReplySpliter.Visible = replyTable.Rows.Count > 0;
    }

    protected void SendReply_Click(object sender, EventArgs e)
    {
        ReplyBody.BackColor = System.Drawing.Color.Empty;
        string replybody = ReplyBody.Text.Trim();
        if (string.IsNullOrEmpty(replybody))
        {
            ReplyBody.BackColor = System.Drawing.Color.Yellow;
            return;
        }

        DataRow currentUser = SampleDB.GetCurentUserRow();
        int senderId = (int)currentUser["UserId"];
        string senderName = (string)currentUser["UserName"];

        int replyid = SampleDB.SendReply(TopicId, senderId, senderName, replybody);

        SampleDB.ExecuteNonQuery("UPDATE UploaderReplys SET IPAddress={1} WHERE ReplyId={0}", replyid, Context.Request.UserHostAddress);

        ReplyBody.Text = "";

        ReplyRepeater.DataBind();
    }


    protected void ManageAction_Click(object sender, EventArgs e)
    {
        DataRow row = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId);
        if (row == null)
        {
            return;
        }

        int userid = (int)row["UserId"];
        if (SampleUtil.IsAdministratorIP || userid == SampleDB.GetCurrentUserId())
        {
            if (ManageOption.SelectedValue == "Edit")
            {
                Context.Response.Redirect("EditTopic.aspx?TopicId=" + TopicId);
            }
            if (ManageOption.SelectedValue == "Delete")
            {
                string filedir = SampleUtil.GetFileDirectory();
                DataTable table = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId);
                foreach (DataRow attrow in table.Rows)
                {
                    string filename = (string)attrow["TempFileName"];
                    File.Delete(Path.Combine(filedir, filename));
                }
                SampleDB.ExecuteNonQuery("DELETE UploaderTopicAttachments Where TopicId={0} DELETE UploaderReplys Where TopicId={0} DELETE UploaderTopics Where TopicId={0}", TopicId);
                Response.Redirect("Ajax-based-File-Forum.aspx");
            }
        }
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
            <div class="TopicContent">
                <table width="100%" border="0" style="font: normal 11px Tahoma; background-color: #999999"
                    cellpadding="0" cellspacing="1">
                    <tr bgcolor="white">
                        <td style="width: 150px; text-align: center; padding: 5px" valign="top">
                            <asp:Label runat="server" ID="LinkSender" Text="Sender"></asp:Label><br />
                            <asp:Image runat="server" ID="ImageSender" />
                        </td>
                        <td style="padding-left: 5px;">
                            <asp:Panel ID="ManagePanel" runat="server" CssClass="ManagePanel">
                                <asp:DropDownList runat="server" ID="ManageOption">
                                    <asp:ListItem Value="Edit">Edit</asp:ListItem>
                                    <asp:ListItem Value="Delete">Delete</asp:ListItem>
                                </asp:DropDownList>
                                <asp:Button ID="ManageAction" runat="server" Text="Action" OnClick="ManageAction_Click" />
                            </asp:Panel>
                            <asp:Label runat="server" ID="LabelTitle" Text="Title"></asp:Label>
                            <table>
                                <tr>
                                    <td style="border-bottom: none; padding-left: 5px;">
                                        <div class="TextBody">
                                            <asp:Label CssClass="TextBody" ID="LabelBody" runat="server" />
                                        </div>
                                        <div class="Attachments">
                                            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" CellPadding="4"
                                                ForeColor="#333333">
                                                <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                                                <Columns>
                                                    <asp:BoundField DataField="AttachmentId" HeaderText="Id" />
                                                    <asp:HyperLinkField HeaderText="FileName" DataTextField="FileName" DataTextFormatString="{0}"
                                                        DataNavigateUrlFields="AttachmentId" DataNavigateUrlFormatString="TopicAttachment.Ashx?AttachmentId={0}"
                                                        Target="_blank"></asp:HyperLinkField>
                                                    <asp:BoundField DataField="FileSize" HeaderText="FileSize" />
                                                    <asp:HyperLinkField DataNavigateUrlFields="AttachmentId" DataNavigateUrlFormatString="TopicAttachment.Ashx?AttachmentId={0}"
                                                        Text="Download" Target="_blank" />
                                                </Columns>
                                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                                <EditRowStyle BackColor="#999999" />
                                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                                                <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                            </asp:GridView>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="border-top: none; border-bottom: none; padding-left: 5px;">
                                        <asp:Label ID="LabelSignature" runat="server"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td style="height: 20px; padding-left: 5px;">
                                        <asp:Literal ID="LiteralBottom" runat="server" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
            <asp:Panel runat="server" ID="TopicReplySpliter">
            </asp:Panel>
            <div class="Reply">
                <asp:Repeater ID="ReplyRepeater" runat="server" OnDataBinding="ReplyRepeater_DataBinding">
                    <ItemTemplate>
                        <table width="100%" border="0" style="margin-top: 2px; font: normal 11px Tahoma;
                            background-color: #999999" cellpadding="0" cellspacing="1">
                            <tr bgcolor="white">
                                <td style="width: 150px; text-align: center; padding: 5px;">
                                    <!--<%#Eval("UserId") %>-->
                                    <div>
                                        <%#Eval("UserName")%>
                                    </div>
                                    <div>
                                        <img src='<%# "UserPhoto.ashx?User="+Eval("UserName") %>' /></div>
                                </td>
                                <td style="padding-left: 5px;">
                                    <%# HttpUtility.HtmlEncode((string)Eval("ReplyBody")).Replace("\r\n","<br/>") %>
                                    <div style="margin-top: 50px;">
                                        <%# HttpUtility.HtmlEncode( Convert.ToString(GetUserRow(Eval("UserId"))["Signature"] )) %>
                                    </div>
                                    <div>
                                        <!--    <%#Eval("IPAddress") %>  -->
                                        <%# SampleUtil.ToUserLocalTime((DateTime)Eval("ReplyTime")).ToString("yyyy-MM-dd HH:mm:ss") %>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div class="WriteReply">
                <table width="100%" border="0" style="margin-top: 2px; font: normal 11px Tahoma;
                    background-color: #999999" cellpadding="0" cellspacing="1">
                    <tr bgcolor="white">
                        <td style="width: 150px; text-align: center; padding: 5px;">
                            Quick Reply :
                        </td>
                        <td style="padding-left: 5px;">
                            <asp:TextBox ID="ReplyBody" runat="server" Height="133px" TextMode="MultiLine" Width="436px"></asp:TextBox>
                        </td>
                    </tr>
                    <tr bgcolor="white">
                        <td colspan="2">
                            <asp:Button ID="SendReply" runat="server" Text="Send Reply" OnClick="SendReply_Click" /></td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</body>
</html>
