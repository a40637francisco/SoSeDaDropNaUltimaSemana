using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SI2App
{
    class Parameter
    {


        public static int GetIntParameter(string msg)
        {
            Console.WriteLine(msg);
            string line = Console.ReadLine();
            int num;
            bool parsed = Int32.TryParse(line, out num);

            if (!parsed)
            {
                // todo throw exception
                Console.WriteLine("Int32.TryParse could not parse '{0}' to an int.\n", line);
                return -1;
            }
                
            return num;

        }

        public static string GetStringParameter(string msg)
        {
            Console.WriteLine(msg);
            return Console.ReadLine();
        }

        public static float GetFloatParameter(string msg)
        {
            Console.WriteLine(msg);
            string line = Console.ReadLine();
            float num;
            bool parsed = float.TryParse(line, out num);

            if (!parsed)
            {
                // todo throw exception
                Console.WriteLine("float.TryParse could not parse '{0}' to an float.\n", line);
                return -1;
            }

            return num;
        }

    }
}
