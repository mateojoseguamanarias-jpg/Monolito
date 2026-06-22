using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Configuration;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CarritoItem
    {
        public int car_id       { get; set; }
        public int usu_id       { get; set; }
        public int pro_id       { get; set; }
        public string pro_nombre   { get; set; }
        public decimal pro_precio  { get; set; }
        public int pro_cantidad    { get; set; }
        public string pro_ruta_foto { get; set; }
        public string cat_nombre   { get; set; }
        public string prov_nombre  { get; set; }
        public DateTime car_fecha  { get; set; }
    }

    public static class CN_Carrito
    {
        private static string Provider => ConfigurationManager.AppSettings["DatabaseProvider"] ?? "SQL";

        private static string GetCnn()
        {
            string[] nombres = { "cnx", "Monolito4toConnectionString", "DefaultConnection", "MonolitoConnectionString", "ConexionBD" };
            foreach (string n in nombres)
            {
                var cs = ConfigurationManager.ConnectionStrings[n];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString))
                    return cs.ConnectionString;
            }
            return "";
        }

        /// <summary>
        /// Agrega un producto al carrito del usuario.
        /// Si ya existe, no hace nada (UNIQUE constraint).
        /// Retorna true si fue agregado, false si ya estaba.
        /// </summary>
        public static bool Agregar(int usuId, int proId)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Carrito.Agregar(usuId, proId);
            }

            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = @"IF NOT EXISTS (SELECT 1 FROM tbl_carrito WHERE usu_id=@uid AND pro_id=@pid)
                               BEGIN INSERT INTO tbl_carrito (usu_id, pro_id) VALUES (@uid, @pid) END";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", usuId);
                    cmd.Parameters.AddWithValue("@pid", proId);
                    cn.Open();
                    int rows = cmd.ExecuteNonQuery();
                    return rows > 0;
                }
            }
        }

        /// <summary>
        /// Elimina un producto del carrito por car_id.
        /// </summary>
        public static void Eliminar(int carId)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Carrito.Eliminar(carId);
                return;
            }

            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = "DELETE FROM tbl_carrito WHERE car_id = @cid";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@cid", carId);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina un producto del carrito por usuario y producto.
        /// </summary>
        public static void EliminarPorUsuYProd(int usuId, int proId)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Carrito.EliminarPorUsuYProd(usuId, proId);
                return;
            }

            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = "DELETE FROM tbl_carrito WHERE usu_id=@uid AND pro_id=@pid";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", usuId);
                    cmd.Parameters.AddWithValue("@pid", proId);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Verifica si un producto ya está en el carrito del usuario.
        /// </summary>
        public static bool EstaEnCarrito(int usuId, int proId)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Carrito.EstaEnCarrito(usuId, proId);
            }

            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = "SELECT COUNT(1) FROM tbl_carrito WHERE usu_id=@uid AND pro_id=@pid";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", usuId);
                    cmd.Parameters.AddWithValue("@pid", proId);
                    cn.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        /// <summary>
        /// Obtiene todos los productos guardados en el carrito de un usuario,
        /// incluyendo detalle del producto (nombre, precio, foto, etc.).
        /// </summary>
        public static List<CarritoItem> ListarPorUsuario(int usuId)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Carrito.ListarPorUsuario(usuId);
            }

            var lista = new List<CarritoItem>();
            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = @"
                    SELECT  c.car_id, c.usu_id, c.pro_id, c.car_fecha,
                            p.pro_nombre, p.pro_precio, p.pro_cantidad, p.pro_ruta_foto,
                            cat.cat_nombre, prov.prov_nombre
                    FROM    tbl_carrito c
                    INNER JOIN tbl_producto p    ON p.pro_id   = c.pro_id
                    LEFT  JOIN tbl_categoria cat ON cat.cat_id = p.cat_id
                    LEFT  JOIN tbl_proveedor prov ON prov.prov_id = p.prov_id
                    WHERE  c.usu_id = @uid
                    ORDER BY c.car_fecha DESC";

                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", usuId);
                    cn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CarritoItem
                            {
                                car_id      = Convert.ToInt32(dr["car_id"]),
                                usu_id      = Convert.ToInt32(dr["usu_id"]),
                                pro_id      = Convert.ToInt32(dr["pro_id"]),
                                car_fecha   = Convert.ToDateTime(dr["car_fecha"]),
                                pro_nombre  = dr["pro_nombre"].ToString(),
                                pro_precio  = Convert.ToDecimal(dr["pro_precio"]),
                                pro_cantidad= Convert.ToInt32(dr["pro_cantidad"]),
                                pro_ruta_foto = dr["pro_ruta_foto"].ToString(),
                                cat_nombre  = dr["cat_nombre"] == DBNull.Value ? "Sin Categoría" : dr["cat_nombre"].ToString(),
                                prov_nombre = dr["prov_nombre"] == DBNull.Value ? "Sin Proveedor"  : dr["prov_nombre"].ToString()
                            });
                        }
                    }
                }
            }
            return lista;
        }

        /// <summary>
        /// Obtiene los IDs de productos que ya están en el carrito del usuario.
        /// Útil para marcar los productos que ya fueron guardados en VerProductos.
        /// </summary>
        public static HashSet<int> ObtenerIdsEnCarrito(int usuId)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Carrito.ObtenerIdsEnCarrito(usuId);
            }

            var ids = new HashSet<int>();
            using (var cn = new SqlConnection(GetCnn()))
            {
                string sql = "SELECT pro_id FROM tbl_carrito WHERE usu_id = @uid";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", usuId);
                    cn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            ids.Add(Convert.ToInt32(dr["pro_id"]));
                    }
                }
            }
            return ids;
        }
    }
}
