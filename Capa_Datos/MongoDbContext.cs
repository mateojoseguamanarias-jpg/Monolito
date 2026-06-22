using System;
using System.Configuration;
using MongoDB.Driver;

namespace Capa_Datos
{
    public static class MongoDbContext
    {
        private static IMongoDatabase _database;

        public static IMongoDatabase Database
        {
            get
            {
                if (_database == null)
                {
                    string connectionString = ConfigurationManager.AppSettings["MongoDbConnection"];
                    if (string.IsNullOrEmpty(connectionString))
                    {
                        connectionString = "mongodb://localhost:27017";
                    }
                    var client = new MongoClient(connectionString);
                    _database = client.GetDatabase("NovaX_DB");
                }
                return _database;
            }
        }
    }
}
