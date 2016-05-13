using System;
using System.Data.SqlClient;


namespace SI2App
{
    class Program
    {


        static void Main(string[] args)
        {
            int userId = -1;
            int itemId = -1;
            float value = -1;

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
                                itemId = Parameter.GetIntParameter("item Id");
                                value = Parameter.GetFloatParameter("value");
                                userId = Parameter.GetIntParameter("user Id");                        
                                
                                dbLink = new SQLServerDbAO();
                                dbLink.InsertBid(con, itemId, value, userId);
                                break;
                            case "2":
                                userId = Parameter.GetIntParameter("user Id");
                                string pw = Parameter.GetStringParameter("password ");
                                dbLink = new SQLServerDbAO();
                                dbLink.CheckPassword(con, userId, pw);
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
            Console.WriteLine("Type '2' to CheckPassword - [userId, password]");
            Console.WriteLine("Type 'end' to terminate app");
        }

        /*
        private void bla()
        {

            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = "Database=SI2_Tests;Data Source=localhost;Integrated Security=SSPI";
                con.Open();
                Console.WriteLine(con.State.ToString());
                SqlCommand cmd = con.CreateCommand();
                cmd.CommandText = "select * from Person";
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        Console.Write(dr.GetInt32(0) + " ");
                        Console.Write(dr.GetString(1) + " ");
                        Console.Write(dr.GetInt32(2) + " ");

                    }
                }
            }
            Console.WriteLine();
        }
        */
    }
   


}
