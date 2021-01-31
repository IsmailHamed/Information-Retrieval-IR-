<%@ Page Language="C#" %>

<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<script runat="server">

	//if you don't plan to postback this page , you could save the file in this event , it will be fired on each file be uploaded
	protected void Uploader1_FileValidating(object sender, UploaderEventArgs args)
	{
		string virpath = "/uploadfiles/"
			+ "/" + args.FileGuid + System.IO.Path.GetExtension(args.FileName);
		string savepath = Server.MapPath(virpath);

		//TEXT: never override existing file unless it's uploaded by same people.
		if (System.IO.File.Exists(savepath))
			return;

		string folder = System.IO.Path.GetDirectoryName(savepath);
		if (!System.IO.Directory.Exists(folder)) System.IO.Directory.CreateDirectory(folder);

		//now copy the file instead of 
		args.CopyTo(savepath);

		//send server information to client side.
		Uploader1.SetValidationServerData(virpath);

	}
</script>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Bootstrap jQuery Upload 01</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="js/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="js/bootstrap.min.js"></script>

</head>
<body>
	<form runat="server">
		<h1>Bootstrap jQuery Upload 01</h1>

		<p>
			This is a jQuery theme of uploader. You can make uploader look exactly how you want it to look and it's very easy to do so.
		</p>

		<div class="panel panel-info" style="margin: 18px; width: 640px;">
			<div class="panel-heading">Please drag and drop your image file here</div>
			<div id="panelbody1" class="panel-body" style="width: 640px; height: 320px;">
				Or just click here...
			</div>
			<div id="panelbody2" class="panel-body" style="width: 640px; height: 320px; display: none">
				<div id="imagecropper" style="width: 640px; height: 320px; position: relative;">
					Image Container
				</div>
			</div>
			<div id="panelbody3" class="panel-body" style="width: 640px; height: 110px; display: none; text-align: center;">
				<button class="btn btn-default" onclick="StartUpload();return false;" id="submitbutton">Upload</button>
				<button class="btn btn-default" onclick="ResetUpload();return false;">Cancel</button>

			</div>
		</div>


		<CuteWebUI:Uploader runat="server" ManualStartUpload="true" ID="Uploader1" ShowQueueTable="false"
			InsertButtonID="panelbody1" DropZoneID="panelbody1" OnFileValidating="Uploader1_FileValidating">
			<ValidateOption MaxSizeKB="10240" />
		</CuteWebUI:Uploader>

		<div id="uploadlinks" style="padding-left: 12px;"></div>

		<script>
			//prevent the default handling by cancelling the event
			document.ondragover = document.ondragenter = document.ondrop = function (e) {
				e.preventDefault();
				return false;
			}

			var uploader;
			function CuteWebUI_AjaxUploader_OnInitialize() {
				uploader = this;//get uploader object
				uploader.internalobject.SetDialogAccept("image/*");
			}

			var uploadlinks = document.getElementById("uploadlinks");

			//Fires after all uploads are complete and submit the form
			function CuteWebUI_AjaxUploader_OnPostback() {
				var files = uploader.getitems();
				for (var i = 0; i < files.length; i++) {
					var task = files[i];
					//Get the information from server
					var virpath = task.ServerData;
					var link = document.createElement("A");
					link.target = "_blank";
					link.href = virpath;
					link.innerHTML = "Open " + task.FileName + " at " + virpath;
					link.style.display = "block";
					uploadlinks.appendChild(link);
				}
				ResetUpload();

				//return false to cancel the default form submission
				return false;
			}

			function StartUpload() {
				uploader.startupload();//Start the upload of all queued files
				uploadlinks.innerHTML = "";
			}
			function ResetUpload() {
				//Clear file queue of uploader in the client side
				uploader.reset();
				$("#panelbody1").show();
				$("#panelbody2").hide();
				$("#panelbody3").hide();
			}

			//Fires when new information about the upload progress for a specific file is available.
			function CuteWebUI_AjaxUploader_OnProgress(isuploading, filename, startTime, sentLen, totalLen) {
				if (isuploading) {
					$("#submitbutton").html(Math.floor(sentLen * 100 / totalLen) + "%");
				}
				return false;//hide the default progress bar
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

				$("#panelbody1").hide();
				$("#panelbody2").show();
				$("#panelbody3").show();
				$("#submitbutton").html("Upload");

				var div = document.getElementById("imagecropper");
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


	</form>
</body>
</html>

