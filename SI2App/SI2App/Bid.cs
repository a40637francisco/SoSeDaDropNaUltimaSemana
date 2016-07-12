using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class Bid
    {
        public int bidAlive { get; internal set; }
        public DateTime bidDate { get; internal set; }
        public int bidId { get; internal set; }
        public int bidItemId { get; internal set; }
        public double bidValue { get; internal set; }
    }
}
