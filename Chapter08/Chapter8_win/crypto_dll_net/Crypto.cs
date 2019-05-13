using System;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Reflection;

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
        byte[] data;

        internal byte[] Data => data;
        internal int Length => data.Length;

#if WIN64
        [DllImport("crypto_w64.dll", CallingConvention = CallingConvention.Cdecl)]
#else
        [DllImport("crypto_w32.dll", CallingConvention = CallingConvention.Cdecl)]
#endif
        internal static extern IntPtr GetPointers();

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern bool SetDllDirectory(string lpNewPath);

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
            string dllPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            //SetDllDirectory(dllPath);
            functions = (Funcs)Marshal.PtrToStructure(GetPointers(), typeof(Funcs));
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
            (Marshal.GetDelegateForFunctionPointer<dSetDataPointer>(functions.f_set_data_pointer))(buffer);
            (Marshal.GetDelegateForFunctionPointer<dSetDataSize>(functions.f_set_data_length))(p.Length);
        }

        internal void Encrypt()
        {
            (Marshal.GetDelegateForFunctionPointer<dEncrypt>(functions.f_encrypt))();
            Marshal.Copy(buffer, data, 0, data.Length);
        }

        internal void Decrypt()
        {
            (Marshal.GetDelegateForFunctionPointer<dDecrypt>(functions.f_decrypt))();
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
