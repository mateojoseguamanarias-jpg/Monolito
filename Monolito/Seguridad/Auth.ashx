<%@ WebHandler Language="C#" Class="Monolito.Seguridad.Auth" %>
using System;
using System.Web;
using System.Web.SessionState;
using System.Web.Script.Serialization;
using Capa_Negocio;
using Capa_Datos;
using System.IO;
using System.Collections.Generic;

namespace Monolito.Seguridad
{
    public class Auth : IHttpHandler, IRequiresSessionState
    {
        private JavaScriptSerializer js = new JavaScriptSerializer();

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            try
            {
                // LEEMOS LA ACCION CON PRIORIDAD
                string action = context.Request.QueryString["action"];
                
                Dictionary<string, object> data = null;
                if (context.Request.InputStream.Length > 0)
                {
                    using (var reader = new StreamReader(context.Request.InputStream))
                    {
                        string body = reader.ReadToEnd();
                        try { data = js.Deserialize<Dictionary<string, object>>(body); } catch { }
                        if (string.IsNullOrEmpty(action) && data != null && data.ContainsKey("action"))
                            action = data["action"].ToString();
                    }
                }

                // SI SIGUE VACIA, BUSCAMOS EN EL FORM
                if (string.IsNullOrEmpty(action)) action = context.Request.Form["action"];

                if (string.IsNullOrEmpty(action)) { Enviar(context, "ERROR: No se especificó acción en URL ni en BODY."); return; }

                switch (action.ToLower())
                {
                    case "autenticar":
                    case "login": LoginNormal(context, data); break;
                    case "autenticarqr":
                    case "loginqr": LoginQR(context, data); break;
                    case "validarotp": ValidarOTP(context, data); break;
                    case "recuperarpass": RecuperarPass(context, data); break;
                    case "autenticargoogle": AutenticarGoogle(context, data); break;
                    case "autenticarfacebook": AutenticarFacebook(context, data); break;
                    case "confirmarcambio": ConfirmarCambio(context, data); break;
                    case "validarkeytemporal": ValidarKeyTemporal(context, data); break;
                    case "logout": Logout(context); break;
                    default: Enviar(context, "ERROR: Acción '" + action + "' no reconocida."); break;
                }
            }
            catch (Exception ex)
            {
                Enviar(context, "ERROR CRITICO: " + ex.Message + " | " + ex.StackTrace);
            }
        }

        private void LoginNormal(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string email = GetVal(data, context, "email");
                string pass = GetVal(data, context, "pass");
                
                Usuario user = CN_Usuario.ValidarLogin(email, pass);
                if (user != null)
                {
                    IniciarFlujoOTP(context, user);
                }
                else Enviar(context, "ERROR: Credenciales incorrectas.");
            } catch (Exception ex) { Enviar(context, "ERROR LOGIN: " + ex.Message); }
        }

        private void LoginQR(HttpContext context, Dictionary<string, object> data)
        {
          
            try {
                string qrOriginal = (GetVal(data, context, "qrData") ?? GetVal(data, context, "qr") ?? "").Trim();
                if (string.IsNullOrEmpty(qrOriginal)) { Enviar(context, "ERROR: No hay datos."); return; }

                
                // Si falla la desencriptación (null), usamos el original por compatibilidad
                string qr = SecurityHelper.Decrypt(qrOriginal) ?? qrOriginal;

                // --- 1. ¿Es el segundo codigo (OTP)? ---
                if (context.Session["TempUser"] != null)
                {
                    Usuario userTemp = (Usuario)context.Session["TempUser"];
                    bool esOtp = (qr == userTemp.usu_otp_hash) || 
                                 (!string.IsNullOrEmpty(userTemp.usu_otp_hash) && userTemp.usu_otp_hash.Contains("|") && SecurityHelper.VerifyFullHash(qr, userTemp.usu_otp_hash));

                    if (esOtp)
                    {
                        LoginExitoso(context, userTemp);
                        return;
                    }
                }

                // --- 2. ¿Es el primer codigo (Registro)? ---
                Usuario user = new CD_Usuario().LoginPorQrCodigo(qr);
                if (user != null)
                {
                    // Si es el QR de registro, disparamos el envio del OTP para el segundo paso
                    IniciarFlujoOTP(context, user);
                }
                else 
                {
                    Enviar(context, "ERROR: Codigo no reconocido o expirado.");
                }
            } catch (Exception ex) { Enviar(context, "ERROR QR: " + ex.Message); }
        }

        private void ValidarOTP(HttpContext context, Dictionary<string, object> data)
        {
            System.Diagnostics.Debugger.Break(); // PUNTO DE QUIEBRE: Validación de OTP manual
            if (context.Session["TempUser"] == null) { Enviar(context, "ERROR: Sesion expirada."); return; }
            Usuario user = (Usuario)context.Session["TempUser"];
            string codigo = GetVal(data, context, "otp");
            
            // Validamos contra el codigo directo o contra el hash
            bool esValido = (codigo == user.usu_otp_hash) || 
                            (!string.IsNullOrEmpty(user.usu_otp_hash) && user.usu_otp_hash.Contains("|") && SecurityHelper.VerifyFullHash(codigo, user.usu_otp_hash));

            if (esValido) LoginExitoso(context, user);
            else Enviar(context, "ERROR: Codigo OTP incorrecto.");
        }

        private void RecuperarPass(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string email = GetVal(data, context, "email");
                Usuario user = CN_Usuario.ObtenerUsuarioPorEmail(email);
                if (user != null) {
                    string key = new Random().Next(100000, 999999).ToString();
                    CN_Usuario.ActualizarPassword(email, key);
                    CommHelper.EnviarCorreoRecuperacion(email, user.usu_nombre, key);
                    
                    // Formato exacto que pidió el usuario
                    string msgWA = "🔓 *NovaX:* Hola " + user.usu_nombre + ", tu clave temporal es: *" + key + "*. Válida por 5 min.";
                    CommHelper.EnviarWhatsApp(user.usu_celular, msgWA);
                    
                    Enviar(context, "OK|ENVIADO_AUTO");
                } else Enviar(context, "ERROR: Correo no encontrado.");
            } catch { Enviar(context, "ERROR: Fallo al procesar."); }
        }

        private void AutenticarGoogle(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string gid = GetVal(data, context, "googleId") ?? GetVal(data, context, "id_token");
                string email = GetVal(data, context, "email");
                string nombre = GetVal(data, context, "nombre") ?? "Usuario Google";

                // 1. Intentar por ID o Email
                Usuario user = new CD_Usuario().LoginPorGoogleId(gid);
                if (user == null && !string.IsNullOrEmpty(email)) user = CN_Usuario.ObtenerUsuarioPorEmail(email);
                
                // 2. Si NO existe, lo REGISTRAMOS automaticamente
                if (user == null && !string.IsNullOrEmpty(email))
                {
                    string pass = Guid.NewGuid().ToString().Substring(0, 8);
                    string staticQR = "NOVAXQR-" + Guid.NewGuid().ToString("N").ToUpper();
                    
                    // Aseguramos los 10 parametros exactos de CN_Usuario.Insertar
                    int newId = CN_Usuario.Insertar(
                        "",      // cedula
                        nombre,  // nombre
                        "",      // apellidos
                        email,   // correo
                        email.Split('@')[0], // nick
                        pass,    // pass
                        2,       // tipoId (Usuario)
                        "",      // celular
                        "",      // direccion
                        DateTime.Now // fechaCumple
                    );
                    
                    if (newId > 0) {
                        CN_Usuario.GuardarCodigoQrOtp(newId, staticQR);
                        new CD_Usuario().VincularGoogle(newId, gid);
                        
                        // Enviamos los 5 parametros que pide CommHelper.EnviarCorreoBienvenida
                        byte[] qrBytes = CommHelper.GenerarQR(staticQR);
                        string nick = email.Split('@')[0];
                        CommHelper.EnviarCorreoBienvenida(email, nombre, nick, newId, qrBytes);
                        
                        user = CN_Usuario.ObtenerUsuarioPorId(newId);
                    }
                }
                
                if (user != null) LoginExitoso(context, user);
                else Enviar(context, "ERROR: No se pudo identificar o crear la cuenta de Google.");
            } catch (Exception ex) { Enviar(context, "ERROR GOOGLE: " + ex.Message); }
        }

        private void AutenticarFacebook(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string fid = GetVal(data, context, "fbId");
                string email = GetVal(data, context, "email");
                string nombre = GetVal(data, context, "nombre") ?? "Usuario Facebook";

                // 1. Intentar por ID o Email
                Usuario user = new CD_Usuario().LoginPorFacebookId(fid);
                if (user == null && !string.IsNullOrEmpty(email)) user = CN_Usuario.ObtenerUsuarioPorEmail(email);
                
                // 2. Si NO existe, lo REGISTRAMOS automaticamente
                if (user == null && !string.IsNullOrEmpty(email))
                {
                    string pass = Guid.NewGuid().ToString().Substring(0, 8);
                    string staticQR = "NOVAXQR-" + Guid.NewGuid().ToString("N").ToUpper();
                    
                    int newId = CN_Usuario.Insertar("", nombre, "", email, email.Split('@')[0], pass, 2, "", "", DateTime.Now);
                    
                    if (newId > 0) {
                        CN_Usuario.GuardarCodigoQrOtp(newId, staticQR);
                        new CD_Usuario().VincularFacebook(newId, fid);
                        
                        byte[] qrBytes = CommHelper.GenerarQR(staticQR);
                        string nick = email.Split('@')[0];
                        CommHelper.EnviarCorreoBienvenida(email, nombre, nick, newId, qrBytes);
                        
                        user = CN_Usuario.ObtenerUsuarioPorId(newId);
                    }
                }
                
                if (user != null) LoginExitoso(context, user);
                else Enviar(context, "ERROR: No se pudo identificar o crear la cuenta de Facebook.");
            } catch (Exception ex) { Enviar(context, "ERROR FB: " + ex.Message); }
        }

        private void IniciarFlujoOTP(HttpContext context, Usuario user)
        {
          
            // Generamos el codigo de 6 digitos
            string otp = new Random().Next(100000, 999999).ToString();
            
            // Lo guardamos PROTEGIDO con Hash en usu_otp_hash
            string hash = SecurityHelper.GenerateFullHash(otp);
            CN_Usuario.GuardarOtpTemp(user.usu_id, hash);
            
            user.usu_otp_hash = hash;
            context.Session["TempUser"] = user;

            // Mandamos el correo con el QR del OTP
            CommHelper.EnviarCorreoOTP(user.usu_correo, user.usu_nombre, CommHelper.GenerarQR(otp));
            
            // Respondemos para que el JS muestre el mensaje de "Verificando..."
            Enviar(context, "OTP_REQUIRED");
        }

        private void LoginExitoso(HttpContext context, Usuario user)
        {
            context.Session["UserId"] = user.usu_id;
            context.Session["UserNombre"] = user.usu_nombre;
            context.Session["UserRole"] = user.tusu_id;
            context.Session["UserEmail"] = user.usu_correo;
            context.Session["UserCedula"] = user.usu_cedula;
            context.Session["UserRolName"] = (user.tusu_id == 1) ? "Administrador" : "Usuario";
            
            string path = (user.tusu_id == 1) ? "../Mantenimiento/Admin/DashboardAdmin.aspx" : "../Mantenimiento/Usuario/DashboardUsuario.aspx";
            Enviar(context, path);
        }

        private void ConfirmarCambio(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string email = GetVal(data, context, "email");
                string key = GetVal(data, context, "key");
                string pass = GetVal(data, context, "pass");

                Usuario user = CN_Usuario.ObtenerUsuarioPorEmail(email);
                if (user != null) {
                    Usuario validado = CN_Usuario.ValidarLogin(email, key);
                    if (validado != null) {
                        CN_Usuario.ActualizarPassword(email, pass);
                        Enviar(context, "OK");
                    } else Enviar(context, "ERROR: La clave temporal es incorrecta.");
                } else Enviar(context, "ERROR: Usuario no encontrado.");
            } catch (Exception ex) { Enviar(context, "ERROR: " + ex.Message); }
        }

        private void ValidarKeyTemporal(HttpContext context, Dictionary<string, object> data)
        {
            try {
                string email = GetVal(data, context, "email");
                string key = GetVal(data, context, "key");
                Usuario validado = CN_Usuario.ValidarLogin(email, key);
                if (validado != null) Enviar(context, "OK");
                else Enviar(context, "ERROR: La clave temporal es incorrecta.");
            } catch { Enviar(context, "ERROR: Fallo al validar."); }
        }

        private void Logout(HttpContext context) { context.Session.Abandon(); Enviar(context, "OK"); }

        private string GetVal(Dictionary<string, object> data, HttpContext ctx, string key) {
            if (data != null && data.ContainsKey(key)) return data[key]?.ToString();
            return ctx.Request.Form[key] ?? ctx.Request.QueryString[key];
        }

        private void Enviar(HttpContext context, string msg) { context.Response.Write(js.Serialize(new { d = msg })); }

        public bool IsReusable => false;
    }
}
