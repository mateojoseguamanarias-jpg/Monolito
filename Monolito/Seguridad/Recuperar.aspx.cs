using Capa_Negocio;
using Capa_Datos;
using System;
using System.Web.UI;

namespace Monolito.Seguridad
{
    public partial class Recuperar : System.Web.UI.Page
    {
        protected void btnRecuperar_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtEmail.Text.Trim();
                if (string.IsNullOrEmpty(email)) throw new Exception("Ingresa tu correo.");

                Usuario usu = CN_Usuario.ObtenerUsuarioPorEmail(email);
                if (usu == null) throw new Exception("No existe un usuario con ese correo.");

                // Generar clave temporal de 8 caracteres
                string claveTemporal = Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();

                // Guardar como nueva contraseña temporal (usando el método existente que encripta)
                CN_Usuario.ActualizarPassword(email, claveTemporal);

                // Enviar por Correo
                CommHelper.EnviarCorreoRecuperacion(email, usu.usu_nombre, claveTemporal);

                // Preparar mensaje de WhatsApp
                string msgWA = $"Hola {usu.usu_nombre}, tu clave temporal de NovaX es: {claveTemporal}";
                string linkWA = CommHelper.GenerarLinkWhatsApp(usu.usu_celular ?? "", msgWA);

                string script = $@"
                    Swal.fire({{
                        title: '\u00A1Clave Enviada!',
                        text: 'Hemos enviado una clave temporal a tu correo.',
                        icon: 'success',
                        background: '#070715', color: '#fff',
                        confirmButtonColor: '#7F77DD',
                        showCancelButton: true,
                        cancelButtonText: 'CERRAR',
                        confirmButtonText: 'IR A WHATSAPP'
                    }}).then((result) => {{
                        if (result.isConfirmed) {{
                            window.open('{linkWA}', '_blank');
                        }}
                        window.location.href = 'Loguin.aspx';
                    }});";

                ScriptManager.RegisterStartupScript(this, GetType(), "recoverySuccess", script, true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "recoveryErr",
                    $"Swal.fire({{title:'Error',text:'{ex.Message}',icon:'error',background:'#070715',color:'#fff'}});", true);
            }
        }
    }
}
