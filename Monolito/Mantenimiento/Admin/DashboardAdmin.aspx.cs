using System;
using System.Web;
using System.Web.UI;
using Capa_Datos;

namespace Monolito.Dashboard
{
    public partial class DashboardAdmin : Page
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
                if (Session["UserId"] != null)
                {
                    int idActual = Convert.ToInt32(Session["UserId"]);
                    Usuario adminData = Capa_Negocio.CN_Usuario.ObtenerUsuarioPorId(idActual);

                    if (adminData != null)
                    {
                        lblNombre.InnerText = adminData.usu_nombre.ToLower();
                        lblRol.InnerText = (adminData.tusu_id == 1) ? "Administrador" : "Usuario";
                        
                        // Forzamos el valor o mostramos un aviso si está vacío (que no debería por DB)
                        lblMail.InnerText = !string.IsNullOrEmpty(adminData.usu_correo) ? adminData.usu_correo : "sin_correo@novax.com";
                        lblCedula.InnerText = !string.IsNullOrEmpty(adminData.usu_cedula) ? adminData.usu_cedula : "0000000000";

                        // Sincronizamos sesión
                        Session["UserNombre"] = adminData.usu_nombre;
                        Session["UserEmail"] = adminData.usu_correo;
                        Session["UserCedula"] = adminData.usu_cedula;
                    }
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("~/Seguridad/Loguin.aspx");
        }

        [System.Web.Services.WebMethod]
        public static object ListarUsuarios()
        {
            var dt = Capa_Negocio.CN_Usuario.ObtenerTodosUsuarios();
            var lista = new System.Collections.Generic.List<object>();
            foreach (System.Data.DataRow dr in dt.Rows)
            {
                lista.Add(new {
                    id = dr["usu_id"],
                    nombre = dr["usu_nombre"],
                    nick = dr["usu_nick"],
                    correo = dr["usu_correo"],
                    estado = dr["usu_estado"],
                    rol = dr["tusu_nombre"],
                    celular = dr["usu_celular"]
                });
            }
            return lista;
        }

        [System.Web.Services.WebMethod]
        public static string CambiarEstado(int id, string estado)
        {
            try {
                string nuevo = (estado == "A") ? "B" : "A";
                Capa_Negocio.CN_Usuario.ActualizarEstado(id, nuevo);
                return "OK";
            } catch (Exception ex) { return ex.Message; }
        }

        [System.Web.Services.WebMethod]
        public static string EditarPerfil(int id, string nombre, string nick, string celular, string correo)
        {
            try {
                // Referencia completa a la capa de negocio
                Capa_Negocio.CN_Usuario.ActualizarPerfil(
                    id: id, 
                    nombre: nombre, 
                    apellidos: null, 
                    nick: nick, 
                    celular: celular, 
                    direccion: null, 
                    fechaCumple: null, 
                    email: correo,
                    cedula: null
                );
                return "OK";
            } catch (Exception ex) { return ex.Message; }
        }

        [System.Web.Services.WebMethod]
        public static object ObtenerEstadisticas()
        {
            var dt = Capa_Negocio.CN_Usuario.ObtenerEstadisticas();
            if (dt.Rows.Count > 0)
            {
                return new {
                    total = dt.Rows[0]["Total"],
                    activos = dt.Rows[0]["Activos"],
                    bloqueados = dt.Rows[0]["Bloqueados"]
                };
            }
            return null;
        }
    }
}