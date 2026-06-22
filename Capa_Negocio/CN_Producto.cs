using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public class ProductoInfo
    {
        public int pro_id { get; set; }
        public string pro_nombre { get; set; }
        public int pro_cantidad { get; set; }
        public decimal pro_precio { get; set; }
        public char? pro_estado { get; set; }
        public int? prov_id { get; set; }
        public string prov_nombre { get; set; }
        public int? cat_id { get; set; }
        public string cat_nombre { get; set; }
        public string pro_ruta_foto { get; set; }
        public int? pro_prev_prov_id { get; set; }
    }

    public class CategoryStatInfo
    {
        public string Categoria { get; set; }
        public int CantidadProductos { get; set; }
    }

    public class StockStatInfo
    {
        public string Producto { get; set; }
        public int Stock { get; set; }
    }

    public static class CN_Producto
    {
        private static string Provider => System.Configuration.ConfigurationManager.AppSettings["DatabaseProvider"] ?? "SQL";

        /// <summary>
        /// Obtiene y filtra productos activos con soporte para búsqueda rápida estilo Facebook.
        /// </summary>
        public static List<ProductoInfo> Listar(string busqueda = "", int? catId = null, int? provId = null)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ListarProductos(busqueda, catId, provId);
            }

            using (var db = new DataClasses1DataContext())
            {
                var query = db.tbl_producto.Where(p => p.pro_estado == 'A');

                if (!string.IsNullOrWhiteSpace(busqueda))
                {
                    query = query.Where(p => p.pro_nombre.Contains(busqueda));
                }

                if (catId.HasValue && catId.Value > 0)
                {
                    query = query.Where(p => p.cat_id == catId.Value);
                }

                if (provId.HasValue && provId.Value > 0)
                {
                    query = query.Where(p => p.prov_id == provId.Value);
                }

                return query.OrderByDescending(p => p.pro_id).Select(p => new ProductoInfo
                {
                    pro_id = p.pro_id,
                    pro_nombre = p.pro_nombre,
                    pro_cantidad = p.pro_cantidad,
                    pro_precio = p.pro_precio,
                    pro_estado = p.pro_estado,
                    prov_id = p.prov_id,
                    prov_nombre = p.tbl_proveedor != null ? p.tbl_proveedor.prov_nombre : "Sin Proveedor",
                    cat_id = p.cat_id,
                    cat_nombre = p.tbl_categoria != null ? p.tbl_categoria.cat_nombre : "Sin Categoría",
                    pro_ruta_foto = p.pro_ruta_foto,
                    pro_prev_prov_id = p.pro_prev_prov_id
                }).ToList();
            }
        }

        /// <summary>
        /// Obtiene un producto por su ID.
        /// </summary>
        public static ProductoInfo ObtenerPorId(int id)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ObtenerProductoPorId(id);
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_producto.FirstOrDefault(x => x.pro_id == id);
                if (p == null) return null;

                return new ProductoInfo
                {
                    pro_id = p.pro_id,
                    pro_nombre = p.pro_nombre,
                    pro_cantidad = p.pro_cantidad,
                    pro_precio = p.pro_precio,
                    pro_estado = p.pro_estado,
                    prov_id = p.prov_id,
                    prov_nombre = p.tbl_proveedor != null ? p.tbl_proveedor.prov_nombre : "Sin Proveedor",
                    cat_id = p.cat_id,
                    cat_nombre = p.tbl_categoria != null ? p.tbl_categoria.cat_nombre : "Sin Categoría",
                    pro_ruta_foto = p.pro_ruta_foto,
                    pro_prev_prov_id = p.pro_prev_prov_id
                };
            }
        }

        /// <summary>
        /// Inserta un producto.
        /// </summary>
        public static int Insertar(string nombre, int cantidad, decimal precio, int? provId, int? catId, string rutaFoto)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.InsertarProducto(nombre, cantidad, precio, provId, catId, rutaFoto);
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = new tbl_producto
                {
                    pro_nombre = nombre,
                    pro_cantidad = cantidad,
                    pro_precio = precio,
                    pro_estado = 'A',
                    prov_id = provId,
                    cat_id = catId,
                    pro_ruta_foto = string.IsNullOrWhiteSpace(rutaFoto) ? "~/wwwroot/imagen/default.png" : rutaFoto
                };
                db.tbl_producto.InsertOnSubmit(p);
                db.SubmitChanges();
                return p.pro_id;
            }
        }

        /// <summary>
        /// Actualiza un producto existente.
        /// </summary>
        public static void Actualizar(int id, string nombre, int cantidad, decimal precio, int? provId, int? catId, string rutaFoto)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.ActualizarProducto(id, nombre, cantidad, precio, provId, catId, rutaFoto);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_producto.FirstOrDefault(x => x.pro_id == id);
                if (p != null)
                {
                    p.pro_nombre = nombre;
                    p.pro_cantidad = cantidad;
                    p.pro_precio = precio;
                    p.prov_id = provId;
                    p.cat_id = catId;
                    if (!string.IsNullOrWhiteSpace(rutaFoto))
                    {
                        p.pro_ruta_foto = rutaFoto;
                    }
                    db.SubmitChanges();
                }
            }
        }

        /// <summary>
        /// Realiza el borrado lógico de un producto.
        /// </summary>
        public static void Eliminar(int id)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.EliminarProducto(id);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_producto.FirstOrDefault(x => x.pro_id == id);
                if (p != null)
                {
                    p.pro_estado = 'I';
                    db.SubmitChanges();
                }
            }
        }

        /// <summary>
        /// Obtiene estadísticas de cantidad de productos agrupados por Categoría (para gráficos).
        /// </summary>
        public static List<CategoryStatInfo> ObtenerEstadisticasCategoria()
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ObtenerEstadisticasCategoria();
            }

            using (var db = new DataClasses1DataContext())
            {
                return db.tbl_producto
                    .Where(p => p.pro_estado == 'A')
                    .GroupBy(p => p.tbl_categoria != null ? p.tbl_categoria.cat_nombre : "Sin Categoría")
                    .Select(g => new CategoryStatInfo
                    {
                        Categoria = g.Key,
                        CantidadProductos = g.Count()
                    }).ToList();
            }
        }

        /// <summary>
        /// Obtiene el stock actual de cada producto (para gráficos).
        /// </summary>
        public static List<StockStatInfo> ObtenerEstadisticasStock()
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ObtenerEstadisticasStock();
            }

            using (var db = new DataClasses1DataContext())
            {
                return db.tbl_producto
                    .Where(p => p.pro_estado == 'A')
                    .Select(p => new StockStatInfo
                    {
                        Producto = p.pro_nombre,
                        Stock = p.pro_cantidad
                    }).Take(10).ToList(); // Tomar los primeros 10 para mejor legibilidad en el chart
            }
        }

        /// <summary>
        /// Procesa y previsualiza un archivo CSV.
        /// Requisito 7: Lee líneas de archivo plano y vincula dinámicamente padres e hijos.
        /// Si no existe el Proveedor o Categoría, se marcan para creación o vinculación directa.
        /// NOTA: Las imágenes del CSV son solo nombres referenciales — el archivo físico debe
        /// subirse manualmente a wwwroot/imagen/. Si no existe, se asigna la imagen por defecto.
        /// </summary>
        public static List<ProductoInfo> VistaPreviaCSV(string contenidoArchivo)
        {
            var productos = new List<ProductoInfo>();
            var lineas = contenidoArchivo.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);

            if (lineas.Length <= 1) return productos; // Archivo vacío o solo cabecera

            // Auto-detectar delimitador: si contiene punto y coma (;), asumimos que es el separador de columnas (estándar Excel en español)
            char separador = contenidoArchivo.Contains(";") ? ';' : ',';

            // Procesar líneas saltando la cabecera
            for (int i = 1; i < lineas.Length; i++)
            {
                var partes = ParsearLineaCSV(lineas[i], separador);

                if (partes.Count < 5) continue; // Línea inválida — mínimo: nombre, cantidad, precio, cat, prov

                string nombre    = partes[0].Trim();
                string strCant   = partes[1].Trim();
                string strPrecio = partes[2].Trim();
                string catNombre = partes[3].Trim();
                string provNombre= partes[4].Trim();

                if (string.IsNullOrWhiteSpace(nombre) || string.IsNullOrWhiteSpace(catNombre) || string.IsNullOrWhiteSpace(provNombre))
                    continue;

                int.TryParse(strCant, out int cantidad);

                // Parseo de decimal robusto: limpia símbolo de dólar y soporta "65.90" y "65,90"
                string cleanPrecio = strPrecio.Replace("$", "").Trim();
                decimal precio = 0;
                if (!decimal.TryParse(cleanPrecio, System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.InvariantCulture, out precio))
                {
                    decimal.TryParse(cleanPrecio.Replace(".", ","),
                        System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.CurrentCulture, out precio);
                }

                // Construir ruta de foto
                string fotoRuta = "~/wwwroot/imagen/default.png";
                if (partes.Count >= 6 && !string.IsNullOrWhiteSpace(partes[5]))
                {
                    string fotoNombre = partes[5].Trim();
                    if (fotoNombre.StartsWith("~/"))
                        fotoRuta = fotoNombre;                          // Ruta virtual completa
                    else
                        fotoRuta = "~/wwwroot/imagen/" + fotoNombre;   // Solo nombre de archivo → agregar ruta
                }

                productos.Add(new ProductoInfo
                {
                    pro_nombre   = nombre,
                    pro_cantidad = cantidad,
                    pro_precio   = precio,
                    cat_nombre   = catNombre,
                    prov_nombre  = provNombre,
                    pro_ruta_foto= fotoRuta
                });
            }

            return productos;
        }

        /// <summary>
        /// Parsea una línea CSV respetando campos entre comillas dobles y el delimitador dinámico.
        /// </summary>
        private static List<string> ParsearLineaCSV(string linea, char separador)
        {
            var campos  = new List<string>();
            var actual  = new System.Text.StringBuilder();
            bool enComillas = false;

            for (int i = 0; i < linea.Length; i++)
            {
                char c = linea[i];

                if (c == '"')
                {
                    // Comilla doble escapada ("") dentro de campo entre comillas
                    if (enComillas && i + 1 < linea.Length && linea[i + 1] == '"')
                    {
                        actual.Append('"');
                        i++; // Saltar la siguiente comilla
                    }
                    else
                    {
                        enComillas = !enComillas; // Abrir/cerrar campo entre comillas
                    }
                }
                else if (c == separador && !enComillas)
                {
                    campos.Add(actual.ToString());
                    actual.Clear();
                }
                else
                {
                    actual.Append(c);
                }
            }

            campos.Add(actual.ToString()); // Último campo
            return campos;
        }


        /// <summary>
        /// Guarda en base de datos los productos y crea dinámicamente los padres (Categoría y Proveedor) si no existen.
        /// </summary>
        public static void GuardarSubidaMasiva(List<ProductoInfo> productos)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.GuardarSubidaMasiva(productos);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                foreach (var prod in productos)
                {
                    // Buscar o crear la Categoría (Padre)
                    var cat = db.tbl_categoria.FirstOrDefault(c => c.cat_nombre.ToLower() == prod.cat_nombre.ToLower());
                    if (cat == null)
                    {
                        cat = new tbl_categoria { cat_nombre = prod.cat_nombre, cat_estado = 'A' };
                        db.tbl_categoria.InsertOnSubmit(cat);
                        db.SubmitChanges(); // Guardar para obtener el ID asignado
                    }

                    // Buscar o crear el Proveedor (Padre)
                    var prov = db.tbl_proveedor.FirstOrDefault(p => p.prov_nombre.ToLower() == prod.prov_nombre.ToLower());
                    if (prov == null)
                    {
                        prov = new tbl_proveedor { prov_nombre = prod.prov_nombre, prov_estado = 'A' };
                        db.tbl_proveedor.InsertOnSubmit(prov);
                        db.SubmitChanges(); // Guardar para obtener el ID asignado
                    }

                    // Crear el producto vinculado
                    var prodNuevo = new tbl_producto
                    {
                        pro_nombre = prod.pro_nombre,
                        pro_cantidad = prod.pro_cantidad,
                        pro_precio = prod.pro_precio,
                        pro_estado = 'A',
                        cat_id = cat.cat_id,
                        prov_id = prov.prov_id,
                        pro_ruta_foto = prod.pro_ruta_foto
                    };
                    db.tbl_producto.InsertOnSubmit(prodNuevo);
                }

                db.SubmitChanges();

                // Auto-poblar carrusel con 5 imágenes relacionadas
                foreach (var prod in productos)
                {
                    if (prod.pro_ruta_foto != "~/wwwroot/imagen/default.png" && !string.IsNullOrWhiteSpace(prod.pro_ruta_foto))
                    {
                        var pDb = db.tbl_producto.FirstOrDefault(x => x.pro_nombre == prod.pro_nombre && x.pro_estado == 'A');
                        if (pDb != null)
                        {
                            string rutaBase = prod.pro_ruta_foto;
                            string ext = System.IO.Path.GetExtension(rutaBase);
                            string nombreSinExt = rutaBase.Substring(0, rutaBase.Length - ext.Length);

                            for (int idx = 1; idx <= 5; idx++)
                            {
                                string rutaFotoCarrusel = string.Format("{0}_{1}{2}", nombreSinExt, idx, ext);
                                InsertarFoto(pDb.pro_id, rutaFotoCarrusel);
                            }
                        }
                    }
                }
            }
        }

        private static string GetCnn()
        {
            string[] nombres = { "cnx", "Monolito4toConnectionString", "DefaultConnection", "MonolitoConnectionString", "ConexionBD" };
            foreach (string nombre in nombres) {
                var cs = System.Configuration.ConfigurationManager.ConnectionStrings[nombre];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
            }
            return "";
        }

        public static void InsertarFoto(int proId, string rutaFoto)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.InsertarFoto(proId, rutaFoto);
                return;
            }

            using (var cn = new System.Data.SqlClient.SqlConnection(GetCnn()))
            {
                string sql = "INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@proId, @ruta)";
                using (var cmd = new System.Data.SqlClient.SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@proId", proId);
                    cmd.Parameters.AddWithValue("@ruta", rutaFoto);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static List<string> ObtenerFotos(int proId)
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ObtenerFotos(proId);
            }

            var list = new List<string>();
            using (var cn = new System.Data.SqlClient.SqlConnection(GetCnn()))
            {
                string sql = "SELECT pfot_ruta_foto FROM tbl_producto_fotos WHERE pro_id = @proId";
                using (var cmd = new System.Data.SqlClient.SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@proId", proId);
                    cn.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            list.Add(dr["pfot_ruta_foto"].ToString());
                        }
                    }
                }
            }
            return list;
        }

        public static void EliminarFotos(int proId)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.EliminarFotos(proId);
                return;
            }

            using (var cn = new System.Data.SqlClient.SqlConnection(GetCnn()))
            {
                string sql = "DELETE FROM tbl_producto_fotos WHERE pro_id = @proId";
                using (var cmd = new System.Data.SqlClient.SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@proId", proId);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
