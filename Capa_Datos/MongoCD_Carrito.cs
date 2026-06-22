using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Bson;
using MongoDB.Driver;
using Capa_Negocio;

namespace Capa_Datos
{
    public static class MongoCD_Carrito
    {
        private static IMongoCollection<BsonDocument> CarritoCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("Carrito"); }
        }

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

        private static int ObtenerSiguienteId()
        {
            var sort = Builders<BsonDocument>.Sort.Descending("_id");
            var doc = CarritoCollection.Find(new BsonDocument()).Sort(sort).FirstOrDefault();
            if (doc != null)
            {
                return doc["_id"].AsInt32 + 1;
            }
            return 1;
        }

        public static bool Agregar(int usuId, int proId)
        {
            // Validar si ya existe
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_id", usuId),
                Builders<BsonDocument>.Filter.Eq("pro_id", proId)
            );
            var count = CarritoCollection.CountDocuments(filter);
            if (count > 0) return false;

            int nextId = ObtenerSiguienteId();
            var doc = new BsonDocument
            {
                { "_id", nextId },
                { "usu_id", usuId },
                { "pro_id", proId },
                { "car_fecha", DateTime.UtcNow }
            };
            CarritoCollection.InsertOne(doc);
            return true;
        }

        public static void Eliminar(int carId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", carId);
            CarritoCollection.DeleteOne(filter);
        }

        public static void EliminarPorUsuYProd(int usuId, int proId)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_id", usuId),
                Builders<BsonDocument>.Filter.Eq("pro_id", proId)
            );
            CarritoCollection.DeleteMany(filter);
        }

        public static bool EstaEnCarrito(int usuId, int proId)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_id", usuId),
                Builders<BsonDocument>.Filter.Eq("pro_id", proId)
            );
            return CarritoCollection.CountDocuments(filter) > 0;
        }

        public static List<CarritoItem> ListarPorUsuario(int usuId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            var sort = Builders<BsonDocument>.Sort.Descending("car_fecha");
            var list = CarritoCollection.Find(filter).Sort(sort).ToList();

            var result = new List<CarritoItem>();
            foreach (var doc in list)
            {
                int proId = doc["pro_id"].AsInt32;
                var pDoc = ProductosCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", proId)).FirstOrDefault();
                if (pDoc == null) continue; // Si el producto no existe, lo saltamos

                int? catId = pDoc.Contains("cat_id") && !pDoc["cat_id"].IsBsonNull ? (int?)pDoc["cat_id"].AsInt32 : null;
                int? provId = pDoc.Contains("prov_id") && !pDoc["prov_id"].IsBsonNull ? (int?)pDoc["prov_id"].AsInt32 : null;

                string catNombre = "Sin Categoría";
                if (catId.HasValue)
                {
                    var catDoc = CategoriasCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", catId.Value)).FirstOrDefault();
                    if (catDoc != null) catNombre = catDoc["cat_nombre"].AsString;
                }

                string provNombre = "Sin Proveedor";
                if (provId.HasValue)
                {
                    var provDoc = ProveedoresCollection.Find(Builders<BsonDocument>.Filter.Eq("_id", provId.Value)).FirstOrDefault();
                    if (provDoc != null) provNombre = provDoc["prov_nombre"].AsString;
                }

                result.Add(new CarritoItem
                {
                    car_id = doc["_id"].AsInt32,
                    usu_id = doc["usu_id"].AsInt32,
                    pro_id = proId,
                    car_fecha = doc["car_fecha"].ToUniversalTime(),
                    pro_nombre = pDoc.Contains("pro_nombre") ? pDoc["pro_nombre"].AsString : "",
                    pro_precio = pDoc.Contains("pro_precio") ? (decimal)pDoc["pro_precio"].AsDouble : 0m,
                    pro_cantidad = pDoc.Contains("pro_cantidad") ? pDoc["pro_cantidad"].AsInt32 : 0,
                    pro_ruta_foto = pDoc.Contains("pro_ruta_foto") ? pDoc["pro_ruta_foto"].AsString : "~/wwwroot/imagen/default.png",
                    cat_nombre = catNombre,
                    prov_nombre = provNombre
                });
            }
            return result;
        }

        public static HashSet<int> ObtenerIdsEnCarrito(int usuId)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_id", usuId);
            var list = CarritoCollection.Find(filter).ToList();
            var ids = new HashSet<int>();
            foreach (var doc in list)
            {
                ids.Add(doc["pro_id"].AsInt32);
            }
            return ids;
        }
    }
}
