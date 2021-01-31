<%@ WebHandler Language="VB" Class="DownloadUserPhoto" %>

Imports System
Imports System.Web
Imports System.IO
Imports System.Data
Imports System.Data.SqlClient

Public Class DownloadUserPhoto
    Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim username As String = context.Request.QueryString("User")
        If String.IsNullOrEmpty(username) Then
            NoFound(context)
            Return
        End If
        
        Dim row As DataRow = SampleDB.ExecuteDataRow("SELECT * From UploaderUsers WHERE UserName={0}", username)
        
        If row Is Nothing Then
            NoFound(context)
            Return
        End If
        
        Dim tempfile As String = TryCast(row("PhotoTempFileName"), String)
        If String.IsNullOrEmpty(tempfile) Then
            NoFound(context)
            Return
        End If
        
        Dim filedir As String = SampleUtil.GetFileDirectory()
        Dim filepath As String = Path.Combine(filedir, tempfile)
        
        If Not File.Exists(filepath) Then
            NoFound(context)
            Return
        End If
        
        'remove ".resx" 
        Dim ext As String = Path.GetExtension(Path.GetFileNameWithoutExtension(tempfile))
        Dim filename As String = username & ext
        
        'context.Response.Cache.SetExpires(DateTime.Now.AddDays(2)); 
        SampleUtil.DownloadFile(context, filepath, filename, True)
        
    End Sub
    
    Private Sub NoFound(ByVal context As HttpContext)
        Dim imgfile As String = "http://ajaxuploader.com/sampleimages/anonymous.gif"
        
        'context.Response.Redirect(imgfile); 
        
        Dim filepath As String = context.Server.MapPath(imgfile)
        SampleUtil.DownloadFile(context, filepath, "anonymous.gif", True)
    End Sub
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
End Class
