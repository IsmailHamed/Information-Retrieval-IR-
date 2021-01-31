namespace IndexingService.Filters
{
    public interface IFilter
    {
        bool Process(TokenSource source);
    }
}