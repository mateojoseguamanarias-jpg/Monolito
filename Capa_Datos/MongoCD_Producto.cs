using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using MongoDB.Bson;
using MongoDB.Driver;
using Capa_Negocio;

namespace Capa_Datos
{
    public static class MongoCD_Producto
    {
        private static IMongoCollection<BsonDocument> ProductosCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("Productos"); }
        }

        private static IMongoCollection<BsonDocument> CategoriasCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("Categorias"); }
        }

        private static IMongoCollection<BsonDocument> ProveedoresCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("Proveedores"); }
        }

        private static IMongoCollection<BsonDocument> FotosCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("ProductoFotos"); }
        }

        private static int ObtenerSiguienteId(string collectionName)
        {
            var collection = MongoDbContext.Database.GetCollection<BsonDocument>(collectionName);
            var sort = Builders<BsonDocument>.Sort.Descending("_id");
            var doc = collection.Find(new BsonDocument()).Sort(sort).FirstOrDefault();
            if (doc != null)
            {
                return doc["_id"].AsInt32 + 1;
            }
            return 1;
        }

        // ==========================================
        // CATEGORIAS
        // ==========================================
        public static List<tbl_categoria> ListarCategorias()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("cat_estado", "A");
            var list = CategoriasCollection.Find(filter).ToList();
            var result = new List<tbl_categoria>();
            foreach (var doc in list)
            {
                result.Add(new tbl_categoria
                {
                    cat_id = doc["_id"].AsInt32,
                    cat_nombre = doc.Contains("cat_nombre") ? doc["cat_nombre"].AsString : "",
                    cat_estado = 'A'
                });
            }
            return result;
        }

        // ==========================================
        // PROVEEDORES
        // ==========================================
        public static List<tbl_proveedor> ListarProveedoresActivos()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("prov_estado", "A");
            var list = ProveedoresCollection.Find(filter).ToList();
            var result = new List<tbl_proveedor>();
            foreach (var doc in list)
            {
                result.Add(new tbl_proveedor
                {
                    prov_id = doc["_id"].AsInt32,
                    prov_nombre = doc.Contains("prov_nombre") ? doc["prov_nombre"].AsString : "",
                    prov_estado = 'A'
                });
            }
            return result;
        }

        public static List<tbl_proveedor> ListarTodosProveedores()
        {
            var list = ProveedoresCollection.Find(new BsonDocument()).ToList();
            var result = new List<tbl_proveedor>();
            foreach (var doc in list)
            {
                string estStr = doc.Contains("prov_estado") ? doc["prov_estado"].AsString : "A";
                char est = estStr.Length > 0 ? estStr[0] : 'A';
                result.Add(new tbl_proveedor
                {
                    prov_id = doc["_id"].AsInt32,
                    prov_nombre = doc.Contains("prov_nombre") ? doc["prov_nombre"].AsString : "",
                    prov_estado = est
                });
            }
            return result;
        }

        public static void InsertarProveedor(string nombre)
        {
            int nextId = ObtenerSiguienteId("Proveedores");
            var doc = new BsonDocument
            {
                { "_id", nextId },
                { "prov_nombre", nombre },
                { "prov_estado", "A" }
            };
            ProveedoresCollection.InsertOne(doc);
        }

        public static void ActualizarProveedor(int id, string nombre)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("prov_nombre", nombre);
            ProveedoresCollection.UpdateOne(filter, update);
        }

        public static void EliminarProveedor(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("prov_estado", "I");
            ProveedoresCollection.UpdateOne(filter, update);

            // Respaldar relación en los productos (Hijos)
            var pFilter = Builders<BsonDocument>.Filter.Eq("prov_id", id);
            var pUpdate = Builders<BsonDocument>.Update
                .Set("pro_prev_prov_id", id)
                .Set("prov_id", BsonNull.Value);
            ProductosCollection.UpdateMany(pFilter, pUpdate);
        }

        public static void RestaurarProveedor(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("prov_estado", "A");
            ProveedoresCollection.UpdateOne(filter, update);

            // Volver a vincular los productos hijos que fueron desvinculados
            var pFilter = Builders<BsonDocument>.Filter.Eq("pro_prev_prov_id", id);
            var pUpdate = Builders<BsonDocument>.Update
                .Set("prov_id", id)
                .Set("pro_prev_prov_id", BsonNull.Value);
            ProductosCollection.UpdateMany(pFilter, pUpdate);
        }

        // ==========================================
        // PRODUCTOS
        // ==========================================
        public static List<ProductoInfo> ListarProductos(string busqueda = "", int? catId = null, int? provId = null)
        {
            var filters = new List<FilterDefinition<BsonDocument>>();
            filters.Add(Builders<BsonDocument>.Filter.Eq("pro_estado", "A"));

            if (!string.IsNullOrWhiteSpace(busqueda))
            {
                filters.Add(Builders<BsonDocument>.Filter.Regex("pro_nombre", new BsonRegularExpression(busqueda, "i")));
            }

            if (catId.HasValue && catId.Value > 0)
            {
                filters.Add(Builders<BsonDocument>.Filter.Eq("cat_id", catId.Value));
            }

            if (provId.HasValue && provId.Value > 0)
            {
                filters.Add(Builders<BsonDocument>.Filter.Eq("prov_id", provId.Value));
            }

            var filter = Builders<BsonDocument>.Filter.And(filters);
            var sort = Builders<BsonDocument>.Sort.Descending("_id");
            var list = ProductosCollection.Find(filter).Sort(sort).ToList();

            var result = new List<ProductoInfo>();
            foreach (var doc in list)
            {
                int? pCatId = doc.Contains("cat_id") && !doc["cat_id"].IsBsonNull ? (int?)doc["cat_id"].AsInt32 : null;
                int? pProvId = doc.Contains("prov_id") && !doc["prov_id"].IsBsonNull ? (int?)doc["prov_id"].AsInt32 : null;

                string catNombre = "Sin Categoría";
                if (pCatId.HasValue)
                {
                    var catDoc = CategoriasCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", pCatId.Value)).FirstOrDefault();
                    if (catDoc != null) catNombre = catDoc["cat_nombre"].AsString;
                }

                string provNombre = "Sin Proveedor";
                if (pProvId.HasValue)
                {
                    var provDoc = ProveedoresCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", pProvId.Value)).FirstOrDefault();
                    if (provDoc != null) provNombre = provDoc["prov_nombre"].AsString;
                }

                string estadoStr = doc.Contains("pro_estado") ? doc["pro_estado"].AsString : "A";
                char? estado = estadoStr.Length > 0 ? estadoStr[0] : 'A';

                int? prevProvId = doc.Contains("pro_prev_prov_id") && !doc["pro_prev_prov_id"].IsBsonNull ? (int?)doc["pro_prev_prov_id"].AsInt32 : null;

                result.Add(new ProductoInfo
                {
                    pro_id = doc["_id"].AsInt32,
                    pro_nombre = doc.Contains("pro_nombre") ? doc["pro_nombre"].AsString : "",
                    pro_cantidad = doc.Contains("pro_cantidad") ? doc["pro_cantidad"].AsInt32 : 0,
                    pro_precio = doc.Contains("pro_precio") ? (decimal)doc["pro_precio"].AsDouble : 0m,
                    pro_estado = estado,
                    prov_id = pProvId,
                    prov_nombre = provNombre,
                    cat_id = pCatId,
                    cat_nombre = catNombre,
                    pro_ruta_foto = doc.Contains("pro_ruta_foto") ? doc["pro_ruta_foto"].AsString : "~/wwwroot/imagen/default.png",
                    pro_prev_prov_id = prevProvId
                });
            }
            return result;
        }

        public static ProductoInfo ObtenerProductoPorId(int id)
        {
            var doc = ProductosCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", id)).FirstOrDefault();
            if (doc == null) return null;

            int? pCatId = doc.Contains("cat_id") && !doc["cat_id"].IsBsonNull ? (int?)doc["cat_id"].AsInt32 : null;
            int? pProvId = doc.Contains("prov_id") && !doc["prov_id"].IsBsonNull ? (int?)doc["prov_id"].AsInt32 : null;

            string catNombre = "Sin Categoría";
            if (pCatId.HasValue)
            {
                var catDoc = CategoriasCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", pCatId.Value)).FirstOrDefault();
                if (catDoc != null) catNombre = catDoc["cat_nombre"].AsString;
            }

            string provNombre = "Sin Proveedor";
            if (pProvId.HasValue)
            {
                var provDoc = ProveedoresCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", pProvId.Value)).FirstOrDefault();
                if (provDoc != null) provNombre = provDoc["prov_nombre"].AsString;
            }

            string estadoStr = doc.Contains("pro_estado") ? doc["pro_estado"].AsString : "A";
            char? estado = estadoStr.Length > 0 ? estadoStr[0] : 'A';

            int? prevProvId = doc.Contains("pro_prev_prov_id") && !doc["pro_prev_prov_id"].IsBsonNull ? (int?)doc["pro_prev_prov_id"].AsInt32 : null;

            return new ProductoInfo
            {
                pro_id = doc["_id"].AsInt32,
                pro_nombre = doc.Contains("pro_nombre") ? doc["pro_nombre"].AsString : "",
                pro_cantidad = doc.Contains("pro_cantidad") ? doc["pro_cantidad"].AsInt32 : 0,
                pro_precio = doc.Contains("pro_precio") ? (decimal)doc["pro_precio"].AsDouble : 0m,
                pro_estado = estado,
                prov_id = pProvId,
                prov_nombre = provNombre,
                cat_id = pCatId,
                cat_nombre = catNombre,
                pro_ruta_foto = doc.Contains("pro_ruta_foto") ? doc["pro_ruta_foto"].AsString : "~/wwwroot/imagen/default.png",
                pro_prev_prov_id = prevProvId
            };
        }

        public static int InsertarProducto(string nombre, int cantidad, decimal precio, int? provId, int? catId, string rutaFoto)
        {
            int nextId = ObtenerSiguienteId("Productos");
            var doc = new BsonDocument
            {
                { "_id", nextId },
                { "pro_nombre", nombre },
                { "pro_cantidad", cantidad },
                { "pro_precio", (double)precio },
                { "pro_estado", "A" },
                { "prov_id", provId.HasValue ? (BsonValue)provId.Value : BsonNull.Value },
                { "cat_id", catId.HasValue ? (BsonValue)catId.Value : BsonNull.Value },
                { "pro_ruta_foto", string.IsNullOrWhiteSpace(rutaFoto) ? "~/wwwroot/imagen/default.png" : rutaFoto },
                { "pro_prev_prov_id", BsonNull.Value }
            };
            ProductosCollection.InsertOne(doc);
            return nextId;
        }

        public static void ActualizarProducto(int id, string nombre, int cantidad, decimal precio, int? provId, int? catId, string rutaFoto)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update
                .Set("pro_nombre", nombre)
                .Set("pro_cantidad", cantidad)
                .Set("pro_precio", (double)precio)
                .Set("prov_id", provId.HasValue ? (BsonValue)provId.Value : BsonNull.Value)
                .Set("cat_id", catId.HasValue ? (BsonValue)catId.Value : BsonNull.Value);

            if (!string.IsNullOrWhiteSpace(rutaFoto))
            {
                update = update.Set("pro_ruta_foto", rutaFoto);
            }

            ProductosCollection.UpdateOne(filter, update);
        }

        public static void EliminarProducto(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("pro_estado", "I");
            ProductosCollection.UpdateOne(filter, update);
        }

        public static List<CategoryStatInfo> ObtenerEstadisticasCategoria()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_estado", "A");
            var prods = ProductosCollection.Find(filter).ToList();
            var dict = new Dictionary<string, int>();

            foreach (var doc in prods)
            {
                int? catId = doc.Contains("cat_id") && !doc["cat_id"].IsBsonNull ? (int?)doc["cat_id"].AsInt32 : null;
                string catNombre = "Sin Categoría";
                if (catId.HasValue)
                {
                    var catDoc = CategoriasCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", catId.Value)).FirstOrDefault();
                    if (catDoc != null) catNombre = catDoc["cat_nombre"].AsString;
                }
                if (dict.ContainsKey(catNombre)) dict[catNombre]++;
                else dict[catNombre] = 1;
            }

            return dict.Select(x => new CategoryStatInfo
            {
                Categoria = x.Key,
                CantidadProductos = x.Value
            }).ToList();
        }

        public static List<StockStatInfo> ObtenerEstadisticasStock()
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_estado", "A");
            var prods = ProductosCollection.Find(filter).Limit(10).ToList();

            return prods.Select(doc => new StockStatInfo
            {
                Producto = doc.Contains("pro_nombre") ? doc["pro_nombre"].AsString : "",
                Stock = doc.Contains("pro_cantidad") ? doc["pro_cantidad"].AsInt32 : 0
            }).ToList();
        }

        public static void GuardarSubidaMasiva(List<ProductoInfo> productos)
        {
            foreach (var prod in productos)
            {
                // Buscar o crear Categoría
                var catFilter = Builders<BsonDocument>.Filter.Regex("cat_nombre", new BsonRegularExpression("^" + prod.cat_nombre + "$", "i"));
                var catDoc = CategoriasCollection.Find(catFilter).FirstOrDefault();
                int catId;
                if (catDoc == null)
                {
                    catId = ObtenerSiguienteId("Categorias");
                    var newCat = new BsonDocument
                    {
                        { "_id", catId },
                        { "cat_nombre", prod.cat_nombre },
                        { "cat_estado", "A" }
                    };
                    CategoriasCollection.InsertOne(newCat);
                }
                else
                {
                    catId = catDoc["_id"].AsInt32;
                }

                // Buscar o crear Proveedor
                var provFilter = Builders<BsonDocument>.Filter.Regex("prov_nombre", new BsonRegularExpression("^" + prod.prov_nombre + "$", "i"));
                var provDoc = ProveedoresCollection.Find(provFilter).FirstOrDefault();
                int provId;
                if (provDoc == null)
                {
                    provId = ObtenerSiguienteId("Proveedores");
                    var newProv = new BsonDocument
                    {
                        { "_id", provId },
                        { "prov_nombre", prod.prov_nombre },
                        { "prov_estado", "A" }
                    };
                    ProveedoresCollection.InsertOne(newProv);
                }
                else
                {
                    provId = provDoc["_id"].AsInt32;
                }

                // Crear Producto
                int proId = InsertarProducto(prod.pro_nombre, prod.pro_cantidad, prod.pro_precio, provId, catId, prod.pro_ruta_foto);

                // Auto-poblar carrusel con 5 imágenes relacionadas
                if (prod.pro_ruta_foto != "~/wwwroot/imagen/default.png" && !string.IsNullOrWhiteSpace(prod.pro_ruta_foto))
                {
                    string rutaBase = prod.pro_ruta_foto;
                    string ext = System.IO.Path.GetExtension(rutaBase);
                    string nombreSinExt = rutaBase.Substring(0, rutaBase.Length - ext.Length);

                    for (int idx = 1; idx <= 5; idx++)
                    {
                        string rutaFotoCarrusel = string.Format("{0}_{1}{2}", nombreSinExt, idx, ext);
                        InsertarFoto(proId, rutaFotoCarrusel);
                    }
                }
            }
        }

        public static void InsertarFoto(int proId, string rutaFoto)
        {
            int nextId = ObtenerSiguienteId("ProductoFotos");
            var doc = new BsonDocument
            {
                { "_id", nextId },
                { "pro_id", proId },
                { "pfot_ruta_foto", rutaFoto }
            };
            FotosCollection.InsertOne(doc);
        }

        public static List<string> ObtenerFotos(int proId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_id", proId);
            var list = FotosCollection.Find(filter).ToList();
            return list.Select(doc => doc["pfot_ruta_foto"].AsString).ToList();
        }

        public static void EliminarFotos(int proId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("pro_id", proId);
            FotosCollection.DeleteMany(filter);
        }
    }
}
