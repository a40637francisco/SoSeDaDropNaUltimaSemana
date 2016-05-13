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

        void CheckPassword(SqlConnection con, int userId, string pw);

    }
}
