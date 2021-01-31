Imports System
Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports System.Data.SqlClient
Imports System.Text

Partial Public Class SampleDB
    Implements IDisposable
    Public Shared Function Create(ByVal ParamArray parameters As Object()) As SampleDB
        Dim query As New SampleDB()
        query._args = parameters
        Return query
    End Function
#Region "instance query helper"
    Private Sub New()
    End Sub

    Private _args As Object()
    Private _select As String
    Private _from As String
    Private _where As String
    Private _order As String
    Private _start As Integer = 0
    Private _count As Integer = 0
    Private _total As Integer = -1
    Private _reader As SqlDataReader

    Private Sub NoReader()
        If _reader IsNot Nothing Then
            Throw (New Exception("reader exists"))
        End If
    End Sub

    Public Function [Select](ByVal strSelect As String) As SampleDB
        NoReader()
        _select = strSelect
        Return Me
    End Function

    Public Function From(ByVal strFrom As String) As SampleDB
        NoReader()
        _from = strFrom
        Return Me
    End Function

    Public Function Where(ByVal strWhere As String) As SampleDB
        NoReader()
        _where = strWhere
        Return Me
    End Function

    Public Function OrderBy(ByVal order As String) As SampleDB
        NoReader()
        _order = order
        Return Me
    End Function

    Public Function Range(ByVal start As Integer, ByVal count As Integer) As SampleDB
        NoReader()
        _start = start
        _count = count
        Return Me
    End Function

    Shared cursorSQL As String = "" & Chr(13) & "" & Chr(10) & "DECLARE @FetchedCount INT SET @FetchedCount=0" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "DECLARE @Cursor CURSOR" & Chr(13) & "" & Chr(10) & "SET @CURSOR = CURSOR READ_ONLY STATIC FOR" & Chr(13) & "" & Chr(10) & "{0}" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "OPEN @Cursor" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "SELECT @@CURSOR_ROWS" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "FETCH {1} FROM @Cursor" & Chr(13) & "" & Chr(10) & "WHILE @@FETCH_STATUS=0" & Chr(13) & "" & Chr(10) & "BEGIN" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "" & Chr(9) & "SET @FetchedCount=@FetchedCount+1" & Chr(13) & "" & Chr(10) & "" & Chr(9) & "IF @FetchedCount>=@ReturnRowCount BREAK" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "" & Chr(9) & "FETCH NEXT FROM @Cursor" & Chr(9) & "" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "END" & Chr(13) & "" & Chr(10) & "" & Chr(13) & "" & Chr(10) & "CLOSE @Cursor" & Chr(13) & "" & Chr(10) & "DEALLOCATE @Cursor" & Chr(13) & "" & Chr(10) & ""

    Private Sub Execute()
        If _select Is Nothing Then
            Throw (New Exception("No select!"))
        End If
        If _from Is Nothing Then
            Throw (New Exception("No from!"))
        End If

        Dim sb As New StringBuilder()
        sb.Append("SELECT ").Append(_select)
        sb.Append(" FROM ").Append(_from)
        If Not String.IsNullOrEmpty(_where) Then
            sb.Append(" WHERE ").Append(_where)
        End If
        If Not String.IsNullOrEmpty(_order) Then
            sb.Append(" ORDER BY ").Append(_order)
        End If

        Dim conn As SqlConnection = SampleDB.CreateConnection()
        Dim cmd As SqlCommand = SampleDB.CreateCommand(conn, sb.ToString(), _args)

        Dim str1 As String = "NEXT"
        If _start <> 0 Then
            str1 = "ABSOLUTE " & (_start + 1).ToString()
        End If

        cmd.CommandText = String.Format(cursorSQL, cmd.CommandText, str1)

        Dim count As Integer = _count
        If count <= 0 Then
            count = Integer.MaxValue
        End If
        cmd.Parameters.AddWithValue("@ReturnRowCount", count)

        conn.Open()
        Try
            _reader = cmd.ExecuteReader(CommandBehavior.CloseConnection)
        Catch
            _reader = Nothing
            conn.Dispose()
            Throw
        End Try

        _reader.Read()
        _total = Convert.ToInt32(_reader.GetValue(0))
        _reader.NextResult()

    End Sub
    Public Function GetTotalCount(ByRef totalCount As Integer) As SampleDB
        If _reader Is Nothing Then
            Execute()
        End If
        totalCount = _total
        Return Me
    End Function
    Public Function ExecuteReader(ByRef totalCount As Integer) As SqlDataReader
        If _reader Is Nothing Then
            Execute()
        End If
        totalCount = _total
        Return _reader
    End Function

    Public Function ExecuteTable(ByRef totalCount As Integer) As DataTable
        If _reader Is Nothing Then
            Execute()
        End If
        totalCount = _total
        Dim objs As Object() = New Object(_reader.FieldCount - 2) {}
        'last is rowstat 
        Dim table As New DataTable()
        For i As Integer = 0 To objs.Length - 1
            table.Columns.Add(_reader.GetName(i), _reader.GetFieldType(i))
        Next
        Do
            While _reader.Read()
                _reader.GetValues(objs)
                table.Rows.Add(objs)
            End While
        Loop While _reader.NextResult()
        _reader.Dispose()
        _reader = Nothing
        table.AcceptChanges()
        Return table
    End Function
    Public Function ExecuteTable() As DataTable
        Dim total As Integer
        Return ExecuteTable(total)
    End Function

    Public Shared Widening Operator CType(ByVal query As SampleDB) As DataTable
        Return query.ExecuteTable()
    End Operator


    Public Sub Dispose() Implements IDisposable.Dispose
        If _reader IsNot Nothing Then
            _reader.Dispose()
        End If
        _reader = Nothing
    End Sub
#End Region
End Class
