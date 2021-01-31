@Code
	ViewBag.Title = "Large File Upload"
End Code
<script type="text/javascript">
	function CuteWebUI_AjaxUploader_OnPostback() {
		//submit the form after the file have been uploaded:
		document.forms[0].submit();
	}
</script>
<h2>
    Large File Upload in ASP.NET</h2>
<p>
    Ajax Uploader allows you to upload large files to a server with the low server memory
    consumption.</p>
<p>
    Click the following button to upload (No size/type restrictions).
</p>
@Code Html.BeginForm() End Code
	@Html.Raw(ViewBag.uploaderhtml)
@Code Html.EndForm() End Code
<br />
<br />
<div>
    Server Trace:
    <br />
	@If Not ViewBag.UploadedMessage Is Nothing Then
		@ViewBag.UploadedMessage  
	End If
</div>