using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Autocomplete
{
    public class AutoComplete
    {
        public SymSpell CreateDictionary(out string ErrorMsg)
        {
            ErrorMsg = string.Empty;
            try
            {
                long memSize = GC.GetTotalMemory(true);
                Stopwatch stopWatch = new Stopwatch();
                stopWatch.Start();
                const int initialCapacity = 82765;
                const int maxEditDistance = 2;
                const int prefixLength = 7;
                var symSpell = new SymSpell(initialCapacity, maxEditDistance, prefixLength);
                string path = AppDomain.CurrentDomain.BaseDirectory + "frequency_dictionary_en_82_765.txt";
                if (!symSpell.LoadDictionary(path, 0, 1))
                    return null;

                stopWatch.Stop();
                long memDelta = GC.GetTotalMemory(true) - memSize;
                var result = symSpell.Lookup("warmup", SymSpell.Verbosity.All);
                return symSpell;
            }
            catch (Exception ex)
            {
                ErrorMsg = ex.ToString();
                return null;
            }
        }
    }
}
