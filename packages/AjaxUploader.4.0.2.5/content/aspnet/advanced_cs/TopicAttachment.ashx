<%@ WebHandler Language="C#" Class="DownloadAttachment" %>

using System;
using System.Web;
using System.IO;
using System.Data;
using System.Data.SqlClient;

public class DownloadAttachment : IHttpHandler {

	public void ProcessRequest(HttpContext context)
	{
		int attid;
		try
		{
			attid = int.Parse(context.Request.QueryString["AttachmentId"]);
		}
		catch
		{
			NoFound(context);
			return;
		}

		DataRow attrow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderTopicAttachments WHERE AttachmentId={0}", attid);
		if (attrow == null)
		{
			NoFound(context);
			return;
		}

		string dir = SampleUtil.GetFileDirectory();
		string filepath = Path.Combine(dir, (string)attrow["TempFileName"]);
		string filename = (string)attrow["FileName"];

		if (!File.Exists(filepath))
		{
			NoFound(context);
			return;
		}
		
		SampleUtil.DownloadFile(context, filepath, filename,true);
		
	}

	void NoFound(HttpContext context)
	{
		context.Response.StatusCode = 404;
		context.Response.Status = "404 Not Found";
		context.Response.Write("Resource Not Found");
		context.Response.End();
	}
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}