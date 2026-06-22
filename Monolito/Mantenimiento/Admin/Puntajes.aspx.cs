using System;
using System.Web;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class Puntajes : Page
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
                CargarRanking();
            }
        }

        private void CargarRanking()
        {
            var dt = CN_Usuario.ObtenerTodosUsuarios();
            
            // Verificación defensiva: si por alguna razón la columna no viene del SQL, la creamos
            if (!dt.Columns.Contains("usu_puntos"))
            {
                dt.Columns.Add("usu_puntos", typeof(int));
                foreach (System.Data.DataRow row in dt.Rows) row["usu_puntos"] = 0;
            }

            // Ordenar por puntos de mayor a menor
            System.Data.DataView dv = dt.DefaultView;
            dv.Sort = "usu_puntos DESC";
            
            rptRanking.DataSource = dv;
            rptRanking.DataBind();
        }
    }
}
