<%@ Control Language="VB" ClassName="SelectMyFile" %>

<script runat="server">
    Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
        MyBase.OnInit(e)
    
        LinkManage.Attributes("onclick") = "window.open(this.href,'ManageMyFiles','width=850,height=600,help=0,menubar=0,resizable=1,scrollbars=1').focus();return false;"
    End Sub

    Protected Sub Start_Click(ByVal sender As Object, ByVal e As EventArgs)
        LoadDataForSelect()
    
        Start.Visible = False
        [Select].Visible = True
    End Sub
    Private Sub LoadDataForSelect()

        Dim table As DataTable = SampleDB.ExecuteDataTable("SELECT * FROM UploaderFiles WHERE UserId={0} ORDER BY FileId DESC", SampleDB.GetCurrentUserId())
    
        [Select].Items.Clear()
        [Select].Items.Add("Please select a file ")
        [Select].Items.Add(" (Refresh this list) ")
        For Each row As DataRow In table.Rows
            Dim fileid As Integer = CInt(row("FileId"))
            Dim filesize As Integer = CInt(row("FileSize"))
            Dim filename As String = DirectCast(row("FileName"), String)
            Dim descript As String = DirectCast(row("Description"), String)
            Dim time As DateTime = DirectCast(row("UploadTime"), DateTime)
            time = SampleUtil.ToUserLocalTime(time)
        
            Dim text As String = time.ToString("MM-dd") & " " & filename & " (" & (filesize / 1024) & "K) " & descript
            [Select].Items.Add(New ListItem(text, fileid.ToString()))
        Next
    End Sub
    Private _filerow As DataRow
    Public ReadOnly Property SelectedFile() As DataRow
        Get
            Return _filerow
        End Get
    End Property

    Protected Sub Select_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        If [Select].SelectedIndex = 1 Then
            LoadDataForSelect()
            Return
        End If
    
        Dim fileid As Integer = Integer.Parse([Select].SelectedValue)
        [Select].SelectedIndex = 0
    
        Dim row As DataRow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE UserId={0} AND FileId={1}", SampleDB.GetCurrentUserId(), fileid)
    
        If row Is Nothing Then
            Return
        End If
    
        _filerow = row
        RaiseEvent SelectedFileChanged(Me, EventArgs.Empty)
    
    End Sub
    Public Event SelectedFileChanged As EventHandler

</script>
<asp:Button runat="server" ID="Start" Text="Select from MyFiles" Width="160px" OnClick="Start_Click" />
<asp:DropDownList runat="server" ID="Select" Visible="false" AutoPostBack="true"
	OnSelectedIndexChanged="Select_SelectedIndexChanged" Width="320px" />
<asp:HyperLink runat="server" ID="LinkManage" Text="Manage" NavigateUrl="~/Ajax-based-File-storage.aspx"
	Target="_blank"></asp:HyperLink>
