using System;
using System.IO;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class RegistrarAgente : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
                Response.Redirect("~/Seguridad/Loguin.aspx");
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            try
            {
                string cedula = txtCedula.Text.Trim();
                string nombre = txtNombre.Text.Trim();
                string apellido = txtApellido.Text.Trim();
                string email = txtEmail.Text.Trim();
                string nick = txtNick.Text.Trim();
                string pass = txtPass.Text.Trim();
                string conf = txtConf.Text.Trim();
                int tipoId = int.Parse(ddlRol.SelectedValue);

                if (string.IsNullOrEmpty(cedula) || string.IsNullOrEmpty(nombre) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(pass))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "err", "Swal.fire('Error','Completa los campos obligatorios','error');", true);
                    return;
                }

                if (pass != conf)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "err", "Swal.fire('Error','Las contraseñas no coinciden','error');", true);
                    return;
                }

                // Insertar usuario
                int nuevoId = CN_Usuario.Insertar(cedula, nombre, apellido, email, nick, pass, tipoId, "", "", null);

                if (nuevoId > 0)
                {
                    // Guardar fotos (múltiples)
                    if (fuFoto.HasFiles)
                    {
                        foreach (var file in fuFoto.PostedFiles)
                        {
                            if (file.ContentLength > 0)
                            {
                                using (BinaryReader br = new BinaryReader(file.InputStream))
                                {
                                    byte[] bytes = br.ReadBytes(file.ContentLength);
                                    CN_Usuario.InsertarFoto(nuevoId, bytes);
                                }
                            }
                        }
                    }

                    ScriptManager.RegisterStartupScript(this, GetType(), "ok", 
                        "Swal.fire({title:'Agente Creado', text:'El agente ha sido registrado con éxito', icon:'success'}).then(() => { window.location.href='GestionarUsuarios.aspx'; });", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "err", "Swal.fire('Error','No se pudo crear el agente. Verifica si el correo o nick ya existen.','error');", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err", $"Swal.fire('Error Crítico','{ex.Message.Replace("'", "")}','error');", true);
            }
        }
    }
}
