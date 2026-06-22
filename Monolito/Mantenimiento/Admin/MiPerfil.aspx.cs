using System;
using System.IO;
using System.Web;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class MiPerfil : Page
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

            // Si hay un archivo, lo procesamos inmediatamente
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
                    // Llenado de campos con fallback para evitar que se vean vacíos si la columna cambió de nombre
                    txtCedula.Text = !string.IsNullOrEmpty(u.usu_cedula) ? u.usu_cedula : "PENDIENTE";
                    txtEmail.Text = !string.IsNullOrEmpty(u.usu_correo) ? u.usu_correo : "NO REGISTRADO";
                    txtNombre.Text = u.usu_nombre;
                    txtApellido.Text = u.usu_apellidos;
                    txtNick.Text = u.usu_nick;
                    txtCelular.Text = u.usu_celular;
                    txtDireccion.Text = u.usu_direccion;
                    
                    if (u.usu_fecha_cumple.HasValue)
                        txtFecha.Text = u.usu_fecha_cumple.Value.ToString("yyyy-MM-dd");

                    // Forzar carga de imagen actual
                    imgPerfil.ImageUrl = "../../Seguridad/ImageHandler.ashx?id=" + id + "&t=" + DateTime.Now.Ticks;

                    // Cargar todas las fotos de la galería
                    rptFotos.DataSource = CN_Usuario.ObtenerTodasFotos(id);
                    rptFotos.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error CargarDatos: " + ex.Message);
            }
        }

        private void SubirFoto()
        {
            try
            {
                int id = Convert.ToInt32(Session["UserId"]);
                if (fuFoto.PostedFile.ContentLength > 2 * 1024 * 1024) // Limite 2MB
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "err", "alert('La imagen es muy pesada. Máximo 2MB.');", true);
                    return;
                }

                using (BinaryReader br = new BinaryReader(fuFoto.PostedFile.InputStream))
                {
                    byte[] bytes = br.ReadBytes(fuFoto.PostedFile.ContentLength);
                    CN_Usuario.InsertarFoto(id, bytes);
                }
                
                // RECARGAR PAGINA PARA LIMPIAR EL FILEUPLOAD Y VER LOS CAMBIOS
                Response.Redirect(Request.RawUrl);
            }
            catch (Exception ex) 
            { 
                ClientScript.RegisterStartupScript(this.GetType(), "err", "alert('Error al procesar foto: " + ex.Message + "');", true); 
            }
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
                if (!string.IsNullOrEmpty(txtFecha.Text)) 
                    fecha = DateTime.Parse(txtFecha.Text);

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

                // Actualizamos sesión
                Session["UserNombre"] = txtNombre.Text.Trim();
                Session["UserEmail"] = txtEmail.Text.Trim();
                Session["UserCedula"] = txtCedula.Text.Trim();

                ClientScript.RegisterStartupScript(this.GetType(), "ok", "alert('¡Expediente actualizado con éxito!'); window.location='DashboardAdmin.aspx';", true);
            }
            catch (Exception ex) 
            { 
                ClientScript.RegisterStartupScript(this.GetType(), "err", "alert('Error al guardar: " + ex.Message + "');", true); 
            }
        }
    }
}
