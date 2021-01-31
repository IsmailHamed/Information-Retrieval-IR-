    using System;
using System.Collections.Generic;
using System.IO;

namespace IndexingService
{
    public class Core
    {
        public static bool IsLastCharPunctuation = false;
        public static List<int> lstDate = new List<int>();
        public InvertedIndex ProcessIndexing(out string ErrorMsg, string DirPath)
        {
            ErrorMsg = string.Empty;

            try
            {
                return new Indexer(DefaultAnalyzer.Instance).CreateIndex(Directory.GetFiles(DirPath, "*.txt", SearchOption.AllDirectories));
            }
            catch (Exception ex)
            {
                ErrorMsg = ex.ToString();
                return null;
            }
        }

        public InvertedIndex ProcessIndexing(InvertedIndex index, List<string> lstAddedFiles)
        {
            try
            {
                return new Indexer(DefaultAnalyzer.Instance).CreateIndex(index, lstAddedFiles.ToArray());
            }
            catch
            {
                return null;
            }
        }
    }


}
