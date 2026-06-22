using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web.UI;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class SubidaMasiva : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session["PreviewList"] = null;
            }
        }

        protected void btnProcesar_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fuArchivo.HasFile)
                {
                    MostrarAlerta("warning", "Falta Archivo", "Por favor seleccione un archivo .csv antes de procesar.");
                    return;
                }

                string extension = Path.GetExtension(fuArchivo.FileName).ToLower();
                if (extension != ".csv" && extension != ".txt")
                {
                    MostrarAlerta("warning", "Formato Inválido", "Únicamente se permiten archivos de extensión plana .csv o .txt.");
                    return;
                }

                // Leer el contenido del archivo plano
                string contenido = string.Empty;
                using (var reader = new StreamReader(fuArchivo.FileContent, Encoding.UTF8))
                {
                    contenido = reader.ReadToEnd();
                }

                // Invocar método del negocio para parsear y devolver vista previa
                List<ProductoInfo> listaPrevia = CN_Producto.VistaPreviaCSV(contenido);

                if (listaPrevia == null || listaPrevia.Count == 0)
                {
                    MostrarAlerta("warning", "Archivo Vacío", "No se encontraron registros válidos o legibles en el archivo plano.");
                    pnlPreview.Visible = false;
                    return;
                }

                // Guardar la vista previa en la sesión para el envío posterior
                Session["PreviewList"] = listaPrevia;

                // Enlazar al GridView de Previsualización
                gvPreview.DataSource = listaPrevia;
                gvPreview.DataBind();

                pnlPreview.Visible = true;
                MostrarAlerta("success", "Archivo Procesado", string.Format("Se cargó la previsualización de {0} productos. Revise la lista y presione Confirmar.", listaPrevia.Count));
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error al procesar", "Ocurrió un fallo de lectura: " + ex.Message);
            }
        }

        protected void btnEnviar_Click(object sender, EventArgs e)
        {
            try
            {
                var listaPrevia = Session["PreviewList"] as List<ProductoInfo>;

                if (listaPrevia == null || listaPrevia.Count == 0)
                {
                    MostrarAlerta("warning", "Sesión Caducada", "La lista de previsualización está vacía. Por favor vuelva a cargar el archivo.");
                    return;
                }

                // Invocar el guardado masivo en la base de datos
                // El negocio se encarga de buscar o crear las categorías y proveedores padres si no existen
                CN_Producto.GuardarSubidaMasiva(listaPrevia);

                // Limpiar sesión y ocultar panel
                Session["PreviewList"] = null;
                pnlPreview.Visible = false;

                MostrarAlerta("success", "Carga Completada", string.Format("Se han insertado exitosamente {0} productos a la base de datos, poblando dinámicamente las relaciones de categorías y proveedores.", listaPrevia.Count));
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Fallo al Guardar", "No se pudo concretar el guardado masivo: " + ex.Message);
            }
        }

        private void MostrarAlerta(string tipo, string titulo, string mensaje)
        {
            string script = string.Format("Swal.fire({{ icon: '{0}', title: '{1}', text: '{2}', confirmButtonColor: '#7F77DD', background: '#07070f', color: '#fff' }});", tipo, titulo, mensaje);
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }

        /// <summary>
        /// Descarga un archivo CSV de plantilla con la cabecera y 2 filas de ejemplo,
        /// listo para ser abierto en Excel y rellenado por el usuario.
        /// </summary>
        protected void btnDescargarPlantilla_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Nombre,Cantidad,Precio,Categoria,Proveedor,Foto");
            sb.AppendLine("Teclado Mecánico RGB Pro,80,65.90,Tecnología,Distribuidora Nova S.A.,teclado.jpg");
            sb.AppendLine("Zapatos Running Speed,120,49.99,Ropa y Calzado,MegaImportaciones Cia. Ltda.,zapatos.jpg");
            sb.AppendLine("Camiseta Deportiva Algodón,200,19.99,Ropa y Calzado,Textiles del Pacífico,camiseta.jpg");

            byte[] bytes = Encoding.UTF8.GetBytes(sb.ToString());
            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=plantilla_productos.csv");
            Response.AddHeader("Content-Length", bytes.Length.ToString());
            Response.BinaryWrite(bytes);
            Response.Flush();
            Response.End();
        }
    }
}
