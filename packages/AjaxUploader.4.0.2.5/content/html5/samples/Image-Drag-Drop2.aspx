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
	<title>Image Upload - Drag Drop Crop </title>
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

		#imagecontainer {
			margin-top: 40px;
			margin-bottom: 20px;
			padding: 100px 0 80px 0;
			text-align: center;
			border: dashed 3px gray;
			background-image: url('images/drag-and-drop-image2.png');
			background-repeat: no-repeat;
			background-position: 50% 40px;
			width: 650px;
			height: 400px;
		}

			#imagecontainer p {
				font-size: 16px;
			}

		#InsertButton {
			-moz-box-shadow: 0px 10px 40px -14px #3e7327;
			-webkit-box-shadow: 0px 10px 40px -14px #3e7327;
			box-shadow: 0px 10px 40px -14px #3e7327;
			background: -webkit-gradient(linear, left top, left bottom, color-stop(0.05, #77b55a), color-stop(1, #72b352));
			background: -moz-linear-gradient(top, #77b55a 5%, #72b352 100%);
			background: -webkit-linear-gradient(top, #77b55a 5%, #72b352 100%);
			background: -o-linear-gradient(top, #77b55a 5%, #72b352 100%);
			background: -ms-linear-gradient(top, #77b55a 5%, #72b352 100%);
			background: linear-gradient(to bottom, #77b55a 5%, #72b352 100%);
			filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#77b55a', endColorstr='#72b352',GradientType=0);
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
				background: -webkit-gradient(linear, left top, left bottom, color-stop(0.05, #72b352), color-stop(1, #77b55a));
				background: -moz-linear-gradient(top, #72b352 5%, #77b55a 100%);
				background: -webkit-linear-gradient(top, #72b352 5%, #77b55a 100%);
				background: -o-linear-gradient(top, #72b352 5%, #77b55a 100%);
				background: -ms-linear-gradient(top, #72b352 5%, #77b55a 100%);
				background: linear-gradient(to bottom, #72b352 5%, #77b55a 100%);
				filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#72b352', endColorstr='#77b55a',GradientType=0);
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
			<h2>Drag and drop & Image Crop (w/a different UI)</h2>
			<p>
				A sample demonstrates how to drag drop photo and crop it before upload.
			</p>


			<div id="imagecontainer" style="position: relative;">

				<p>
					<button id="InsertButton">Choose file to Upload</button>
				</p>
				<p>Or drop image file here</p>

			</div>


			<CuteWebUI:Uploader runat="server" ManualStartUpload="true" ID="Uploader1" ShowQueueTable="false"
				InsertButtonID="InsertButton" DropZoneID="imagecontainer" OnFileUploaded="Uploader_FileUploaded">
				<ValidateOption MaxSizeKB="10240" />
			</CuteWebUI:Uploader>

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

		var uploader;
		function CuteWebUI_AjaxUploader_OnInitialize() {
			uploader = this;//get uploader object
			uploader.internalobject.SetDialogAccept("image/*");
		}


		var fileuploaded = false;
		var submitbutton = document.getElementById('<%=SubmitButton.ClientID %>');
		function submitbutton_click() {

			//return true and submit form if event is triggered by submitbutton.click
			if (fileuploaded)
				return true;

			//start uploading after file selection
			if (uploader.getqueuecount() > 0) {
				uploader.startupload();//Start the upload of all queued files
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

		//Fires when files are selected successfully.
		function CuteWebUI_AjaxUploader_OnSelect(files) {
			var task = files[0];
			//Retrieve a list of file items defined by HTML5 <input type=file/>
			var srcfile = task.GetDomFile();
			if (!srcfile || srcfile.type.indexOf("image/") != 0)
				return;

			//if the browse don't support
			if (!window.Uint8Array || !window.ArrayBuffer)
				return;

			var div = document.getElementById("imagecontainer");
			div.style.display = "block";

			var option = {};
			//specify a file object for <input type=file/>
			option.file = srcfile;
			//specify an element for UI container 
			option.container = div;
			//specify the container padding
			option.padding = 5;
			//When square is set to false, uploader will use rectangular crop-area.
			option.square = false;
			//set the minimum width of an element
			option.minWidth = 64;
			//set the minimum height of an element
			option.minHeight = 64;

			//Fires after a file gets processed
			option.onchange = function (newfile, dataurl, width, height) {

				//use this function to overwrite the uploader file
				task.OverrideDomFile(newfile);

				document.title = width + "x" + height + "," + newfile.size + " bytes";
			}

			uploader.cropper(option);

		}
	</script>

</body>
</html>
