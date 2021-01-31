<%@ Page Language="C#" %>

<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
	void InsertMsg(string msg)
	{
		ListBoxEvents.Items.Insert(0, msg);
		ListBoxEvents.SelectedIndex = 0;
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
	<title>Drag Drop File</title>
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
			background-image: url('images/cloud-upload3.png');
			background-repeat: no-repeat;
			background-size: 100px 100px;
			background-position: 50% 20px;
			width: 650px;
		}

			#DropZone p {
				font-size: 15px;
			}

		#InsertButton {
			-moz-box-shadow: 0px 10px 40px -14px #3e7327;
			-webkit-box-shadow: 0px 10px 40px -14px #3e7327;
			box-shadow: 0px 10px 40px -14px #3e7327;
			background: linear-gradient(to bottom, #77b55a 5%, #72b352 100%);
			background-color: #77b55a;
			-moz-border-radius: 4px;
			-webkit-border-radius: 4px;
			border-radius: 4px;
			border: 1px solid #4b8f29;
			display: inline-block;
			cursor: pointer;
			color: #ffffff;
			font-family: Arial;
			font-size: 18px;
			font-weight: bold;
			padding: 9px 27px;
			text-decoration: none;
			text-shadow: 0px 1px 0px #5b8a3c;
		}

			#InsertButton:hover {
				background: linear-gradient(to bottom, #72b352 5%, #77b55a 100%);
				background-color: #72b352;
			}

			#InsertButton:active {
				position: relative;
				top: 1px;
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
			<h2>Drag and drop, automatic upload</h2>
			<p>
				Drag a file into the drop zone, and it'll be uploaded to the server instantly.
			</p>
			<p style="font-size:12px; color:#666666">
				Note:
				<br />
				1. Use DropZoneID set the ID of a web control or HTML element where files can be dragged and dropped for upload.
				<br />
                2. ManualStartUpload=false
			</p>

			<div id="DropZone" style="">
				<p>
				</p>
				<p>
					<button id="InsertButton">Choose files to Upload</button>
				</p>
				<p>
					or drag and drop them here
				</p>

			</div>

			<CuteWebUI:UploadAttachments runat="server" ManualStartUpload="false" ID="Uploader1"
				InsertButtonID="InsertButton" QueuePanelID="QueuePanel" DropZoneID="DropZone" OnFileUploaded="Uploader_FileUploaded">
				<ValidateOption MaxSizeKB="10240" />
			</CuteWebUI:UploadAttachments>
			<p id="QueuePanel">
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

		//Fires after all uploads are complete and submit the form
		function CuteWebUI_AjaxUploader_OnPostback() {

			//submit form
			document.forms[0].submit();

			//return false to cancel the default form submission
			return false;
		}
	</script>
</body>
</html>
