<%@ WebHandler Language="VB" Class="DownloadPhotoAttachment" %>

Imports System
Imports System.Web
Imports System.IO
Imports System.Data
Imports System.Data.SqlClient

Public Class DownloadPhotoAttachment
    Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim guidname As String = context.Request.QueryString("Guid")
        If String.IsNullOrEmpty(guidname) Then
            NoFound(context)
            Return
        End If
        
        Dim guid As New Guid(guidname)
        
        Dim tempdir As String = context.Server.MapPath("~/UploaderTemp/")
        Dim files As String() = Directory.GetFiles(tempdir, "persisted." + guid.ToString() + ".*")
        If files Is Nothing OrElse files.Length = 0 Then
            NoFound(context)
            Return
        End If
        
        Dim filepath As String = files(0)
        
        Dim filename As String = Path.GetFileNameWithoutExtension(filepath).Remove(0, 47)
        
        'context.Response.Cache.SetExpires(DateTime.Now.AddDays(2)); 
        SampleUtil.DownloadFile(context, filepath, filename, True)
        
    End Sub
    
    Private Sub NoFound(ByVal context As HttpContext)
        Dim imgfile As String = "http://ajaxuploader.com/sampleimages/anonymous.gif"
        
        context.Response.Redirect(imgfile)
        
        'string filepath = context.Server.MapPath(imgfile); 
        'SampleUtil.DownloadFile(context, filepath, "anonymous.gif", true); 
    End Sub
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
End Class
