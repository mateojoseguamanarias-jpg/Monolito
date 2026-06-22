using System;
using System.Web.Services;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class Juego : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) 
                Response.Redirect("~/Seguridad/Loguin.aspx");
            
            if (!IsPostBack)
            {
                lblPuntos.Text = Session["UserPuntos"]?.ToString() ?? "0";
            }
        }

        [WebMethod]
        public static object GuardarPuntos(int puntos)
        {
            try
            {
                if (System.Web.HttpContext.Current.Session["UserId"] == null) 
                    return new { success = false, message = "Sesión expirada" };

                int userId = Convert.ToInt32(System.Web.HttpContext.Current.Session["UserId"]);
                
                // Guardar en Base de Datos
                CN_Usuario.SumarPuntos(userId, puntos);
                
                // Actualizar en Sesión
                int actuales = System.Web.HttpContext.Current.Session["UserPuntos"] != null 
                    ? Convert.ToInt32(System.Web.HttpContext.Current.Session["UserPuntos"]) 
                    : 0;
                System.Web.HttpContext.Current.Session["UserPuntos"] = actuales + puntos;

                return new { success = true, nuevoTotal = actuales + puntos };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }
    }
}
