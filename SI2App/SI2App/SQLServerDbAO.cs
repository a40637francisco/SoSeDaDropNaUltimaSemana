using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class SQLServerDbAO : IDbAO
    {

        public void InsertBid(SqlConnection con, int itemId, float value, int userId)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {

                SqlParameter itemIdPara = new SqlParameter("@iId", SqlDbType.Int);
                itemIdPara.Value = itemId;
                SqlParameter valuePara = new SqlParameter("@value", SqlDbType.Float);
                valuePara.Value = value;
                SqlParameter uIdPara = new SqlParameter("@uId", SqlDbType.Int);
                uIdPara.Value = userId;

                cmd.Parameters.Add(itemIdPara);
                cmd.Parameters.Add(valuePara);
                cmd.Parameters.Add(uIdPara);
                cmd.CommandText = "dbo.insertBid";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.ExecuteNonQuery();
                Console.WriteLine("Bid inserted successfuly");
            }
        }

        public void RemoveBid(SqlConnection con, int bidId)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                SqlParameter bidIdParam = new SqlParameter("@bId", SqlDbType.Int);
                bidIdParam.Value = bidId;
                cmd.Parameters.Add(bidIdParam);
                cmd.CommandText = "dbo.removeBid";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.ExecuteNonQuery();
                Console.WriteLine("Bid removed successfuly");
            }
        }

        public void ConcludeAuction(SqlConnection con, int itemId, int userId, Decimal creadCard, Decimal countryCode, string address)
        {
            ConcludeSale(con, itemId, userId, creadCard, countryCode, address);
        }

        public void BuyItemDirectSale(SqlConnection con, int itemId, int userId, decimal creadCard, decimal countryCode, string address)
        {
            ConcludeSale(con, itemId, userId, creadCard, countryCode, address);
        }

        public void ConcludeSale(SqlConnection con, int itemId, int userId, Decimal creadCard, Decimal countryCode, string address)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                SqlParameter itemIdPara = new SqlParameter("@iId", SqlDbType.Int);
                itemIdPara.Value = itemId;
                SqlParameter uIdPara = new SqlParameter("@uId", SqlDbType.Int);
                uIdPara.Value = userId;
                SqlParameter credCardParam = new SqlParameter("@credCard", SqlDbType.Decimal);
                credCardParam.Value = creadCard;
                SqlParameter addressParam = new SqlParameter("@countryCode", SqlDbType.Text);
                addressParam.Value = address;

                cmd.Parameters.Add(itemIdPara);
                cmd.Parameters.Add(uIdPara);
                cmd.Parameters.Add(credCardParam);
                cmd.Parameters.Add(addressParam);
                cmd.CommandText = "dbo.concludeSale";
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.ExecuteNonQuery();
                Console.WriteLine("Bid inserted successfuly");

            }
        }

        public float GetItemBiddingPrice(SqlConnection con, int itemId)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                SqlParameter itemIdPara = new SqlParameter("@iId", SqlDbType.Int);
                itemIdPara.Value = itemId;

                cmd.Parameters.Add(itemIdPara);
                cmd.CommandText = "dbo.BiddingPrice";
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter returnValue = cmd.Parameters.Add("@RETURN_VALUE", SqlDbType.Float);
                returnValue.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();
                return (float)returnValue.Value;

            }
        }

        public IEnumerable<Bid> LastNBids(SqlConnection con, int numberOfBids)
        {
            List<Bid> lastNBids = new List<Bid>();
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.Parameters.AddWithValue("@n", numberOfBids);
                cmd.CommandText = "dbo.LastNBids";
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    Bid bid = new Bid();
                    bid.bidId = reader.GetInt32(0);
                    bid.bidItemId = reader.GetInt32(1);
                    bid.bidDate = reader.GetDateTime(2);
                    bid.bidValue = reader.GetDouble(3);
                    bid.bidAlive = reader.GetInt32(4);
                    lastNBids.Add(bid);
                }
            }

            return lastNBids;
        }

        public IEnumerable<Auction> NotConcludedAuction(SqlConnection con)
        {
            List<Auction> notConcludedAuctions = new List<Auction>();
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText = "dbo.NotConcludedAuction";
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    Auction auction = new Auction();
                    auction.itemId = reader.GetInt32(0);
                    auction.saleDesc = reader.GetString(1);
                    auction.minBid = reader.GetDouble(2);
                    auction.date = reader.GetDateTime(3);
                    auction.endDate = reader.GetDateTime(4);
                    notConcludedAuctions.Add(auction);
                }
            }

            return notConcludedAuctions;

        }

        public double GetShippingPrice(SqlConnection con, Decimal toCode, Decimal fromCode)
        {

            using (SqlCommand cmd = con.CreateCommand())
            {
                SqlParameter toCodeParam = new SqlParameter("@to", SqlDbType.Decimal);
                toCodeParam.Value = toCode;
                SqlParameter fromCodeParam = new SqlParameter("@from", SqlDbType.Decimal);
                fromCodeParam.Value = fromCode;

                cmd.Parameters.Add(toCodeParam);
                cmd.Parameters.Add(fromCodeParam);
                cmd.CommandText = "dbo.ShippingPrice";
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter returnValue = cmd.Parameters.Add("@RETURN_VALUE", SqlDbType.Float);
                returnValue.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();
                return (double)returnValue.Value;

            }
        }

        public void CheckPassword(SqlConnection con, int userId, string pw)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                SqlParameter uIdPara = new SqlParameter("@uId", SqlDbType.Int);
                uIdPara.Value = userId;
                SqlParameter pwPara = new SqlParameter("@pw", SqlDbType.VarChar, 255);
                pwPara.Value = pw;

                cmd.Parameters.Add(uIdPara);
                cmd.Parameters.Add(pwPara);
                cmd.CommandText = "dbo.checkPassword";
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter returnValue = cmd.Parameters.Add("@RETURN_VALUE", SqlDbType.Bit);
                returnValue.Direction = ParameterDirection.ReturnValue;

                cmd.ExecuteNonQuery();
                string msg = returnValue.Value.ToString().Equals("True") ? "Correct password" : "Incorrect password";
                Console.WriteLine(msg);
            }
        }


    }
}
