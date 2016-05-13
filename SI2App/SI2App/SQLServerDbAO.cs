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


        public void CheckPassword(SqlConnection con, int userId, string pw)
        {
            SqlParameter uIdPara = new SqlParameter("@uId", SqlDbType.Int);
            uIdPara.Value = userId;
            SqlParameter pwPara = new SqlParameter("@pw", SqlDbType.VarChar, 255);
            pwPara.Value = pw;

            SqlCommand cmd = con.CreateCommand();
            cmd.Parameters.Add(uIdPara);
            cmd.Parameters.Add(pwPara);
            cmd.CommandText = "dbo.checkPassword";
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter returnValue = cmd.Parameters.Add("@RETURN_VALUE", SqlDbType.Bit);
            returnValue.Direction = ParameterDirection.ReturnValue;

            cmd.ExecuteNonQuery();
            string msg = returnValue.Value.ToString().Equals("True")  ? "Correct password" : "Incorrect password";
            Console.WriteLine(msg);
        }


        public void InsertBid(SqlConnection con, int itemId, float value, int userId)
        {

            SqlParameter itemIdPara = new SqlParameter("@iId", SqlDbType.Int);
            itemIdPara.Value = itemId;
            SqlParameter valuePara = new SqlParameter("@value", SqlDbType.Float);
            valuePara.Value = value;
            SqlParameter uIdPara = new SqlParameter("@uId",SqlDbType.Int);
            uIdPara.Value = userId;

            SqlCommand cmd = con.CreateCommand();
            cmd.Parameters.Add(itemIdPara);   
            cmd.Parameters.Add(valuePara);
            cmd.Parameters.Add(uIdPara);
            cmd.CommandText = "dbo.insertBid";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.ExecuteNonQuery();

            Console.WriteLine("Bid inserted successfuly");
        }

    }
}
