using Capa_Negocio;
using QRCoder;
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Web.UI;

namespace Monolito.Seguridad
{
    public partial class Registrar : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarTiposUsuario();
                CargarSiguienteId();
            }
        }

        private void CargarTiposUsuario()
        {
            try
            {
                var lista = CN_Usuario.ObtenerTiposUsuario();
                if (lista != null && lista.Rows.Count > 0)
                {
                    ddlTipoUsuario.DataSource = lista;
                    ddlTipoUsuario.DataTextField = "tusu_nombre";
                    ddlTipoUsuario.DataValueField = "tusu_id";
                    ddlTipoUsuario.DataBind();
                    ddlTipoUsuario.Items.Insert(0,
                        new System.Web.UI.WebControls.ListItem("-- Selecciona --", "0"));
                }
                else
                {
                    CargarTiposHardcoded();
                }
            }
            catch
            {
                CargarTiposHardcoded();
            }
        }

        private void CargarTiposHardcoded()
        {
            ddlTipoUsuario.Items.Clear();
            ddlTipoUsuario.Items.Add(new System.Web.UI.WebControls.ListItem("-- Selecciona --", "0"));
            ddlTipoUsuario.Items.Add(new System.Web.UI.WebControls.ListItem("Usuario", "2"));
            ddlTipoUsuario.Items.Add(new System.Web.UI.WebControls.ListItem("Administrador", "1"));
        }

        private void CargarSiguienteId()
        {
            try { regId.Text = CN_Usuario.ObtenerSiguienteId().ToString(); }
            catch { regId.Text = "AUTO"; }
        }

        protected void btnCrear_Click(object sender, EventArgs e)
        {
            try
            {
                // 1. Validaciones de Tipo de Cuenta - Forzado a Rol 2 (Usuario)
                int tipoId = 2;

                // 2. Validaciones de Cédula (10 dígitos, solo números, sin 7 repetidos)
                string cedula = regCedula.Text.Trim();
                if (string.IsNullOrWhiteSpace(cedula) || cedula.Length != 10 || !EsSoloNumeros(cedula))
                    throw new Exception("La cédula debe tener exactamente 10 dígitos numéricos.");
                
                if (TieneNumerosRepetidos(cedula, 7))
                    throw new Exception("La cédula no es válida (demasiados números repetidos).");

                // 3. Validaciones de Nombres (Obligatorio 2, sin números, máx 100)
                string nombres = regNom.Text.Trim();
                if (string.IsNullOrWhiteSpace(nombres) || nombres.Length > 100 || TieneNumeros(nombres))
                    throw new Exception("Nombres inválidos. No se permiten números y el máximo es 100 caracteres.");
                
                if (ContarPalabras(nombres) < 2)
                    throw new Exception("Debes ingresar al menos 2 nombres. Si solo tienes uno, escríbelo dos veces (ej: Mateo Mateo).");

                // 4. Validaciones de Apellidos (Obligatorio 2, sin números, máx 100)
                string apellidos = regApe.Text.Trim();
                if (string.IsNullOrWhiteSpace(apellidos) || apellidos.Length > 100 || TieneNumeros(apellidos))
                    throw new Exception("Apellidos inválidos. No se permiten números y el máximo es 100 caracteres.");
                
                if (ContarPalabras(apellidos) < 2)
                    throw new Exception("Debes ingresar al menos 2 apellidos. Si solo tienes uno, escríbelo dos veces.");

                // 5. Validaciones de Correo (Formato y longitud)
                string correo = regEmail.Text.Trim();
                if (string.IsNullOrWhiteSpace(correo) || correo.Length > 150 || !ValidarEmail(correo))
                    throw new Exception("Correo inválido o demasiado largo (máx 150). Debe ser formato @correo.com");

                // 6. Validaciones de Dirección (No vacío, máx 100)
                string direccion = regDireccion.Text.Trim();
                if (string.IsNullOrWhiteSpace(direccion) || direccion.Length > 100)
                    throw new Exception("La dirección es obligatoria y no debe superar los 100 caracteres.");

                // 7. Validaciones de Celular (10 dígitos, solo números)
                string celular = regCelular.Text.Trim();
                if (string.IsNullOrWhiteSpace(celular) || celular.Length != 10 || !EsSoloNumeros(celular))
                    throw new Exception("El celular debe tener 10 dígitos numéricos.");

                DateTime? fechaCumple = null;
                if (!string.IsNullOrWhiteSpace(regFecha.Text))
                    fechaCumple = DateTime.Parse(regFecha.Text);

                if (regPass.Text != regConf.Text)
                    throw new Exception("Las contraseñas no coinciden.");

                int nuevoId = CN_Usuario.Insertar(
                    cedula: cedula,
                    nombre: nombres,
                    apellidos: apellidos,
                    correo: correo,
                    nick: regNick.Text.Trim(),
                    pass: regPass.Text,
                    tipoId: tipoId,
                    celular: celular,
                    direccion: direccion,
                    fechaCumple: fechaCumple
                );

                // ... resto del código (QR, Fotos, Correo) ...
                string codigoQrOtp = "NOVAXQR-" + Guid.NewGuid().ToString("N").Substring(0, 24).ToUpperInvariant();
                CN_Usuario.GuardarCodigoQrOtp(nuevoId, codigoQrOtp);
                string hashedQr = Capa_Datos.SecurityHelper.GenerateFullHash(codigoQrOtp);
                CN_Usuario.GuardarOtpTemp(nuevoId, hashedQr);

                {
                    foreach (var file in fuFotos.PostedFiles)
                    {
                        using (BinaryReader br = new BinaryReader(file.InputStream))
                        {
                            byte[] bytes = br.ReadBytes(file.ContentLength);
                            CN_Usuario.InsertarFoto(nuevoId, bytes);
                        }
                    }
                }

                string infoQR = codigoQrOtp;
                byte[] qrBytes = CommHelper.GenerarQR(infoQR);
                string qrB64 = Convert.ToBase64String(qrBytes);

                CommHelper.EnviarCorreoBienvenida(correo, nombres, regNick.Text.Trim(), nuevoId, qrBytes);

                string script = string.Format(@"
                    Swal.fire({{
                        title: '¡Usuario Registrado!',
                        html: '<p style=""color:#fff"">Bienvenido a NovaX.<br>Tu QR fue enviado al correo.</p>',
                        imageUrl: 'data:image/png;base64,{0}',
                        imageWidth: 200, imageHeight: 200, imageAlt: 'QR',
                        background: '#070715', color: '#fff',
                        confirmButtonColor: '#7F77DD',
                        confirmButtonText: 'ACCEDER AL SISTEMA'
                    }}).then(function() {{
                        window.location.href = 'Loguin.aspx';
                    }});", qrB64);

                ScriptManager.RegisterStartupScript(this, GetType(), "qrAlert", script, true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errAlert",
                    string.Format("Swal.fire({{title:'Validación Fallida',text:'{0}',icon:'error',background:'#070715',color:'#fff'}});", ex.Message.Replace("'", "\"")), true);
            }
        }

        private bool EsSoloNumeros(string s) => System.Text.RegularExpressions.Regex.IsMatch(s, "^[0-9]+$");
        private bool TieneNumeros(string s) => System.Text.RegularExpressions.Regex.IsMatch(s, "[0-9]");
        private int ContarPalabras(string s) => s.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Length;
        private bool ValidarEmail(string email) => System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        private bool TieneNumerosRepetidos(string s, int limite)
        {
            if (string.IsNullOrEmpty(s)) return false;
            int count = 1;
            for (int i = 1; i < s.Length; i++)
            {
                if (s[i] == s[i - 1]) { count++; if (count >= limite) return true; }
                else count = 1;
            }
            return false;
        }


        protected void btnVolverLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Seguridad/Loguin.aspx");
        }
    }
}