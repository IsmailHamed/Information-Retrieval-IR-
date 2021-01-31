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

Partial Public Class SampleDB
#Region "Connection"
    Public Shared ReadOnly Property ConnectionString() As String
        Get
            Return System.Configuration.ConfigurationManager.ConnectionStrings("SampleSqlServer").ConnectionString
        End Get
    End Property

    Public Shared Function CreateConnection() As SqlConnection
        Return New SqlConnection(ConnectionString)
    End Function
    Public Shared Function OpenConnection() As SqlConnection
        Dim conn As SqlConnection = CreateConnection()
        conn.Open()
        Return conn
    End Function

    Private Shared Function CreateCommand(ByVal conn As SqlConnection, ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As SqlCommand
        Dim cmd As SqlCommand = conn.CreateCommand()
        If args IsNot Nothing AndAlso args.Length <> 0 Then
            Dim argnames As Object() = New Object(args.Length - 1) {}
            For i As Integer = 0 To args.Length - 1
                Dim name As String = "@AutoArg" & Convert.ToString(i + 1)
                argnames(i) = name
                cmd.Parameters.AddWithValue(name, args(i))
            Next
            text = String.Format(text, argnames)
        End If
        cmd.Connection = conn
        cmd.Transaction = trans
        cmd.CommandText = text
        Return cmd
    End Function
    Public Shared Function CreateCommand(ByVal conn As SqlConnection, ByVal text As String, ByVal ParamArray args As Object()) As SqlCommand
        If conn Is Nothing Then
            Throw (New ArgumentNullException("conn"))
        End If
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Return CreateCommand(conn, Nothing, text, args)
    End Function
    Public Shared Function CreateCommand(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As SqlCommand
        If trans Is Nothing Then
            Throw (New ArgumentNullException("trans"))
        End If
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Return CreateCommand(trans.Connection, trans, text, args)
    End Function

#Region "No Transaction"
    Public Shared Function ExecuteReader(ByVal text As String, ByVal ParamArray args As Object()) As SqlDataReader
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Dim conn As SqlConnection = CreateConnection()
        Dim cmd As SqlCommand = CreateCommand(conn, text, args)
        conn.Open()
        Return cmd.ExecuteReader(CommandBehavior.CloseConnection)
    End Function
    Public Shared Sub ExecuteNonQuery(ByVal text As String, ByVal ParamArray args As Object())
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Using conn As SqlConnection = OpenConnection()
            Dim cmd As SqlCommand = CreateCommand(conn, text, args)
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Public Shared Function ExecuteScalar(ByVal text As String, ByVal ParamArray args As Object()) As Object
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Using conn As SqlConnection = OpenConnection()
            Dim cmd As SqlCommand = CreateCommand(conn, text, args)
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Shared Function ExecuteInt32(ByVal text As String, ByVal ParamArray args As Object()) As Integer
        Return Convert.ToInt32(ExecuteScalar(text, args))
    End Function
    Public Shared Function ExecuteString(ByVal text As String, ByVal ParamArray args As Object()) As String
        Dim obj As Object = ExecuteScalar(text, args)
        If obj Is Nothing Then
            Return Nothing
        End If
        Return obj.ToString()
    End Function

    Public Shared Function ExecuteDataTable(ByVal text As String, ByVal ParamArray args As Object()) As DataTable
        Using reader As SqlDataReader = ExecuteReader(text, args)
            Dim table As New DataTable()
            table.Load(reader)
            Return table
        End Using
    End Function
    Public Shared Function ExecuteDataRow(ByVal text As String, ByVal ParamArray args As Object()) As DataRow
        Return GetDataRow(ExecuteDataTable(text, args), False)
    End Function
    Public Shared Function ExecuteDataRow(ByVal checkOnlyOne As Boolean, ByVal text As String, ByVal ParamArray args As Object()) As DataRow
        Return GetDataRow(ExecuteDataTable(text, args), checkOnlyOne)
    End Function
#End Region

#Region "With Transaction"
    Public Shared Function ExecuteReader(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As SqlDataReader
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Dim cmd As SqlCommand = CreateCommand(trans, text, args)
        Return cmd.ExecuteReader()
    End Function
    Public Shared Sub ExecuteNonQuery(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object())
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Dim cmd As SqlCommand = CreateCommand(trans, text, args)
        cmd.ExecuteNonQuery()
    End Sub
    Public Shared Function ExecuteScalar(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As Object
        If text Is Nothing Then
            Throw (New ArgumentNullException("text"))
        End If
        Dim cmd As SqlCommand = CreateCommand(trans, text, args)
        Return cmd.ExecuteScalar()
    End Function

    Public Shared Function ExecuteInt32(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As Integer
        Return Convert.ToInt32(ExecuteScalar(trans, text, args))
    End Function
    Public Shared Function ExecuteString(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As String
        Dim obj As Object = ExecuteScalar(trans, text, args)
        If obj Is Nothing Then
            Return Nothing
        End If
        Return obj.ToString()
    End Function

    Public Shared Function ExecuteDataTable(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As DataTable
        Using reader As SqlDataReader = ExecuteReader(trans, text, args)
            Dim table As New DataTable()
            table.Load(reader)
            Return table
        End Using
    End Function
    Public Shared Function ExecuteDataRow(ByVal trans As SqlTransaction, ByVal text As String, ByVal ParamArray args As Object()) As DataRow
        Return GetDataRow(ExecuteDataTable(trans, text, args), False)
    End Function
    Public Shared Function ExecuteDataRow(ByVal trans As SqlTransaction, ByVal checkOnlyOne As Boolean, ByVal text As String, ByVal ParamArray args As Object()) As DataRow
        Return GetDataRow(ExecuteDataTable(trans, text, args), checkOnlyOne)
    End Function
#End Region

    Public Shared Function GetDataRow(ByVal table As DataTable, ByVal checkOnlyOne As Boolean) As DataRow
        If table Is Nothing Then
            Throw (New ArgumentNullException("table"))
        End If
        Dim rc As Integer = table.Rows.Count
        If checkOnlyOne AndAlso rc <> 1 Then
            If rc = 0 Then
                Throw (New Exception("Table contains no row"))
            End If
            Throw (New Exception("Table contains multi row"))
        End If
        If rc = 0 Then
            Return Nothing
        End If
        Return table.Rows(0)
    End Function
#End Region

    Public Shared ReadOnly Property Context() As HttpContext
        Get
            Return HttpContext.Current
        End Get
    End Property

    Public Shared Function GetCurrentUserId() As Integer
        Dim row As DataRow = GetCurentUserRow()
        If row Is Nothing Then
            Throw (New Exception("no found"))
        End If
        Return CInt(row("UserId"))
    End Function
    Public Shared Function GetCurentUserRow() As DataRow
        Dim row As DataRow = DirectCast(Context.Items("CurentUserRow"), DataRow)
        If row IsNot Nothing Then
            Return row
        End If

        Dim username As String = "Guest"

        row = ExecuteDataRow("SELECT * FROM UploaderUsers WHERE Username={0}", username)
        If row Is Nothing Then
            Dim userid As Integer = ExecuteInt32("INSERT UploaderUsers (UserName) VALUES ({0}) SELECT SCOPE_IDENTITY()", username)
            row = ExecuteDataRow("SELECT * FROM UploaderUsers WHERE UserId={0}", userid)
        End If
        Context.Items("CurentUserRow") = row
        Return row
    End Function
    Public Shared Sub ResetCurrentUserRow()
        Context.Items("CurentUserRow") = Nothing
    End Sub

    Public Shared Function SendMail(ByVal senderId As Integer, ByVal senderName As String, ByVal targetId As Integer, ByVal title As String, ByVal mailbody As String, ByVal fileitems As FileItem()) As Integer
        If title Is Nothing Then
            Throw (New ArgumentNullException("title"))
        End If
        If mailbody Is Nothing Then
            Throw (New ArgumentNullException("mailbody"))
        End If

        Dim filecount As Integer = 0
        If fileitems IsNot Nothing Then
            filecount = fileitems.Length
        End If

        Dim mailid As Integer
        Using conn As SqlConnection = OpenConnection()
            Using trans As SqlTransaction = conn.BeginTransaction()
                mailid = ExecuteInt32(trans, "INSERT Mails (UserId,SenderId,SenderName,Title,MailBody,SendTime,FileCount) VALUES ({0},{1},{2},{3},{4},{5},{6}) SELECT SCOPE_IDENTITY()", targetId, senderId, senderName, title, _
                mailbody, DateTime.Now, filecount)

                ExecuteNonQuery(trans, "UPDATE UploaderUsers SET MailCount=MailCount+1,UnreadMail=UnreadMail+1 WHERE UserId={0}", targetId)

                If fileitems IsNot Nothing Then
                    For Each fileitem As FileItem In fileitems
                        ExecuteNonQuery(trans, "INSERT MailAttachments (MailId,FileGuid,FileSize,FileName,TempFileName) VALUES ({0},{1},{2},{3},{4})", mailid, fileitem.FileGuid, fileitem.FileSize, fileitem.FileName, _
                        fileitem.TempFileName)
                    Next
                End If



                trans.Commit()
            End Using
        End Using

        If senderId = targetId Then
            SampleDB.ResetCurrentUserRow()
        End If

        Return mailid
    End Function

    Public Shared Function SendTopic(ByVal senderId As Integer, ByVal senderName As String, ByVal title As String, ByVal topicbody As String, ByVal fileitems As FileItem()) As Integer
        If title Is Nothing Then
            Throw (New ArgumentNullException("title"))
        End If
        If topicbody Is Nothing Then
            Throw (New ArgumentNullException("topicbody"))
        End If

        Dim filecount As Integer = 0
        If fileitems IsNot Nothing Then
            filecount = fileitems.Length
        End If

        Using conn As SqlConnection = OpenConnection()
            Using trans As SqlTransaction = conn.BeginTransaction()
                Dim topicid As Integer = ExecuteInt32(trans, "INSERT UploaderTopics (UserId,UserName,Title,TopicBody,CreateTime,UpdateTime,FileCount) VALUES ({0},{1},{2},{3},{4},{5},{6}) SELECT SCOPE_IDENTITY()", senderId, senderName, title, topicbody, _
                DateTime.Now, DateTime.Now, filecount)

                If fileitems IsNot Nothing Then
                    For Each fileitem As FileItem In fileitems
                        ExecuteNonQuery(trans, "INSERT UploaderTopicAttachments (TopicId,FileGuid,FileSize,FileName,TempFileName) VALUES ({0},{1},{2},{3},{4})", topicid, fileitem.FileGuid, fileitem.FileSize, fileitem.FileName, _
                        fileitem.TempFileName)
                    Next
                End If

                trans.Commit()

                Return topicid
            End Using
        End Using
    End Function

    Public Shared Function SendReply(ByVal topicId As Integer, ByVal senderId As Integer, ByVal senderName As String, ByVal replyBody As String) As Integer
        Using conn As SqlConnection = OpenConnection()
            Using trans As SqlTransaction = conn.BeginTransaction()
                Dim replyid As Integer = ExecuteInt32(trans, "INSERT UploaderReplys (TopicId,UserId,UserName,ReplyBody,ReplyTime) VALUES ({0},{1},{2},{3},{4}) SELECT SCOPE_IDENTITY()", topicId, senderId, senderName, replyBody, _
                DateTime.Now)

                ExecuteNonQuery(trans, "UPDATE UploaderTopics SET ReplyCount=ReplyCount+1 WHERE TopicId={0}", topicId)

                trans.Commit()

                Return replyid
            End Using
        End Using
    End Function

End Class
