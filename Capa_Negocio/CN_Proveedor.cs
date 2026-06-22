using System;
using System.Collections.Generic;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocio
{
    public static class CN_Proveedor
    {
        private static string Provider => System.Configuration.ConfigurationManager.AppSettings["DatabaseProvider"] ?? "SQL";

        /// <summary>
        /// Obtiene únicamente los proveedores activos.
        /// </summary>
        public static List<tbl_proveedor> ListarActivos()
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ListarProveedoresActivos();
            }

            using (var db = new DataClasses1DataContext())
            {
                return db.tbl_proveedor.Where(p => p.prov_estado == 'A').ToList();
            }
        }

        /// <summary>
        /// Obtiene todos los proveedores de la base (activos e inactivos).
        /// </summary>
        public static List<tbl_proveedor> ListarTodos()
        {
            if (Provider == "MongoDB")
            {
                return MongoCD_Producto.ListarTodosProveedores();
            }

            using (var db = new DataClasses1DataContext())
            {
                return db.tbl_proveedor.ToList();
            }
        }

        /// <summary>
        /// Inserta un nuevo proveedor.
        /// </summary>
        public static void Insertar(string nombre)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.InsertarProveedor(nombre);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = new tbl_proveedor
                {
                    prov_nombre = nombre,
                    prov_estado = 'A'
                };
                db.tbl_proveedor.InsertOnSubmit(p);
                db.SubmitChanges();
            }
        }

        /// <summary>
        /// Actualiza el nombre de un proveedor existente.
        /// </summary>
        public static void Actualizar(int id, string nombre)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.ActualizarProveedor(id, nombre);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_proveedor.FirstOrDefault(x => x.prov_id == id);
                if (p != null)
                {
                    p.prov_nombre = nombre;
                    db.SubmitChanges();
                }
            }
        }

        /// <summary>
        /// Borrado lógico de un proveedor (Estado 'I').
        /// Requisito 7: Al borrar el padre, se respalda el prov_id en pro_prev_prov_id and se setea prov_id en NULL.
        /// </summary>
        public static void Eliminar(int id)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.EliminarProveedor(id);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_proveedor.FirstOrDefault(x => x.prov_id == id);
                if (p != null)
                {
                    p.prov_estado = 'I'; // Borrado lógico

                    // Respaldar relación en los productos (Hijos)
                    var productos = db.tbl_producto.Where(pr => pr.prov_id == id).ToList();
                    foreach (var prod in productos)
                    {
                        prod.pro_prev_prov_id = prod.prov_id;
                        prod.prov_id = null; // Desvincular temporalmente para evitar huérfanos
                    }

                    db.SubmitChanges();
                }
            }
        }

        /// <summary>
        /// Restaura un proveedor inactivo.
        /// Requisito 7: Al restaurar el padre, se devuelve el campo anterior prov_id a partir de pro_prev_prov_id.
        /// </summary>
        public static void Restaurar(int id)
        {
            if (Provider == "MongoDB")
            {
                MongoCD_Producto.RestaurarProveedor(id);
                return;
            }

            using (var db = new DataClasses1DataContext())
            {
                var p = db.tbl_proveedor.FirstOrDefault(x => x.prov_id == id);
                if (p != null)
                {
                    p.prov_estado = 'A'; // Volver a activar

                    // Volver a vincular los productos hijos que fueron desvinculados
                    var productos = db.tbl_producto.Where(pr => pr.pro_prev_prov_id == id).ToList();
                    foreach (var prod in productos)
                    {
                        prod.prov_id = prod.pro_prev_prov_id;
                        prod.pro_prev_prov_id = null; // Limpiar el respaldo
                    }

                    db.SubmitChanges();
                }
            }
        }
    }
}
