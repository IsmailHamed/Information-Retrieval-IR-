using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

public class FileItem
{
    public FileItem(string dir, CuteWebUI.AttachmentItem item)
	{
		_dir=dir;
		_guid = item.FileGuid;
		_name = item.FileName;
		_size = item.FileSize;
		_tempname = item.GetTempFilePath();
	}

	public FileItem(string dir)
	{
		_dir=dir;
	}

	string _dir;
	Guid _guid;
	string _name;
	int _size;
	string _tempname;

	public string Directory
	{
		get
		{
			return _dir;
		}
	}

	public Guid FileGuid
	{
		get
		{
			return _guid;
		}
		set
		{
			_guid = value;
		}
	}
	public string FileName
	{
		get
		{
			return _name;
		}
		set
		{
			_name = value;
		}
	}
	public int FileSize
	{
		get
		{
			return _size;
		}
		set
		{
			_size = value;
		}
	}
	public string TempFileName
	{
		get
		{
			return _tempname;
		}
		set
		{
			_tempname = value;
			_temppath = null;
		}
	}

	string _temppath;
	public string TempFilePath
	{
		get
		{
			if(_temppath==null)
				_temppath=System.IO.Path.Combine(_dir, _tempname);
			return _temppath;
		}
	}
}
