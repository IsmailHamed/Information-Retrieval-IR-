@Code
	ViewBag.Title = "Simple Upload (Customizing the UI)"
End Code
<h2>
    Simple Upload (Customizing the UI)
</h2>
<p>
    A sample demonstrating how to customize the look and feel of file upload controls.
    (Maximum file size: 10M).
</p>
@Code Html.BeginForm() End Code
<img id="Uploader1Insert" alt="Upload File" src="http://ajaxuploader.com/sampleimages/upload.png" />
<div id="Uploader1Progress" style="padding:4px; border:2px dashed Orange;">
    <span id="Uploader1ProgressText" style="color:Firebrick;"></span>
</div>
<img id="Uploader1Cancel" alt="Cancel" src="http://ajaxuploader.com/sampleimages/cancel_button.gif" />          
	@Html.Raw(ViewBag.uploaderhtml)
@Code Html.EndForm() End Code
<p>
    Server Trace:
    <br/>
    <br/>
    @If Not ViewBag.UploadedMessage Is Nothing Then
		@ViewBag.UploadedMessage	  
	End If
</p>
