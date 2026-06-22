using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public static class CN_Categoria
    {
        private static string Provider => System.Configuration.ConfigurationManager.AppSettings["DatabaseProvider"] ?? "SQL";

        /// <summary>
        /// Obtiene todas las categorías activas.
        /// </summary>
        public static List<tbl_categoria> Listar()
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ListarCategorias();
            }

            using (var db = new DataClasses1DataContext())
            {
                // Forzamos la carga a memoria para evitar problemas de contexto cerrado en la UI
                return db.tbl_categoria.Where(c => c.cat_estado == 'A').ToList();
            }
        }
    }
}
