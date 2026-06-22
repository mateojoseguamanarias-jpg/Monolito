using Capa_Negocio;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Monolito.Mantenimiento.Admin
{
    public partial class UsuariosBloqueados : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
                Response.Redirect("~/Seguridad/Loguin.aspx");

            if (!IsPostBack)
            {
                CargarGrid();
            }
        }

        private void CargarGrid()
        {
            DataTable dt = CN_Usuario.ObtenerUsuariosBloqueados();
            if (dt != null && dt.Rows.Count > 0)
            {
                gvBloqueados.DataSource = dt;
                gvBloqueados.DataBind();
                gvBloqueados.Visible = true;
                pnlVacio.Visible = false;
            }
            else
            {
                gvBloqueados.Visible = false;
                pnlVacio.Visible = true;
            }
        }

        protected void gvBloqueados_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Desbloquear")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                CN_Usuario.DesbloquearUsuario(id);
                
                ScriptManager.RegisterStartupScript(this, GetType(), "unlocked",
                    "Swal.fire({title:'\\u00A1\\u00C9xito!',text:'Usuario desbloqueado correctamente.',icon:'success',background:'#07070f',color:'#fff'});", true);
                
                CargarGrid();
            }
        }
    }
}
