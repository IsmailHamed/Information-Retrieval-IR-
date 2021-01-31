<%@ Control Language="C#" ClassName="SelectMyFile" %>

<script runat="server">
	
	protected override void OnInit(EventArgs e)
	{
		base.OnInit(e);

		LinkManage.Attributes["onclick"] = "window.open(this.href,'ManageMyFiles','width=850,height=600,help=0,menubar=0,resizable=1,scrollbars=1').focus();return false;";
	}

	protected void Start_Click(object sender, EventArgs e)
	{
		LoadDataForSelect();


		Start.Visible = false;
		Select.Visible = true;
	}

	private void LoadDataForSelect()
	{
		DataTable table = SampleDB.ExecuteDataTable("SELECT * FROM UploaderFiles WHERE UserId={0} ORDER BY FileId DESC"
				  , SampleDB.GetCurrentUserId());

		Select.Items.Clear();
		Select.Items.Add("Please select a file ");
		Select.Items.Add(" (Refresh this list) ");
		foreach (DataRow row in table.Rows)
		{
			int fileid = (int)row["FileId"];
			int filesize = (int)row["FileSize"];
			string filename = (string)row["FileName"];
			string descript = (string)row["Description"];
			DateTime time = (DateTime)row["UploadTime"];
			time = SampleUtil.ToUserLocalTime(time);

			string text = time.ToString("MM-dd") + " " + filename + " (" + (filesize / 1024) + "K) " + descript;
			Select.Items.Add(new ListItem(text, fileid.ToString()));
		}
	}

	DataRow _filerow;
	public DataRow SelectedFile
	{
		get
		{
			return _filerow;
		}
	}

	protected void Select_SelectedIndexChanged(object sender, EventArgs e)
	{
		if (Select.SelectedIndex == 1)
		{
			LoadDataForSelect();
			return;
		}

		int fileid = int.Parse(Select.SelectedValue);
		Select.SelectedIndex = 0;

		DataRow row = SampleDB.ExecuteDataRow("SELECT * FROM UploaderFiles WHERE UserId={0} AND FileId={1}"
			, SampleDB.GetCurrentUserId(), fileid);

		if (row == null)
			return;

		_filerow = row;

		if (SelectedFileChanged != null)
		{
			SelectedFileChanged(this, EventArgs.Empty);
		}
	}

	public event EventHandler SelectedFileChanged;
	
</script>

<asp:Button runat="server" ID="Start" Text="Select from MyFiles" Width="160px" OnClick="Start_Click" />
<asp:DropDownList runat="server" ID="Select" Visible="false" AutoPostBack="true"
	OnSelectedIndexChanged="Select_SelectedIndexChanged" Width="320px" />
<asp:HyperLink runat="server" ID="LinkManage" Text="Manage" NavigateUrl="~/Ajax-based-File-storage.aspx"
	Target="_blank"></asp:HyperLink>
