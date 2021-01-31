<%@ Page Language="C#" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            string filename = Context.Request.QueryString["File"];
            if (string.IsNullOrEmpty(filename))
            {
                filename = Context.Request.CurrentExecutionFilePath;
            }

            TextBoxFile.Text = filename;

            try
            {
                string filepath = Server.MapPath(filename);

                this.Title = Path.GetFileName(filepath) + " - ViewCode";

                string rootdir = Server.MapPath("~/");
                if (!filepath.StartsWith(rootdir, StringComparison.InvariantCultureIgnoreCase))
                {
                    TextBoxCode.Text = "INVALID FILE";
                    return;
                }
                if (!File.Exists(filepath))
                {
                    TextBoxCode.Text = "INVALID FILE";
                    return;
                }
                string ext = Path.GetExtension(filepath).ToLower();
                switch (ext)
                {
                    case ".aspx":
                    case ".ascx":
                    case ".ashx":
                    case ".master":
                    case ".sitemap":
                    case ".css":
                        break;
                    default:
                        TextBoxCode.Text = "INVALID FILE TYPE";
                        return;
                }

                string code;
                using (StreamReader reader = new StreamReader(filepath, Encoding.UTF8, true))
                {
                    code = reader.ReadToEnd();
                }
                TextBoxCode.Text = code;
            }
            catch (Exception x)
            {
                TextBoxCode.Text = x.ToString();
            }

        }
    }

    //protected void ButtonGoto_Click(object sender, EventArgs e)
    //{
    //    Response.Redirect("ViewCode.aspx?File=" + HttpUtility.UrlEncode(TextBoxFile.Text.Trim()));
    //}
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Viewcode</title>
</head>
<body>
    <form id="form1" runat="server">
        Read Code :
        <asp:TextBox runat="server" ID="TextBoxFile" Font-Bold="true" ForeColor="Red" Width="560"></asp:TextBox>
        <br />
        <asp:TextBox ID="TextBoxCode" runat="server" Rows="18" Columns="80" TextMode="multiLine">
        </asp:TextBox>
    </form>
</body>
</html>
