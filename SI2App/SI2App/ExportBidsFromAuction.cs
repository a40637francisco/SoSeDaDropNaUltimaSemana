using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class ExportBidsFromAuction
    {

        public AuctionInfo auctionInfo;
        public IEnumerable<Bid> bids;

        public ExportBidsFromAuction(SqlConnection con, int itemId)
        {
            auctionInfo = getAuctionInfo(con, itemId);
            bids = getBidsFromAuction(con, itemId);
        }


        private IEnumerable<Bid> getBidsFromAuction(SqlConnection con, int itemId)
        {
            List<Bid> lastNBids = new List<Bid>();
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.Parameters.AddWithValue("@iId", itemId);
                cmd.CommandText = "dbo.BidsInfoFromConcludedAuction";
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    Bid bid = new Bid();
                    bid.bidUserId = reader.GetInt32(0).ToString();
                    bid.bidDate = reader.GetDateTime(1);
                    lastNBids.Add(bid);
                }
            }

            return lastNBids;
        }


        private AuctionInfo getAuctionInfo(SqlConnection con, int itemId)
        {
            AuctionInfo info = new AuctionInfo();
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.Parameters.AddWithValue("@iId", itemId);
                cmd.CommandText = "dbo.AuctionInfoFromConcludedAuction";
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    info.id = reader.GetInt32(0).ToString();
                    info.minimumBid = reader.GetDouble(1).ToString();
                    info.initialDate = reader.GetDateTime(2).ToString();
                    info.reservationPrice = reader.GetDouble(3).ToString();
                }
                reader.Close();
            }
            return info;
        }

    }
}
