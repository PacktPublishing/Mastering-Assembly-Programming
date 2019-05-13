using System;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Reflection;
using System.Collections.Generic;

namespace crypto_dll_net
{
	[StructLayout(LayoutKind.Sequential,Pack =1)]
	internal struct Funcs
	{
		internal IntPtr f_set_data_pointer;
		internal IntPtr f_set_data_length;
		internal IntPtr f_encrypt;
		internal IntPtr f_decrypt;
	}

	internal class Crypto
	{
		Funcs functions;
		IntPtr buffer;
		//int len;
		byte[] data;

		//internal byte[] Data => data;
		//internal int Length => len;
		internal byte[] Data { get { return data; } }
		internal int Length{ get { return data.Length; } }

		[DllImport("crypto_64.so", CallingConvention = CallingConvention.Cdecl)]
		internal static extern IntPtr GetPointers();


		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		internal delegate void dSetDataPointer(IntPtr p);

		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		internal delegate void dSetDataSize(int s);

		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		internal delegate void dEncrypt();

		[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
		internal delegate void dDecrypt();

		internal Crypto()
		{
				functions = (Funcs)Marshal.PtrToStructure (GetPointers (), typeof(Funcs));
				buffer = IntPtr.Zero;
		}

		internal void SetDataPointer(byte[] p)
		{
			if (IntPtr.Zero != buffer)
				Marshal.FreeHGlobal(buffer);
			data = new byte[p.Length];
			buffer = Marshal.AllocHGlobal(p.Length);
			Array.Copy(p, data, p.Length);
			Marshal.Copy(p, 0, buffer, p.Length);
			//dSetDataPointer func = (dSetDataPointer) Marshal.GetDelegateForFunctionPointer(functions.f_set_data_pointer,typeof( dSetDataPointer));
			//func(buffer);
			((dSetDataPointer)Marshal.GetDelegateForFunctionPointer (functions.f_set_data_pointer, typeof(dSetDataPointer))) (buffer);

			//dSetDataSize func1 = (dSetDataSize)Marshal.GetDelegateForFunctionPointer(functions.f_set_data_length, typeof(dSetDataSize));
			//func1(p.Length);
			((dSetDataSize)Marshal.GetDelegateForFunctionPointer (functions.f_set_data_length, typeof(dSetDataSize))) (p.Length);
		}
		/*
		internal void SetDataLength(int l)
		{
			len = l;
			dSetDataSize func = (dSetDataSize)Marshal.GetDelegateForFunctionPointer(functions.f_set_data_length, typeof(dSetDataSize));
			func(l);
		}
		*/

		internal void Encrypt()
		{
			//dEncrypt func = (dEncrypt)Marshal.GetDelegateForFunctionPointer(functions.f_encrypt, typeof(dEncrypt));
			//func();
			((dEncrypt)Marshal.GetDelegateForFunctionPointer (functions.f_encrypt, typeof(dEncrypt))) ();
			Marshal.Copy(buffer, data, 0, data.Length);
		}

		internal void Decrypt()
		{
			//dDecrypt func =(dDecrypt) Marshal.GetDelegateForFunctionPointer(functions.f_decrypt, typeof(dDecrypt));
			//func();
			((dDecrypt)Marshal.GetDelegateForFunctionPointer (functions.f_decrypt, typeof(dDecrypt))) ();
			Marshal.Copy(buffer, data, 0, data.Length);
		}

		internal string PrintBinaryData()
		{
			string result = "";
			int i, j;

			for (i = 0; i < data.Length; i += 16)
			{
				for(j=0;j<16;j++)
				{
					if(i+j<data.Length)
					{
						result += data[i + j].ToString("x2") + " ";
					}
					else
					{
						result += "   ";
					}
				}

				result += "     ";

				for (j = 0; j < 16; j++)
				{
					if (i + j < data.Length)
					{
						result += ASCIIEncoding.ASCII.GetChars(data, i+j,1)[0];
					}
					else
					{
						result += " ";
					}
				}
				result += "\r\n";
			}
			return result;
		}
	}
}

