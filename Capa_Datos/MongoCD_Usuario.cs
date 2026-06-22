using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Capa_Datos
{
    public static class MongoCD_Usuario
    {
        private static IMongoCollection<BsonDocument> UsuariosCollection
        {
            get { return MongoDbContext.Database.GetCollection<BsonDocument>("Usuarios"); }
        }

        private static Usuario MapBsonToUsuario(BsonDocument doc)
        {
            if (doc == null) return null;
            var u = new Usuario();
            u.usu_id = doc.Contains("_id") ? doc["_id"].AsInt32 : 0;
            u.usu_cedula = doc.Contains("usu_cedula") ? doc["usu_cedula"].AsString : "";
            u.usu_nombre = doc.Contains("usu_nombre") ? doc["usu_nombre"].AsString : "";
            u.usu_apellidos = doc.Contains("usu_apellidos") ? doc["usu_apellidos"].AsString : "";
            u.usu_nick = doc.Contains("usu_nick") ? doc["usu_nick"].AsString : "";
            u.usu_correo = doc.Contains("usu_correo") ? doc["usu_correo"].AsString : "";
            u.tusu_id = doc.Contains("tusu_id") ? doc["tusu_id"].AsInt32 : 2;
            u.usu_celular = doc.Contains("usu_celular") ? doc["usu_celular"].AsString : "";
            u.usu_direccion = doc.Contains("usu_direccion") ? doc["usu_direccion"].AsString : "";
            u.usu_estado = doc.Contains("usu_estado") ? doc["usu_estado"].AsString : "A";
            u.usu_puntos = doc.Contains("usu_puntos") ? doc["usu_puntos"].AsInt32 : 0;
            u.usu_google_id = doc.Contains("usu_google_id") ? doc["usu_google_id"].AsString : "";
            u.usu_otp_hash = doc.Contains("usu_otp_hash") ? doc["usu_otp_hash"].AsString : "";
            
            if (doc.Contains("usu_fecha_cumple") && !doc["usu_fecha_cumple"].IsBsonNull)
            {
                u.usu_fecha_cumple = doc["usu_fecha_cumple"].ToUniversalTime();
            }
            
            return u;
        }

        public static Usuario Login(string email, string pass)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_correo", email),
                Builders<BsonDocument>.Filter.Eq("usu_estado", "A")
            );
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null)
            {
                string encryptedPass = doc.Contains("usu_contrasena") ? doc["usu_contrasena"].AsString : "";
                string decrypted = SecurityHelper.Decrypt(encryptedPass);
                if (decrypted == pass)
                {
                    return MapBsonToUsuario(doc);
                }
            }
            return null;
        }

        public static Usuario ObtenerUsuarioPorId(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            return MapBsonToUsuario(doc);
        }

        public static Usuario ObtenerUsuarioPorEmail(string email)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_correo", email);
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            return MapBsonToUsuario(doc);
        }

        public static void VincularGoogle(int id, string gid)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_google_id", gid);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void VincularFacebook(int id, string fid)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_facebook_id", fid);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static Usuario LoginPorGoogleId(string gid)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_google_id", gid),
                Builders<BsonDocument>.Filter.Eq("usu_estado", "A")
            );
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            return MapBsonToUsuario(doc);
        }

        public static Usuario LoginPorFacebookId(string fid)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_facebook_id", fid),
                Builders<BsonDocument>.Filter.Eq("usu_estado", "A")
            );
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            return MapBsonToUsuario(doc);
        }

        public static Usuario LoginPorQrCodigo(string qr)
        {
            var filter = Builders<BsonDocument>.Filter.And(
                Builders<BsonDocument>.Filter.Eq("usu_codigo_OTP", qr),
                Builders<BsonDocument>.Filter.Eq("usu_estado", "A")
            );
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            return MapBsonToUsuario(doc);
        }

        public static void ActualizarPerfil(int id, string nombre, string apellidos, string nick, string celular, string direccion, DateTime? fechaCumple, string email, string cedula)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update
                .Set("usu_nombre", nombre)
                .Set("usu_apellidos", apellidos ?? "")
                .Set("usu_nick", nick)
                .Set("usu_celular", celular ?? "")
                .Set("usu_direccion", direccion ?? "")
                .Set("usu_fecha_cumple", (object)fechaCumple ?? BsonNull.Value)
                .Set("usu_correo", email)
                .Set("usu_cedula", cedula ?? "");

            UsuariosCollection.UpdateOne(filter, update);
        }

        public static int Insertar(string cedula, string nombre, string apellidos, string correo, string nick, string pass, int tipoId, string celular, string direccion, DateTime? fechaCumple)
        {
            int nextId = ObtenerSiguienteId();
            string encryptedPass = SecurityHelper.Encrypt(pass);

            var doc = new BsonDocument
            {
                { "_id", nextId },
                { "usu_cedula", cedula ?? "" },
                { "usu_nombre", nombre },
                { "usu_apellidos", apellidos ?? "" },
                { "usu_correo", correo },
                { "usu_nick", nick },
                { "usu_contrasena", encryptedPass },
                { "tusu_id", tipoId },
                { "tusu_nombre", tipoId == 1 ? "Administrador" : "Usuario" },
                { "usu_celular", celular ?? "" },
                { "usu_direccion", direccion ?? "" },
                { "usu_fecha_cumple", fechaCumple.HasValue ? (BsonValue)fechaCumple.Value : BsonNull.Value },
                { "usu_fecha_creacion", DateTime.UtcNow },
                { "usu_estado", "A" },
                { "usu_puntos", 0 },
                { "usu_google_id", "" },
                { "usu_facebook_id", "" },
                { "usu_codigo_OTP", "" },
                { "usu_otp_hash", "" },
                { "fotos", new BsonArray() }
            };

            UsuariosCollection.InsertOne(doc);
            return nextId;
        }

        public static void InsertarFoto(int id, byte[] foto)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null)
            {
                var fotos = doc.Contains("fotos") ? doc["fotos"].AsBsonArray : new BsonArray();
                int nextFotoId = fotos.Count > 0 ? fotos.Max(x => x["foto_id"].AsInt32) + 1 : 1;
                
                var newFoto = new BsonDocument
                {
                    { "foto_id", nextFotoId },
                    { "foto_data", foto }
                };

                // Si ya existe alguna foto, podemos decidir reemplazarla o agregarla a la lista
                // El comportamiento original en SQL Server es sobreescribir/actualizar si ya hay una para este usuario:
                // "IF EXISTS(SELECT 1 FROM tbl_usuario_fotos WHERE usu_id=@id) UPDATE tbl_usuario_fotos SET foto_data=@f WHERE usu_id=@id ELSE ..."
                // Para mantener compatibilidad exacta, limpiaremos y colocaremos la nueva
                var update = Builders<BsonDocument>.Update.Set("fotos", new BsonArray { newFoto });
                UsuariosCollection.UpdateOne(filter, update);
            }
        }

        public static byte[] ObtenerFoto(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null && doc.Contains("fotos"))
            {
                var fotos = doc["fotos"].AsBsonArray;
                if (fotos.Count > 0)
                {
                    return fotos.Last()["foto_data"].AsByteArray;
                }
            }
            return null;
        }

        public static byte[] ObtenerFotoPorId(int fotoId)
        {
            // Busca en todos los usuarios el documento que contenga la foto con foto_id
            var filter = Builders<BsonDocument>.Filter.ElemMatch("fotos", Builders<BsonDocument>.Filter.Eq("foto_id", fotoId));
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null && doc.Contains("fotos"))
            {
                var fotos = doc["fotos"].AsBsonArray;
                var foto = fotos.FirstOrDefault(f => f["foto_id"].AsInt32 == fotoId);
                if (foto != null)
                {
                    return foto["foto_data"].AsByteArray;
                }
            }
            return null;
        }

        public static DataTable ObtenerTodasFotos(int userId)
        {
            var dt = new DataTable();
            dt.Columns.Add("foto_id", typeof(int));

            var filter = Builders<BsonDocument>.Filter.Eq("_id", userId);
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null && doc.Contains("fotos"))
            {
                var fotos = doc["fotos"].AsBsonArray;
                foreach (var f in fotos)
                {
                    dt.Rows.Add(f["foto_id"].AsInt32);
                }
            }
            return dt;
        }

        public static void EliminarFoto(int fotoId)
        {
            var filter = Builders<BsonDocument>.Filter.ElemMatch("fotos", Builders<BsonDocument>.Filter.Eq("foto_id", fotoId));
            var doc = UsuariosCollection.Find(filter).FirstOrDefault();
            if (doc != null)
            {
                var fotos = doc["fotos"].AsBsonArray;
                var itemToRemove = fotos.FirstOrDefault(f => f["foto_id"].AsInt32 == fotoId);
                if (itemToRemove != null)
                {
                    fotos.Remove(itemToRemove);
                    var updateFilter = Builders<BsonDocument>.Filter.Eq("_id", doc["_id"].AsInt32);
                    var update = Builders<BsonDocument>.Update.Set("fotos", fotos);
                    UsuariosCollection.UpdateOne(updateFilter, update);
                }
            }
        }

        public static DataTable ObtenerTodosUsuarios()
        {
            var dt = new DataTable();
            dt.Columns.Add("usu_id", typeof(int));
            dt.Columns.Add("usu_nombre", typeof(string));
            dt.Columns.Add("usu_apellidos", typeof(string));
            dt.Columns.Add("usu_nick", typeof(string));
            dt.Columns.Add("usu_correo", typeof(string));
            dt.Columns.Add("usu_celular", typeof(string));
            dt.Columns.Add("usu_direccion", typeof(string));
            dt.Columns.Add("usu_estado", typeof(string));
            dt.Columns.Add("tiene_foto", typeof(int));
            dt.Columns.Add("usu_puntos", typeof(int));
            dt.Columns.Add("tusu_nombre", typeof(string));

            var filter = Builders<BsonDocument>.Filter.Ne("usu_estado", "X");
            var list = UsuariosCollection.Find(filter).ToList();

            foreach (var doc in list)
            {
                int id = doc["_id"].AsInt32;
                int tieneFoto = (doc.Contains("fotos") && doc["fotos"].AsBsonArray.Count > 0) ? 1 : 0;
                
                dt.Rows.Add(
                    id,
                    doc.Contains("usu_nombre") ? doc["usu_nombre"].AsString : "",
                    doc.Contains("usu_apellidos") ? doc["usu_apellidos"].AsString : "",
                    doc.Contains("usu_nick") ? doc["usu_nick"].AsString : "",
                    doc.Contains("usu_correo") ? doc["usu_correo"].AsString : "",
                    doc.Contains("usu_celular") ? doc["usu_celular"].AsString : "",
                    doc.Contains("usu_direccion") ? doc["usu_direccion"].AsString : "",
                    doc.Contains("usu_estado") ? doc["usu_estado"].AsString : "A",
                    tieneFoto,
                    doc.Contains("usu_puntos") ? doc["usu_puntos"].AsInt32 : 0,
                    doc.Contains("tusu_nombre") ? doc["tusu_nombre"].AsString : "Usuario"
                );
            }
            return dt;
        }

        public static void ActualizarEstado(int id, string est)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_estado", est);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void GuardarOtpTemp(int id, string hash)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_otp_hash", hash ?? "");
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void ActualizarPassword(string email, string pass)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("usu_correo", email);
            string encrypted = SecurityHelper.Encrypt(pass);
            var update = Builders<BsonDocument>.Update.Set("usu_contrasena", encrypted);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static DataTable ObtenerEstadisticas()
        {
            var dt = new DataTable();
            dt.Columns.Add("Total", typeof(int));
            dt.Columns.Add("Activos", typeof(int));
            dt.Columns.Add("Bloqueados", typeof(int));

            var totalFilter = Builders<BsonDocument>.Filter.Ne("usu_estado", "X");
            long total = UsuariosCollection.CountDocuments(totalFilter);

            var activosFilter = Builders<BsonDocument>.Filter.Eq("usu_estado", "A");
            long activos = UsuariosCollection.CountDocuments(activosFilter);

            var bloqueadosFilter = Builders<BsonDocument>.Filter.Eq("usu_estado", "B");
            long bloqueados = UsuariosCollection.CountDocuments(bloqueadosFilter);

            dt.Rows.Add((int)total, (int)activos, (int)bloqueados);
            return dt;
        }

        public static DataTable ObtenerTiposUsuario()
        {
            var dt = new DataTable();
            dt.Columns.Add("tusu_id", typeof(int));
            dt.Columns.Add("tusu_nombre", typeof(string));

            // MongoDB estático para tipos de usuario
            dt.Rows.Add(1, "Administrador");
            dt.Rows.Add(2, "Usuario");
            return dt;
        }

        public static int ObtenerSiguienteId()
        {
            var sort = Builders<BsonDocument>.Sort.Descending("_id");
            var doc = UsuariosCollection.Find(new BsonDocument()).Sort(sort).FirstOrDefault();
            if (doc != null)
            {
                return doc["_id"].AsInt32 + 1;
            }
            return 1;
        }

        public static void GuardarCodigoQrOtp(int id, string qr)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_codigo_OTP", qr);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static void SumarPuntos(int id, int puntos)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Inc("usu_puntos", puntos);
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static DataTable ObtenerUsuariosBloqueados()
        {
            var dt = new DataTable();
            dt.Columns.Add("usu_id", typeof(int));
            dt.Columns.Add("usu_nombre", typeof(string));
            dt.Columns.Add("usu_nick", typeof(string));
            dt.Columns.Add("usu_correo", typeof(string));

            var filter = Builders<BsonDocument>.Filter.Eq("usu_estado", "B");
            var list = UsuariosCollection.Find(filter).ToList();

            foreach (var doc in list)
            {
                dt.Rows.Add(
                    doc["_id"].AsInt32,
                    doc.Contains("usu_nombre") ? doc["usu_nombre"].AsString : "",
                    doc.Contains("usu_nick") ? doc["usu_nick"].AsString : "",
                    doc.Contains("usu_correo") ? doc["usu_correo"].AsString : ""
                );
            }
            return dt;
        }

        public static void DesbloquearUsuario(int id)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update.Set("usu_estado", "A");
            UsuariosCollection.UpdateOne(filter, update);
        }

        public static List<Usuario> ObtenerUsuariosRanking()
        {
            var filter = Builders<BsonDocument>.Filter.Ne("usu_estado", "X");
            var sort = Builders<BsonDocument>.Sort.Descending("usu_puntos");
            var list = UsuariosCollection.Find(filter).Sort(sort).ToList();
            return list.Select(MapBsonToUsuario).ToList();
        }
    }
}
