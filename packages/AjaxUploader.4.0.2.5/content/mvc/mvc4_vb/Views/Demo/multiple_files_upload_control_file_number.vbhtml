@Code
	ViewBag.Title = "Uploading multiple files"
End Code
<script type="text/javascript">
	var handlerurl = '@Url.Action("FileUploadAjaxWithoutSave")'

	function CreateAjaxRequest() {
		var xh;
		if (window.XMLHttpRequest)
			xh = new window.XMLHttpRequest();
		else
			xh = new ActiveXObject("Microsoft.XMLHTTP");

		xh.open("POST", handlerurl, false, null, null);
		xh.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8");
		return xh;
	}
</script>
<script type="text/javascript">
	var fileArray = [];

	function ShowAttachmentsTable() {
		var table = document.getElementById("filelist");
		while (table.firstChild) table.removeChild(table.firstChild);

		AppendToFileList(fileArray);
	}
	function AppendToFileList(list) {
		var table = document.getElementById("filelist");

		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			var row = table.insertRow(-1);
			row.setAttribute("fileguid", item.FileID);
			row.setAttribute("filename", item.FileName);
			var td1 = row.insertCell(-1);
			td1.innerHTML = "<img src='/Content/circle.png' border='0'/>";
			var td2 = row.insertCell(-1);
			td2.innerHTML = item.FileName;
			var td4 = row.insertCell(-1);
			td4.innerHTML = "[<a href='javascript:void(0)' onclick='Attachment_Remove(this)'>remove</a>]";
		}
	}

	function Attachment_FindRow(element) {
		while (true) {
			if (element.nodeName == "TR")
				return element;
			element = element.parentNode;
		}
	}

	function Attachment_Remove(link) {
		var row = Attachment_FindRow(link);
		if (!confirm("Are you sure you want to delete '" + row.getAttribute("filename") + "'?"))
			return;

		var guid = row.getAttribute("fileguid");

		var table = document.getElementById("filelist");
		table.deleteRow(row.rowIndex);

		for (var i = 0; i < fileArray.length; i++) {
			if (fileArray[i].FileID == guid) {
				fileArray.splice(i, 1);
				break;
			}
		}
		CheckFileCount();
	}

	function CuteWebUI_AjaxUploader_OnPostback() {
		var uploader = document.getElementById("myuploader");
		var guidlist = uploader.value;

		var xh = CreateAjaxRequest();
		xh.send("guidlist=" + guidlist + "&limitcount=3&hascount=" + fileArray.length);

		//call uploader to clear the client state
		uploader.reset();

		if (xh.status != 200) {
			alert("http error " + xh.status);
			setTimeout(function () { document.write(xh.responseText); }, 10);
			return;
		}

		var list = eval(xh.responseText); //get JSON objects

		fileArray = fileArray.concat(list);
		CheckFileCount();
		AppendToFileList(list);
	}

	function CheckFileCount() {
		var uploadbutton = document.getElementById("uploadbutton");
		if (fileArray.length >= 3) {
			uploadbutton.disabled = true;
		}
		else
			uploadbutton.disabled = false;
		ShowFiles();
	}

	function ShowFiles() {
		var msgs = [];
		for (var i = 0; i < fileArray.length; i++) {
			msgs.push(fileArray[i].FileName + ", " + fileArray[i].FileSize + "Kb");
		}
		document.getElementById("text_info").value = msgs.join("\r\n");
	}	
</script>
<h2>
    Uploading multiple files (Limit the maximum allowed number of files to be uploaded)</h2>
<p>
    This example shows you how to limit the maximum allowed number of files to be uploaded.
    In the following example, you can only upload 3 files.</p>
<br />
<fieldset style="height: 130px">
    <legend>
		<button id="uploadbutton">Upload Multiple files Now</button>
    </legend>
    <div>                    
        @Html.Raw(ViewBag.uploaderhtml)
		<table id="filelist" style='border-collapse: collapse' class='Grid' border='0' cellspacing='0' cellpadding='2'>
		</table>
    </div>
</fieldset>
<br />
<div>
    Server Trace:
    <br />
    <textarea id="text_info" style="height:200px; width:400px;"></textarea>
</div>