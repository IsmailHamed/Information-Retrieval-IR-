using System.Collections;

namespace IndexingService
{
    public class NumericComparer : IComparer
    {
        public NumericComparer()
        { }

        public int Compare(object x, object y)
        {
            if ((x is string) && (y is string))
            {
                return StringLogicalComparer.Compare((string)x, (string)y);
            }
            return -1;
        }
    }
}