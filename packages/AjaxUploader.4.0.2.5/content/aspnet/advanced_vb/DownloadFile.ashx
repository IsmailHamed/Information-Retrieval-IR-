<%@ WebHandler Language="VB" Class="DownloadFileAttachment" %>

Imports System
Imports System.Web
Imports System.IO
Imports System.Data
Imports System.Data.SqlClient

Public Class DownloadFileAttachment
    Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim fileid As Integer
        Try
            fileid = Integer.Parse(context.Request.QueryString("FileId"))
        Catch
            NoFound(context)
            Return
        End Try
        
        Dim filerow As DataRow = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE FileId={0}", fileid)
        If filerow Is Nothing Then
            NoFound(context)
            Return
        End If
        
        Dim fileowner As Integer = CInt(filerow("UserId"))
        Dim logonuserid As Integer = SampleDB.GetCurrentUserId()
        
        If fileowner <> logonuserid Then
            Throw (New Exception("Invalid User"))
        End If
        
        Dim dir As String = SampleUtil.GetFileDirectory()
        Dim filepath As String = Path.Combine(dir, DirectCast(filerow("TempFileName"), String))
        Dim filename As String = DirectCast(filerow("FileName"), String)
        
        If Not File.Exists(filepath) Then
            NoFound(context)
            Return
        End If
        
        SampleUtil.DownloadFile(context, filepath, filename, False)
        
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
