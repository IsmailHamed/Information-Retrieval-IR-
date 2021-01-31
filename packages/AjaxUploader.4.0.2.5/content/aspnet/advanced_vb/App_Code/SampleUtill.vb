Imports System
Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports System.Data.SqlClient
Imports System.IO

Partial Public Class SampleUtil
    Public Shared ReadOnly Property Context() As HttpContext
        Get
            Return HttpContext.Current
        End Get
    End Property

    Public Shared Function GetFileDirectory() As String
        Dim dir As String = Context.Server.MapPath("~/Files/")
        If Not System.IO.Directory.Exists(dir) Then
            System.IO.Directory.CreateDirectory(dir)
        End If
        Return dir
    End Function

    Public Shared Function ToUserLocalTime(ByVal time As DateTime) As DateTime
        Dim cookie As HttpCookie = Context.Request.Cookies("TimeZone")
        If cookie Is Nothing Then
            Return time
        End If
        Dim tzo As Integer = Integer.Parse(cookie.Value)
        Return time.ToUniversalTime().AddHours(tzo)
    End Function

    Public Shared Function GetAjaxMode() As String
        Dim cookie As HttpCookie = Nothing
        Return GetAjaxMode(cookie)
    End Function
    Public Shared Function GetAjaxMode(ByRef cookie As HttpCookie) As String
        cookie = Context.Request.Cookies("AjaxMode")
        If cookie IsNot Nothing Then
            Select Case cookie.Value
                Case "Atlas"
                    Return "Atlas"
                Case "None"
                    Return "None"
                Case Else
                    Exit Select
            End Select
        End If
        Return "None"
    End Function

    Public Shared Sub SetAjaxMode(ByVal mode As String)
        Dim cookie As New HttpCookie("AjaxMode")
        cookie.Path = "/"
        cookie.Expires = DateTime.Now.AddYears(1)
        cookie.Value = mode
        Context.Response.Cookies.Add(cookie)
    End Sub

    Public Shared Sub SetPageCache()
        If Context.Request.Browser.Browser = "Opera" Then
            Context.Response.Cache.SetCacheability(HttpCacheability.NoCache)
        End If
    End Sub

    Public Shared ReadOnly Property IsAdministratorIP() As Boolean
        Get
            Dim ip As String = Context.Request.UserHostAddress
            If ip = "127.0.0.1" Then
                Return True
            End If
            If ip.StartsWith("192.168.") Then
                Return True
            End If
            Return False
        End Get
    End Property
    Public Shared Sub DemandAdministratorPermission()
        If Not IsAdministratorIP Then
            Throw (New Exception("No permission"))
        End If
    End Sub

    Public Shared Function GetMimeType(ByVal filename As String) As String
        Dim ext As String = System.IO.Path.GetExtension(filename)
        If Not String.IsNullOrEmpty(ext) Then
            ext = ext.ToLower()

            InitMimeMap()
            Dim mime As String = Nothing
            If mimemap.TryGetValue(ext, mime) Then
                Return mime
            End If
        End If
        Return "application/unknown"
    End Function
    Shared mimemap As System.Collections.Generic.Dictionary(Of String, String)


#Region "copy from registry of my pc"
    Private Shared Sub InitMimeMap()
        If mimemap IsNot Nothing Then
            Return
        End If
        SyncLock GetType(SampleUtil)
            If mimemap IsNot Nothing Then
                Return
            End If

            Dim map As New System.Collections.Generic.Dictionary(Of String, String)()

            map.Add(".323", "text/h323")
            map.Add(".act", "text/xml")
            map.Add(".actproj", "text/plain")
            map.Add(".addin", "text/xml")
            map.Add(".ai", "application/postscript")
            map.Add(".aif", "audio/aiff")
            map.Add(".aifc", "audio/aiff")
            map.Add(".aiff", "audio/aiff")
            map.Add(".application", "application/x-ms-application")
            map.Add(".asax", "application/xml")
            map.Add(".ascx", "application/xml")
            map.Add(".asf", "video/x-ms-asf")
            map.Add(".ashx", "application/xml")
            map.Add(".asmx", "application/xml")
            map.Add(".aspx", "application/xml")
            map.Add(".asx", "video/x-ms-asf")
            map.Add(".au", "audio/basic")
            map.Add(".avi", "video/avi")
            map.Add(".bmp", "image/bmp")
            map.Add(".cat", "application/vnd.ms-pki.seccat")
            map.Add(".cd", "text/plain")
            map.Add(".cer", "application/x-x509-ca-cert")
            map.Add(".config", "application/xml")
            map.Add(".crl", "application/pkix-crl")
            map.Add(".crt", "application/x-x509-ca-cert")
            map.Add(".cs", "text/plain")
            map.Add(".csdproj", "text/plain")
            map.Add(".csproj", "text/plain")
            map.Add(".css", "text/css")
            map.Add(".datasource", "application/xml")
            map.Add(".dbs", "text/plain")
            map.Add(".der", "application/x-x509-ca-cert")
            map.Add(".dib", "image/bmp")
            map.Add(".dll", "application/x-msdownload")
            map.Add(".dtd", "application/xml-dtd")
            map.Add(".eml", "message/rfc822")
            map.Add(".eps", "application/postscript")
            map.Add(".eta", "application/earthviewer")
            map.Add(".etp", "text/plain")
            map.Add(".exe", "application/x-msdownload")
            map.Add(".ext", "text/plain")
            map.Add(".fif", "application/fractals")
            map.Add(".fky", "text/plain")
            map.Add(".gif", "image/gif")
            map.Add(".gz", "application/x-gzip")
            map.Add(".hqx", "application/mac-binhex40")
            map.Add(".hta", "application/hta")
            map.Add(".htc", "text/x-component")
            map.Add(".htm", "text/html")
            map.Add(".html", "text/html")
            map.Add(".htt", "text/webviewhtml")
            map.Add(".hxa", "application/xml")
            map.Add(".hxc", "application/xml")
            map.Add(".hxd", "application/octet-stream")
            map.Add(".hxe", "application/xml")
            map.Add(".hxf", "application/xml")
            map.Add(".hxh", "application/octet-stream")
            map.Add(".hxi", "application/octet-stream")
            map.Add(".hxk", "application/xml")
            map.Add(".hxq", "application/octet-stream")
            map.Add(".hxr", "application/octet-stream")
            map.Add(".hxs", "application/octet-stream")
            map.Add(".hxt", "application/xml")
            map.Add(".hxv", "application/xml")
            map.Add(".hxw", "application/octet-stream")
            map.Add(".ico", "image/x-icon")
            map.Add(".iii", "application/x-iphone")
            map.Add(".ins", "application/x-internet-signup")
            map.Add(".isp", "application/x-internet-signup")
            map.Add(".jfif", "image/jpeg")
            map.Add(".jpe", "image/jpeg")
            map.Add(".jpeg", "image/jpeg")
            map.Add(".jpg", "image/jpeg")
            map.Add(".kci", "text/plain")
            map.Add(".kml", "application/vnd.google-earth.kml+xml")
            map.Add(".kmz", "application/vnd.google-earth.kmz")
            map.Add(".latex", "application/x-latex")
            map.Add(".lgn", "text/plain")
            map.Add(".m1v", "video/mpeg")
            map.Add(".m3u", "audio/x-mpegurl")
            map.Add(".man", "application/x-troff-man")
            map.Add(".master", "application/xml")
            map.Add(".mfp", "application/x-shockwave-flash")
            map.Add(".mht", "message/rfc822")
            map.Add(".mhtml", "message/rfc822")
            map.Add(".mid", "audio/mid")
            map.Add(".midi", "audio/mid")
            map.Add(".mp2", "video/mpeg")
            map.Add(".mp2v", "video/mpeg")
            map.Add(".mp3", "audio/mpeg")
            map.Add(".mpa", "video/mpeg")
            map.Add(".mpe", "video/mpeg")
            map.Add(".mpeg", "video/mpeg")
            map.Add(".mpg", "video/mpeg")
            map.Add(".mpv2", "video/mpeg")
            map.Add(".nmw", "application/nmwb")
            map.Add(".nws", "message/rfc822")
            map.Add(".p10", "application/pkcs10")
            map.Add(".p12", "application/x-pkcs12")
            map.Add(".p7b", "application/x-pkcs7-certificates")
            map.Add(".p7c", "application/pkcs7-mime")
            map.Add(".p7m", "application/pkcs7-mime")
            map.Add(".p7r", "application/x-pkcs7-certreqresp")
            map.Add(".p7s", "application/pkcs7-signature")
            map.Add(".pfx", "application/x-pkcs12")
            map.Add(".pko", "application/vnd.ms-pki.pko")
            map.Add(".png", "image/png")
            map.Add(".prc", "text/plain")
            map.Add(".prf", "application/pics-rules")
            map.Add(".ps", "application/postscript")
            map.Add(".ra", "audio/vnd.rn-realaudio")
            map.Add(".ram", "audio/x-pn-realaudio")
            map.Add(".rat", "application/rat-file")
            map.Add(".rc", "text/plain")
            map.Add(".rc2", "text/plain")
            map.Add(".rct", "text/plain")
            map.Add(".rdlc", "application/xml")
            map.Add(".resx", "application/xml")
            map.Add(".rm", "application/vnd.rn-realmedia")
            map.Add(".rmi", "audio/mid")
            map.Add(".rms", "application/vnd.rn-realmedia-secure")
            map.Add(".rmvb", "application/vnd.rn-realmedia-vbr")
            map.Add(".rp", "image/vnd.rn-realpix")
            map.Add(".rpm", "audio/x-pn-realaudio-plugin")
            map.Add(".rt", "text/vnd.rn-realtext")
            map.Add(".rul", "text/plain")
            map.Add(".rv", "video/vnd.rn-realvideo")
            map.Add(".sct", "text/scriptlet")
            map.Add(".settings", "application/xml")
            map.Add(".sit", "application/x-stuffit")
            map.Add(".sitemap", "application/xml")
            map.Add(".skin", "application/xml")
            map.Add(".sln", "text/plain")
            map.Add(".smi", "application/smil")
            map.Add(".smil", "application/smil")
            map.Add(".snd", "audio/basic")
            map.Add(".snippet", "application/xml")
            map.Add(".sol", "text/plain")
            map.Add(".sor", "text/plain")
            map.Add(".spc", "application/x-pkcs7-certificates")
            map.Add(".spl", "application/futuresplash")
            map.Add(".sql", "text/plain")
            map.Add(".sst", "application/vnd.ms-pki.certstore")
            map.Add(".stl", "application/vnd.ms-pki.stl")
            map.Add(".swf", "application/x-shockwave-flash")
            map.Add(".tab", "text/plain")
            map.Add(".tar", "application/x-tar")
            map.Add(".tdl", "text/xml")
            map.Add(".tgz", "application/x-compressed")
            map.Add(".tif", "image/tiff")
            map.Add(".tiff", "image/tiff")
            map.Add(".torrent", "application/x-bittorrent")
            map.Add(".trg", "text/plain")
            map.Add(".txt", "text/plain")
            map.Add(".udf", "text/plain")
            map.Add(".udt", "text/plain")
            map.Add(".uls", "text/iuls")
            map.Add(".user", "text/plain")
            map.Add(".usr", "text/plain")
            map.Add(".vb", "text/plain")
            map.Add(".vbdproj", "text/plain")
            map.Add(".vbproj", "text/plain")
            map.Add(".vcf", "text/x-vcard")
            map.Add(".vddproj", "text/plain")
            map.Add(".vdp", "text/plain")
            map.Add(".vdproj", "text/plain")
            map.Add(".viw", "text/plain")
            map.Add(".vscontent", "application/xml")
            map.Add(".vsi", "application/ms-vsi")
            map.Add(".vspolicy", "application/xml")
            map.Add(".vspolicydef", "application/xml")
            map.Add(".vspscc", "text/plain")
            map.Add(".vsscc", "text/plain")
            map.Add(".vssettings", "text/xml")
            map.Add(".vssscc", "text/plain")
            map.Add(".vstemplate", "text/xml")
            map.Add(".wav", "audio/wav")
            map.Add(".wax", "audio/x-ms-wax")
            map.Add(".wm", "video/x-ms-wm")
            map.Add(".wma", "audio/x-ms-wma")
            map.Add(".wmd", "application/x-ms-wmd")
            map.Add(".wmv", "video/x-ms-wmv")
            map.Add(".wmx", "video/x-ms-wmx")
            map.Add(".wmz", "application/x-ms-wmz")
            map.Add(".wpl", "application/vnd.ms-wpl")
            map.Add(".wsc", "text/scriptlet")
            map.Add(".wsdl", "application/xml")
            map.Add(".wvx", "video/x-ms-wvx")
            map.Add(".xdr", "application/xml")
            map.Add(".xhash", "application/x-BaiduHashFile")
            map.Add(".xml", "text/xml")
            map.Add(".xmta", "application/xml")
            map.Add(".xsc", "application/xml")
            map.Add(".xsd", "application/xml")
            map.Add(".xsl", "text/xml")
            map.Add(".xslt", "application/xml")
            map.Add(".xss", "application/xml")
            map.Add(".z", "application/x-compress")

            mimemap = map
        End SyncLock
    End Sub

#End Region


    Public Shared Sub DownloadFile(ByVal context As HttpContext, ByVal filepath As String, ByVal filename As String, ByVal isPublic As Boolean)
        If context Is Nothing Then
            Throw (New ArgumentNullException("context"))
        End If
        If filepath Is Nothing Then
            Throw (New ArgumentNullException("filepath"))
        End If
        If filename Is Nothing Then
            Throw (New ArgumentNullException("filename"))
        End If

        If Not File.Exists(filepath) Then
            Throw (New HttpException(404, filename & " not found!"))
        End If

        Dim fileinfo As New FileInfo(filepath)
        Dim filesize As Integer = CInt(fileinfo.Length)

        Dim start As Integer, length As Integer
        Dim hasRange As Boolean = GetRange(context, filesize, start, length)

        If Not hasRange Then
            Dim since As String = context.Request.Headers("If-Modified-Since")
            If Not String.IsNullOrEmpty(since) Then
                Dim sinceDate As DateTime = DateTime.Parse(since)
                Dim sinceSpan As TimeSpan = fileinfo.LastWriteTime - sinceDate

                If sinceSpan.TotalSeconds < 1 AndAlso sinceSpan.TotalSeconds > -1 Then
                    context.Response.Status = "304 (Not Modified)"
                    context.Response.[End]()
                    Return
                End If
            End If
        End If

        If isPublic Then
            context.Response.Cache.SetCacheability(HttpCacheability.[Private])
            context.Response.Cache.SetETag(CalcETag(fileinfo.FullName & ":" & fileinfo.LastWriteTime.Ticks.ToString()))
            context.Response.Cache.SetLastModified(fileinfo.LastWriteTime)
        Else
            'maybe the attachment is security file . do not cache it! 
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache)
        End If

        Dim attachemntame As String = filename

        Dim mime As String = SampleUtil.GetMimeType(filename)

        context.Response.ContentType = mime

        If mime.StartsWith("text/") Then
            'all text file can be html or script. 
            'it's dangerous that let the user open the html file on the browser directly. 
            'the html may contains javascript that can thieve the cookie of the user on your website. 

            'change the response and force the browser download the file. 
            context.Response.ContentType = "application/unknown"
            attachemntame = attachemntame & ".download"
        End If

        'attachemntame = context.Server.UrlEncode(attachemntame); 
        context.Response.AddHeader("Content-Disposition", "inline;filename=" & attachemntame)


        Dim buff As Byte() = New Byte(65535) {}
        Dim outp As Stream = context.Response.OutputStream
        Using fs As New FileStream(filepath, FileMode.Open, FileAccess.Read, FileShare.Read)
            If hasRange Then
                context.Response.StatusCode = 206
                context.Response.AddHeader("Content-Length", length.ToString())
                context.Response.AddHeader("Content-Range", "bytes " & start.ToString() & "-" & Convert.ToString(start + length - 1) & "/" & filesize.ToString())
            Else
                context.Response.AddHeader("Content-Length", filesize.ToString())
                start = 0
                length = filesize
            End If

            If start <> 0 Then
                fs.Seek(start, SeekOrigin.Begin)
            End If

            Dim readlen As Integer = 0

            While True
                Dim readnow As Integer = Math.Min(65536, length - readlen)
                If readnow <= 0 Then
                    Exit While
                End If

                Dim rc As Integer = fs.Read(buff, 0, readnow)
                If rc <= 0 Then
                    Exit While
                End If

                readlen += rc

                If CuteWebUI.UploadModule.LimitSpeedForTest Then
                    System.Threading.Thread.Sleep(100)
                End If

                outp.Write(buff, 0, rc)

                'if the client is disconnect , this method will throw an exception and stop sending file data 
                context.Response.Flush()
            End While
        End Using
    End Sub

    Private Shared Function GetRange(ByVal context As HttpContext, ByVal maxLen As Integer, ByRef start As Integer, ByRef len As Integer) As Boolean
        Dim range As String = context.Request.Headers("Range")

        start = 0
        len = maxLen

        If maxLen < 1 Then
            Return False
        End If

        If String.IsNullOrEmpty(range) Then
            Return False
        End If

        range = range.Trim()
        If Not range.StartsWith("bytes=") Then
            Return False
        End If

        range = range.Remove(0, 6).Trim()

        Dim parts As String() = range.Split("-"c)
        If parts.Length <> 2 Then
            Return False
        End If

        Dim p1 As Integer, p2 As Integer
        If Not Integer.TryParse(parts(0), p1) Then
            Return False
        End If

        If parts(1).Length = 0 Then
            p2 = maxLen
        Else
            If Not Integer.TryParse(parts(1), p2) Then
                Return False
            End If
        End If

        'imporssible ? the parts is splited by '-' 
        If p1 < 0 Then
            Return False
        End If

        If p1 > p2 Then
            Return False
        End If

        If p2 > maxLen Then
            Return False
        End If

        start = p1
        len = p2 - p1

        Return True
    End Function

    Public Shared Function CalcETag(ByVal str As String) As String
        Dim md5 As New System.Security.Cryptography.MD5CryptoServiceProvider()
        Dim hash As Byte() = md5.ComputeHash(System.Text.Encoding.Unicode.GetBytes(str))
        md5.Clear()
        Return Convert.ToBase64String(hash)
    End Function

End Class
