@Code
	ViewBag.Title = "Selecting multiple files for uploading"
End Code
<script type="text/javascript">
	function CuteWebUI_AjaxUploader_OnPostback() {
		//submit the form after the file have been uploaded:
		document.forms[0].submit();
	}
</script>
<h2>
	Selecting multiple files for uploading</h2>
<p>
	Select multiple files in the file browser dialog then upload them at once.</p>
@Code Html.BeginForm() End Code
<button id="uploadbutton" onclick="return false;">
	Select multiple files to upload</button>
	@Html.Raw(ViewBag.uploaderhtml)  
@Code Html.EndForm() End Code
<p>
	Server Trace:
	<br />
	@If Not ViewBag.UploadedMessage Is Nothing Then
		@ViewBag.UploadedMessage
	End If
</p>
