<%@ WebHandler Language="C#" Class="DownloadAttachment" %>

using System;
using System.Web;
using System.IO;
using System.Data;
using System.Data.SqlClient;

public class DownloadAttachment : IHttpHandler {

	public void ProcessRequest(HttpContext context)
	{
		string username = context.Request.QueryString["User"];
		if (string.IsNullOrEmpty(username))
		{
			NoFound(context);
			return;
		}
		
		DataRow row=SampleDB.ExecuteDataRow("SELECT * From UploaderUsers WHERE UserName={0}", username);

		if (row == null)
		{
			NoFound(context);
			return;
		}

		string tempfile = row["PhotoTempFileName"] as string;
		if (string.IsNullOrEmpty(tempfile))
		{
			NoFound(context);
			return;
		}
		
		string filedir = SampleUtil.GetFileDirectory();
		string filepath = Path.Combine(filedir, tempfile);
		
		if(!File.Exists(filepath))
		{
			NoFound(context);
			return;
		}

		string ext = Path.GetExtension(Path.GetFileNameWithoutExtension(tempfile));
		string filename = username + ext;

		//context.Response.Cache.SetExpires(DateTime.Now.AddDays(2));
		SampleUtil.DownloadFile(context, filepath, filename,true);
		
	}

	void NoFound(HttpContext context)
	{
		string imgfile = "http://ajaxuploader.com/sampleimages/anonymous.gif";

		//context.Response.Redirect(imgfile);
		
		string filepath = context.Server.MapPath(imgfile);
		SampleUtil.DownloadFile(context, filepath, "anonymous.gif", true);
	}
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}