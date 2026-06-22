using System;
using System.Web;
using Capa_Negocio;
using Capa_Datos;

namespace Monolito.Seguridad
{
    public partial class Loguin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Evitar que la página sea almacenada en el caché del navegador (para las flechas atrás/adelante)
            Response.Buffer = true;
            Response.ExpiresAbsolute = DateTime.Now.AddDays(-1d);
            Response.Expires = -1500;
            Response.CacheControl = "no-cache";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.Cache.SetValidUntilExpires(false);
            Response.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);

            if (!IsPostBack)
            {
                // Verificar si existe la cookie de "Recuérdame"
                HttpCookie cookie = Request.Cookies["NovaX_Auth"];
                if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
                {
                    try
                    {
                        // Desencriptar el ID del usuario
                        string decryptedId = SecurityHelper.Decrypt(cookie.Value);
                        int userId = int.Parse(decryptedId);

                        // Buscar al usuario
                        Usuario user = CN_Usuario.ObtenerUsuarioPorId(userId);

                        if (user != null && user.usu_estado == "A")
                        {
                            // Iniciar sesión automáticamente
                            Session["UserId"] = user.usu_id;
                            Session["UserNick"] = user.usu_nick;
                            Session["UserRol"] = user.tusu_id.ToString();
                            Session["UserNombre"] = user.usu_nombre;
                            Session["UserEmail"] = user.usu_correo;
                            Session["UserCedula"] = user.usu_cedula;
                            Session["UserRolName"] = (user.tusu_id == 1) ? "Administrador" : "Usuario";

                            // Redirigir según el rol
                            string dash = user.tusu_id == 1 
                                ? "~/Mantenimiento/Admin/DashboardAdmin.aspx" 
                                : "~/Mantenimiento/Usuario/DashboardUsuario.aspx";
                            
                            Response.Redirect(dash);
                        }
                    }
                    catch
                    {
                        // Si la cookie es inválida o expiró, la borramos
                        HttpCookie c = new HttpCookie("NovaX_Auth");
                        c.Expires = DateTime.Now.AddDays(-1);
                        Response.Cookies.Add(c);
                    }
                }
            }
        }
    }
}