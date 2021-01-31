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

		//Handle the client side onClick event for the Submit button. Script Error Exception will trigger a full page postback.
		SubmitButton.Attributes["onclick"] = "return submitbutton_click()";

	}

	void SubmitButton_Click(object sender, EventArgs e)
	{
		InsertMsg("You clicked the Submit Button.");
	}

	void Uploader_FileUploaded(object sender, UploaderEventArgs args)
	{
		//Get the full path of file that will be saved.
		string virpath = "/uploadfiles/" + args.FileGuid + System.IO.Path.GetExtension(args.FileName);

		InsertMsg("File uploaded! " + args.FileName + ", " + args.FileSize + " bytes.");
		InsertMsg(args.FileName + " saved to " + virpath);

		//Map the path to to a physical path.
		string savepath = Server.MapPath(virpath);

		//Do not overwrite an existing file
		if (System.IO.File.Exists(savepath))
			return;

		//Move the uploaded file to the target location
		args.MoveTo(savepath);


		//Get the data of uploaded file		
		HyperLink link = new HyperLink();
		link.Text = "Open " + args.FileName + " : " + virpath;
		link.NavigateUrl = virpath;
		link.Target = "_blank";
		link.Style[HtmlTextWriterStyle.Display] = "block";
		uploadedlinks.Controls.Add(link);

	}

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<title>Drag and drop, without automatic upload</title>
	<style>
		body {
			text-align: center;
			margin-top: 20px;
		}

		.content {
			text-align: left;
			width: 800px;
			border: solid 5px #CBCAC6;
			background-color: #f9f9f9;
			padding: 20px 20px 40px 20px;
			font-family: Segoe UI, Arial,Verdana,Helvetica,sans-serif;
			font-size: 80%;
			margin: 0 auto;
		}

		#DropZone {
			margin-top: 40px;
			margin-bottom: 20px;
			padding: 100px 0 80px 0;
			text-align: center;
			border: dashed 3px gray;
			background-image: url('images/cloud-upload1.png');
			background-repeat: no-repeat;
			background-position: 50% 40px;
			width: 650px;
		}

			#DropZone p {
				font-size: 25px;
			}

			#DropZone button {
				font-size: 16px;
			}

		select {
			width: 400px;
		}

		fieldset {
			background-color: White;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div class="content">
			<h2>Drag and drop, without automatic upload</h2>
			<p>
				Ajax Uploader allows users to upload files by simply dragging and dropping them over the control - without uploading files to server automatically.
			</p>
			<p style="font-size:12px; color:#666666">
				Note:
				<br />
				1. Use DropZoneID set the ID of a web control or HTML element where files can be dragged and dropped for upload.
				<br />
                2. Handle the client side onClick event for the Submit button.
                <br />
                3. ManualStartUpload=true
			</p>
			<div id="DropZone" style="">
				<p>
					Drag and drop Files Here to Upload
				</p>
				<p>
				</p>
				<p>
					<button id="InsertButton">Or Select Files to Upload</button>
				</p>

			</div>

			<CuteWebUI:UploadAttachments runat="server" ManualStartUpload="true" ID="Uploader1"
				InsertButtonID="InsertButton" QueuePanelID="QueuePanel" DropZoneID="DropZone" OnFileUploaded="Uploader_FileUploaded">
				<ValidateOption MaxSizeKB="10240" />
			</CuteWebUI:UploadAttachments>
			<p id="QueuePanel">
			</p>

			<p>
				<asp:Button runat="server" ID="SubmitButton" Text="Submit" OnClick="SubmitButton_Click" />
			</p>
			<p>
				<asp:ListBox runat="server" ID="ListBoxEvents" />
				<asp:Panel runat="server" ID="uploadedlinks"></asp:Panel>
			</p>

		</div>
	</form>


	<script type="text/javascript">

		//prevent the default handling by cancelling the event
		document.ondragover = document.ondragenter = document.ondrop = function (e) {
			e.preventDefault();
			return false;
		}



		// NOTE : Both WebForms/MVC Uploader use the same JavaScript API

		//get the uploader object by using document.getElementById
		var uploader = document.getElementById('<%=Uploader1.ClientID %>');

		var fileuploaded = false;
		var submitbutton = document.getElementById('<%=SubmitButton.ClientID %>');
		function submitbutton_click() {
			
			//return true and submit form if event is triggered by submitbutton.click
			if (fileuploaded)
				return true;

			//start uploading after file selection
			if (uploader.getqueuecount() > 0) {
				uploader.startupload();
			}
			else {
				alert("Please browse files for uploading");
			}
			//prevent form submission on button click event
			return false;
		}

		//Fires after all uploads are complete and submit the form
		function CuteWebUI_AjaxUploader_OnPostback() {
			fileuploaded = true;

			//use submitbutton to submit the form
			submitbutton.click();

			//return false to cancel the default form submission
			return false;
		}
	</script>
</body>
</html>
