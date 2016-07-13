using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class AuctionInfo
    {
        public string id { get; internal set; }
        public string initialDate { get; internal set; }
        public string minimumBid { get; internal set; }
        public string reservationPrice { get; internal set; }
    }
}
