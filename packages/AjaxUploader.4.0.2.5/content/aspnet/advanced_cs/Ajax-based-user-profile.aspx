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
            LoadView();
        }
    }

    private void LoadView()
    {
        DataRow row = SampleDB.GetCurentUserRow();

        TextBoxSignature.Text = row["Signature"].ToString();
        TextBoxDescription.Text = row["Description"].ToString();
        string photoname = row["PhotoTempFileName"].ToString();
        if (string.IsNullOrEmpty(photoname))
        {
            ImagePhoto.ImageUrl = "http://ajaxuploader.com/sampleimages/anonymous.gif";
        }
        else
        {
            ImagePhoto.ImageUrl = "UserPhoto.ashx?User=" + row["UserName"] + "&_hash=" + photoname.GetHashCode();
        }
    }

    double MaxWidth = 160.0;
    double MaxHeight = 120.0;

    protected void UploadPhoto_FileUploaded(object sender, UploaderEventArgs args)
    {
        try
        {
            System.Drawing.Bitmap img;
            using (Stream stream = args.OpenStream())
            {
                img = new System.Drawing.Bitmap(stream);
            }
            using (img)
            {
                if (img.Width > MaxWidth || img.Height > MaxHeight)
                {
                    double scale = Math.Max(img.Width / MaxWidth, img.Height / MaxHeight);
                    int w = (int)(img.Width / scale);
                    int h = (int)(img.Height / scale);
                    //System.Drawing.Image.GetThumbnailImageAbort

                    try
                    {
                        using (System.Drawing.Image thumb = new System.Drawing.Bitmap(w, h, System.Drawing.Imaging.PixelFormat.Format24bppRgb))
                        {
                            using (System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(thumb))
                            {
                                g.DrawImage(img
                                    , new System.Drawing.Rectangle(0, 0, w, h)
                                    , new System.Drawing.Rectangle(0, 0, img.Width, img.Height)
                                    , System.Drawing.GraphicsUnit.Pixel);
                            }

                            thumb.Save(args.GetTempFilePath(), System.Drawing.Imaging.ImageFormat.Png);
                            LabelPhotoError.Text = "The image is uploaded and resized.";
                        }

                    }
                    catch (Exception x)
                    {
                        LabelPhotoError.Text = w + ":" + h + ":" + x.ToString();
                        args.Delete();
                    }
                }
            }
        }
        catch (Exception x)
        {
            LabelPhotoError.Text = x.ToString();
            args.Delete();
        }
    }

    protected void UploadPhoto_FileChanged(object sender, PersistedFileEventArgs args)
    {
        ImagePhoto.ImageUrl = "ShowUploadPhoto.ashx?Guid=" + args.FileGuid;
    }

    protected void ButtonUpdate_Click(object sender, EventArgs e)
    {
        int userid = SampleDB.GetCurrentUserId();

        if (UploadPhoto.File != null)
        {
            DataRow row = SampleDB.GetCurentUserRow();
            string oldphotoname = row["PhotoTempFileName"].ToString();

            string filedir = SampleUtil.GetFileDirectory();
            string newfilename = "photo." + UploadPhoto.File.FileGuid + "." + UploadPhoto.File.FileName + ".resx";
            UploadPhoto.File.MoveTo(Path.Combine(filedir, newfilename));
            SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET Signature={1},Description={2},PhotoTempFileName={3} WHERE UserId={0}"
            , userid, TextBoxSignature.Text, TextBoxDescription.Text, newfilename);

            if (!string.IsNullOrEmpty(oldphotoname))
            {
                string oldphotopath = Path.Combine(filedir, oldphotoname);
                if (File.Exists(oldphotopath))
                {
                    File.Delete(oldphotopath);
                }
            }
        }
        else
        {
            SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET Signature={1},Description={2} WHERE UserId={0}"
            , userid, TextBoxSignature.Text, TextBoxDescription.Text);
        }

        SampleDB.ExecuteNonQuery("UPDATE UploaderUsers SET IPAddress={1} WHERE UserId={0}", userid, Context.Request.UserHostAddress);

        SampleDB.ResetCurrentUserRow();

        LoadView();

        int time = 0;
        if (ViewState["SaveOK"] != null)
            time = (int)ViewState["SaveOK"];
        time++;
        ViewState["SaveOK"] = time;

        ButtonUpdate.Text = "Updated successfully " + new string('!', time);
    }
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
                    <td>
                        Image:
                    </td>
                    <td>
                        <asp:Image ID="ImagePhoto" runat="server" CssClass="ImagePhoto" />
                        <br />
                        <CuteWebUI:UploadPersistedFile AutoUseSystemTempFolder="false" runat="server" ID="UploadPhoto"
                            DirtyText="(not saved)" InsertText="Change the profile Image" OnFileUploaded="UploadPhoto_FileUploaded"
                            OnFileChanged="UploadPhoto_FileChanged" ItemTextTemplate="<br/>{0} {1} ({2})">
                            <ValidateOption AllowedFileExtensions="jpg,jpeg,gif,png" />
                        </CuteWebUI:UploadPersistedFile>
                    </td>
                </tr>
                <tr>
                    <td>
                        Description:
                    </td>
                    <td>
                        <asp:TextBox ID="TextBoxDescription" runat="server" Height="50px" TextMode="MultiLine"
                            Width="250px"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        Signature:
                    </td>
                    <td>
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
