<%@ Page Language="vb" %>
<%@ Register Namespace="CuteWebUI" Assembly="CuteWebUI.AjaxUploader" TagPrefix="CuteWebUI" %>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Customize Progress Bar</title>
    <link rel="stylesheet" href="demo.css" type="text/css" />

    <script runat="server">
        Private Sub InsertMsg(ByVal msg As String)
            ListBoxEvents.Items.Insert(0, msg)
            ListBoxEvents.SelectedIndex = 0
        End Sub
   
        Private Sub ButtonPostBack_Click(ByVal sender As Object, ByVal e As EventArgs)
            InsertMsg("You clicked a PostBack Button.")
        End Sub

        Private Sub Uploader_FileUploaded(ByVal sender As Object, ByVal args As UploaderEventArgs)
            InsertMsg("File uploaded! " & args.FileName & ", " & args.FileSize & " bytes.")
            'Copies the uploaded file to a new location.
            'args.CopyTo("c:\\temp\\"& args.FileName)
            'You can also open the uploaded file's data stream.
            'System.IO.Stream data = args.OpenStream()
        End Sub
    </script>

     <script type="text/javascript">
        function CuteWebUI_AjaxUploader_OnProgress(enable, filename, begintime, uploadedsize, totalsize) {
            var hidden = this;
            if (enable) {
                if (totalsize) {

                    var total = Math.floor(100 * uploadedsize / totalsize);

                    for (var i = 1; i <= 12; i++)
                        document.getElementById("custom_progress_" + i).style.display = '';

                    document.getElementById("custom_progress_bar_1_text").style.color = "#333333";
                    document.getElementById("custom_progress_bar_1_text").innerHTML = total + "%";
                    document.getElementById("custom_progress_bar_1_filename").innerHTML = filename;
                    if (total >= 50)
                        document.getElementById("custom_progress_bar_1_text").style.color = "#ffffff";
                    //document.title = filename + " - " + Math.floor(100 * uploadedsize / totalsize) + '%';
                    for (var i = 1; i <= 12; i++) {
                        document.getElementById("custom_progress_bar_" + i).style.width = total + '%';
                    }

                    document.getElementById("custom_progress_91").style.display = '';
                    document.getElementById("custom_progress_92").style.display = '';
                    document.getElementById("custom_progress_bar_92").value = total;

                    var stacked_1 = 0, stacked_2 = 0, stacked_3 = 0;
                    if (total > 33) {
                        stacked_1 = 33;
                        total -= 33;
                    }
                    else {
                        stacked_1 = total;
                        total = 0;
                    }
                    if (total > 34) {
                        stacked_2 = 34;
                        total -= 34;
                    }
                    else {
                        stacked_2 = total;
                        total = 0;
                    }
                    stacked_3 = total;

                    document.getElementById("custom_progress_bar_91_1").style.width = stacked_1 + '%';
                    document.getElementById("custom_progress_bar_91_2").style.width = stacked_2 + '%';
                    document.getElementById("custom_progress_bar_91_3").style.width = stacked_3 + '%';
                }
                else {
                    for (var i = 1; i <= 12; i++)
                        document.getElementById("custom_progress_" + i).style.display = 'none';
                    for (var i = 1; i <= 12; i++)
                        document.getElementById("custom_progress_bar_" + i).style.width = '0%';

                    document.getElementById("custom_progress_91").style.display = 'none';
                    document.getElementById("custom_progress_bar_91_1").style.width = '0%';
                    document.getElementById("custom_progress_bar_91_2").style.width = '0%';
                    document.getElementById("custom_progress_bar_91_3").style.width = '0%';

                    document.getElementById("custom_progress_92").style.display = 'none';
                    document.getElementById("custom_progress_bar_92").value = 0;
                }
            }
            else {
                for (var i = 1; i <= 12; i++)
                    document.getElementById("custom_progress_" + i).style.display = 'none';
                for (var i = 1; i <= 12; i++)
                    document.getElementById("custom_progress_bar_" + i).style.width = '0%';

                document.getElementById("custom_progress_91").style.display = 'none';
                document.getElementById("custom_progress_bar_91_1").style.width = '0%';
                document.getElementById("custom_progress_bar_91_2").style.width = '0%';
                document.getElementById("custom_progress_bar_91_3").style.width = '0%';

                document.getElementById("custom_progress_92").style.display = 'none';
                document.getElementById("custom_progress_bar_92").value = 0;
            }
            return false; //hide the default UI.
        }
    </script>
    <link  href="../uploadertheme.css" rel="stylesheet"/>
    <style>
        h3 {
            margin-bottom:5px;
            font-size:14px;
        }
    </style>
</head>
<body>
    <form id="Form1" method="post" runat="server">
        <div class="content">
            <h2>
                Customize Progress Bar</h2>
            <p>A sample demonstrates how to customize default progress bar to fully suit your needs.</p>
            <CuteWebUI:Uploader runat="server" ID="Uploader1" InsertText="Upload File (Max 10M)"
                OnFileUploaded="Uploader_FileUploaded">
                <ValidateOption MaxSizeKB="10240" />
            </CuteWebUI:Uploader>
            <br />
             <div id="custom_progress_1" class="basic-purple" style="display:none;">
                <div><h3>Basic 1 <span style="font-weight:normal;">(with file name and text)</span></h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_1" style="width: 0%;" class="progress-bar"></div>
                    <div id="custom_progress_bar_1_text" style="width:100%; position:absolute; top:0px; left:0px; height:20px; line-height:20px; text-align:center;"></div>
                </div>
                <div id="custom_progress_bar_1_filename">

                </div>
            </div>
            <div id="custom_progress_2" class="basic-pinkblue" style="display:none;">
                <div><h3>Basic 2</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_2" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_3" class="basic-green" style="display:none;">
                <div><h3>Basic 3</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_3" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_4" class="basic-orange" style="display:none;">
                <div><h3>Basic 4</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_4" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_5" class="basic-red" style="display:none;">
                <div><h3>Basic 5</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_5" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_6" class="striped-pinkblue" style="display:none;">
                <div><h3>Striped 1</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_6" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_7" class="striped-green" style="display:none;">
                <div><h3>Striped 2</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_7" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_8" class="striped-orange" style="display:none;">
                <div><h3>Striped 3</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_8" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_9" class="striped-red" style="display:none;">
                <div><h3>Striped 4</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_9" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_10" class="animated-purple" style="display:none;">
                <div><h3>Animated 1</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_10" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            
            <div id="custom_progress_91" class="stacked" style="display:none;">
                <div><h3>Stacked</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_91_1" style="width: 0%;" class="progress-bar-1"></div>
                    <div id="custom_progress_bar_91_2" style="width: 0%;" class="progress-bar-2"></div>
                    <div id="custom_progress_bar_91_3" style="width: 0%;" class="progress-bar-3"></div>
                </div>
            </div>

            
            <div id="custom_progress_11" class="windows7" style="display:none;">
                <div><h3>Like Windows 7</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_11" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            
            <div id="custom_progress_12" class="macos" style="display:none;">
                <div><h3>Like Mac OS X</h3></div>
                <div class="progress">
                    <div id="custom_progress_bar_12" style="width: 0%;" class="progress-bar"></div>
                </div>
            </div>
            <div id="custom_progress_92" class="html5" style="display:none;">
                <div><h3>Native Html5 Porgress Tag</h3></div>
                <div class="progress">
                    <progress id="custom_progress_bar_92" max="100" value="0" class="progress-bar"></progress>
                </div>
            </div>
            <br />
            <div>
                Server Trace:
                <br />
                <asp:ListBox runat="server" ID="ListBoxEvents" />
            </div>
            <br />
            <br />
            <asp:Button ID="ButtonPostBack" Text="This is a PostBack button" runat="server" OnClick="ButtonPostBack_Click" />
        </div>
    </form>
</body>
</html>
