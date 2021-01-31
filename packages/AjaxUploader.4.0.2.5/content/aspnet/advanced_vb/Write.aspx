<%@ Page Language="VB" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<%@ Register Src="~/Controls/SelectMyFile.ascx" TagName="SelectMyFile" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
        MyBase.OnInit(e)
        SampleUtil.SetPageCache()
        AddHandler SelectMyFile1.SelectedFileChanged, AddressOf SelectMyFile1_SelectedFileChanged
    End Sub

    Private Sub SelectMyFile1_SelectedFileChanged(ByVal sender As Object, ByVal e As EventArgs)
        Dim filesize As Integer = CInt(SelectMyFile1.SelectedFile("FileSize"))
        Dim filename As String = DirectCast(SelectMyFile1.SelectedFile("FileName"), String)
        Dim tempname As String = DirectCast(SelectMyFile1.SelectedFile("TempFileName"), String)
        Dim filedir As String = SampleUtil.GetFileDirectory()
        Dim tempfilepath As String = Path.Combine(filedir, tempname)
        Using stream As New FileStream(tempfilepath, FileMode.Open, FileAccess.Read, FileShare.Read)
            TopicFiles.Items.Add(filesize, filename, stream)
        End Using
    End Sub

    Protected Sub SendTopic_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim valid As Boolean = True
    
        TopicTitle.BackColor = System.Drawing.Color.Empty
    
        Dim title As String = TopicTitle.Text.Trim()
    
        If String.IsNullOrEmpty(title) Then
            TopicTitle.BackColor = System.Drawing.Color.Yellow
            valid = False
        End If
    
        Dim body As String = TopicBody.Text
    
        If Not valid Then
            Return
        End If
    
        Dim currentUser As DataRow = SampleDB.GetCurentUserRow()
        Dim senderId As Integer = CInt(currentUser("UserId"))
        Dim senderName As String = DirectCast(currentUser("UserName"), String)
    
        Dim dir As String = SampleUtil.GetFileDirectory()
        Dim files As New List(Of FileItem)()
    
        'use to array so the Delete action will not break the foreach. 
        For Each attitem As AttachmentItem In TopicFiles.Items.ToArray()
            If attitem.Checked Then
                Dim newfilename As String = "topic." & attitem.FileGuid.ToString() & "." & attitem.FileSize.ToString() & "." & attitem.FileName & ".resx"
                Dim fileitem As New FileItem(dir, attitem)
                fileitem.TempFileName = newfilename
                attitem.CopyTo(fileitem.TempFilePath)
                files.Add(fileitem)
                attitem.Delete()
            End If
        Next
    
        Dim topicid As Integer = SampleDB.SendTopic(senderId, senderName, title, body, files.ToArray())
    
        SampleDB.ExecuteNonQuery("UPDATE UploaderTopics SET IPAddress={1} WHERE TopicId={0}", topicid, Context.Request.UserHostAddress)
    
        Response.Redirect("ReadTopic.aspx?TopicId=" & topicid.ToString())
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
    <h3>Send Topic</h3>                
    <table style="font:normal 12px Tahoma;width:98%">
        <tr>
            <td>
                Subject
            </td>
            <td>
                <asp:TextBox ID="TopicTitle" runat="server" Width="400px"></asp:TextBox></td>
        </tr>
        <tr>
            <td valign="top">
                Files
            </td>
            <td>
                <CuteWebUI:UploadAttachments runat="server" ID="TopicFiles">
			    <VALIDATEOPTION AllowedFileExtensions="jpeg, jpg, gif, zip, doc, pdf" MaxSizeKB="10240" />
                </CuteWebUI:UploadAttachments>
                <span style="margin-left:10px;font:normal 11px Tahoma;">
                    (Maximum file size: 10M, Allowed file types: jpeg, jpg, gif, zip, doc, pdf)
                </span>
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
            <td valign="top">
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
