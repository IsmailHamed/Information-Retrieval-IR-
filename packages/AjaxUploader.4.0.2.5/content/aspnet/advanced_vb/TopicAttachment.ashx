<%@ WebHandler Language="VB" Class="DownloadTopicAttachment" %>
Imports System 
Imports System.Web 
Imports System.IO 
Imports System.Data 
Imports System.Data.SqlClient 

Public Class DownloadTopicAttachment
    Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim attid As Integer
        Try
            attid = Integer.Parse(context.Request.QueryString("AttachmentId"))
        Catch
            NoFound(context)
            Return
        End Try
        
        Dim attrow As DataRow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderTopicAttachments WHERE AttachmentId={0}", attid)
        If attrow Is Nothing Then
            NoFound(context)
            Return
        End If
        
        Dim dir As String = SampleUtil.GetFileDirectory()
        Dim filepath As String = Path.Combine(dir, DirectCast(attrow("TempFileName"), String))
        Dim filename As String = DirectCast(attrow("FileName"), String)
        
        If Not File.Exists(filepath) Then
            NoFound(context)
            Return
        End If
        
        SampleUtil.DownloadFile(context, filepath, filename, True)
        
    End Sub
    
    Private Sub NoFound(ByVal context As HttpContext)
        context.Response.StatusCode = 404
        context.Response.Status = "404 Not Found"
        context.Response.Write("Resource Not Found")
        context.Response.[End]()
    End Sub
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
End Class
