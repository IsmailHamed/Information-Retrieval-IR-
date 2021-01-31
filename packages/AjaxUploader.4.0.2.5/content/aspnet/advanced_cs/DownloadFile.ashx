<%@ WebHandler Language="C#" Class="DownloadAttachment" %>

using System;
using System.Web;
using System.IO;
using System.Data;
using System.Data.SqlClient;

public class DownloadAttachment : IHttpHandler {

	public void ProcessRequest(HttpContext context)
	{
		int fileid;
		try
		{
			fileid = int.Parse(context.Request.QueryString["FileId"]);
		}
		catch
		{
			NoFound(context);
			return;
		}

		DataRow filerow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE FileId={0}", fileid);
		if (filerow == null)
		{
			NoFound(context);
			return;
		}

		int fileowner = (int)filerow["UserId"];
		int logonuserid = SampleDB.GetCurrentUserId();

		if (fileowner != logonuserid)
			throw (new Exception("Invalid User"));

		string dir = SampleUtil.GetFileDirectory();
		string filepath = Path.Combine(dir, (string)filerow["TempFileName"]);
		string filename = (string)filerow["FileName"];

		if (!File.Exists(filepath))
		{
			NoFound(context);
			return;
		}
		
		SampleUtil.DownloadFile(context, filepath, filename,false);
		
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