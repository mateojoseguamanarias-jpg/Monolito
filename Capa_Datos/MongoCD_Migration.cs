using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Capa_Datos
{
    public static class MongoCD_Migration
    {
        private static string GetSqlCnn()
        {
            string[] nombres = { "cnx", "Monolito4toConnectionString", "DefaultConnection", "MonolitoConnectionString", "ConexionBD" };
            foreach (string nombre in nombres) {
                var cs = ConfigurationManager.ConnectionStrings[nombre];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
            }
            return "";
        }

        public static void MigrateSqlToMongoIfNeeded()
        {
            try
            {
                var db = MongoDbContext.Database;
                var usuariosCol = db.GetCollection<BsonDocument>("Usuarios");
                
                // Si ya hay usuarios en MongoDB, asumimos que ya se migró o se está usando activamente, así que no sobreescribimos.
                if (usuariosCol.CountDocuments(new BsonDocument()) > 0)
                {
                    return;
                }

                string sqlConnStr = GetSqlCnn();
                if (string.IsNullOrEmpty(sqlConnStr)) return;

                // 1. MIGRAR CATEGORIAS
                var categoriasCol = db.GetCollection<BsonDocument>("Categorias");
                using (SqlConnection cn = new SqlConnection(sqlConnStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT cat_id, cat_nombre, cat_estado FROM tbl_categoria", cn);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int catId = Convert.ToInt32(dr["cat_id"]);
                            string catNombre = dr["cat_nombre"].ToString();
                            string catEstado = dr["cat_estado"].ToString();
                            
                            var doc = new BsonDocument
                            {
                                { "_id", catId },
                                { "cat_nombre", catNombre },
                                { "cat_estado", catEstado }
                            };
                            categoriasCol.ReplaceOne(
                                Builders<BsonDocument>.Filter.Eq("_id", catId),
                                doc,
                                new ReplaceOptions { IsUpsert = true }
                            );
                        }
                    }
                }

                // 2. MIGRAR PROVEEDORES
                var proveedoresCol = db.GetCollection<BsonDocument>("Proveedores");
                using (SqlConnection cn = new SqlConnection(sqlConnStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT prov_id, prov_nombre, prov_estado FROM tbl_proveedor", cn);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int provId = Convert.ToInt32(dr["prov_id"]);
                            string provNombre = dr["prov_nombre"].ToString();
                            string provEstado = dr["prov_estado"].ToString();
                            
                            var doc = new BsonDocument
                            {
                                { "_id", provId },
                                { "prov_nombre", provNombre },
                                { "prov_estado", provEstado }
                            };
                            proveedoresCol.ReplaceOne(
                                Builders<BsonDocument>.Filter.Eq("_id", provId),
                                doc,
                                new ReplaceOptions { IsUpsert = true }
                            );
                        }
                    }
                }

                // 3. MIGRAR PRODUCTOS
                var productosCol = db.GetCollection<BsonDocument>("Productos");
                using (SqlConnection cn = new SqlConnection(sqlConnStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT pro_id, pro_nombre, pro_cantidad, pro_precio, pro_estado, prov_id, cat_id, pro_ruta_foto FROM tbl_producto", cn);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int proId = Convert.ToInt32(dr["pro_id"]);
                            string proNombre = dr["pro_nombre"].ToString();
                            int proCantidad = Convert.ToInt32(dr["pro_cantidad"]);
                            double proPrecio = Convert.ToDouble(dr["pro_precio"]);
                            string proEstado = dr["pro_estado"].ToString();
                            
                            object provVal = dr["prov_id"];
                            BsonValue bProvId = (provVal == null || provVal == DBNull.Value) ? (BsonValue)BsonNull.Value : BsonValue.Create(Convert.ToInt32(provVal));
                            
                            object catVal = dr["cat_id"];
                            BsonValue bCatId = (catVal == null || catVal == DBNull.Value) ? (BsonValue)BsonNull.Value : BsonValue.Create(Convert.ToInt32(catVal));
                            
                            string proRutaFoto = dr["pro_ruta_foto"].ToString();

                            var doc = new BsonDocument
                            {
                                { "_id", proId },
                                { "pro_nombre", proNombre },
                                { "pro_cantidad", proCantidad },
                                { "pro_precio", proPrecio },
                                { "pro_estado", proEstado },
                                { "prov_id", bProvId },
                                { "cat_id", bCatId },
                                { "pro_ruta_foto", proRutaFoto },
                                { "pro_prev_prov_id", BsonNull.Value }
                            };
                            productosCol.ReplaceOne(
                                Builders<BsonDocument>.Filter.Eq("_id", proId),
                                doc,
                                new ReplaceOptions { IsUpsert = true }
                            );
                        }
                    }
                }

                // 4. MIGRAR PRODUCTO FOTOS
                var fotosCol = db.GetCollection<BsonDocument>("ProductoFotos");
                using (SqlConnection cn = new SqlConnection(sqlConnStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT pfot_id, pro_id, pfot_ruta_foto FROM tbl_producto_fotos", cn);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int pfotId = Convert.ToInt32(dr["pfot_id"]);
                            int proId = Convert.ToInt32(dr["pro_id"]);
                            string pfotRutaFoto = dr["pfot_ruta_foto"].ToString();

                            var doc = new BsonDocument
                            {
                                { "_id", pfotId },
                                { "pro_id", proId },
                                { "pfot_ruta_foto", pfotRutaFoto }
                            };
                            fotosCol.ReplaceOne(
                                Builders<BsonDocument>.Filter.Eq("_id", pfotId),
                                doc,
                                new ReplaceOptions { IsUpsert = true }
                            );
                        }
                    }
                }

                // 5. MIGRAR USUARIOS Y SUS FOTOS (DESENCRIPTAR CON SQL Y RE-ENCRIPTAR CON AES)
                using (SqlConnection cn = new SqlConnection(sqlConnStr))
                {
                    // Obtenemos los usuarios con su contraseña desencriptada
                    string sqlQuery = @"
                        SELECT usu_id, usu_cedula, usu_nombre, usu_apellidos, usu_correo, usu_nick, 
                               CONVERT(VARCHAR(500), DECRYPTBYPASSPHRASE('cl@ve', usu_contrasena)) AS decrypted_pass,
                               tusu_id, usu_celular, usu_direccion, usu_fecha_cumple, usu_estado, usu_puntos,
                               usu_google_id, usu_facebook_id, usu_codigo_OTP, usu_otp_hash
                        FROM tbl_usuario";
                    SqlCommand cmd = new SqlCommand(sqlQuery, cn);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int usuId = Convert.ToInt32(dr["usu_id"]);
                            string usuCedula = dr["usu_cedula"].ToString();
                            string usuNombre = dr["usu_nombre"].ToString();
                            string usuApellidos = dr["usu_apellidos"].ToString();
                            string usuCorreo = dr["usu_correo"].ToString();
                            string usuNick = dr["usu_nick"].ToString();
                            
                            string plainPass = dr["decrypted_pass"] != DBNull.Value ? dr["decrypted_pass"].ToString() : "123456";
                            string encryptedPass = SecurityHelper.Encrypt(plainPass);

                            int tusuId = Convert.ToInt32(dr["tusu_id"]);
                            string tusuNombre = tusuId == 1 ? "Administrador" : "Usuario";

                            string usuCelular = dr["usu_celular"].ToString();
                            string usuDireccion = dr["usu_direccion"].ToString();
                            
                            object cumpleVal = dr["usu_fecha_cumple"];
                            BsonValue bCumple = (cumpleVal == null || cumpleVal == DBNull.Value) ? (BsonValue)BsonNull.Value : BsonValue.Create(Convert.ToDateTime(cumpleVal).ToUniversalTime());

                            string usuEstado = dr["usu_estado"].ToString();
                            int usuPuntos = dr["usu_puntos"] != DBNull.Value ? Convert.ToInt32(dr["usu_puntos"]) : 0;

                            string usuGoogleId = dr["usu_google_id"].ToString();
                            string usuFacebookId = dr["usu_facebook_id"] != DBNull.Value ? dr["usu_facebook_id"].ToString() : "";
                            string usuCodigoOtp = dr["usu_codigo_OTP"].ToString();
                            string usuOtpHash = dr["usu_otp_hash"].ToString();

                            // Buscar fotos asociadas en SQL
                            var bFotos = new BsonArray();
                            using (SqlConnection cnFoto = new SqlConnection(sqlConnStr))
                            {
                                SqlCommand cmdFoto = new SqlCommand("SELECT foto_id, foto_data FROM tbl_usuario_fotos WHERE usu_id = @uid", cnFoto);
                                cmdFoto.Parameters.AddWithValue("@uid", usuId);
                                cnFoto.Open();
                                using (SqlDataReader drFoto = cmdFoto.ExecuteReader())
                                {
                                    while (drFoto.Read())
                                    {
                                        int fotoId = Convert.ToInt32(drFoto["foto_id"]);
                                        byte[] fotoData = (byte[])drFoto["foto_data"];

                                        bFotos.Add(new BsonDocument
                                        {
                                            { "foto_id", fotoId },
                                            { "foto_data", fotoData }
                                        });
                                    }
                                }
                            }

                            var doc = new BsonDocument
                            {
                                { "_id", usuId },
                                { "usu_cedula", usuCedula },
                                { "usu_nombre", usuNombre },
                                { "usu_apellidos", usuApellidos },
                                { "usu_correo", usuCorreo },
                                { "usu_nick", usuNick },
                                { "usu_contrasena", encryptedPass },
                                { "tusu_id", tusuId },
                                { "tusu_nombre", tusuNombre },
                                { "usu_celular", usuCelular },
                                { "usu_direccion", usuDireccion },
                                { "usu_fecha_cumple", bCumple },
                                { "usu_fecha_creacion", DateTime.UtcNow },
                                { "usu_estado", usuEstado },
                                { "usu_puntos", usuPuntos },
                                { "usu_google_id", usuGoogleId },
                                { "usu_facebook_id", usuFacebookId },
                                { "usu_codigo_OTP", usuCodigoOtp },
                                { "usu_otp_hash", usuOtpHash },
                                { "fotos", bFotos }
                            };

                            usuariosCol.ReplaceOne(
                                Builders<BsonDocument>.Filter.Eq("_id", usuId),
                                doc,
                                new ReplaceOptions { IsUpsert = true }
                            );
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Guardamos en consola para debugging si ocurre algún problema durante la migración automática
                System.Diagnostics.Debug.WriteLine("Error en la migración de SQL a MongoDB: " + ex.Message);
            }
        }
    }
}
