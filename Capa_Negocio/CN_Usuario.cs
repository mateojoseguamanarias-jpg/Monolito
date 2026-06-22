using System;
using System.Data;
using Capa_Datos;

namespace Capa_Negocio
{
    public static class CN_Usuario
    {
        private static CD_Usuario objData = new CD_Usuario();
        private static string Provider => System.Configuration.ConfigurationManager.AppSettings["DatabaseProvider"] ?? "SQL";

        public static Usuario ValidarLogin(string email, string pass)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.Login(email, pass);
            return objData.Login(email, pass);
        }

        public static Usuario ObtenerUsuarioPorId(int id)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerUsuarioPorId(id);
            return objData.ObtenerUsuarioPorId(id);
        }

        public static Usuario ObtenerUsuarioPorEmail(string email)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerUsuarioPorEmail(email);
            return objData.ObtenerUsuarioPorEmail(email);
        }
        
        public static Usuario LoginPorGoogleId(string gid)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.LoginPorGoogleId(gid);
            return objData.LoginPorGoogleId(gid);
        }

        public static Usuario LoginPorFacebookId(string fid)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.LoginPorFacebookId(fid);
            return objData.LoginPorFacebookId(fid);
        }

        public static Usuario LoginPorQrCodigo(string qr)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.LoginPorQrCodigo(qr);
            return objData.LoginPorQrCodigo(qr);
        }

        public static void ActualizarPerfil(int id, string nombre, string apellidos, string nick, string celular, string direccion, DateTime? fechaCumple, string email, string cedula)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.ActualizarPerfil(id, nombre, apellidos, nick, celular, direccion, fechaCumple, email, cedula);
            else objData.ActualizarPerfil(id, nombre, apellidos, nick, celular, direccion, fechaCumple, email, cedula);
        }

        public static int Insertar(string cedula, string nombre, string apellidos, string correo, string nick, string pass, int tipoId, string celular, string direccion, DateTime? fechaCumple)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.Insertar(cedula, nombre, apellidos, correo, nick, pass, tipoId, celular, direccion, fechaCumple);
            return objData.Insertar(cedula, nombre, apellidos, correo, nick, pass, tipoId, celular, direccion, fechaCumple);
        }

        public static void InsertarFoto(int id, byte[] foto)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.InsertarFoto(id, foto);
            else objData.InsertarFoto(id, foto);
        }

        public static void EliminarFoto(int fotoId)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.EliminarFoto(fotoId);
            else objData.EliminarFoto(fotoId);
        }

        public static byte[] ObtenerFoto(int id)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerFoto(id);
            return objData.ObtenerFoto(id);
        }

        public static byte[] ObtenerFotoPorId(int fotoId)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerFotoPorId(fotoId);
            return objData.ObtenerFotoPorId(fotoId);
        }

        public static DataTable ObtenerTodasFotos(int userId)
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerTodasFotos(userId);
            return objData.ObtenerTodasFotos(userId);
        }
        
        public static DataTable ObtenerTodosUsuarios()
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerTodosUsuarios();
            return objData.ObtenerTodosUsuarios();
        }

        public static void ActualizarEstado(int id, string estado)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.ActualizarEstado(id, estado);
            else objData.ActualizarEstado(id, estado);
        }

        public static DataTable ObtenerEstadisticas()
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerEstadisticas();
            return objData.ObtenerEstadisticas();
        }

        public static DataTable ObtenerTiposUsuario()
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerTiposUsuario();
            return objData.ObtenerTiposUsuario();
        }

        public static int ObtenerSiguienteId()
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerSiguienteId();
            return objData.ObtenerSiguienteId();
        }

        public static void GuardarOtpTemp(int id, string hash)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.GuardarOtpTemp(id, hash);
            else objData.GuardarOtpTemp(id, hash);
        }

        public static void GuardarCodigoQrOtp(int id, string qr)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.GuardarCodigoQrOtp(id, qr);
            else objData.GuardarCodigoQrOtp(id, qr);
        }

        public static void ActualizarPassword(string email, string pass)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.ActualizarPassword(email, pass);
            else objData.ActualizarPassword(email, pass);
        }

        public static void SumarPuntos(int id, int puntos)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.SumarPuntos(id, puntos);
            else objData.SumarPuntos(id, puntos);
        }

        public static DataTable ObtenerUsuariosBloqueados()
        {
            if (Provider == "MongoDB") return MongoCD_Usuario.ObtenerUsuariosBloqueados();
            return objData.ObtenerUsuariosBloqueados();
        }

        public static void DesbloquearUsuario(int id)
        {
            if (Provider == "MongoDB") MongoCD_Usuario.DesbloquearUsuario(id);
            else objData.DesbloquearUsuario(id);
        }
    }
}