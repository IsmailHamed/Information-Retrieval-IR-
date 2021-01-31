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
        Dim table As DataTable = SampleDB.Create(SampleDB.GetCurrentUserId()).[Select]("*").From("UploaderFiles").Where("UserId={0}").OrderBy("FileId DESC").Range(start, count).GetTotalCount(total)
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
        link.NavigateUrl = "Ajax-based-File-storage.aspx?Page=" & num.ToString()
    End Sub

    Protected Sub Uploader1_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
        
    
        Dim filedir As String = SampleUtil.GetFileDirectory()
        Dim newname As String = "myfile." & args.FileGuid.ToString() & "." & args.FileName & ".resx"
    
        SampleDB.ExecuteNonQuery("INSERT UploaderFiles (UserId,UploadTime,FileGuid,FileSize,FileName,TempFileName,IPAddress) VALUES ({0},{1},{2},{3},{4},{5},{6})", SampleDB.GetCurrentUserId(), DateTime.Now, args.FileGuid, args.FileSize, _
        args.FileName, newname, Context.Request.UserHostAddress)
    
        args.CopyTo(Path.Combine(SampleUtil.GetFileDirectory(), newname))
    
       
        GridView1.DataBind()
    End Sub

    Protected Sub ButtonDelete_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim fileids As New List(Of Integer)()
        For Each row As GridViewRow In GridView1.Rows
            If row.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = DirectCast(row.FindControl("CheckBoxSelect"), CheckBox)
                If cb IsNot Nothing AndAlso Not cb.Checked Then
                    Try
                        Dim fileid As Integer = CInt(GridView1.DataKeys(row.RowIndex).Value)
                    
                        
                        fileids.Add(fileid)
                    Catch
                        
                        cb.Checked = True
                    End Try
                End If
            End If
        Next
    
        If fileids.Count = 0 Then
            Return
        End If
    
        Dim filedir As String = SampleUtil.GetFileDirectory()
    
        'check the userid , dont trust the viewstate 
        Dim userid As Integer = SampleDB.GetCurrentUserId()
    
        For Each fileid As Integer In fileids
            Dim row As DataRow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE FileId={0} AND UserId={1}", fileid, userid)
            If row IsNot Nothing AndAlso userid.Equals(row("UserId")) Then
                SampleDB.ExecuteNonQuery("DELETE UploaderFiles WHERE FileId={0} AND UserId={1}", fileid, userid)
                File.Delete(Path.Combine(filedir, DirectCast(row("TempFileName"), String)))
            End If
        Next
    
        GridView1.DataBind()
    End Sub
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
                File storage application powered by Ajax
            </h2>
            <p>
                This example shows you how to use Ajax Uploader create an online file storage application.
                Make your file upload page more user friendly!
            </p>
            <div>                   
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Add files (Max 100MB)" OnFileUploaded="Uploader1_FileUploaded" MultipleFilesUpload="true">
               <VALIDATEOPTION AllowedFileExtensions="jpeg, jpg, gif, png, zip, doc, rtf, pdf" MaxSizeKB="102400" />
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
                                <%#SampleUtil.ToUserLocalTime(Convert.ToDateTime(Eval("UploadTime"))).ToString("MM-dd")%>
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
