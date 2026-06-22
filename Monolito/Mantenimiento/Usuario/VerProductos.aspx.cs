using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;
using System.Web.UI.HtmlControls;

namespace Monolito.Dashboard
{
    public partial class VerProductos : System.Web.UI.Page
    {
        // IDs de productos que el usuario ya guardó en su lista (cargado al inicio)
        private HashSet<int> _carritoIds = new HashSet<int>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Seguridad/Loguin.aspx");
            }

            if (!IsPostBack)
            {
                CargarDropdowns();
                CargarProductos();
            }
        }

        private void CargarDropdowns()
        {
            try
            {
                // Cargar categorías
                var categorias = CN_Categoria.Listar();
                ddlCategoriaFiltro.Items.Clear();
                ddlCategoriaFiltro.Items.Add(new ListItem("Todas las Categorías", "0"));
                foreach (var cat in categorias)
                {
                    ddlCategoriaFiltro.Items.Add(new ListItem(cat.cat_nombre, cat.cat_id.ToString()));
                }

                // Cargar proveedores
                var proveedores = CN_Proveedor.ListarActivos();
                ddlProveedorFiltro.Items.Clear();
                ddlProveedorFiltro.Items.Add(new ListItem("Todos los Proveedores", "0"));
                foreach (var prov in proveedores)
                {
                    ddlProveedorFiltro.Items.Add(new ListItem(prov.prov_nombre, prov.prov_id.ToString()));
                }
            }
            catch (Exception)
            {
                // Fallback silencioso en caso de error de base de datos
            }
        }

        private void CargarProductos()
        {
            // Cargar IDs guardados por este usuario para marcar botones
            if (Session["UserId"] != null)
                _carritoIds = CN_Carrito.ObtenerIdsEnCarrito(Convert.ToInt32(Session["UserId"]));

            try
            {
                string busqueda = txtBusqueda.Text.Trim();
                int catId  = int.Parse(ddlCategoriaFiltro.SelectedValue);
                int provId = int.Parse(ddlProveedorFiltro.SelectedValue);

                var lista = CN_Producto.Listar(busqueda, catId > 0 ? (int?)catId : null, provId > 0 ? (int?)provId : null);

                if (lista != null && lista.Count > 0)
                {
                    rptProductos.DataSource = lista;
                    rptProductos.DataBind();
                    rptProductos.Visible = true;
                    pnlVacio.Visible = false;
                }
                else
                {
                    rptProductos.Visible = false;
                    pnlVacio.Visible = true;
                }
            }
            catch (Exception)
            {
                rptProductos.Visible = false;
                pnlVacio.Visible = true;
            }
        }

        /// <summary>
        /// Devuelve true si el producto ya fue guardado por el usuario actual.
        /// Se usa desde el ASPX para cambiar el estilo y texto del botón.
        /// </summary>
        public bool EsProductoGuardado(int proId)
        {
            return _carritoIds.Contains(proId);
        }

        /// <summary>
        /// Maneja el clic en "Mi Lista" dentro de cada tarjeta de producto.
        /// Agrega el producto al carrito del usuario actual.
        /// </summary>
        protected void rptProductos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "AgregarCarrito") return;
            if (Session["UserId"] == null) return;

            int usuId = Convert.ToInt32(Session["UserId"]);
            int proId = Convert.ToInt32(e.CommandArgument);

            bool agregado = CN_Carrito.Agregar(usuId, proId);

            if (agregado)
                MostrarToast("✓ Producto guardado en tu lista.", true);
            else
                MostrarToast("Este producto ya está en tu lista.", false);

            CargarProductos();
        }

        private void MostrarToast(string mensaje, bool esExito)
        {
            pnlToast.Visible = true;
            lblToast.Text    = mensaje;
            ScriptManager.RegisterStartupScript(this, GetType(), "hideToast",
                "setTimeout(function(){ var t=document.querySelector('.toast-wrap'); if(t) t.style.display='none'; }, 3000);", true);
        }

        protected void txtBusqueda_TextChanged(object sender, EventArgs e)
        {
            CargarProductos();
        }

        protected void ddlCategoriaFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarProductos();
        }

        protected void ddlProveedorFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarProductos();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBusqueda.Text = string.Empty;
            ddlCategoriaFiltro.SelectedValue = "0";
            ddlProveedorFiltro.SelectedValue = "0";
            CargarProductos();
        }

        /// <summary>
        /// Convierte una ruta relativa de foto a URL navegable.
        /// </summary>
        public string ObtenerUrlFoto(string path, string nombreProducto)
        {
            string fallbackUrl = "https://placehold.co/400x300/07070f/00f2ff?text=" + Uri.EscapeDataString(nombreProducto ?? "Producto");
            if (string.IsNullOrWhiteSpace(path)) return fallbackUrl;

            try
            {
                if (path.StartsWith("http://") || path.StartsWith("https://"))
                    return path;

                string cleanPath = path.StartsWith("~") ? path : "~/" + path.TrimStart('/');
                string physicalPath = Server.MapPath(cleanPath);
                if (System.IO.File.Exists(physicalPath))
                    return ResolveUrl(cleanPath);
            }
            catch { }

            return fallbackUrl;
        }

        /// <summary>
        /// Genera el HTML del carrusel: muestra UNA imagen a la vez con transición suave.
        /// - 1 foto  → Efecto Ken Burns (zoom + pan suave en bucle infinito).
        /// - N fotos → Slider JS que muestra una imagen a la vez (sin apilamiento).
        /// Las imágenes rotas se saltan automáticamente.
        /// </summary>
        public string GenerarCarrusel(int proId, string nombre, string rutaFoto)
        {
            var sb   = new StringBuilder();
            string cid      = "kbc" + proId;
            string fallback = "https://placehold.co/400x300/07070f/7F77DD?text=" + Uri.EscapeDataString(nombre ?? "NovaX");

            // 1. Recopilar URLs de fotos válidas
            var fotos = new List<string>();
            try
            {
                var fotosDb = CN_Producto.ObtenerFotos(proId);
                if (fotosDb != null)
                    foreach (var f in fotosDb)
                    {
                        string url = ObtenerUrlFoto(f, nombre);
                        // Solo añadir si la URL no es el placeholder (significa que el archivo existe)
                        if (!url.StartsWith("https://placehold.co"))
                            fotos.Add(url);
                    }
            }
            catch { }

            // 2. Si no hay fotos válidas, intentar foto principal
            if (fotos.Count == 0)
            {
                string mainUrl = ObtenerUrlFoto(rutaFoto, nombre);
                fotos.Add(mainUrl); // Puede ser placeholder, se mostrará igualmente
            }

            int total = fotos.Count;

            // 3. Contenedor base
            sb.AppendFormat(
                "<div id=\"{0}\" style=\"position:relative;width:100%;height:220px;" +
                "overflow:hidden;background:#0a0a15;border-radius:8px 8px 0 0;\">", cid);

            if (total == 1)
            {
                // ── Una imagen: Ken Burns ──────────────────────────────────────
                sb.AppendFormat(
                    "<style>" +
                    "@keyframes kb{0}{{" +
                    "0%{{transform:scale(1.0) translate(0%,0%)}}" +
                    "33%{{transform:scale(1.12) translate(-2%,-1%)}}" +
                    "66%{{transform:scale(1.08) translate(1%,2%)}}" +
                    "100%{{transform:scale(1.0) translate(0%,0%)}}}}" +
                    "#{0} .kb-solo{{width:100%;height:220px;object-fit:cover;" +
                    "transform-origin:center;animation:kb{0} 10s ease-in-out infinite;" +
                    "transition:opacity .4s;}}" +
                    "</style>", cid);

                sb.AppendFormat(
                    "<img class=\"kb-solo\" src=\"{0}\" alt=\"{1}\" " +
                    "onerror=\"this.src='{2}'\" />",
                    System.Web.HttpUtility.HtmlAttributeEncode(fotos[0]),
                    System.Web.HttpUtility.HtmlAttributeEncode(nombre ?? "Producto"),
                    fallback);
            }
            else
            {
                // ── Varias imágenes: JS slider (una a la vez) ─────────────────
                sb.Append(
                    "<style>" +
                    ".kb-slide-img{position:absolute;inset:0;width:100%;height:100%;" +
                    "object-fit:cover;opacity:0;transition:opacity .6s ease;}" +
                    ".kb-slide-img.active{opacity:1;}" +
                    "</style>");

                // Badge de cantidad
                sb.AppendFormat(
                    "<span style=\"position:absolute;top:8px;right:8px;z-index:10;" +
                    "background:rgba(0,0,0,.65);color:#fff;font-size:11px;padding:3px 8px;" +
                    "border-radius:20px;backdrop-filter:blur(4px);\">" +
                    "<i class=\"fas fa-images\"></i> {0}</span>", total);

                // Imágenes apiladas — solo la primera visible al inicio
                for (int i = 0; i < total; i++)
                {
                    sb.AppendFormat(
                        "<img class=\"kb-slide-img{0}\" src=\"{1}\" alt=\"{2}\" " +
                        "onerror=\"this.classList.add('img-broken');this.style.display='none';\" />",
                        i == 0 ? " active" : "",
                        System.Web.HttpUtility.HtmlAttributeEncode(fotos[i]),
                        System.Web.HttpUtility.HtmlAttributeEncode(nombre ?? "Producto"));
                }

                // JS inline: cambia imagen activa cada 3.5s, saltando las rotas
                sb.AppendFormat(
                    "<script>" +
                    "(function(){{" +
                    "  var d=document.getElementById('{0}');" +
                    "  if(!d)return;" +
                    "  var imgs=Array.from(d.querySelectorAll('.kb-slide-img'));" +
                    "  var cur=0;" +
                    "  setInterval(function(){{" +
                    "    imgs[cur].classList.remove('active');" +
                    "    var next=(cur+1)%imgs.length;" +
                    "    var tries=0;" +
                    "    while(imgs[next].style.display==='none' && tries<imgs.length){{next=(next+1)%imgs.length;tries++;}}" +
                    "    imgs[next].classList.add('active');" +
                    "    cur=next;" +
                    "  }},3500);" +
                    "}})();" +
                    "</script>", cid);
            }

            sb.Append("</div>");
            return sb.ToString();
        }

        protected void rptProductos_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var litCarrusel = e.Item.FindControl("litCarrusel") as Literal;
                if (litCarrusel == null) return;

                int proId = 0;
                string nombre = "";
                string rutaFoto = "";

                var row = e.Item.DataItem as System.Data.DataRowView;
                if (row != null)
                {
                    proId    = Convert.ToInt32(row["pro_id"]);
                    nombre   = row["pro_nombre"]?.ToString() ?? "";
                    rutaFoto = row["pro_ruta_foto"]?.ToString() ?? "";
                }
                else
                {
                    // Soporte para List<ProductoInfo> y otros tipos
                    try { proId    = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "pro_id")); }    catch { }
                    try { nombre   = DataBinder.Eval(e.Item.DataItem, "pro_nombre")?.ToString() ?? ""; }  catch { }
                    try { rutaFoto = DataBinder.Eval(e.Item.DataItem, "pro_ruta_foto")?.ToString() ?? ""; } catch { }
                }

                litCarrusel.Text = GenerarCarrusel(proId, nombre, rutaFoto);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Seguridad/Loguin.aspx");
        }
    }
}
