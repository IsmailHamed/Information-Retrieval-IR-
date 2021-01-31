using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.Text;

public partial class SampleDB : IDisposable
{
	static public SampleDB Create(params object[] parameters)
	{
		SampleDB query = new SampleDB();
		query._args = parameters;
		return query;
	}
	#region instance query helper
	private SampleDB()
	{
	}

	object[] _args;
	string _select;
	string _from;
	string _where;
	string _order;
	int _start=0;
	int _count=0;
	int _total=-1;
	SqlDataReader _reader;

	void NoReader()
	{
		if (_reader != null)
			throw (new Exception("reader exists"));
	}

	public SampleDB Select(string select)
	{
		NoReader();
		_select = select;
		return this;
	}

	public SampleDB From(string from)
	{
		NoReader();
		_from = from;
		return this;
	}

	public SampleDB Where(string where)
	{
		NoReader();
		_where = where;
		return this;
	}

	public SampleDB OrderBy(string order)
	{
		NoReader();
		_order = order;
		return this;
	}

	public SampleDB Range(int start, int count)
	{
		NoReader();
		_start = start;
		_count = count;
		return this;
	}
	
	static string cursorSQL = @"
DECLARE @FetchedCount INT SET @FetchedCount=0

DECLARE @Cursor CURSOR
SET @CURSOR = CURSOR READ_ONLY STATIC FOR
{0}

OPEN @Cursor

SELECT @@CURSOR_ROWS

FETCH {1} FROM @Cursor
WHILE @@FETCH_STATUS=0
BEGIN

	SET @FetchedCount=@FetchedCount+1
	IF @FetchedCount>=@ReturnRowCount BREAK

	FETCH NEXT FROM @Cursor	

END

CLOSE @Cursor
DEALLOCATE @Cursor
";

	private void Execute()
	{
		if (_select == null) throw (new Exception("No select!"));
		if (_from == null) throw (new Exception("No from!"));
		
		StringBuilder sb = new StringBuilder();
		sb.Append("SELECT ").Append(_select);
		sb.Append(" FROM ").Append(_from);
		if (!string.IsNullOrEmpty(_where))
			sb.Append(" WHERE ").Append(_where);
		if (!string.IsNullOrEmpty(_order))
			sb.Append(" ORDER BY ").Append(_order);

		SqlConnection conn = SampleDB.CreateConnection();
		SqlCommand cmd = SampleDB.CreateCommand(conn, sb.ToString(), _args);

		string str1 = "NEXT";
		if (_start != 0) str1 = "ABSOLUTE " + (_start + 1);

		cmd.CommandText = string.Format(cursorSQL, cmd.CommandText, str1);

		int count = _count;
		if (count <= 0)
			count = int.MaxValue;
		cmd.Parameters.AddWithValue("@ReturnRowCount", count);

		conn.Open();
		try
		{
			_reader = cmd.ExecuteReader(CommandBehavior.CloseConnection);
		}
		catch
		{
			_reader = null;
			conn.Dispose();
			throw;
		}

		_reader.Read();
		_total = Convert.ToInt32(_reader.GetValue(0));
		_reader.NextResult();

	}
	public SampleDB GetTotalCount(out int totalCount)
	{
		if (_reader == null) Execute();
		totalCount = _total;
		return this;
	}
	public SqlDataReader ExecuteReader(out int totalCount)
	{
		if (_reader == null) Execute();
		totalCount = _total;
		return _reader;
	}
	
	public DataTable ExecuteTable(out int totalCount)
	{
		if (_reader == null) Execute();
		totalCount = _total;
		object[] objs = new object[_reader.FieldCount - 1];//last is rowstat
		DataTable table = new DataTable();
		for (int i = 0; i < objs.Length; i++)
		{
			table.Columns.Add(_reader.GetName(i), _reader.GetFieldType(i));
		}
		do
		{
			while (_reader.Read())
			{
				_reader.GetValues(objs);
				table.Rows.Add(objs);
			}
		} while (_reader.NextResult());
		_reader.Dispose();
		_reader = null;
		table.AcceptChanges();
		return table;
	}
	public DataTable ExecuteTable()
	{
		int total;
		return ExecuteTable(out total);
	}

	static public implicit operator DataTable(SampleDB query)
	{
		return query.ExecuteTable();
	}

	
	public void Dispose()
	{
		if (_reader != null)
			_reader.Dispose();
		_reader = null;
	}
	#endregion
}
