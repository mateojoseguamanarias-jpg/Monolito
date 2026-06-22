using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Capa_Datos
{
    public class CD_Usuario
    {
        private string GetCnn()
        {
            string[] nombres = { "cnx", "Monolito4toConnectionString", "DefaultConnection", "MonolitoConnectionString", "ConexionBD" };
            foreach (string nombre in nombres) {
                var cs = ConfigurationManager.ConnectionStrings[nombre];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
            }
            return "";
        }

        private string GetSafeString(SqlDataReader dr, string colName)
        {
            try {
                int ord = dr.GetOrdinal(colName);
                if (dr.IsDBNull(ord)) return "";
                return dr.GetValue(ord)?.ToString() ?? "";
            } catch {
                return "";
            }
        }

        private Usuario MapRowToUsuario(SqlDataReader dr)
        {
            var u = new Usuario();
            try { u.usu_id = Convert.ToInt32(dr["usu_id"]); } catch {}
            u.usu_nombre = GetSafeString(dr, "usu_nombre");
            u.usu_apellidos = GetSafeString(dr, "usu_apellidos");
            u.usu_nick = GetSafeString(dr, "usu_nick");
            u.usu_celular = GetSafeString(dr, "usu_celular");
            u.usu_direccion = GetSafeString(dr, "usu_direccion");
            try { u.tusu_id = Convert.ToInt32(dr["tusu_id"]); } catch {}
            u.usu_estado = GetSafeString(dr, "usu_estado");
            
            u.usu_cedula = GetSafeString(dr, "usu_cedula");
            if (string.IsNullOrEmpty(u.usu_cedula)) u.usu_cedula = GetSafeString(dr, "usu_cedula_id");

            u.usu_correo = GetSafeString(dr, "usu_correo");
            if (string.IsNullOrEmpty(u.usu_correo)) u.usu_correo = GetSafeString(dr, "usu_email");

            u.usu_google_id = GetSafeString(dr, "usu_google_id");
            u.usu_otp_hash = GetSafeString(dr, "usu_otp_hash");
            
            try {
                int ord = dr.GetOrdinal("usu_puntos");
                u.usu_puntos = dr.IsDBNull(ord) ? 0 : Convert.ToInt32(dr.GetValue(ord));
            } catch { u.usu_puntos = 0; }

            try {
                int ord = dr.GetOrdinal("usu_fecha_cumple");
                u.usu_fecha_cumple = dr.IsDBNull(ord) ? (DateTime?)null : Convert.ToDateTime(dr.GetValue(ord));
            } catch { u.usu_fecha_cumple = null; }

            return u;
        }

        public Usuario Login(string email, string pass)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_correo = @e AND usu_estado = 'A'", cn);
                cmd.Parameters.AddWithValue("@e", email);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        int id = Convert.ToInt32(dr["usu_id"]);
                        cn.Close(); // Cerramos para validar la clave con otra conexión

                        // Validamos la clave usando el motor de SQL
                        using (SqlConnection cn2 = new SqlConnection(GetCnn())) {
                            string sqlCheck = "SELECT * FROM tbl_usuario WHERE usu_id=@id AND DECRYPTBYPASSPHRASE('cl@ve', usu_contrasena) = @p";
                            SqlCommand cmd2 = new SqlCommand(sqlCheck, cn2);
                            cmd2.Parameters.AddWithValue("@id", id);
                            cmd2.Parameters.AddWithValue("@p", pass);
                            cn2.Open();
                            using (SqlDataReader dr2 = cmd2.ExecuteReader()) {
                                if (dr2.Read()) {
                                    return MapRowToUsuario(dr2);
                                }
                            }
                        }
                    }
                }
            }
            return null;
        }

        public Usuario ObtenerUsuarioPorId(int id)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_id = @id", cn);
                cmd.Parameters.AddWithValue("@id", id);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        return MapRowToUsuario(dr);
                    }
                }
            }
            return null;
        }

        public Usuario ObtenerUsuarioPorEmail(string email)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_correo = @e", cn);
                cmd.Parameters.AddWithValue("@e", email);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        return MapRowToUsuario(dr);
                    }
                }
            }
            return null;
        }

        public void VincularGoogle(int id, string gid)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_google_id=@g WHERE usu_id=@id", cn);
                cmd.Parameters.AddWithValue("@g", gid); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public void VincularFacebook(int id, string fid)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_facebook_id=@f WHERE usu_id=@id", cn);
                cmd.Parameters.AddWithValue("@f", fid); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public Usuario LoginPorGoogleId(string gid)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_google_id=@g AND usu_estado='A'", cn);
                cmd.Parameters.AddWithValue("@g", gid);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        return MapRowToUsuario(dr);
                    }
                }
            }
            return null;
        }

        public Usuario LoginPorFacebookId(string fid)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_facebook_id=@f AND usu_estado='A'", cn);
                cmd.Parameters.AddWithValue("@f", fid);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        return MapRowToUsuario(dr);
                    }
                }
            }
            return null;
        }

        public Usuario LoginPorQrCodigo(string qr)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_usuario WHERE usu_codigo_OTP=@qr AND usu_estado='A'", cn);
                cmd.Parameters.AddWithValue("@qr", qr);
                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader()) {
                    if (dr.Read()) {
                        return MapRowToUsuario(dr);
                    }
                }
            }
            return null;
        }

        public void ActualizarPerfil(int id, string nombre, string apellidos, string nick, string celular, string direccion, DateTime? fechaCumple, string email, string cedula)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = @"UPDATE tbl_usuario SET usu_nombre=@nom, usu_apellidos=@ape, usu_nick=@nick, 
                               usu_celular=@cel, usu_direccion=@dir, usu_fecha_cumple=@fec, usu_correo=@mail,
                               usu_cedula=@ced
                               WHERE usu_id=@id";
                SqlCommand cmd = new SqlCommand(sql, cn);
                cmd.Parameters.AddWithValue("@nom", nombre); cmd.Parameters.AddWithValue("@ape", (object)apellidos ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@nick", nick); cmd.Parameters.AddWithValue("@cel", (object)celular ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dir", (object)direccion ?? DBNull.Value); cmd.Parameters.AddWithValue("@fec", (object)fechaCumple ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@mail", email); cmd.Parameters.AddWithValue("@ced", (object)cedula ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public int Insertar(string cedula, string nombre, string apellidos, string correo, string nick, string pass, int tipoId, string celular, string direccion, DateTime? fechaCumple)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = @"INSERT INTO tbl_usuario (usu_cedula, usu_nombre, usu_apellidos, usu_correo, usu_nick, usu_contrasena, tusu_id, usu_celular, usu_direccion, usu_fecha_cumple, usu_fecha_creacion, usu_estado)
                               VALUES (@ced, @nom, @ape, @mail, @nick, ENCRYPTBYPASSPHRASE('cl@ve', @pass), @tid, @cel, @dir, @fec, GETDATE(), 'A'); SELECT SCOPE_IDENTITY();";
                SqlCommand cmd = new SqlCommand(sql, cn);
                cmd.Parameters.AddWithValue("@ced", (object)cedula ?? DBNull.Value); cmd.Parameters.AddWithValue("@nom", nombre); cmd.Parameters.AddWithValue("@ape", (object)apellidos ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@mail", correo); cmd.Parameters.AddWithValue("@nick", nick); cmd.Parameters.AddWithValue("@pass", pass);
                cmd.Parameters.AddWithValue("@tid", tipoId); cmd.Parameters.AddWithValue("@cel", (object)celular ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dir", (object)direccion ?? DBNull.Value); cmd.Parameters.AddWithValue("@fec", (object)fechaCumple ?? DBNull.Value);
                cn.Open(); return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public void InsertarFoto(int id, byte[] foto)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "IF EXISTS(SELECT 1 FROM tbl_usuario_fotos WHERE usu_id=@id) UPDATE tbl_usuario_fotos SET foto_data=@f WHERE usu_id=@id ELSE INSERT INTO tbl_usuario_fotos(usu_id, foto_data) VALUES(@id,@f)";
                SqlCommand cmd = new SqlCommand(sql, cn);
                cmd.Parameters.AddWithValue("@id", id); cmd.Parameters.AddWithValue("@f", foto);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public byte[] ObtenerFoto(int id)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT TOP 1 foto_data FROM tbl_usuario_fotos WHERE usu_id = @id ORDER BY foto_id DESC", cn);
                cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); object res = cmd.ExecuteScalar();
                return (res == null || res == DBNull.Value) ? null : (byte[])res;
            }
        }

        public byte[] ObtenerFotoPorId(int fotoId)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT foto_data FROM tbl_usuario_fotos WHERE foto_id = @fid", cn);
                cmd.Parameters.AddWithValue("@fid", fotoId);
                cn.Open(); object res = cmd.ExecuteScalar();
                return (res == null || res == DBNull.Value) ? null : (byte[])res;
            }
        }

        public DataTable ObtenerTodasFotos(int userId)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "SELECT foto_id FROM tbl_usuario_fotos WHERE usu_id = @id ORDER BY foto_id DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, cn);
                da.SelectCommand.Parameters.AddWithValue("@id", userId);
                DataTable dt = new DataTable(); da.Fill(dt); return dt;
            }
        }

        public void EliminarFoto(int fotoId)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("DELETE FROM tbl_usuario_fotos WHERE foto_id = @fid", cn);
                cmd.Parameters.AddWithValue("@fid", fotoId);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public DataTable ObtenerTodosUsuarios()
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = @"SELECT u.usu_id, u.usu_nombre, u.usu_apellidos, u.usu_nick, u.usu_correo, 
                               u.usu_celular, u.usu_direccion, u.usu_estado, 
                               (SELECT TOP 1 1 FROM tbl_usuario_fotos WHERE usu_id = u.usu_id) as tiene_foto,
                               ISNULL(u.usu_puntos, 0) as usu_puntos, t.tusu_nombre 
                               FROM tbl_usuario u 
                               INNER JOIN tbl_tipo_usuario t ON u.tusu_id = t.tusu_id 
                               WHERE u.usu_estado <> 'X'";
                SqlDataAdapter da = new SqlDataAdapter(sql, cn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        public void ActualizarEstado(int id, string est)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_estado=@e WHERE usu_id=@id", cn);
                cmd.Parameters.AddWithValue("@e", est); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public void GuardarOtpTemp(int id, string hash)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_otp_hash=@h WHERE usu_id=@id", cn);
                cmd.Parameters.AddWithValue("@h", (object)hash ?? DBNull.Value); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public void ActualizarPassword(string email, string pass)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_contrasena=ENCRYPTBYPASSPHRASE('cl@ve', @p) WHERE usu_correo=@e", cn);
                cmd.Parameters.AddWithValue("@p", pass); cmd.Parameters.AddWithValue("@e", email);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public DataTable ObtenerEstadisticas()
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = @"SELECT 
                                (SELECT COUNT(*) FROM tbl_usuario WHERE usu_estado <> 'X') as Total,
                                (SELECT COUNT(*) FROM tbl_usuario WHERE usu_estado = 'A') as Activos,
                                (SELECT COUNT(*) FROM tbl_usuario WHERE usu_estado = 'B') as Bloqueados";
                SqlDataAdapter da = new SqlDataAdapter(sql, cn);
                DataTable dt = new DataTable(); da.Fill(dt); return dt;
            }
        }

        public DataTable ObtenerTiposUsuario()
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "SELECT tusu_id, tusu_nombre FROM tbl_tipo_usuario WHERE tusu_estado = 'A'";
                SqlDataAdapter da = new SqlDataAdapter(sql, cn);
                DataTable dt = new DataTable(); da.Fill(dt); return dt;
            }
        }

        public int ObtenerSiguienteId()
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(usu_id), 0) + 1 FROM tbl_usuario", cn);
                cn.Open(); return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public void GuardarCodigoQrOtp(int id, string qr)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                SqlCommand cmd = new SqlCommand("UPDATE tbl_usuario SET usu_codigo_OTP=@qr WHERE usu_id=@id", cn);
                cmd.Parameters.AddWithValue("@qr", qr); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public void SumarPuntos(int id, int puntos)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "UPDATE tbl_usuario SET usu_puntos = ISNULL(usu_puntos,0) + @p WHERE usu_id = @id";
                SqlCommand cmd = new SqlCommand(sql, cn);
                cmd.Parameters.AddWithValue("@p", puntos); cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }

        public DataTable ObtenerUsuariosBloqueados()
        {
            DataTable dt = new DataTable();
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "SELECT usu_id, usu_nombre, usu_nick, usu_correo FROM tbl_usuario WHERE usu_estado = 'B'";
                SqlDataAdapter da = new SqlDataAdapter(sql, cn);
                da.Fill(dt);
            }
            return dt;
        }

        public void DesbloquearUsuario(int id)
        {
            using (SqlConnection cn = new SqlConnection(GetCnn())) {
                string sql = "UPDATE tbl_usuario SET usu_estado = 'A' WHERE usu_id = @id";
                SqlCommand cmd = new SqlCommand(sql, cn);
                cmd.Parameters.AddWithValue("@id", id);
                cn.Open(); cmd.ExecuteNonQuery();
            }
        }
    }
}
