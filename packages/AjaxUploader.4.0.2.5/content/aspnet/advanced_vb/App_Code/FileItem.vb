Imports System
Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Public Class FileItem
    Public Sub New(ByVal dir As String, ByVal item As CuteWebUI.AttachmentItem)
        _dir = dir
        _guid = item.FileGuid
        _name = item.FileName
        _size = item.FileSize
        _tempname = item.GetTempFilePath()
    End Sub

    Public Sub New(ByVal dir As String)
        _dir = dir
    End Sub

    Private _dir As String
    Private _guid As Guid
    Private _name As String
    Private _size As Integer
    Private _tempname As String

    Public ReadOnly Property Directory() As String
        Get
            Return _dir
        End Get
    End Property

    Public Property FileGuid() As Guid
        Get
            Return _guid
        End Get
        Set(ByVal value As Guid)
            _guid = value
        End Set
    End Property
    Public Property FileName() As String
        Get
            Return _name
        End Get
        Set(ByVal value As String)
            _name = value
        End Set
    End Property
    Public Property FileSize() As Integer
        Get
            Return _size
        End Get
        Set(ByVal value As Integer)
            _size = value
        End Set
    End Property
    Public Property TempFileName() As String
        Get
            Return _tempname
        End Get
        Set(ByVal value As String)
            _tempname = value
            _temppath = Nothing
        End Set
    End Property

    Private _temppath As String
    Public ReadOnly Property TempFilePath() As String
        Get
            If _temppath Is Nothing Then
                _temppath = System.IO.Path.Combine(_dir, _tempname)
            End If
            Return _temppath
        End Get
    End Property
End Class
