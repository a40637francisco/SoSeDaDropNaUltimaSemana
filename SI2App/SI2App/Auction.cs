using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class Auction
    {
        public DateTime date { get; internal set; }
        public DateTime endDate { get; internal set; }
        public int itemId { get; internal set; }
        public double minBid { get; internal set; }
        public string saleDesc { get; internal set; }
    }
}
