<%@ Page Language="VB" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<%@ Register Src="~/Controls/SelectMyFile.ascx" TagName="SelectMyFile" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
 
    Class TopicAttachmentProvider
        Implements CuteWebUI.IAttachmentProvider
        
        Private Class FileItem
            Inherits Global.FileItem
            Public Sub New(ByVal topicid As Integer, ByVal guid As Guid)
                MyBase.New(SampleUtil.GetFileDirectory())
                _topicid = topicid
                FileGuid = guid
            End Sub
        
            Private _topicid As Integer
            Private attrow As DataRow
            Public Sub Prepair()
                attrow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderTopicAttachments WHERE TopicId={0} AND FileGuid={1}", _topicid, FileGuid)
                If attrow IsNot Nothing Then
                    Me.FileSize = CInt(attrow("FileSize"))
                    Me.FileName = DirectCast(attrow("FileName"), String)
                    Me.TempFileName = DirectCast(attrow("TempFileName"), String)
                End If
            
            End Sub
        
            Private _deleted As Boolean = False
            Public ReadOnly Property Exists() As Boolean
                Get
                    If _deleted Then
                        Return False
                    End If
                    If attrow Is Nothing Then
                        Return False
                    End If
                    Return True
                End Get
            End Property
        End Class
    
        Private _topicid As Integer
        Public Sub New(ByVal topicid As Integer)
            _topicid = topicid
        End Sub
    
        Public Function OpenQuery(ByVal guid As Guid) As Object Implements CuteWebUI.IAttachmentProvider.OpenQuery
            Dim item As New FileItem(_topicid, guid)
            item.Prepair()
            Return item
        End Function
    
        Public Sub CloseQuery(ByVal cookie As Object) Implements CuteWebUI.IAttachmentProvider.CloseQuery
        
        End Sub
    
        Public Function FileExists(ByVal guid As Guid, ByVal cookie As Object) As Boolean Implements CuteWebUI.IAttachmentProvider.FileExists
            Dim item As FileItem = DirectCast(cookie, FileItem)
            Return item.Exists
        End Function
    
        Public Function GetFileSize(ByVal guid As Guid, ByVal cookie As Object) As Integer Implements CuteWebUI.IAttachmentProvider.GetFileSize
            Dim item As FileItem = DirectCast(cookie, FileItem)
            Return item.FileSize
        End Function
    
        Public Function GetFileName(ByVal guid As Guid, ByVal cookie As Object) As String Implements CuteWebUI.IAttachmentProvider.GetFileName
            Dim item As FileItem = DirectCast(cookie, FileItem)
            Return item.FileName
        End Function
    
        Public Function OpenFileStream(ByVal guid As Guid, ByVal cookie As Object) As Stream Implements CuteWebUI.IAttachmentProvider.OpenFileStream
            Dim item As FileItem = DirectCast(cookie, FileItem)
            If Not item.Exists Then
                Throw (New Exception("File not exists"))
            End If
            Return New FileStream(item.TempFilePath, FileMode.Open, FileAccess.Read, FileShare.Read)
        End Function
    
        Public Function HasTempPath(ByVal guid As Guid, ByVal cookie As Object) As String Implements CuteWebUI.IAttachmentProvider.HasTempPath
            Dim item As FileItem = DirectCast(cookie, FileItem)
            Return item.TempFilePath
        End Function
    
        Public Sub DeleteFile(ByVal guid As Guid, ByVal cookie As Object) Implements CuteWebUI.IAttachmentProvider.DeleteFile
            Dim item As FileItem = DirectCast(cookie, FileItem)
            If Not item.Exists Then
                Return
            End If
        
            File.Delete(item.TempFilePath)
            SampleDB.ExecuteNonQuery("DELETE UploaderTopicAttachments WHERE FileGuid={0}", item.FileGuid)
        End Sub
    End Class
    Public ReadOnly Property TopicId() As Integer
    
    
        Get
            Return Integer.Parse(Request.QueryString("TopicId"))
        End Get
    End Property
    Private row As DataRow


    Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
        MyBase.OnInit(e)
    
        SampleUtil.SetPageCache()
        row = SampleDB.ExecuteDataRow("UPDATE UploaderTopics SET ViewCount=ViewCount+1 WHERE TopicId={0} SELECT * FROM UploaderTopics WHERE TopicId={0}", TopicId)
    
        Dim userid As Integer = CInt(row("UserId"))
        'OK 
        If SampleUtil.IsAdministratorIP OrElse userid = SampleDB.GetCurrentUserId() Then
        Else
            Throw (New Exception("INVALID OWNER"))
        End If
    
        TopicFiles.CustomProvider = New TopicAttachmentProvider(TopicId)
    
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

    Protected Overloads Overrides Sub OnLoad(ByVal e As EventArgs)
        MyBase.OnLoad(e)
    
        If Not IsPostBack Then
            TopicTitle.Text = DirectCast(row("Title"), String)
            TopicBody.Text = DirectCast(row("TopicBody"), String)
            Dim table As DataTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderTopicAttachments Where TopicId={0}", TopicId)
            For Each attrow As DataRow In table.Rows
                TopicFiles.AddCustomAttachment(DirectCast(attrow("FileGuid"), Guid))
            Next
        End If
    End Sub

    Protected Sub SaveTopic_Click(ByVal sender As Object, ByVal e As EventArgs)
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
    
        Dim dir As String = SampleUtil.GetFileDirectory()
        Dim files As New List(Of FileItem)()
        Dim removes As New List(Of Guid)()
    
        'use to array so the Delete action will not break the foreach. 
        For Each attitem As AttachmentItem In TopicFiles.Items.ToArray()
            If attitem.IsCustom Then
                'remove exists item.. 
                If Not attitem.Checked Then
                    removes.Add(attitem.FileGuid)
                    attitem.Delete()
                End If
            ElseIf attitem.Checked Then
                Dim newfilename As String = "topic." & attitem.FileGuid.ToString() & "." & attitem.FileSize.ToString() & "." & attitem.FileName & ".resx"
                Dim fileitem As New FileItem(dir, attitem)
                fileitem.TempFileName = newfilename
                attitem.CopyTo(fileitem.TempFilePath)
                files.Add(fileitem)
                attitem.Delete()
            End If
        Next
    
        SampleDB.ExecuteNonQuery("UPDATE UploaderTopics SET Title={1},TopicBody={2},IPAddress={3} WHERE TopicId={0}", TopicId, title, body, Context.Request.UserHostAddress)
        For Each fileitem As FileItem In files
            SampleDB.ExecuteNonQuery("INSERT UploaderTopicAttachments (TopicId,FileGuid,FileSize,FileName,TempFileName) VALUES ({0},{1},{2},{3},{4})", TopicId, fileitem.FileGuid, fileitem.FileSize, fileitem.FileName, fileitem.TempFileName)
        Next
    
        Response.Redirect("ReadTopic.aspx?TopicId=" & TopicId.ToString())
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
    <h3>Edit Topic</h3>
     <table width="100%" border="0" style="font:normal 12px Tahoma;" cellpadding="2" cellspacing="1">           
        <tr>
            <td valign="top">
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
                <asp:Button ID="SaveTopic" runat="server" Text="Save Change" OnClick="SaveTopic_Click" /></td>
        </tr>
    </table>
                </div>
         
    </form>
</body>
</html>
