using System.Collections.Generic;

namespace IndexingService
{
    public interface IAnalyzer
    {
        bool Process(TokenSource source);
        IEnumerable<string> Analyze(string source);
        string AnalyzeOnlyTheFirstToken(string source);
    }
}