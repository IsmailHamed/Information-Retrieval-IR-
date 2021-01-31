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
	<title>Drag and Drop - Webcam Demo</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="js/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="js/bootstrap.min.js"></script>

</head>
<body>
	<form runat="server">
		<h1>Hello, world!</h1>

		<div class="panel panel-info" style="margin: 18px; width: 640px;">
			<div class="panel-heading">Please drag and drop your image file here</div>
			<div id="panelbody1" class="panel-body" style="width: 640px; height: 320px;">
				Or just click here...
			</div>
		</div>

		<button class="btn btn-info" onclick="ShowCamera();return false;" style="margin: 18px;">Test Camera</button>


		<div class="modal fade" id="myModal" tabindex="-1" role="dialog">
			<div class="modal-dialog" style="width: 670px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
						<h4 class="modal-title">Crop and upload</h4>
					</div>
					<div class="modal-body">
						<div id="imagecropper" style="width: 640px; height: 480px; position: relative;">
						</div>
					</div>
					<div class="modal-footer">

						<button class="btn btn-primary" onclick="StartUpload();return false;" id="submitbutton">Upload</button>
						<button class="btn btn-default" onclick="ResetUpload();return false;" data-dismiss="modal">Cancel</button>

					</div>
				</div>
				<!-- /.modal-content -->
			</div>
			<!-- /.modal-dialog -->
		</div>
		<!-- /.modal -->


		<div class="modal fade" id="cameraDialog" tabindex="-1" role="dialog">
			<div class="modal-dialog" style="width: 670px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
						<h4 class="modal-title">Use Camera</h4>
					</div>
					<div class="modal-body">
						<video id="cameravideo" width="640" height="480" autoplay style="margin: 5px;"></video>
						<div id="cameracropper" style="width: 650px; height: 490px; position: relative;">
						</div>

					</div>
					<div class="modal-footer">

						<button class="btn btn-primary" onclick="setTimeout(CameraCapture,1);return false;" id="btnCameraCapture">Capture</button>
						<button class="btn btn-default" onclick="setTimeout(CameraCancel,1);return false;" id="btnCameraCancel">Cancel</button>

						<button class="btn btn-success" onclick="setTimeout(CameraCommit,1);return false;" id="btnCameraCommit">Upload</button>
						<button class="btn btn-default" onclick="setTimeout(CameraReset,1);return false;" id="btnCameraReset">Reset</button>

					</div>
				</div>
				<!-- /.modal-content -->
			</div>
			<!-- /.modal-dialog -->
		</div>
		<!-- /.modal -->

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
			}
			function ResetUpload() {
				//Clear file queue of uploader in the client side
				uploader.reset();
				$("#panelbody1").show();
				$('#myModal').modal("hide")
				$('#cameraDialog').modal("hide")
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

				var div;

				if (srcfile.cameraDialog) {
					div = document.getElementById("cameracropper");
				}
				else {
					$('#myModal').modal({})
					$("#submitbutton").html("Upload");
					div = document.getElementById("imagecropper");
				}

				div.innerHTML = "";
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

			function SwitchDialogControls(mode) {
				//Switch the UI
				var list1 = ["cameravideo", "btnCameraCapture", "btnCameraCancel"];
				var list2 = ["cameracropper", "btnCameraCommit", "btnCameraReset"];

				if (mode != "video") {
					var t = list1;
					list1 = list2;
					list2 = t;
				}
				for (var i = 0; i < list1.length; i++)
					$("#" + list1[i]).show();
				for (var i = 0; i < list2.length; i++)
					$("#" + list2[i]).hide();
			}

			var camerainit = false;

			function ShowCamera() {

				SwitchDialogControls("video");

				$('#cameraDialog').modal({});

				if (camerainit)
					return;

				var video = document.getElementById("cameravideo");

				function startVideo(url) {
					video.src = url;
					video.play();
				}

				function onerror(error) {
					alert("Camera Error : " + error);//Make sure the camera is not used by another application.
					$('#cameraDialog').modal("hide");
				};

				//access a specific camera device using HTML5

				if (navigator.getUserMedia) { // Standard
					navigator.getUserMedia({ video: true }, function (streamurl) {
						startVideo(streamurl)
					}, onerror);
				} else if (navigator.webkitGetUserMedia) { // WebKit-prefixed
					navigator.webkitGetUserMedia({ video: true }, function (stream) {
						startVideo(window.URL.createObjectURL(stream))
					}, onerror);
				} else if (navigator.mozGetUserMedia) {
					navigator.mozGetUserMedia({ video: true }, function (stream) {
						startVideo(window.URL.createObjectURL(stream))
					}, onerror);
				}
				else {
					alert("Not Support Camera " + navigator.mozGetUserMedia);
					$('#cameraDialog').modal("hide");
				}

				camerainit = true;

			}

			function CameraCapture() {
				var video = document.getElementById("cameravideo");
				var canvas = document.createElement("canvas");
				canvas.width = 640;
				canvas.height = 480;
				canvas.getContext("2d").drawImage(video, 0, 0, 640, 480);
				SwitchDialogControls("cropper");

				var div = document.getElementById("cameracropper");
				div.innerHTML = "";

				//create an HTML5 canvas file object
				var dataurl = canvas.toDataURL("image/png");
				var bs = atob(dataurl.split(',')[1]);
				var ab = new ArrayBuffer(bs.length);
				var ia = new Uint8Array(ab);
				for (i = 0; i < bs.length; i += 1) {
					ia[i] = bs.charCodeAt(i);
				}
				var file = new Blob([ab], { type: "image/png" });
				file.name = "camera.png";

				//set a flag to let the previous function to detect the file is from camera or not
				file.cameraDialog = true;

				//use AddHtml5Files to add file object into uploader queue
				uploader.internalobject.AddHtml5Files([file]);

			}
			function CameraCancel() {
				$('#cameraDialog').modal("hide");
			}
			function CameraCommit() {
				uploader.startupload();//Start the upload of all queued files
			}
			function CameraReset() {
				SwitchDialogControls("video");
			}


		</script>


	</form>
</body>
</html>

