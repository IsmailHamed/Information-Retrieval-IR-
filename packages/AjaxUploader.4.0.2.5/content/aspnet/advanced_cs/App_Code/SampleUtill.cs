using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.IO;

public partial class SampleUtil
{
    static public HttpContext Context
    {
        get
        {
            return HttpContext.Current;
        }
    }

    static public string GetFileDirectory()
    {
        string dir = Context.Server.MapPath("~/Files/");
        if (!System.IO.Directory.Exists(dir))
            System.IO.Directory.CreateDirectory(dir);
        return dir;
    }

    static public DateTime ToUserLocalTime(DateTime time)
    {
        HttpCookie cookie = Context.Request.Cookies["TimeZone"];
        if (cookie == null)
            return time;
        int tzo = int.Parse(cookie.Value);
        return time.ToUniversalTime().AddHours(tzo);
    }

    static public string GetAjaxMode()
    {
        HttpCookie cookie;
        return GetAjaxMode(out cookie);
    }
    static public string GetAjaxMode(out HttpCookie cookie)
    {
        cookie = Context.Request.Cookies["AjaxMode"];
        if (cookie != null)
        {
            switch (cookie.Value)
            {
                case "Atlas":
                    return "Atlas";
                case "None":
                    return "None";
                default:
                    break;
            }
        }
        return "Atlas";
    }

    static public void SetAjaxMode(string mode)
    {
        HttpCookie cookie = new HttpCookie("AjaxMode");
        cookie.Path = "/";
        cookie.Expires = DateTime.Now.AddYears(1);
        cookie.Value = mode;
        Context.Response.Cookies.Add(cookie);
    }

    static public void SetPageCache()
    {
        if (Context.Request.Browser.Browser == "Opera")
        {
            Context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        }
    }

    static public bool IsAdministratorIP
    {
        get
        {
            //string ip = Context.Request.UserHostAddress;
            //if (ip == "127.0.0.1")
            //    return true;
            //if (ip.StartsWith("192.168."))
            //    return true;
            //return false;

            return true;
        }
    }
    static public void DemandAdministratorPermission()
    {
        if (!IsAdministratorIP)
        {
            throw (new Exception("No permission"));
        }
    }

    static public string GetMimeType(string filename)
    {
        string ext = System.IO.Path.GetExtension(filename);
        if (!string.IsNullOrEmpty(ext))
        {
            ext = ext.ToLower();

            InitMimeMap();
            string mime;
            if (mimemap.TryGetValue(ext, out mime))
            {
                return mime;
            }
        }
        return "application/unknown";
    }
    static System.Collections.Generic.Dictionary<string, string> mimemap;
    static void InitMimeMap()
    {
        if (mimemap != null) return;
        lock (typeof(SampleUtil))
        {
            if (mimemap != null) return;

            System.Collections.Generic.Dictionary<string, string> map = new System.Collections.Generic.Dictionary<string, string>();

            #region copy from registry of my pc
            map.Add(".323", "text/h323");
            map.Add(".act", "text/xml");
            map.Add(".actproj", "text/plain");
            map.Add(".addin", "text/xml");
            map.Add(".ai", "application/postscript");
            map.Add(".aif", "audio/aiff");
            map.Add(".aifc", "audio/aiff");
            map.Add(".aiff", "audio/aiff");
            map.Add(".application", "application/x-ms-application");
            map.Add(".asax", "application/xml");
            map.Add(".ascx", "application/xml");
            map.Add(".asf", "video/x-ms-asf");
            map.Add(".ashx", "application/xml");
            map.Add(".asmx", "application/xml");
            map.Add(".aspx", "application/xml");
            map.Add(".asx", "video/x-ms-asf");
            map.Add(".au", "audio/basic");
            map.Add(".avi", "video/avi");
            map.Add(".bmp", "image/bmp");
            map.Add(".cat", "application/vnd.ms-pki.seccat");
            map.Add(".cd", "text/plain");
            map.Add(".cer", "application/x-x509-ca-cert");
            map.Add(".config", "application/xml");
            map.Add(".crl", "application/pkix-crl");
            map.Add(".crt", "application/x-x509-ca-cert");
            map.Add(".cs", "text/plain");
            map.Add(".csdproj", "text/plain");
            map.Add(".csproj", "text/plain");
            map.Add(".css", "text/css");
            map.Add(".datasource", "application/xml");
            map.Add(".dbs", "text/plain");
            map.Add(".der", "application/x-x509-ca-cert");
            map.Add(".dib", "image/bmp");
            map.Add(".dll", "application/x-msdownload");
            map.Add(".dtd", "application/xml-dtd");
            map.Add(".eml", "message/rfc822");
            map.Add(".eps", "application/postscript");
            map.Add(".eta", "application/earthviewer");
            map.Add(".etp", "text/plain");
            map.Add(".exe", "application/x-msdownload");
            map.Add(".ext", "text/plain");
            map.Add(".fif", "application/fractals");
            map.Add(".fky", "text/plain");
            map.Add(".gif", "image/gif");
            map.Add(".gz", "application/x-gzip");
            map.Add(".hqx", "application/mac-binhex40");
            map.Add(".hta", "application/hta");
            map.Add(".htc", "text/x-component");
            map.Add(".htm", "text/html");
            map.Add(".html", "text/html");
            map.Add(".htt", "text/webviewhtml");
            map.Add(".hxa", "application/xml");
            map.Add(".hxc", "application/xml");
            map.Add(".hxd", "application/octet-stream");
            map.Add(".hxe", "application/xml");
            map.Add(".hxf", "application/xml");
            map.Add(".hxh", "application/octet-stream");
            map.Add(".hxi", "application/octet-stream");
            map.Add(".hxk", "application/xml");
            map.Add(".hxq", "application/octet-stream");
            map.Add(".hxr", "application/octet-stream");
            map.Add(".hxs", "application/octet-stream");
            map.Add(".hxt", "application/xml");
            map.Add(".hxv", "application/xml");
            map.Add(".hxw", "application/octet-stream");
            map.Add(".ico", "image/x-icon");
            map.Add(".iii", "application/x-iphone");
            map.Add(".ins", "application/x-internet-signup");
            map.Add(".isp", "application/x-internet-signup");
            map.Add(".jfif", "image/jpeg");
            map.Add(".jpe", "image/jpeg");
            map.Add(".jpeg", "image/jpeg");
            map.Add(".jpg", "image/jpeg");
            map.Add(".kci", "text/plain");
            map.Add(".kml", "application/vnd.google-earth.kml+xml");
            map.Add(".kmz", "application/vnd.google-earth.kmz");
            map.Add(".latex", "application/x-latex");
            map.Add(".lgn", "text/plain");
            map.Add(".m1v", "video/mpeg");
            map.Add(".m3u", "audio/x-mpegurl");
            map.Add(".man", "application/x-troff-man");
            map.Add(".master", "application/xml");
            map.Add(".mfp", "application/x-shockwave-flash");
            map.Add(".mht", "message/rfc822");
            map.Add(".mhtml", "message/rfc822");
            map.Add(".mid", "audio/mid");
            map.Add(".midi", "audio/mid");
            map.Add(".mp2", "video/mpeg");
            map.Add(".mp2v", "video/mpeg");
            map.Add(".mp3", "audio/mpeg");
            map.Add(".mpa", "video/mpeg");
            map.Add(".mpe", "video/mpeg");
            map.Add(".mpeg", "video/mpeg");
            map.Add(".mpg", "video/mpeg");
            map.Add(".mpv2", "video/mpeg");
            map.Add(".nmw", "application/nmwb");
            map.Add(".nws", "message/rfc822");
            map.Add(".p10", "application/pkcs10");
            map.Add(".p12", "application/x-pkcs12");
            map.Add(".p7b", "application/x-pkcs7-certificates");
            map.Add(".p7c", "application/pkcs7-mime");
            map.Add(".p7m", "application/pkcs7-mime");
            map.Add(".p7r", "application/x-pkcs7-certreqresp");
            map.Add(".p7s", "application/pkcs7-signature");
            map.Add(".pfx", "application/x-pkcs12");
            map.Add(".pko", "application/vnd.ms-pki.pko");
            map.Add(".png", "image/png");
            map.Add(".prc", "text/plain");
            map.Add(".prf", "application/pics-rules");
            map.Add(".ps", "application/postscript");
            map.Add(".ra", "audio/vnd.rn-realaudio");
            map.Add(".ram", "audio/x-pn-realaudio");
            map.Add(".rat", "application/rat-file");
            map.Add(".rc", "text/plain");
            map.Add(".rc2", "text/plain");
            map.Add(".rct", "text/plain");
            map.Add(".rdlc", "application/xml");
            map.Add(".resx", "application/xml");
            map.Add(".rm", "application/vnd.rn-realmedia");
            map.Add(".rmi", "audio/mid");
            map.Add(".rms", "application/vnd.rn-realmedia-secure");
            map.Add(".rmvb", "application/vnd.rn-realmedia-vbr");
            map.Add(".rp", "image/vnd.rn-realpix");
            map.Add(".rpm", "audio/x-pn-realaudio-plugin");
            map.Add(".rt", "text/vnd.rn-realtext");
            map.Add(".rul", "text/plain");
            map.Add(".rv", "video/vnd.rn-realvideo");
            map.Add(".sct", "text/scriptlet");
            map.Add(".settings", "application/xml");
            map.Add(".sit", "application/x-stuffit");
            map.Add(".sitemap", "application/xml");
            map.Add(".skin", "application/xml");
            map.Add(".sln", "text/plain");
            map.Add(".smi", "application/smil");
            map.Add(".smil", "application/smil");
            map.Add(".snd", "audio/basic");
            map.Add(".snippet", "application/xml");
            map.Add(".sol", "text/plain");
            map.Add(".sor", "text/plain");
            map.Add(".spc", "application/x-pkcs7-certificates");
            map.Add(".spl", "application/futuresplash");
            map.Add(".sql", "text/plain");
            map.Add(".sst", "application/vnd.ms-pki.certstore");
            map.Add(".stl", "application/vnd.ms-pki.stl");
            map.Add(".swf", "application/x-shockwave-flash");
            map.Add(".tab", "text/plain");
            map.Add(".tar", "application/x-tar");
            map.Add(".tdl", "text/xml");
            map.Add(".tgz", "application/x-compressed");
            map.Add(".tif", "image/tiff");
            map.Add(".tiff", "image/tiff");
            map.Add(".torrent", "application/x-bittorrent");
            map.Add(".trg", "text/plain");
            map.Add(".txt", "text/plain");
            map.Add(".udf", "text/plain");
            map.Add(".udt", "text/plain");
            map.Add(".uls", "text/iuls");
            map.Add(".user", "text/plain");
            map.Add(".usr", "text/plain");
            map.Add(".vb", "text/plain");
            map.Add(".vbdproj", "text/plain");
            map.Add(".vbproj", "text/plain");
            map.Add(".vcf", "text/x-vcard");
            map.Add(".vddproj", "text/plain");
            map.Add(".vdp", "text/plain");
            map.Add(".vdproj", "text/plain");
            map.Add(".viw", "text/plain");
            map.Add(".vscontent", "application/xml");
            map.Add(".vsi", "application/ms-vsi");
            map.Add(".vspolicy", "application/xml");
            map.Add(".vspolicydef", "application/xml");
            map.Add(".vspscc", "text/plain");
            map.Add(".vsscc", "text/plain");
            map.Add(".vssettings", "text/xml");
            map.Add(".vssscc", "text/plain");
            map.Add(".vstemplate", "text/xml");
            map.Add(".wav", "audio/wav");
            map.Add(".wax", "audio/x-ms-wax");
            map.Add(".wm", "video/x-ms-wm");
            map.Add(".wma", "audio/x-ms-wma");
            map.Add(".wmd", "application/x-ms-wmd");
            map.Add(".wmv", "video/x-ms-wmv");
            map.Add(".wmx", "video/x-ms-wmx");
            map.Add(".wmz", "application/x-ms-wmz");
            map.Add(".wpl", "application/vnd.ms-wpl");
            map.Add(".wsc", "text/scriptlet");
            map.Add(".wsdl", "application/xml");
            map.Add(".wvx", "video/x-ms-wvx");
            map.Add(".xdr", "application/xml");
            map.Add(".xhash", "application/x-BaiduHashFile");
            map.Add(".xml", "text/xml");
            map.Add(".xmta", "application/xml");
            map.Add(".xsc", "application/xml");
            map.Add(".xsd", "application/xml");
            map.Add(".xsl", "text/xml");
            map.Add(".xslt", "application/xml");
            map.Add(".xss", "application/xml");
            map.Add(".z", "application/x-compress");
            #endregion

            mimemap = map;
        }
    }



    public static void DownloadFile(HttpContext context, string filepath, string filename, bool isPublic)
    {
        if (context == null) throw (new ArgumentNullException("context"));
        if (filepath == null) throw (new ArgumentNullException("filepath"));
        if (filename == null) throw (new ArgumentNullException("filename"));

        if (!File.Exists(filepath))
            throw (new HttpException(404, filename + " not found!"));

        FileInfo fileinfo = new FileInfo(filepath);
        int filesize = (int)fileinfo.Length;

        int start, length;
        bool hasRange = GetRange(context, filesize, out start, out length);

        if (!hasRange)
        {
            string since = context.Request.Headers["If-Modified-Since"];
            if (!string.IsNullOrEmpty(since))
            {
                DateTime sinceDate = DateTime.Parse(since);
                TimeSpan sinceSpan = fileinfo.LastWriteTime - sinceDate;

                if (sinceSpan.TotalSeconds < 1 && sinceSpan.TotalSeconds > -1)
                {
                    context.Response.Status = "304 (Not Modified)";
                    context.Response.End();
                    return;
                }
            }
        }

        if (isPublic)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.Private);
            context.Response.Cache.SetETag(CalcETag(fileinfo.FullName + ":" + fileinfo.LastWriteTime.Ticks));
            context.Response.Cache.SetLastModified(fileinfo.LastWriteTime);
        }
        else
        {
            //maybe the attachment is security file . do not cache it!
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        }

        string attachemntame = filename;

        string mime = SampleUtil.GetMimeType(filename);

        context.Response.ContentType = mime;

        if (mime.StartsWith("text/"))
        {
            //all text file can be html or script.
            //it's dangerous that let the user open the html file on the browser directly.
            //the html may contains javascript that can thieve the cookie of the user on your website.

            //change the response and force the browser download the file.
            context.Response.ContentType = "application/unknown";
            attachemntame = attachemntame + ".download";
        }

        //attachemntame = context.Server.UrlEncode(attachemntame);
        context.Response.AddHeader("Content-Disposition", "inline;filename=" + attachemntame);


        byte[] buff = new byte[0x10000];
        Stream outp = context.Response.OutputStream;
        using (FileStream fs = new FileStream(filepath, FileMode.Open, FileAccess.Read, FileShare.Read))
        {
            if (hasRange)
            {
                context.Response.StatusCode = 206;
                context.Response.AddHeader("Content-Length", length.ToString());
                context.Response.AddHeader("Content-Range", "bytes " + start + "-" + (start + length - 1) + "/" + filesize);
            }
            else
            {
                context.Response.AddHeader("Content-Length", filesize.ToString());
                start = 0;
                length = filesize;
            }

            if (start != 0)
            {
                fs.Seek(start, SeekOrigin.Begin);
            }

            int readlen = 0;

            while (true)
            {
                int readnow = Math.Min(0x10000, length - readlen);
                if (readnow <= 0)
                    break;

                int rc = fs.Read(buff, 0, readnow);
                if (rc <= 0)
                    break;

                readlen += rc;

                if (CuteWebUI.UploadModule.LimitSpeedForTest)
                {
                    System.Threading.Thread.Sleep(100);
                }

                outp.Write(buff, 0, rc);

                //if the client is disconnect , this method will throw an exception and stop sending file data
                context.Response.Flush();
            }
        }
    }

    static bool GetRange(HttpContext context, int maxLen, out int start, out int len)
    {
        string range = context.Request.Headers["Range"];

        start = 0;
        len = maxLen;

        if (maxLen < 1)
            return false;

        if (string.IsNullOrEmpty(range))
            return false;

        range = range.Trim();
        if (!range.StartsWith("bytes="))
            return false;

        range = range.Remove(0, 6).Trim();

        string[] parts = range.Split('-');
        if (parts.Length != 2)
            return false;

        int p1, p2;
        if (!int.TryParse(parts[0], out p1))
            return false;

        if (parts[1].Length == 0)
        {
            p2 = maxLen;
        }
        else
        {
            if (!int.TryParse(parts[1], out p2))
                return false;
        }

        //imporssible ? the parts is splited by '-'
        if (p1 < 0)
            return false;

        if (p1 > p2)
            return false;

        if (p2 > maxLen)
            return false;

        start = p1;
        len = p2 - p1;

        return true;
    }

    static public string CalcETag(string str)
    {
        System.Security.Cryptography.MD5CryptoServiceProvider md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] hash = md5.ComputeHash(System.Text.Encoding.Unicode.GetBytes(str));
        md5.Clear();
        return Convert.ToBase64String(hash);
    }

}
