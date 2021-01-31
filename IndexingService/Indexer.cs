using System;
using System.Collections.Generic;
using System.IO;
using IndexingService.Filters;

namespace IndexingService
{
    public class Indexer
    {
        private readonly IAnalyzer _analyzer;

        public Indexer(IAnalyzer analyzer = null)
        {
            _analyzer = analyzer ?? DefaultAnalyzer.Instance;
        }

        public InvertedIndex CreateIndex(params string[] documents)
        {
            var result = new InvertedIndex(documents.Length);

            try
            {
                NumericComparer ns = new NumericComparer();
                Array.Sort(documents, ns);
            }
            catch { }

            for (var i = 0; i < documents.Length; i++)
            {
                using (var reader = new StreamReader(documents[i]))
                {
                    var tokenSource = new TokenSource(reader);

                    while (tokenSource.Next())
                    {
                        if (_analyzer.Process(tokenSource))
                        {
                            result.Append(
                                new TermSegment(tokenSource.Buffer, tokenSource.Size),
                                i, tokenSource.Position);
                        }
                    }
                }
            }

            return result;
        }

        public InvertedIndex CreateIndex(InvertedIndex result, params string[] documents)
        {
            int corpusCount = result._maxDocumentId;
            try
            {
                NumericComparer ns = new NumericComparer();
                Array.Sort(documents, ns);
            }
            catch { }

            for (var i = 0; i < documents.Length; i++)
            {
                using (var reader = new StreamReader(documents[i]))
                {
                    var tokenSource = new TokenSource(reader);

                    while (tokenSource.Next())
                    {
                        if (_analyzer.Process(tokenSource))
                        {
                            result.Append(
                                new TermSegment(tokenSource.Buffer, tokenSource.Size),
                                corpusCount + i, tokenSource.Position);
                        }
                    }
                }
            }

            return result;
        }
    }
}
