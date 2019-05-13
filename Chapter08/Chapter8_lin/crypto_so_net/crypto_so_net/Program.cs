using System;
using System.Text;

namespace crypto_dll_net
{
	class Program
	{

		static void Main(string[] args)
		{
			Crypto c = new Crypto();
			string message = "This program uses \"Crypto Engine\" written in Assembly language.";

			c.SetDataPointer(ASCIIEncoding.ASCII.GetBytes(message));
			//c.SetDataLength(message.Length);

			Console.Write(c.PrintBinaryData());
			Console.WriteLine();
			c.Encrypt();
			Console.Write(c.PrintBinaryData());
			Console.WriteLine();
			c.Decrypt();
			Console.Write(c.PrintBinaryData());
			Console.WriteLine();
		}
	}
}
