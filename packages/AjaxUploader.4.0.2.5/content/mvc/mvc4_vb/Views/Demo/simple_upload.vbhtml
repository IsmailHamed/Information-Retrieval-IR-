@Code
	ViewBag.Title = "Simple Upload with Progress"
End Code
<script type="text/javascript">
	function CuteWebUI_AjaxUploader_OnPostback() {
		//submit the form after the file have been uploaded:
		document.forms[0].submit();
	}
</script>
<h2>
	Simple Upload with Progress</h2>
<p>
	A basic sample demonstrating the use of the Upload control. You can use .CopyTo
	or .MoveTo method to copy the temporary file to a permanent location.</p>

@Code Html.BeginForm() End Code
	@Html.Raw(ViewBag.uploaderhtml)
@Code Html.EndForm() End Code
<p>
	Server Trace:
	<br />
@If Not ViewBag.UploadedMessage Is Nothing Then
	@ViewBag.UploadedMessage
End If
</p>