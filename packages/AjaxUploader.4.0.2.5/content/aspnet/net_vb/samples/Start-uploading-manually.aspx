<%@ Page Language="VB" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Private Sub InsertMsg(ByVal msg As String)
        ListBoxEvents.Items.Insert(0, msg)
        ListBoxEvents.SelectedIndex = 0
    End Sub

    Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
        MyBase.OnInit(e)
        SubmitButton.Attributes("onclick") = "return submitbutton_click()"
    End Sub

    Private Sub ButtonPostBack_Click(ByVal sender As Object, ByVal e As EventArgs)
        InsertMsg("You clicked a PostBack Button.")
    End Sub

    Private Sub SubmitButton_Click(ByVal sender As Object, ByVal e As EventArgs)
        InsertMsg("You clicked the Submit Button.")
        InsertMsg("You have uploaded " & uploadcount & "/" & Uploader1.Items.Count & " files.")
    End Sub

    Private uploadcount As Integer = 0

    Private Sub Uploader_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
        uploadcount += 1
    
        Dim uploader As Uploader = DirectCast(sender, Uploader)
        InsertMsg("File uploaded! " & args.FileName & ", " & args.FileSize & " bytes.")
    
        'Copys the uploaded file to a new location. 
        'args.CopyTo(path); 
        'You can also open the uploaded file's data stream. 
        'System.IO.Stream data = args.OpenStream(); 
    End Sub

    Protected Overloads Overrides Sub OnPreRender(ByVal e As EventArgs)
        SubmitButton.Attributes("itemcount") = Uploader1.Items.Count.ToString()
    
        MyBase.OnPreRender(e)
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Start uploading manually</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="content">
            <h2>
                Start uploading manually</h2>
            <p>
                This sample demonstrates how to start uploading manually after file selection vs
                automatically.</p>
            <CuteWebUI:UploadAttachments runat="server" ManualStartUpload="true" ID="Uploader1"
                InsertText="Browse Files (Max 1M)" OnFileUploaded="Uploader_FileUploaded">
                <ValidateOption MaxSizeKB="1024" />
            </CuteWebUI:UploadAttachments>
            <p>
                <asp:Button runat="server" ID="SubmitButton" Text="Submit" OnClick="SubmitButton_Click" />
            </p>
            <p>
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </p>
            <asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />

        <script type="text/javascript">
	
	function submitbutton_click()
	{
		var submitbutton=document.getElementById('<%=SubmitButton.ClientID %>');
		var uploadobj=document.getElementById('<%=Uploader1.ClientID %>');
		if(!window.filesuploaded)
		{
			if(uploadobj.getqueuecount()>0)
			{
				uploadobj.startupload();
			}
			else
			{
				var uploadedcount=parseInt(submitbutton.getAttribute("itemcount"))||0;
				if(uploadedcount>0)
				{
					return true;
				}
				alert("Please browse files for uploading");
			}
			return false;
		}
		window.filesuploaded=false;
		return true;
	}
	function CuteWebUI_AjaxUploader_OnPostback()
	{
		window.filesuploaded=true;
		var submitbutton=document.getElementById('<%=SubmitButton.ClientID %>');
		submitbutton.click();
		return false;
	}
        </script>

    </div>
    </form>
</body>
</html>
