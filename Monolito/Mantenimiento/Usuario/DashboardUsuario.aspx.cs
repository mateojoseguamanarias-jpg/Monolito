using System;
using System.Web;
using System.Web.UI;
using Capa_Datos;

namespace Monolito.Dashboard
{
    public partial class DashboardUsuario : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.Cache.SetValidUntilExpires(false);
            Response.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);

            if (Session["UserId"] == null)
                Response.Redirect("~/Seguridad/Loguin.aspx");

            if (!IsPostBack)
            {
                int userId = int.Parse(Session["UserId"].ToString());
                var user = Capa_Negocio.CN_Usuario.ObtenerUsuarioPorId(userId);

                if (user != null)
                {
                    lblNombre.InnerText = (user.usu_nombre ?? "usuario").ToLower();
                    lblRol.InnerText = "USUARIO";
                    lblPuntos.Text = user.usu_puntos.ToString();
                    
                    // Forzamos el valor directo con .Text (más confiable en Label)
                    lblMail.Text = !string.IsNullOrEmpty(user.usu_correo) ? user.usu_correo : "sin_correo@novax.com";
                    lblCedula.Text = !string.IsNullOrEmpty(user.usu_cedula) ? user.usu_cedula : "0000000000";
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("~/Seguridad/Loguin.aspx");
        }
    }
}