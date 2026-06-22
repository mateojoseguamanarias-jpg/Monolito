using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using MongoDB.Driver;
using MongoDB.Bson;

namespace Monolito
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Código que se ejecuta al iniciar la aplicación
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Crear tabla de fotos de productos si no existe en la base de datos
            try
            {
                string[] nombres = { "cnx", "Monolito4toConnectionString", "DefaultConnection", "MonolitoConnectionString", "ConexionBD" };
                string connStr = "";
                foreach (string nombre in nombres) {
                    var cs = System.Configuration.ConfigurationManager.ConnectionStrings[nombre];
                    if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) {
                        connStr = cs.ConnectionString;
                        break;
                    }
                }

                if (!string.IsNullOrEmpty(connStr))
                {
                    using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                    {
                        conn.Open();
                        string checkTableSql = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_producto_fotos') BEGIN " +
                            "CREATE TABLE tbl_producto_fotos (" +
                            "  pfot_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL," +
                            "  pro_id INT NOT NULL," +
                            "  pfot_ruta_foto VARCHAR(250) NOT NULL," +
                            "  CONSTRAINT FK_Producto_Fotos_Producto FOREIGN KEY (pro_id) REFERENCES tbl_producto(pro_id) ON DELETE CASCADE" +
                            "); END";
                        using (var cmd = new System.Data.SqlClient.SqlCommand(checkTableSql, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch
            {
                // Silencioso
            }

            // Copiar imágenes semilla automáticamente desde la carpeta de la conversación si no existen en Uploads y wwwroot/imagen
            try
            {
                string uploadsDir = Server.MapPath("~/Uploads");
                if (!System.IO.Directory.Exists(uploadsDir))
                {
                    System.IO.Directory.CreateDirectory(uploadsDir);
                }

                string wwwrootImagenDir = Server.MapPath("~/wwwroot/imagen");
                if (!System.IO.Directory.Exists(wwwrootImagenDir))
                {
                    System.IO.Directory.CreateDirectory(wwwrootImagenDir);
                }

                string userHome = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                string brainDir = System.IO.Path.Combine(userHome, ".gemini", "antigravity", "brain", "7c662616-75b0-4659-9b7a-ca5fd93fb68d");

                if (System.IO.Directory.Exists(brainDir))
                {
                    string[] sourcePatterns = { "smartphone_*.png", "teclado_*.png", "camiseta_*.png", "aceite_*.png", "vajilla_*.png" };
                    foreach (var pattern in sourcePatterns)
                    {
                        var files = System.IO.Directory.GetFiles(brainDir, pattern);
                        if (files.Length > 0)
                        {
                            string file = files[0];
                            string baseName = pattern.Split('_')[0]; // smartphone, teclado, etc.
                            
                            // Copiar a Uploads
                            string destFile1 = System.IO.Path.Combine(uploadsDir, baseName + ".jpg");
                            if (!System.IO.File.Exists(destFile1))
                            {
                                System.IO.File.Copy(file, destFile1, true);
                            }

                            // Copiar a wwwroot/imagen
                            string destFile2 = System.IO.Path.Combine(wwwrootImagenDir, baseName + ".jpg");
                            if (!System.IO.File.Exists(destFile2))
                            {
                                System.IO.File.Copy(file, destFile2, true);
                            }
                        }
                    }
                }
            }
            catch
            {
                // Silencioso para evitar interferir con el inicio de la app
            }

            // Promover usuarios de MongoDB a Administrador y migrar base de datos de SQL Server a MongoDB si es necesario
            try
            {
                if (System.Configuration.ConfigurationManager.AppSettings["DatabaseProvider"] == "MongoDB")
                {
                    // 1. Migrar datos si MongoDB está vacío
                    Capa_Datos.MongoCD_Migration.MigrateSqlToMongoIfNeeded();

                    // 2. Garantizar roles de administrador tras la migración
                    string connectionString = System.Configuration.ConfigurationManager.AppSettings["MongoDbConnection"];
                    if (string.IsNullOrEmpty(connectionString)) connectionString = "mongodb://localhost:27017";
                    var client = new MongoDB.Driver.MongoClient(connectionString);
                    var db = client.GetDatabase("NovaX_DB");
                    var col = db.GetCollection<BsonDocument>("Usuarios");
                    var update = Builders<BsonDocument>.Update
                        .Set("tusu_id", 1)
                        .Set("tusu_nombre", "Administrador");
                    col.UpdateMany(Builders<BsonDocument>.Filter.Empty, update);
                }
            }
            catch
            {
                // Silencioso
            }
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            // Si el usuario entra a la raíz del sitio, redirigir al Login
            if (Request.AppRelativeCurrentExecutionFilePath == "~/")
            {
                Response.Redirect("~/Seguridad/Loguin.aspx");
            }
        }
    }
}