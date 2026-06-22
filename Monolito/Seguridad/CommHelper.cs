using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;
using QRCoder;
using System.Net.Mail;
using System.Threading.Tasks;
using Capa_Datos;


namespace Monolito.Seguridad
{
    public static class CommHelper
    {
        private const string SMTP_HOST = "smtp.gmail.com";
        private const int SMTP_PORT = 587;
        private const string SMTP_USER = "mateo.mishel12@gmail.com";
        private const string SMTP_PASS = "kjqp rquj actu qdso";
        
        private const string ULTRA_INSTANCE = "instance175254"; 
        private const string ULTRA_TOKEN    = "8fdum3u64rir43bw";

        public static byte[] GenerarQR(string contenido)
        {
            // Encriptamos el contenido para que no sea legible por escáneres genéricos
            string contenidoEncriptado = SecurityHelper.Encrypt(contenido);

            using (var gen = new QRCodeGenerator())
            using (var data = gen.CreateQrCode(contenidoEncriptado, QRCodeGenerator.ECCLevel.M))
            using (var qr = new QRCode(data))
            // Usamos 15 de resolución y habilitamos el QuietZone (borde blanco) para que escanee bien
            using (var bmp = qr.GetGraphic(15, Color.Black, Color.White, true))
            using (var ms = new MemoryStream())
            {
                bmp.Save(ms, ImageFormat.Png);
                return ms.ToArray();
            }
        }

        // --- MÉTODOS DE WHATSAPP (RESTAURADOS PARA COMPATIBILIDAD) ---

        public static bool EnviarWhatsApp(string celular, string mensaje)
        {
            EnviarWhatsAppAsync(celular, mensaje);
            return true;
        }

        public static bool EnviarWhatsAppTwilio(string celular, string mensaje)
        {
            EnviarWhatsAppAsync(celular, mensaje);
            return true;
        }

        public static bool EnviarWhatsAppUltraMsg(string celular, string mensaje)
        {
            EnviarWhatsAppAsync(celular, mensaje);
            return true;
        }

        public static string GenerarLinkWhatsApp(string celular, string mensaje)
        {
            string num = FormatearNumero(celular);
            return $"https://api.whatsapp.com/send?phone={num}&text={Uri.EscapeDataString(mensaje)}";
        }

        // MOTOR ASÍNCRONO (EL QUE DA LA VELOCIDAD)
        private static void EnviarWhatsAppAsync(string celular, string mensaje)
        {
            // Lo hacemos sincronico para asegurar que el IIS no mate el proceso antes de enviar
            try {
                string num = FormatearNumero(celular);
                if (string.IsNullOrEmpty(num)) return;
                
                // Aseguramos el signo + que pide UltraMsg
                if (!num.StartsWith("+")) num = "+" + num;

                string url = $"https://api.ultramsg.com/{ULTRA_INSTANCE}/messages/chat";
                using (var client = new WebClient()) {
                    client.Encoding = System.Text.Encoding.UTF8; // Para que salgan bien los emojis
                    var data = new System.Collections.Specialized.NameValueCollection();
                    data["token"] = ULTRA_TOKEN;
                    data["to"] = num;
                    data["body"] = mensaje;
                    client.UploadValues(url, "POST", data);
                }
            } catch { }
        }

        private static string FormatearNumero(string celular)
        {
            string num = "";
            if (string.IsNullOrEmpty(celular)) return "";
            foreach (char c in celular) if (char.IsDigit(c)) num += c;
            if (num.Length == 10 && num.StartsWith("0")) num = "593" + num.Substring(1);
            else if (num.Length == 9) num = "593" + num;
            return num;
        }

        // --- CORREOS (SINCRONICOS PARA ESTABILIDAD) ---
        public static void EnviarCorreoOTP(string destino, string nombre, byte[] qrBytes)
        {
            try {
                using (var client = new SmtpClient(SMTP_HOST, SMTP_PORT)) {
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(SMTP_USER, SMTP_PASS);
                    client.EnableSsl = true;
                    using (var msg = new MailMessage()) {
                        msg.From = new MailAddress(SMTP_USER, "NovaX Security");
                        msg.Subject = "🔐 Código de Acceso NovaX";
                        msg.IsBodyHtml = true;
                        msg.To.Add(destino);
                        string html = $@"
                            <div style='background:#07071a; padding:40px; color:#fff; text-align:center; font-family:sans-serif;'>
                                <h1 style='color:#7F77DD;'>NovaX Security</h1>
                                <p>Tu código de acceso seguro ha sido generado.</p>
                                <div style='background:#ffffff; padding:15px; display:inline-block; border-radius:10px;'>
                                    <img src='cid:qr_otp' width='200' height='200' style='display:block;' />
                                </div>
                                <p style='font-size:12px; opacity:0.6; margin-top:20px;'>NovaX Protocol - Módulo de Seguridad</p>
                            </div>";
                        
                        var view = AlternateView.CreateAlternateViewFromString(html, null, "text/html");
                        
                        MemoryStream ms = new MemoryStream(qrBytes);
                        LinkedResource lr = new LinkedResource(ms, "image/png");
                        lr.ContentId = "qr_otp";
                        lr.TransferEncoding = System.Net.Mime.TransferEncoding.Base64;
                        
                        view.LinkedResources.Add(lr);
                        msg.AlternateViews.Add(view);
                        
                        client.Send(msg);
                        
                        // Cerramos después de enviar
                        ms.Close(); ms.Dispose();
                    }
                }
            } catch { }
        }

        public static void EnviarCorreoRecuperacion(string destino, string nombre, string claveTemporal)
        {
            try {
                using (var client = new SmtpClient(SMTP_HOST, SMTP_PORT)) {
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(SMTP_USER, SMTP_PASS);
                    client.EnableSsl = true;
                    using (var msg = new MailMessage()) {
                        msg.From = new MailAddress(SMTP_USER, "NovaX Security");
                        msg.Subject = "🔑 Recuperación de Contraseña";
                        msg.IsBodyHtml = true;
                        msg.To.Add(destino);
                        msg.Body = $"Hola {nombre}, tu clave temporal es: <b>{claveTemporal}</b>";
                        client.Send(msg);
                    }
                }
            } catch { }
        }

        public static void EnviarCorreoBienvenida(string destino, string nombre, string nick, int id, byte[] qrBytes)
        {
            try {
                using (var client = new SmtpClient(SMTP_HOST, SMTP_PORT)) {
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(SMTP_USER, SMTP_PASS);
                    client.EnableSsl = true;
                    using (var msg = new MailMessage()) {
                        msg.From = new MailAddress(SMTP_USER, "NovaX Pro");
                        msg.Subject = $"✨ Bienvenido a NovaX - Usuario {nick}";
                        msg.IsBodyHtml = true;
                        msg.To.Add(destino);
                        string html = $@"
                            <div style='background:#07071a; padding:40px; color:#fff; text-align:center; font-family:sans-serif;'>
                                <h1 style='color:#7F77DD;'>Bienvenido a NovaX</h1>
                                <p>Hola <b>{nombre}</b> (@{nick}), tu cuenta ha sido activada en NovaX Pro.</p>
                                <div style='background:#ffffff; padding:15px; display:inline-block; border-radius:10px; margin:20px 0;'>
                                    <img src='cid:qr_welcome' width='200' height='200' style='display:block;' />
                                </div>
                                <p>Escanea este código en la aplicación para vincular tu dispositivo.</p>
                                <p style='font-size:12px; opacity:0.6;'>ID de Usuario: {id}</p>
                            </div>";

                        var view = AlternateView.CreateAlternateViewFromString(html, null, "text/html");
                        
                        MemoryStream ms = new MemoryStream(qrBytes);
                        LinkedResource lr = new LinkedResource(ms, "image/png");
                        lr.ContentId = "qr_welcome";
                        lr.TransferEncoding = System.Net.Mime.TransferEncoding.Base64;
                        
                        view.LinkedResources.Add(lr);
                        msg.AlternateViews.Add(view);
                        
                        client.Send(msg);
                        
                        ms.Close(); ms.Dispose();
                    }
                }
            } catch { }
        }
    }
}
