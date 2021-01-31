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
            
            LoadTopic()
        End If
    End Sub
    Public ReadOnly Property TopicId() As Integer
    
        Get
            Return Integer.Parse(Request.QueryString("TopicId"))
        End Get
    End Property
    Private Sub LoadTopic()



        Dim row As DataRow = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId)
        If row Is Nothing Then
            LabelTitle.Text = "Record Not Found"
            Return
        End If
    
        Dim userid As Integer = CInt(row("UserId"))
        If SampleUtil.IsAdministratorIP OrElse userid = SampleDB.GetCurrentUserId() Then
            ManagePanel.Visible = True
        Else
            ManagePanel.Visible = False
        End If
    
        Dim sender As String = DirectCast(row("UserName"), String)
        Dim title As String = DirectCast(row("Title"), String)
    
        Me.Title = title & " - " & sender
    
        LabelTitle.Text = HttpUtility.HtmlEncode(title)
        LinkSender.Text = sender
    
        ImageSender.ImageUrl = "~/UserPhoto.ashx?User=" & sender
    
        Dim sb As New StringBuilder()
        sb.Append(HttpUtility.HtmlEncode(DirectCast(row("TopicBody"), String)))
        sb.Replace("" & Chr(13) & "" & Chr(10) & "", "<br/>")
    
        Dim table As DataTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId)
        GridView1.DataSource = table
        If table.Rows.Count = 0 Then
            GridView1.Visible = False
        Else
            GridView1.Visible = True
        End If
        GridView1.DataBind()
    
        For Each attrow As DataRow In table.Rows
            Dim attfilename As String = DirectCast(attrow("FileName"), String)
            ' if (attfilename.EndsWith(".swf", StringComparison.InvariantCultureIgnoreCase)) 
            ' { 
            ' sb.Append("<div class='TopicFlashFrame'>"); 
            ' sb.AppendFormat(@"<object width='500' height='400' classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/ 
            'swflash.cab#version=7,0,0,0'> 
            '<param name='movie' value='TopicAttachment.ashx?AttachmentId={0}' /> 
            '<param name='width' value='500' /> 
            '<param name='height' value='400' /> 
            '<param name='quality' value='high' /> 
            '<param name='bgcolor' value='#ffffff'/> 
            '<embed src='TopicAttachment.ashx?AttachmentId={0}' width='500' height='400' quality='high' bgcolor='#ffffff' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer' /> 
            '</object>", attrow["AttachmentId"]); 
            ' sb.Append("</div>"); 
            ' } 
            ' else 
            If SampleUtil.GetMimeType(attfilename).StartsWith("image/") Then
                sb.Append("<div class='TopicPhotoFrame'>")
                sb.Append(HttpUtility.HtmlEncode(DirectCast(attrow("FileName"), String)))
                sb.Append("<br/>")
                sb.Append("<img src='TopicAttachment.ashx?AttachmentId=")
                sb.Append(attrow("AttachmentId"))
                sb.Append("'/>")
                sb.Append("</div>")
            End If
        Next
    
        LabelBody.Text = sb.ToString()
    
        LabelSignature.Text = HttpUtility.HtmlEncode(Convert.ToString(GetUserRow(row("UserId"))("Signature")))
    
        Dim createTime As DateTime = DirectCast(row("CreateTime"), DateTime)
        LiteralBottom.Text = row("IPAddress").ToString() & " " & SampleUtil.ToUserLocalTime(createTime).ToString("yyyy-MM-dd HH:mm:ss")
    
        ReplyRepeater.DataBind()
    End Sub
    
    
    Private dictusers As New Dictionary(Of Integer, DataRow)()


    Private Function GetUserRow(ByVal userid As Object) As DataRow
        Dim id As Integer = Convert.ToInt32(userid)
        Dim row As DataRow = Nothing
        If dictusers.TryGetValue(id, row) Then
            Return row
        End If
        row = SampleDB.ExecuteDataRow("SELECT * FROM UploaderUsers WHERE UserId={0}", id)
        dictusers.Add(id, row)
        Return row
    End Function

    Protected Sub ReplyRepeater_DataBinding(ByVal sender As Object, ByVal e As EventArgs)
        Dim replyTable As DataTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderReplys WHERE TopicId={0}", TopicId)
        ReplyRepeater.DataSource = replyTable
        TopicReplySpliter.Visible = replyTable.Rows.Count > 0
    End Sub

    Protected Sub SendReply_Click(ByVal sender As Object, ByVal e As EventArgs)
        
        Me.ReplyBody.BackColor = System.Drawing.Color.Empty
        Dim ReplyBody As String = Me.ReplyBody.Text.Trim()
        If String.IsNullOrEmpty(ReplyBody) Then
            Me.ReplyBody.BackColor = System.Drawing.Color.Yellow
            Return
        End If
    
        Dim currentUser As DataRow = SampleDB.GetCurentUserRow()
        Dim senderId As Integer = CInt(currentUser("UserId"))
        Dim senderName As String = DirectCast(currentUser("UserName"), String)
    
        Dim replyid As Integer = SampleDB.SendReply(TopicId, senderId, senderName, ReplyBody)
    
        SampleDB.ExecuteNonQuery("UPDATE UploaderReplys SET IPAddress={1} WHERE ReplyId={0}", replyid, Context.Request.UserHostAddress)
    
        Me.ReplyBody.Text = ""
    
        ReplyRepeater.DataBind()
    End Sub


    Protected Sub ManageAction_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim row As DataRow = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId)
        If row Is Nothing Then
            Return
        End If
    
        Dim userid As Integer = CInt(row("UserId"))
        If SampleUtil.IsAdministratorIP OrElse userid = SampleDB.GetCurrentUserId() Then
            If ManageOption.SelectedValue = "Edit" Then
                Context.Response.Redirect("EditTopic.aspx?TopicId=" & TopicId.ToString())
            End If
            If ManageOption.SelectedValue = "Delete" Then
                Dim filedir As String = SampleUtil.GetFileDirectory()
                Dim table As DataTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId)
                For Each attrow As DataRow In table.Rows
                    Dim filename As String = DirectCast(attrow("TempFileName"), String)
                    File.Delete(Path.Combine(filedir, filename))
                Next
                SampleDB.ExecuteNonQuery("DELETE UploaderTopicAttachments Where TopicId={0} DELETE UploaderReplys Where TopicId={0} DELETE UploaderTopics Where TopicId={0}", TopicId)
                Response.Redirect("Ajax-based-File-Forum.aspx")
            End If
        End If
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
    </p><span style="float:right"><a href="Ajax-based-File-Forum.aspx">Forum Home</a></span>
        <div class="TopicContent">
            <table width="100%" border="0" style="font:normal 11px Tahoma; background-color:#999999" cellpadding="0" cellspacing="1">
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
                      <table width="100%" border="0" style="margin-top:2px;font:normal 11px Tahoma; background-color:#999999" cellpadding="0" cellspacing="1">
                         <tr bgcolor="white">
                            <td style="width: 150px; text-align: center; padding: 5px;">
                                <!--<%#Eval("UserId") %>-->
                                <div>
                                    <%#Eval("UserName")%>
                                </div>
                                <div>
                                    <img src='<%# "UserPhoto.ashx?User="&Eval("UserName") %>' /></div>
                            </td>
                            <td style="padding-left: 5px;">
                                <%#HttpUtility.HtmlEncode(Convert.ToString(Eval("ReplyBody"))).Replace("\r\n", "<br/>")%>
                                <div style="margin-top: 50px;">
                                    <%#HttpUtility.HtmlEncode(Convert.ToString(GetUserRow(Eval("UserId"))("Signature")))%>
                                </div>
                                <div>
                                    <%#Eval("IPAddress") %>
                                    <%#SampleUtil.ToUserLocalTime(Convert.ToDateTime(Eval("ReplyTime"))).ToString("yyyy-MM-dd HH:mm:ss")%>
                                </div>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="WriteReply">
           <table width="100%" border="0" style="margin-top:2px;font:normal 11px Tahoma; background-color:#999999" cellpadding="0" cellspacing="1">
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
