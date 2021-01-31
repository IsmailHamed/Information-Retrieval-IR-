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
            LoadView()
        End If
    End Sub
    Private Sub LoadView()

        Dim row As DataRow = SampleDB.GetCurentUserRow()
    
        TextBoxSignature.Text = row("Signature").ToString()
        TextBoxDescription.Text = row("Description").ToString()
        Dim photoname As String = row("PhotoTempFileName").ToString()
        If String.IsNullOrEmpty(photoname) Then
            ImagePhoto.ImageUrl = "http://ajaxuploader.com/sampleimages/anonymous.gif"
        Else
            ImagePhoto.ImageUrl = "UserPhoto.ashx?User=" & row("UserName").ToString() & "&_hash=" & photoname.GetHashCode().ToString()
        End If
    End Sub
    Private MaxWidth As Double = 160
    Private MaxHeight As Double = 120


    Protected Sub UploadPhoto_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
    
    
        Try
            Dim img As System.Drawing.Bitmap
            Using stream As Stream = args.OpenStream()
                img = New System.Drawing.Bitmap(stream)
            End Using
            Using img
                If img.Width / img.Height > 2 OrElse img.Height / img.Width > 2 Then
                    LabelPhotoError.Text = "Width:Height must between 2 and 1/2"
                    args.Delete()
                    Return
                End If
                If img.Width < 32 OrElse img.Height < 32 Then
                    LabelPhotoError.Text = "Photo too small"
                    args.Delete()
                    Return
                End If
                If img.Width > MaxWidth OrElse img.Height > MaxHeight Then
                    Dim scale As Double = Math.Max(img.Width / MaxWidth, img.Height / MaxHeight)
                    Dim w As Integer = CInt((img.Width / scale))
                    Dim h As Integer = CInt((img.Height / scale))
                    'System.Drawing.Image.GetThumbnailImageAbort 
                
                    Try
                        Using thumb As System.Drawing.Image = New System.Drawing.Bitmap(w, h, System.Drawing.Imaging.PixelFormat.Format24bppRgb)
                            Using g As System.Drawing.Graphics = System.Drawing.Graphics.FromImage(thumb)
                                g.DrawImage(img, New System.Drawing.Rectangle(0, 0, w, h), New System.Drawing.Rectangle(0, 0, img.Width, img.Height), System.Drawing.GraphicsUnit.Pixel)
                            End Using
                        
                            thumb.Save(args.GetTempFilePath(), System.Drawing.Imaging.ImageFormat.Png)
                            LabelPhotoError.Text = "Photo replaced , the size been changed too."
                        
                        End Using
                    Catch x As Exception
                        LabelPhotoError.Text = w & ":" & h & ":" & x.ToString()
                        args.Delete()
                    End Try
                End If
            End Using
        Catch x As Exception
            LabelPhotoError.Text = x.ToString()
            args.Delete()
        End Try
    End Sub

    Protected Sub UploadPhoto_FileChanged(ByVal sender As Object, ByVal args As PersistedFileEventArgs)
        ImagePhoto.ImageUrl = "ShowUploadPhoto.ashx?Guid=" & args.FileGuid.ToString()
    End Sub

    Protected Sub ButtonUpdate_Click(ByVal sender As Object, ByVal e As EventArgs)
        Dim userid As Integer = SampleDB.GetCurrentUserId()
    
        If UploadPhoto.File IsNot Nothing Then
            Dim row As DataRow = SampleDB.GetCurentUserRow()
            Dim oldphotoname As String = row("PhotoTempFileName").ToString()
        
            Dim filedir As String = SampleUtil.GetFileDirectory()
            Dim newfilename As String = "photo." & UploadPhoto.File.FileGuid.ToString() & "." & UploadPhoto.File.FileName & ".resx"
            UploadPhoto.File.MoveTo(Path.Combine(filedir, newfilename))
            SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET Signature={1},Description={2},PhotoTempFileName={3} WHERE UserId={0}", userid, TextBoxSignature.Text, TextBoxDescription.Text, newfilename)
        
            If Not String.IsNullOrEmpty(oldphotoname) Then
                Dim oldphotopath As String = Path.Combine(filedir, oldphotoname)
                If File.Exists(oldphotopath) Then
                    File.Delete(oldphotopath)
                End If
            End If
        Else
            SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET Signature={1},Description={2} WHERE UserId={0}", userid, TextBoxSignature.Text, TextBoxDescription.Text)
        End If
    
        SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET IPAddress={1} WHERE UserId={0}", userid, Context.Request.UserHostAddress)
    
        SampleDB.ResetCurrentUserRow()
    
        LoadView()
    
        Dim time As Integer = 0
        If ViewState("SaveOK") IsNot Nothing Then
            time = CInt(ViewState("SaveOK"))
        End If
        time += 1
        ViewState("SaveOK") = time
    
        ButtonUpdate.Text = "Updated successfully " & New String("!"c, time)
    End Sub
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Ajax based user profile</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="content">
            <h2>
                Ajax based user profile</h2>
            <p>
                User profile is the primary part of a community application. Ever wanted to allow
                users update the images of their profiles using AJAX without reloading the page?
                Test it now!
            </p>
            <table cellpadding="2" cellspacing="2">
                <tr>
                    <td valign="top">
                        Image:
                    </td>
                    <td valign="top">
                        <asp:Image ID="ImagePhoto" runat="server" CssClass="ImagePhoto" />
                        <br />
                        <cutewebui:uploadpersistedfile autousesystemtempfolder="false" runat="server" id="UploadPhoto"
                            dirtytext="(not saved)" inserttext="Change the profile Image" onfileuploaded="UploadPhoto_FileUploaded"
                            onfilechanged="UploadPhoto_FileChanged" itemtexttemplate="<br/>{0} {1} ({2})">
                            <ValidateOption AllowedFileExtensions="jpg,jpeg,gif,png" />
                        </cutewebui:uploadpersistedfile>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Description:
                    </td>
                    <td valign="top">
                        <asp:TextBox ID="TextBoxDescription" runat="server" Height="50px" TextMode="MultiLine"
                            Width="250px"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        Signature:
                    </td>
                    <td valign="top">
                        <asp:TextBox ID="TextBoxSignature" runat="server" Height="50px" TextMode="MultiLine"
                            Width="250px"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Button ID="ButtonUpdate" runat="server" OnClick="ButtonUpdate_Click" Text="Save My Information" />
                        <asp:Label ID="LabelPhotoError" runat="server" EnableViewState="false" Font-Bold="true"
                            ForeColor="red"></asp:Label>
                    </td>
                </tr>
            </table>
            <asp:Label ID="l1" runat="server"></asp:Label>&nbsp;&nbsp;
            <asp:Label ID="l2" runat="server"></asp:Label>
        </div>
    </form>
</body>
</html>
