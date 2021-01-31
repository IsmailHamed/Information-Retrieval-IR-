<%@ WebHandler Language="C#" Class="DownloadAttachment" %>

using System;
using System.Web;
using System.IO;
using System.Data;
using System.Data.SqlClient;

public class DownloadAttachment : IHttpHandler {

	public void ProcessRequest(HttpContext context)
	{
		string guidname = context.Request.QueryString["Guid"];
		if (string.IsNullOrEmpty(guidname))
		{
			NoFound(context);
			return;
		}

		Guid guid = new Guid(guidname);

		string tempdir=context.Server.MapPath("~/UploaderTemp/");
		string[] files=Directory.GetFiles(tempdir,"persisted." + guid + ".*");
		if (files == null || files.Length == 0)
		{
			NoFound(context);
			return;
		}

		string filepath = files[0];

		string filename = Path.GetFileNameWithoutExtension(filepath).Remove(0, 47);

		//context.Response.Cache.SetExpires(DateTime.Now.AddDays(2));
		SampleUtil.DownloadFile(context, filepath, filename,true);
		
	}

	void NoFound(HttpContext context)
	{
		string imgfile = "http://ajaxuploader.com/sampleimages/anonymous.gif";

		context.Response.Redirect(imgfile);
		
		//string filepath = context.Server.MapPath(imgfile);
		//SampleUtil.DownloadFile(context, filepath, "anonymous.gif", true);
	}
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}