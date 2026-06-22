using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class MiCarrito : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Seguridad/Loguin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarCarrito();
            }
        }

        private void CargarCarrito()
        {
            int usuId = Convert.ToInt32(Session["UserId"]);

            try
            {
                var lista = CN_Carrito.ListarPorUsuario(usuId);

                if (lista != null && lista.Count > 0)
                {
                    rptCarrito.DataSource = lista;
                    rptCarrito.DataBind();
                    rptCarrito.Visible = true;
                    pnlVacio.Visible   = false;

                    // Resumen
                    lblTotalItems.Text  = lista.Count.ToString();
                    decimal total = 0;
                    foreach (var item in lista) total += item.pro_precio;
                    lblTotalPrecio.Text = "$" + total.ToString("N2");
                }
                else
                {
                    rptCarrito.Visible = false;
                    pnlVacio.Visible   = true;
                    lblTotalItems.Text  = "0";
                    lblTotalPrecio.Text = "$0.00";
                }
            }
            catch (Exception)
            {
                rptCarrito.Visible = false;
                pnlVacio.Visible   = true;
            }
        }

        protected void rptCarrito_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Eliminar")
            {
                int carId = Convert.ToInt32(e.CommandArgument);
                CN_Carrito.Eliminar(carId);

                MostrarToast("Producto eliminado de tu lista.", false);
                CargarCarrito();
            }
        }

        /// <summary>
        /// Resuelve la URL de la foto del producto para mostrarla en la página.
        /// </summary>
        public string ObtenerUrlFoto(string path, string nombreProducto)
        {
            string fallback = "https://placehold.co/400x300/07070f/00f2ff?text=" + Uri.EscapeDataString(nombreProducto ?? "Producto");
            if (string.IsNullOrWhiteSpace(path)) return fallback;

            try
            {
                if (path.StartsWith("http://") || path.StartsWith("https://")) return path;
                string cleanPath = path.StartsWith("~") ? path : "~/" + path.TrimStart('/');
                string physicalPath = Server.MapPath(cleanPath);
                if (System.IO.File.Exists(physicalPath)) return ResolveUrl(cleanPath);
            }
            catch { }

            return fallback;
        }

        private void MostrarToast(string mensaje, bool esExito)
        {
            pnlToast.Visible = true;
            lblToast.Text    = mensaje;

            // Cambiar clase según tipo
            var div = pnlToast.Controls[0] as System.Web.UI.HtmlControls.HtmlGenericControl;
            if (div != null)
                div.Attributes["class"] = esExito ? "toast-msg success" : "toast-msg";

            // Auto-ocultar con script
            ScriptManager.RegisterStartupScript(this, GetType(), "toastHide",
                "setTimeout(function(){ var t=document.querySelector('.toast-container'); if(t) t.style.display='none'; }, 3000);", true);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Seguridad/Loguin.aspx");
        }
    }
}
