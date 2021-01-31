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
    Simple Upload with Progress (Custom Validation)
</h2>
<p>
    A sample demonstrating how to create user-defined validation functions for an upload
    control. In this example, we defined two validation rules:</p>
<ul>
    <li>Maximum file size: 100K</li>
    <li>Allowed file types: jpeg, jpg, gif,png </li>
</ul>
<p>
    Click the following button to upload.
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