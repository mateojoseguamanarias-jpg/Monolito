using System;

namespace Capa_Datos
{
    public class Usuario
    {
        public int usu_id { get; set; }
        public string usu_cedula { get; set; }
        public string usu_nombre { get; set; }
        public string usu_apellidos { get; set; }
        public string usu_correo { get; set; }
        public string usu_nick { get; set; }
        public string usu_celular { get; set; }
        public string usu_direccion { get; set; }
        public DateTime? usu_fecha_cumple { get; set; }
        public int tusu_id { get; set; }
        public string usu_estado { get; set; }
        public string usu_otp_hash { get; set; }
        public string usu_google_id { get; set; }
        public int usu_puntos { get; set; }
    }

    public class TipoUsuario
    {
        public int tusu_id { get; set; }
        public string tusu_nombre { get; set; }
        public string tusu_estado { get; set; }
    }
}
