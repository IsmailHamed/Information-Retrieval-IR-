using System;
using System.Collections.Generic;
using System.IO;

namespace IndexingService.Filters
{
    public class StopWordsFilter : IFilter
    {
        private static List<string> DefaultStopWords;

        private readonly HashSet<TermSegment> _stopWords
            = new HashSet<TermSegment>();

        private static List<string> LoadStopWords(string stopWordPath)
        {
            List<string> lstStopWords = new List<string>();
            using (FileStream fs = new FileStream(stopWordPath, FileMode.Open, FileAccess.Read, FileShare.None))
            using (StreamReader sr = new StreamReader(fs))
            {
                string line = null;

                while ((line = sr.ReadLine()) != null)
                {
                    if (!string.IsNullOrEmpty(line))
                    {
                        lstStopWords.Add(line);
                    }
                }
            }
            return lstStopWords;
        }

        public StopWordsFilter()
        {
            DefaultStopWords = LoadStopWords(Paths.StopWordPath);

            foreach (var word in DefaultStopWords)
            {
                _stopWords.Add(new TermSegment(word.ToCharArray()));
            }
        }

        public bool Process(TokenSource source)
        {
            var term = new TermSegment(source.Buffer, source.Size);
            return !_stopWords.Contains(term);
        }
    }
}
