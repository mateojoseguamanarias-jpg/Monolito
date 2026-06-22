using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Configuration;

namespace Capa_Datos
{
    public class CD_TipoUsuario
    {
        private string GetCnn()
        {
            var cs = ConfigurationManager.ConnectionStrings["cnx"];
            if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
            return ConfigurationManager.ConnectionStrings["Monolito4toConnectionString"]?.ConnectionString ?? "";
        }

        public List<TipoUsuario> Listar()
        {
            var lista = new List<TipoUsuario>();
            using (SqlConnection cn = new SqlConnection(GetCnn()))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT tusu_id, tusu_nombre, tusu_estado FROM tbl_tipo_usuario WHERE tusu_estado='A'", cn);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new TipoUsuario
                        {
                            tusu_id = (int)dr["tusu_id"],
                            tusu_nombre = dr["tusu_nombre"].ToString(),
                            tusu_estado = dr["tusu_estado"].ToString()
                        });
                    }
                }
            }
            return lista;
        }
    }
}
