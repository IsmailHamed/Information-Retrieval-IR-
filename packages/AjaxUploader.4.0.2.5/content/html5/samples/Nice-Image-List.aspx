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
	<title>Drag and drop & preview image from listview</title>
	<style>
		body {
			text-align: center;
			margin-top: 20px;
		}

		.content {
			text-align: left;
			width: 750px;
			border: solid 5px #CBCAC6;
			background-color: #f9f9f9;
			padding: 20px 20px 40px 20px;
			font-family: Segoe UI, Arial,Verdana,Helvetica,sans-serif;
			font-size: 80%;
			margin: 0 auto;
		}

		select {
			width: 400px;
		}

		fieldset {
			background-color: White;
		}

		#grid {
			box-sizing: border-box;
			width: 725px;
			height: 525px;
			padding: 8px;
			margin: 8px;
			background-image: url(images/drag-and-drop-area.png);
			background-repeat: no-repeat;
			overflow: auto;
		}

		.itemdiv {
			width: 100%;
			height: 60px;
			box-sizing: border-box;
			position: relative;
			box-sizing: border-box;
			border-bottom: dashed 1px gray;
			padding-bottom: 3px;
			background-color: rgba(225,225,225,0.7);
		}

		.iteminner {
			position: absolute;
			left: 15px;
			top: 5px;
			width: 46px;
			height: 46px;
			box-sizing: border-box;
			border-radius: 8px;
			border: solid 1px #333333;
			background-color: white;
			padding: 5px;
			display: table;
			text-align: center;
			vertical-align: middle;
			box-shadow: 1px 2px 2px 1px #333333;
		}

		.itemcell {
			display: table-cell;
			vertical-align: middle;
		}

		.itemimage {
			max-width: 36px;
			max-height: 36px;
			vertical-align: middle;
		}

		.itemclose {
			position: absolute;
			right: 10px;
			top: 20px;
			width: 16px;
			height: 16px;
			background-repeat: no-repeat;
			background-position: center center;
			background-image: url(images/icon16_close.png);
			cursor: pointer;
		}

		.iteminfo {
			font-size: 18px;
			position: absolute;
			display: block;
			border-radius: 8px;
			top: 20px;
			left: 80px;
			width: 396px;
		}

		.itemdivfinish .iteminfo {
			color: blue;
		}

		.itemdiverror .iteminfo {
			color: red;
		}

		.itemdivupload .iteminfo {
			color: orange;
		}

		.itemdivqueue .iteminfo {
			color: black;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div class="content">
			<h2>Drag and drop & preview image from listview</h2>
			<p>
				An advanced sample demonstrates how to drag drop images and preview images from listview.
			</p>
			<p style="color: red">
				Click the thumbnails to edit the images.
			</p>

			<p>

				<asp:Button runat="server" ID="insertbtn" Text="Browser Files" Font-Size="18px" />
				<asp:Button runat="server" ID="SubmitButton" Text="Upload Files Now" OnClick="SubmitButton_Click" Font-Size="18px" />
			</p>

			<div id="grid">
			</div>


			<CuteWebUI:UploadAttachments runat="server" DropZoneID="form1" ManualStartUpload="true" ID="Uploader1" ShowQueueTable="false"
				InsertButtonID="insertbtn" OnFileUploaded="Uploader_FileUploaded">
				<InsertButtonStyle Font-Size="18px" />
			</CuteWebUI:UploadAttachments>

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

		var lastprogress;
		var uploadingitem = null;

		//Fires when new information about the upload progress for a specific file is available.
		function CuteWebUI_AjaxUploader_OnProgress(isuploading, filename, startTime, sentLen, totalLen) {
			if (!isuploading) {
				lastprogress = null;
				return false;
			}
			lastprogress = {};
			lastprogress.name = filename;
			lastprogress.sent = sentLen;
			lastprogress.size = totalLen;
			SetProgress(uploadingitem);
			return false;//hide the default progress bar
		}

		function SetProgress(item) {
			if (!item)
				return;
			if (lastprogress && lastprogress.name == item.name) {
				var p = Math.floor(100 * lastprogress.sent / lastprogress.size);
				if (!isNaN(p)) {
					item.info.innerHTML = p + "%";
					return;
				}
			}
			item.info.innerHTML = "-%";
		}

		var divgrid = document.getElementById("grid");

		var imageItems = [];
		function FindItem(guid) {
			for (var i = 0; i < imageItems.length; i++)
				if (imageItems[i].guid == guid)
					return imageItems[i];
		}

		function CreateItemUI(item) {
			item.div = document.createElement("div");
			item.div.className = "itemdiv";
			item.inner = document.createElement("div");
			item.inner.className = "iteminner";
			item.close = document.createElement("div");
			item.close.className = "itemclose";

			item.cell = document.createElement("span");
			item.cell.className = "itemcell";

			item.image = document.createElement("img");
			item.image.className = "itemimage";

			item.info = document.createElement("div");
			item.info.className = "iteminfo";

			divgrid.appendChild(item.div);
			item.div.appendChild(item.inner);
			item.div.appendChild(item.close);
			item.inner.appendChild(item.cell);
			item.cell.appendChild(item.image);

			item.div.appendChild(item.info);

		}

		var esckeycallback = null;
		document.addEventListener("keydown", function (e) {
			if (e.keyCode == 27 && esckeycallback) {
				var func = esckeycallback;
				esckeycallback = null;
				func();
			}
		});

		function AppendItem(task) {

			var item = {};

			item.guid = task.InitGuid;
			item.name = task.FileName;

			CreateItemUI(item);

			item.close.onclick = function () {
				task.Cancel();
			}

			//Retrieve a list of file items defined by HTML5 <input type=file/>
			var srcfile = task.GetDomFile();
			if (!srcfile || srcfile.type.indexOf("image/") != 0) {
				item.notimage = true;
				item.image.src = "images/file.png";
				var ext = item.name.split('.');
				ext = ext[Math.max(1, ext.length - 1)] || "";
				item.info.innerHTML = "." + ext;
				return item;
			}

			var reader = new FileReader();
			reader.onload = function (e) {
				item.image.src = e.target.result;
			}
			reader.readAsDataURL(srcfile);

			item.image.style.cursor = "pointer";
			item.image.onclick = function () {
				if (!item.container) {
					item.container = document.createElement("div");
				}

				var full = document.createElement("div");

				var fs = full.style;
				fs.position = "fixed";
				fs.left = fs.top = "0px";
				fs.width = fs.height = "100%";
				document.body.appendChild(full);

				var mask = document.createElement("div");
				var ms = mask.style;
				ms.position = "absolute";
				ms.left = ms.top = "0px";
				ms.width = ms.height = "100%";
				ms.backgroundColor = "rgba(127,127,127,0.5)";

				esckeycallback = mask.onclick = item.container.ondblclick = function () {
					if (full.parentNode == document.body)
						document.body.removeChild(full);
				}

				full.appendChild(mask);

				var s = item.container.style;
				s.position = "absolute";
				s.display = "block";
				s.width = s.height = "500px";
				s.border = "solid 1px gray";
				s.backgroundColor = "white";
				s.left = (document.documentElement.clientWidth - 500) / 2 + "px";
				s.top = (document.documentElement.clientHeight - 500) / 2 + "px";

				full.appendChild(item.container);

				if (!item.cropping) {
					item.cropping = true;
					StartCropper(item.task, item.container, onchange);
				}


			}

			//Fires after a file gets processed
			function onchange(newfile, dataurl, width, height) {

				//use this function to overwrite the uploader file
				task.OverrideDomFile(newfile);

				item.image.src = dataurl;

			}

			return item;
		}

		function UpdateItem(item, task) {
			item.task = task;

			switch (task.Status) {
				case "Finish":
					item.div.className = "itemdiv itemdivfinish";
					item.info.innerHTML = "DONE";
					break;
				case "Error":
					item.div.className = "itemdiv itemdiverror";
					item.info.innerHTML = "ERROR";
					break;
				case "Upload":
					item.div.className = "itemdiv itemdivupload";
					uploadingitem = item;
					SetProgress(item);
					break;
				case "Queue":
					item.div.className = "itemdiv itemdivqueue";
					item.info.innerHTML = task.FileName + " (" + task.FileSize + ")";
					break;
			}
		}


		function OnItemRemoved(item) {
			divgrid.removeChild(item.div);
		}

		function CuteWebUI_AjaxUploader_OnQueueUI(files) {
			for (var i = 0; i < imageItems.length; i++)
				imageItems[i].exists = false;
			for (var i = 0; i < files.length; i++) {
				var task = files[i];
				var item = FindItem(task.InitGuid);
				if (item == null) {
					item = AppendItem(task);
					imageItems.push(item);
				}
				UpdateItem(item, task);
				item.exists = true;
			}
			for (var i = 0; i < imageItems.length; i++) {
				var item = imageItems[i];
				if (item.exists)
					continue;
				imageItems.splice(i, 1);
				i--;
				OnItemRemoved(item);
			}

			//divgrid.style.backgroundImage = files.length > 0 ? "none" : "";
		}

		function StartCropper(task, div, onchange) {

			//Retrieve a list of file items defined by HTML5 <input type=file/>
			var srcfile = task.GetDomFile();
			if (!srcfile || srcfile.type.indexOf("image/") != 0)
				return;

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
			option.onchange = onchange;

			uploader.cropper(option);

		}

		function InitPage() {

		}

		InitPage();

	</script>


</body>
</html>
