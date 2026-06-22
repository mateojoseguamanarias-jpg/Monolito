using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using SimpleCrypto;

namespace Capa_Datos
{
    public static class SecurityHelper
    {
        private static readonly byte[] Key = Encoding.UTF8.GetBytes("N0v4X_S3cur1ty_P"); // 16 bytes
        private static readonly byte[] IV = Encoding.UTF8.GetBytes("7f77dd_00f2ff_S2"); // 16 bytes

        public static string GenerateFullHash(string otp)
        {
            var crypto = new PBKDF2();
            string salt = crypto.GenerateSalt();
            string hash = crypto.Compute(otp, salt);
            return hash + "|" + salt;
        }

        public static bool VerifyFullHash(string plainOtp, string storedValue)
        {
            if (string.IsNullOrEmpty(storedValue) || !storedValue.Contains("|")) return false;
            string[] parts = storedValue.Split('|');
            var crypto = new PBKDF2();
            return crypto.Compute(plainOtp, parts[1]) == parts[0];
        }

        public static string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return "";
            using (Aes aes = Aes.Create())
            {
                aes.Key = Key;
                aes.IV = IV;
                ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor, CryptoStreamMode.Write))
                    {
                        using (StreamWriter sw = new StreamWriter(cs))
                        {
                            sw.Write(plainText);
                        }
                        return Convert.ToBase64String(ms.ToArray());
                    }
                }
            }
        }

        public static string Decrypt(string cipherText)
        {
            if (string.IsNullOrEmpty(cipherText)) return null;
            try
            {
                using (Aes aes = Aes.Create())
                {
                    aes.Key = Key;
                    aes.IV = IV;
                    ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
                    using (MemoryStream ms = new MemoryStream(Convert.FromBase64String(cipherText)))
                    {
                        using (CryptoStream cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
                        {
                            using (StreamReader sr = new StreamReader(cs))
                            {
                                return sr.ReadToEnd();
                            }
                        }
                    }
                }
            }
            catch { return null; }
        }
    }
}
