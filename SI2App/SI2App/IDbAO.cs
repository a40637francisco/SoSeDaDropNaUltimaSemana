using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    interface IDbAO
    {

        void InsertBid(SqlConnection con, int itemId, float value, int userId);

        void RemoveBid(SqlConnection con, int bidId);

        void ConcludeAuction(SqlConnection con, int itemId, int userId, Decimal creadCard, Decimal countryCode, string address);

        void BuyItemDirectSale(SqlConnection con, int itemId, int userId, Decimal creadCard, Decimal countryCode, string address);

        double GetItemBiddingPrice(SqlConnection con, int itemId);

        IEnumerable<Bid> LastNBids(SqlConnection con, int numberOfBids);

        double GetShippingPrice(SqlConnection con, Decimal toCode, Decimal fromCode);

        IEnumerable<Auction> NotConcludedAuction(SqlConnection con);

        void CheckPassword(SqlConnection con, int userId, string pw);



    }
}
