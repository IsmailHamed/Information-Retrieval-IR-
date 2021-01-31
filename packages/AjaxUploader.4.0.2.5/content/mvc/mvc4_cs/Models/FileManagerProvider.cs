using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.IO;
using System.Xml;

namespace mvc_cs
{
	public class FileManagerProvider
	{
		HttpContext _context;
		public FileManagerProvider()
		{
			_context = HttpContext.Current;
		}

		protected string GetUserDirectory(string username,bool autocreate)
		{
			if (string.IsNullOrEmpty(username)) throw (new ArgumentNullException("username"));
			StringBuilder sb = new StringBuilder();
			foreach (char c in username)
			{
				if (char.IsLetterOrDigit(c))
					sb.Append(c);
				else
					sb.Append("_").Append((int)c);
			}

			string virpath=_context.Response.ApplyAppPathModifier("~/FileManagerFolder/"+sb.ToString());
			string phypath= _context.Server.MapPath(virpath);
			if (autocreate)
			{
				if (!Directory.Exists(phypath))
					Directory.CreateDirectory(phypath);
			}
			return phypath;
		}

		public FileItem[] GetFiles(string username)
		{
			string folder = GetUserDirectory(username,false);
			if (!Directory.Exists(folder))
				return new FileItem[0];
			string[] files=Directory.GetFiles(folder, "*.resx");
			Array.Sort(files);
			FileItem[] items = new FileItem[files.Length];
			for (int i = 0; i < files.Length; i++)
				items[i] = new FileItem(files[i]);
			return items;
		}

		public FileItem GetFileByID(string username, string fileid)
		{
			Guid guid = new Guid(fileid);
			string folder = GetUserDirectory(username,false);
			if (!Directory.Exists(folder))
				return null;
			string[] files = Directory.GetFiles(folder, "*." + guid.ToString() + ".resx");
			if (files.Length == 0)
				return null;
			return new FileItem(files[0]);
		}

		public FileItem MoveFile(string username, string srcpath, string filename, string description)
		{
			if (string.IsNullOrEmpty("srcpath")) throw (new ArgumentNullException("srcpath"));
			if (string.IsNullOrEmpty("filename")) throw (new ArgumentNullException("filename"));
			if (!File.Exists(srcpath))
				throw (new Exception("srcpath not exists!"));

			string folder = GetUserDirectory(username,true);
			string basename = DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss") + "." + Guid.NewGuid().ToString();
			string resxpath = Path.Combine(folder, basename + ".resx");
			string confpath = Path.Combine(folder, basename + ".config");

			XmlDocument doc = new XmlDocument();
			doc.LoadXml("<file/>");
			doc.DocumentElement.SetAttribute("name", filename);
			if (description != null)
				doc.DocumentElement.SetAttribute("comment", description);

			File.Move(srcpath, resxpath);
			doc.Save(confpath);

			return new FileItem(resxpath);
		}

	}

	public class FileItem
	{
		string _configpath;
		XmlDocument _doc;

		string _filepath;
		string _fileid;
		DateTime _filetime = DateTime.MinValue;
		string _filename;
		string _filedesc;

		internal FileItem(string filepath)
		{
			_filepath = filepath;
		}
		internal FileItem(string filepath,string configpath,XmlDocument doc)
		{
			_filepath = filepath;
			_configpath = configpath;
			_doc = doc;
		}

		public string FilePath
		{
			get
			{
				return _filepath;
			}
		}

		public string FileID
		{
			get
			{
				if (_fileid == null)
				{
					string name=Path.GetFileName(_filepath);
					_fileid=name.Split('.')[1];
				}
				return _fileid;
			}
		}

		public DateTime UploadTime
		{
			get
			{
				if (_filetime == DateTime.MinValue)
				{
					string name = Path.GetFileName(_filepath);
					_filetime = DateTime.ParseExact(name.Split('.')[0], "yyyy-MM-dd HH-mm-ss",null);
				}
				return _filetime;
			}
		}

		void LoadConfig()
		{
			if (_doc != null) return;

			_configpath = _filepath.Remove(_filepath.Length - 5) + ".config";
			XmlDocument doc = new XmlDocument();
			doc.Load(_configpath);

			_filename = doc.DocumentElement.GetAttribute("name");
			_filedesc = doc.DocumentElement.GetAttribute("comment");

			_doc = doc;
		}

		public int FileSize
		{
			get
			{
				return (int)new FileInfo(_filepath).Length;
			}
		}
		
		public string FileName
		{
			get
			{
				LoadConfig();
				return _filename;
			}
			set
			{
				if (string.IsNullOrEmpty(value)) throw (new ArgumentNullException("value"));

				LoadConfig();
				_filename = value;
				_doc.DocumentElement.SetAttribute("name", value);
				_doc.Save(_configpath);
			}
		}

		public string Description
		{
			get
			{
				LoadConfig();
				return _filedesc;
			}
			set
			{
				LoadConfig();
				_filedesc = value;
				if (value != null)
					_doc.DocumentElement.SetAttribute("comment", value);
				else
					_doc.DocumentElement.RemoveAttribute("comment");
				_doc.Save(_configpath);
			}
		}

		public void Delete()
		{
			LoadConfig();
			File.Delete(_filepath);
			File.Delete(_configpath);
		}

	}
}
