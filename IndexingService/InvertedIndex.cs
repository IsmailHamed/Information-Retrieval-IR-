using System;
using System.Collections.Generic;
using System.Linq;
using IndexingService.Filters;

namespace IndexingService
{
    public class InvertedIndex
    {
        public readonly int _maxDocumentId;

        internal InvertedIndex(int maxDocumentId)
        {
            _maxDocumentId = maxDocumentId;
        }

        private readonly ISet<int> _indexedDocuments = 
            new SortedSet<int>();
        public IEnumerable<int> IndexedDocuments => _indexedDocuments;
        public object NumberOfTerms => _data.Count;

        private readonly IDictionary<TermSegment, Posting[]> _data = 
            new Dictionary<TermSegment, Posting[]>();

        internal void Append(TermSegment term, int documentId, long position)
        {
            if (_data.TryGetValue(term, out var postings))
            {
                if (postings[documentId] == null)
                {
                    postings[documentId] = new Posting(documentId);
                }

                postings[documentId].Positions.Add(position);
            }
            else
            {
                var posting = new Posting(documentId);
                posting.Positions.Add(position);

                postings = new Posting[_maxDocumentId + 1];
                postings[documentId] = posting;
                _data.Add(term.Stabilize(), postings);
            }

            _indexedDocuments.Add(documentId);
        }

        public IEnumerable<Posting> GetPostingsFor(string term)
        {
            var key = new TermSegment(term);
            return !_data.ContainsKey(key)
                ? Enumerable.Empty<Posting>()
                : _data[key];
        } 
    }

    public class Posting
    {
        public int DocumentId { get; }
        public IList<long> Positions { get; } = new List<long>(); 

        public Posting(int documentId)
        {
            DocumentId = documentId;
        }

        public static implicit operator int(Posting entry) =>
            entry.DocumentId;
    }
}