using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IndexingService.Filters
{
    class SynonymsFilter : IFilter
    {

        private readonly HashSet<List<TermSegment>> _months
           = new HashSet<List<TermSegment>>()
           {
                new List<TermSegment>(){ new TermSegment("january".ToCharArray()), new TermSegment("jan".ToCharArray()), new TermSegment("jan.".ToCharArray()) },
                new List<TermSegment>(){ new TermSegment("february".ToCharArray()),new TermSegment("feb".ToCharArray()),new TermSegment("feb.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("march".ToCharArray()),new TermSegment("mar".ToCharArray()),new TermSegment("mar.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("april".ToCharArray()),new TermSegment("apr".ToCharArray()),new TermSegment("apr.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("may".ToCharArray()),new TermSegment("may".ToCharArray()),new TermSegment("may.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("june".ToCharArray()),new TermSegment("jun".ToCharArray()),new TermSegment("jun.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("july".ToCharArray()),new TermSegment("jul".ToCharArray()),new TermSegment("jul.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("august".ToCharArray()),new TermSegment("aug".ToCharArray()),new TermSegment("aug.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("september".ToCharArray()),new TermSegment("sept".ToCharArray())
                                        ,new TermSegment("sep".ToCharArray()),new TermSegment("sept.".ToCharArray()),new TermSegment("sep.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("october".ToCharArray()),new TermSegment("oct".ToCharArray()),new TermSegment("oct.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("november".ToCharArray()),new TermSegment("nov".ToCharArray()),new TermSegment("nov.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("december".ToCharArray()), new TermSegment("dec".ToCharArray()), new TermSegment("dec.".ToCharArray()) }
           };

        private readonly HashSet<List<TermSegment>> _daysOfWeek
          = new HashSet<List<TermSegment>>()
          {
                new List<TermSegment>(){ new TermSegment("monday".ToCharArray()),new TermSegment("mon.".ToCharArray()),new TermSegment("mo.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("tuesday".ToCharArray()),new TermSegment("tue.".ToCharArray()),new TermSegment("tu.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("wednesday".ToCharArray()),new TermSegment("wed.".ToCharArray()),new TermSegment("we.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("thursday".ToCharArray()),new TermSegment("thu.".ToCharArray()),new TermSegment("th.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("friday".ToCharArray()),new TermSegment("fri.".ToCharArray()),new TermSegment("fr.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("saturday".ToCharArray()),new TermSegment("sat.".ToCharArray()),new TermSegment("sa.".ToCharArray())},
                new List<TermSegment>(){ new TermSegment("sunday".ToCharArray()),new TermSegment("sun.".ToCharArray()),new TermSegment("su.".ToCharArray())}
          };

        private readonly HashSet<List<TermSegment>> _currencies
      = new HashSet<List<TermSegment>>()
      {
            new List<TermSegment>(){ new TermSegment("usd".ToCharArray()),new TermSegment("dollar sign".ToCharArray()),new TermSegment("$".ToCharArray())},
            new List<TermSegment>(){ new TermSegment("Cent".ToCharArray()),new TermSegment("¢".ToCharArray())},
            new List<TermSegment>(){ new TermSegment("Euro".ToCharArray()),new TermSegment("€".ToCharArray())},
            new List<TermSegment>(){ new TermSegment("British Pound".ToCharArray()),new TermSegment("£".ToCharArray())}
      };

        public bool Process(TokenSource source)
        {
            CheckSynonymList(source, _months);
            CheckSynonymList(source, _daysOfWeek);
            CheckSynonymList(source, _currencies);

            return true;
        }

        private void CheckSynonymList(TokenSource source, HashSet<List<TermSegment>> synonymList)
        {
            var synonym = synonymList.Where(x => x.Contains(new TermSegment(source.Buffer, source.Size))).FirstOrDefault();
            if (synonym != null)
            {
                TermSegment term = synonym.FirstOrDefault();
                source.Size = term._buffer.Length;
                for (int i = 0; i < term._buffer.Length; i++)
                    source.Buffer[i] = term._buffer[i];
            }

        }
    }
}
