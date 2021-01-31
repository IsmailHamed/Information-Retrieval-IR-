<%@ Page Language="C#" %>

<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
	void InsertMsg(string msg)
	{
		ListBoxEvents.Items.Insert(0, msg);
		ListBoxEvents.SelectedIndex = 0;
	}

	protected override void OnInit(EventArgs e)
	{
		base.OnInit(e);

		SubmitButton.Attributes["onclick"] = "return submitbutton_click()";
	}

	void ButtonPostBack_Click(object sender, EventArgs e)
	{
		InsertMsg("You clicked a PostBack Button.");
	}

	void SubmitButton_Click(object sender, EventArgs e)
	{

		InsertMsg("You clicked the Submit Button.");
		InsertMsg("You have uploaded " + uploadcount + "/" + Uploader1.Items.Count + " files.");
	}

	int uploadcount = 0;

	void Uploader_FileUploaded(object sender, UploaderEventArgs args)
	{

		uploadcount++;

		InsertMsg("File uploaded! " + args.FileName + ", " + args.FileSize + " bytes.");

		//Copys the uploaded file to a new location.
		//args.CopyTo(path);
		//You can also open the uploaded file's data stream.
		//System.IO.Stream data = args.OpenStream();
	}

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<title>Drag Drop File</title>
	<link rel="stylesheet" href="demo.css" type="text/css" />
</head>
<body>
	<form id="form1" runat="server">
		<div class="content">
			<h2>Drag Drop File (HTML5 Only)</h2>
			<p>
				This sample shows you how to accept the files from drag&amp;drop.
			</p>
			<div id="DropPanel" style="border-style: dashed; border-width: 3px; border-color: gray; margin: 20px 0; padding: 50px 10px; text-align: center;">

				<p style="font-size: 25px;">
					Please drag and drop files into this panel
				</p>
				<p>
					Or:
				</p>
				<p>
					<button id="InsertButton">Browse Files (Max 1M)</button>
				</p>

			</div>

			<CuteWebUI:UploadAttachments runat="server" ManualStartUpload="true" ID="Uploader1"
				InsertButtonID="InsertButton" QueuePanelID="QueuePanel" DropZoneID="DropPanel" OnFileUploaded="Uploader_FileUploaded">
				<ValidateOption MaxSizeKB="1024" />
			</CuteWebUI:UploadAttachments>
			<p id="QueuePanel">
			</p>
			<p>
				<asp:Button runat="server" ID="SubmitButton" Text="Submit" OnClick="SubmitButton_Click" />
			</p>
			<p>
				<asp:ListBox runat="server" ID="ListBoxEvents" />
			</p>
			<asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />

			<script type="text/javascript">
				var fileuploaded = false;
				var submitbutton = document.getElementById('<%=SubmitButton.ClientID %>');
				function submitbutton_click() {
					var uploadobj = document.getElementById('<%=Uploader1.ClientID %>');
					if (fileuploaded)
						return true;
					if (uploadobj.getqueuecount() > 0) {
						uploadobj.startupload();
					}
					else {
						alert("Please browse files for uploading");
					}
					return false;
				}
				function CuteWebUI_AjaxUploader_OnPostback() {
					fileuploaded = true;
					submitbutton.click();
					return false;
				}
			</script>

		</div>
	</form>
</body>
</html>
