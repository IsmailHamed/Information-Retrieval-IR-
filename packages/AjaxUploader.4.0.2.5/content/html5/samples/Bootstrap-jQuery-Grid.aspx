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

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Bootstrap Grid</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="js/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="js/bootstrap.min.js"></script>
	<style>
		body {
			text-align: center;
			margin-top: 20px;
		}

		.content {
			text-align: left;
			width: 790px;
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
			background-image: url(images/drag-and-drop-zone.png);
			background-repeat: no-repeat;
		}

		.itemdiv {
			float: left;
			width: 112px;
			height: 112px;
			box-sizing: border-box;
			position: relative;
		}

		.iteminner {
			position: absolute;
			left: 8px;
			top: 8px;
			width: 96px;
			height: 96px;
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
			max-width: 86px;
			max-height: 86px;
			vertical-align: middle;
		}

		.itemclose {
			position: absolute;
			right: 0px;
			top: 0px;
			width: 16px;
			height: 16px;
			background-repeat: no-repeat;
			background-position: center center;
			background-image: url(images/icon16_close.png);
			cursor: pointer;
		}

		.iteminfo {
			font-size: 18px;
			line-height: 86px;
			position: absolute;
			display: block;
			border-radius: 8px;
			left: 0px;
			top: 0px;
			width: 96px;
			height: 96px;
			background-color: rgba(127,127,127,0.6);
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
			display: none;
		}

		.itemnotimage .iteminfo {
			display: block;
			color: white;
		}

		.itemdivaddbtn .iteminfo {
			color: blue;
			background-color: transparent;
		}

		.itemdivaddbtn .itemclose {
			display: none;
		}

		.itemdivaddbtn #insertbtn {
			background-image: url(images/icon64_add.png);
			background-repeat: no-repeat;
			background-position: center center;
			width: 96px;
			height: 96px;
			cursor: pointer;
		}
	</style>
</head>
</head>
<body>
	<form id="form1" runat="server">


		<div class="modal fade" id="myModal" tabindex="-1" role="dialog">
			<div class="modal-dialog" style="width: 520px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
						<h4 class="modal-title">Crop and upload</h4>
					</div>
					<div class="modal-body">
						<div id="imagecropper" style="width: 500px; height: 500px; position: relative;">
						</div>
					</div>
				</div>
				<!-- /.modal-content -->
			</div>
			<!-- /.modal-dialog -->
		</div>
		<!-- /.modal -->

		<div class="content">
			<h2>Image Grid</h2>
			<p>
				This sample show how to upload part of a selected image file.
			</p>
			<p style="color: red">
				Click the thumbnails to edit the image.
			</p>


			<div id="grid">
			</div>

			<div id="insertbtn"></div>

			<CuteWebUI:UploadAttachments runat="server" DropZoneID="form1" ManualStartUpload="true" ID="Uploader1" ShowQueueTable="false"
				InsertButtonID="insertbtn" OnFileUploaded="Uploader_FileUploaded">
				<ValidateOption MaxSizeKB="10240" />
			</CuteWebUI:UploadAttachments>

			<p>
				<asp:Button CssClass="btn btn-default" runat="server" ID="SubmitButton" Text="Upload Files Now" OnClick="SubmitButton_Click" Font-Size="18px" />
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
			item.inner.appendChild(item.info);
			item.cell.appendChild(item.image);
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

				$('#myModal').modal({})

				item.container.ondblclick = function () {
					$('#myModal').modal("hide")
				}

				var imagecropper = document.getElementById("imagecropper");
				imagecropper.innerHTML = "";
				imagecropper.appendChild(item.container);

				var s = item.container.style;
				s.position = "absolute";
				s.display = "block";
				s.width = s.height = "500px";
				s.backgroundColor = "white";
				s.left = "0px";
				s.top = "0px";

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
					if (item.notimage)
						item.div.className = "itemdiv itemdivqueue itemnotimage";
					else
						item.div.className = "itemdiv itemdivqueue";
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
			var item = {};
			CreateItemUI(item);
			item.div.className = "itemdiv itemdivaddbtn";
			item.info.appendChild(document.getElementById("insertbtn"));
		}

		InitPage();

	</script>


</body>
</html>
