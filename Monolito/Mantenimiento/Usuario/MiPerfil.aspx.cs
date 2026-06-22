using System;
using System.IO;
using System.Web;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class MiPerfilUsuario : Page
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

            if (IsPostBack && fuFoto.HasFile)
            {
                SubirFoto();
            }

            if (!IsPostBack)
            {
                CargarDatos();
            }
        }

        private void CargarDatos()
        {
            try
            {
                int id = Convert.ToInt32(Session["UserId"]);
                var u = CN_Usuario.ObtenerUsuarioPorId(id);
                if (u != null)
                {
                    txtCedula.Text = u.usu_cedula;
                    txtEmail.Text = u.usu_correo;
                    txtNombre.Text = u.usu_nombre;
                    txtApellido.Text = u.usu_apellidos;
                    txtNick.Text = u.usu_nick;
                    txtCelular.Text = u.usu_celular;
                    txtDireccion.Text = u.usu_direccion;
                    if (u.usu_fecha_cumple.HasValue)
                        txtFecha.Text = u.usu_fecha_cumple.Value.ToString("yyyy-MM-dd");

                    imgPerfil.ImageUrl = "../../Seguridad/ImageHandler.ashx?t=" + DateTime.Now.Ticks;

                    // Cargar todas las fotos
                    rptFotos.DataSource = CN_Usuario.ObtenerTodasFotos(id);
                    rptFotos.DataBind();
                }
            }
            catch { }
        }

        private void SubirFoto()
        {
           
            try
            {
                int id = Convert.ToInt32(Session["UserId"]);
                using (BinaryReader br = new BinaryReader(fuFoto.PostedFile.InputStream))
                {
                    byte[] bytes = br.ReadBytes(fuFoto.PostedFile.ContentLength);
                    CN_Usuario.InsertarFoto(id, bytes);
                }
                Response.Redirect(Request.RawUrl);
            }
            catch { }
        }

        protected void rptFotos_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Eliminar")
            {
                int fotoId = Convert.ToInt32(e.CommandArgument);
                CN_Usuario.EliminarFoto(fotoId);
                CargarDatos();
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                int id = Convert.ToInt32(Session["UserId"]);
                DateTime? fecha = null;
                if (!string.IsNullOrEmpty(txtFecha.Text)) fecha = DateTime.Parse(txtFecha.Text);

                // LLAMADA AL NUEVO MÉTODO CON PARÁMETROS NOMBRADOS
                CN_Usuario.ActualizarPerfil(
                    id: id, 
                    nombre: txtNombre.Text.Trim(), 
                    apellidos: txtApellido.Text.Trim(), 
                    nick: txtNick.Text.Trim(), 
                    celular: txtCelular.Text.Trim(), 
                    direccion: txtDireccion.Text.Trim(), 
                    fechaCumple: fecha, 
                    email: txtEmail.Text.Trim(),
                    cedula: txtCedula.Text.Trim()
                );

                // Sincronizamos sesión para que el dashboard se vea actualizado
                Session["UserNombre"] = txtNombre.Text.Trim();
                Session["UserEmail"] = txtEmail.Text.Trim();
                Session["UserCedula"] = txtCedula.Text.Trim();

                ClientScript.RegisterStartupScript(this.GetType(), "ok", "alert('¡Perfil actualizado con éxito!'); window.location='DashboardUsuario.aspx';", true);
            }
            catch (Exception ex) { ClientScript.RegisterStartupScript(this.GetType(), "err", "alert('Error: " + ex.Message + "');", true); }
        }
    }
}
