using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class GestionarUsuarios : Page
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
                CargarUsuarios();
            }
        }

        private void CargarUsuarios()
        {
            var dt = CN_Usuario.ObtenerTodosUsuarios();
            rptUsuarios.DataSource = dt;
            rptUsuarios.DataBind();
            lblTotal.Text = dt.Rows.Count.ToString();
        }

        protected void Accion_Command(object sender, CommandEventArgs e)
        {
            if (e.CommandName == "Toggle")
            {
                try
                {
                    string[] parts = e.CommandArgument.ToString().Split('|');
                    int id = int.Parse(parts[0]);
                    string estadoActual = parts[1];
                    string nuevoEstado = (estadoActual == "A") ? "B" : "A";

                    CN_Usuario.ActualizarEstado(id, nuevoEstado);
                    CargarUsuarios();
                }
                catch (Exception ex)
                {
                    string cleanMsg = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                    if (ex.InnerException != null)
                    {
                        cleanMsg += " - " + ex.InnerException.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                    }
                    
                    ScriptManager.RegisterStartupScript(this, GetType(), "errTrigger",
                        $"Swal.fire({{ title: 'Restricci&oacute;n de Seguridad', text: '{cleanMsg}', icon: 'error', confirmButtonColor: '#7F77DD' }});", true);
                }
            }
        }
    }
}
