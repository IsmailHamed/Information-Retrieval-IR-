@Code
	ViewBag.Title = "Drag Drop File"
End Code
<h2>Drag Drop File</h2>
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

@Code Html.BeginForm() End Code
	@Html.Raw(ViewBag.uploaderhtml)
<p id="QueuePanel">
</p>
<br />
<br />
<button id="SubmitButton" onclick="return submitbutton_click()">Submit</button>
@Code Html.EndForm() End Code
<br />
<br />
<div>
	<textarea id="text_info" style="height: 200px; width: 400px;"></textarea>
</div>

<script type="text/javascript">
	function submitbutton_click() {
		var submitbutton = document.getElementById('SubmitButton');
		var uploadobj = document.getElementById('myuploader');
		if (!window.filesuploaded) {
			if (uploadobj.getqueuecount() > 0) {
				uploadobj.startupload();
			}
			else {
				var uploadedcount = parseInt(submitbutton.getAttribute("itemcount")) || 0;
				if (uploadedcount > 0) {
					return true;
				}
				alert("Please browse files for upload");
			}
			return false;
		}
		window.filesuploaded = false;
		return true;
	}
	function CuteWebUI_AjaxUploader_OnPostback() {
		window.filesuploaded = true;
		var submitbutton = document.getElementById('SubmitButton');
		submitbutton.click();
		return false;
	}
	function GetTrace() {
		var html = @Html.Raw(Json.Encode(ViewBag.UploadedMessage)) || '';
		if (html) {
			document.getElementById("text_info").value = html;
		}
	}
	GetTrace();
</script>
