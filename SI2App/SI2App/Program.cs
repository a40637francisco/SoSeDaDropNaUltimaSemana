using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;

namespace SI2App
{
    class Program
    {


        static void Main(string[] args)
        {
            int userId = -1;
            int itemId = -1;
            float value = -1;
            int bidId = -1;
            Decimal credCard;
            string address;
            Decimal countryCode;
            Decimal toCode, fromCode;

            Boolean terminator = true;
            string line;

            IDbAO dbLink;

            Help();

            while (terminator)
            {
                Console.WriteLine("\nWrite command:");
                line = Console.ReadLine();

                using (SqlConnection con = new SqlConnection())
                {
                    try
                    {
                        con.ConnectionString = "Database=SI2;Data Source=localhost;Integrated Security=SSPI";
                        con.Open();
                        switch (line)
                        {
                            case "1":
                                itemId = Parameter.GetIntParameter("Item Id");
                                value = Parameter.GetFloatParameter("Value");
                                userId = Parameter.GetIntParameter("User Id");
                                dbLink = new SQLServerDbAO();
                                dbLink.InsertBid(con, itemId, value, userId);
                                break;
                            case "2":
                                bidId = Parameter.GetIntParameter("Bid id");
                                dbLink = new SQLServerDbAO();
                                dbLink.RemoveBid(con, bidId);
                                break;
                            case "3":
                                bidId = Parameter.GetIntParameter("Item id");
                                userId = Parameter.GetIntParameter("User id");
                                credCard = Parameter.GetDecimalParameter("Credit card");
                                countryCode = Parameter.GetDecimalParameter("Country code");
                                address = Parameter.GetStringParameter("Address");
                                dbLink = new SQLServerDbAO();
                                dbLink.ConcludeAuction(con, itemId, userId, credCard, countryCode, address);
                                break;
                            case "4":
                                bidId = Parameter.GetIntParameter("Item id");
                                userId = Parameter.GetIntParameter("User id");
                                credCard = Parameter.GetDecimalParameter("Credit card");
                                countryCode = Parameter.GetDecimalParameter("Country code");
                                address = Parameter.GetStringParameter("Address");
                                dbLink = new SQLServerDbAO();
                                dbLink.BuyItemDirectSale(con, itemId, userId, credCard, countryCode, address);
                                break;
                            case "5":
                                itemId = Parameter.GetIntParameter("Item id");
                                dbLink = new SQLServerDbAO();
                                double price = dbLink.GetItemBiddingPrice(con, itemId);
                                Console.WriteLine("Price = " + price);
                                break;
                            case "6":
                                int n = Parameter.GetIntParameter("Number of bids");
                                dbLink = new SQLServerDbAO();
                                ConsoleFormatBidPrint(dbLink.LastNBids(con, n));
                                break;
                            case "7":
                                toCode = Parameter.GetDecimalParameter("to location code");
                                fromCode = Parameter.GetDecimalParameter("from location code");
                                dbLink = new SQLServerDbAO();
                                double shipPrice = dbLink.GetShippingPrice(con, toCode, fromCode);
                                Console.WriteLine("Price = " + shipPrice);
                                break;
                            case "8":
                                dbLink = new SQLServerDbAO();
                                ConsoleFormatAuctionPrint(dbLink.NotConcludedAuction(con));
                                break;
                            case "9":
                                userId = Parameter.GetIntParameter("user Id");
                                string pw = Parameter.GetStringParameter("password ");
                                dbLink = new SQLServerDbAO();
                                dbLink.CheckPassword(con, userId, pw);
                                break;
                            case "10":
                                itemId = Parameter.GetIntParameter("item id");
                                string fileName = Parameter.GetStringParameter("file name");
                                GetNotConcludedAuctionInfo(con, itemId, fileName);
                                Console.WriteLine("Finished writing file");
                                break;
                            case "end":
                                Console.WriteLine("\nTerminating application");
                                terminator = false;
                                break;
                            default:
                                Help();
                                break;

                        }
                        con.Close();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message + "\n");
                        Help();
                    }

                }

            }
            Console.WriteLine("Press 'Enter' to exit");
            Console.ReadLine();


        }

        private static void Help()
        {
            Console.WriteLine("Type '1' to InsertBid - [itemId, value, userId]");
            Console.WriteLine("Type '2' to RemoveBid - [bidId]");
            Console.WriteLine("Type '3' to Conclude Auction - [itemId, userId, credCard, countryCode, adress ]");
            Console.WriteLine("Type '4' to Buy Item Direct Sale - [itemId, userId, credCard, countryCode, adress ]");
            Console.WriteLine("Type '5' to Get Item Bidding Price - [itemId]");
            Console.WriteLine("Type '6' to Get last N bids - [N]");
            Console.WriteLine("Type '7' to Get shipping price between 2 locations - [toCode, fromCode]");
            Console.WriteLine("Type '8' to Get not concluded Auctions - []");
            Console.WriteLine("Type '9' to CheckPassword - [userId, password]");
            Console.WriteLine("Type '10' to Get cloced auction info - [itemId, fileName]");
            Console.WriteLine("Type 'end' to terminate app");
        }


        private static void ConsoleFormatAuctionPrint(IEnumerable<Auction> l)
        {
            if (!l.Any())
            {
                Console.WriteLine("No results to print");
            }
            foreach (Auction b in l)
            {
                Console.WriteLine("Auction: " + b.itemId + " | "
                    + b.saleDesc + " | "
                    + b.minBid + " | "
                    + b.date + " | "
                    + b.endDate
                    );
            }

        }

        private static void ConsoleFormatBidPrint(IEnumerable<Bid> l)
        {
            if (!l.Any())
            {
                Console.WriteLine("No results to print");
            }

            foreach (Bid b in l)
            {
                Console.WriteLine("Bid: " + b.bidId + " | "
                    + b.bidItemId + " | "
                    + b.bidValue + " | "
                    + b.bidDate + " | "
                    + b.bidAlive
                    );
            }
        }

        private static void GetNotConcludedAuctionInfo(SqlConnection con, int itemId, string fileName)
        {
            XmlTextWriter writer = new XmlTextWriter(fileName, new UTF8Encoding());
            writer.Formatting = Formatting.Indented;
            ExportBidsFromAuction auction =  new ExportBidsFromAuction(con, itemId);
            writer.WriteStartDocument();


            if (auction != null)
            {
                writer.WriteStartElement("auction");
                writer.WriteAttributeString("id", auction.auctionInfo.id);

                    writer.WriteStartElement("info");
                        writer.WriteElementString("minimumBid", auction.auctionInfo.minimumBid);
                        writer.WriteElementString("reservationPrice", auction.auctionInfo.reservationPrice);
                        writer.WriteElementString("initialDate", auction.auctionInfo.initialDate);
                    writer.WriteEndElement();

                    if(auction.bids.Any())
                    {
                    writer.WriteStartElement("bids");
                    writer.WriteAttributeString("num", auction.bids.Count().ToString());
                    foreach (Bid b in auction.bids)
                        {
                            writer.WriteStartElement("bid");                          
                            writer.WriteAttributeString("userId", b.bidUserId);
                            writer.WriteAttributeString("datetime", b.bidDate.ToString());
                            writer.WriteEndElement();
                        }                   
                    writer.WriteEndElement();               
                    }
                writer.WriteEndElement();
            }
            else
            {
                Console.WriteLine("File created is empty"); 
            }
            writer.WriteEndDocument();
            writer.Flush();
            writer.Close();
        }

    }



}
