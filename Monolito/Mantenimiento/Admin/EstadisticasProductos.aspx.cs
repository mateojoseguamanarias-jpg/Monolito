using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using Capa_Negocio;

namespace Monolito.Dashboard
{
    public partial class EstadisticasProductos : System.Web.UI.Page
    {
        // Campos que almacenarán los strings JSON serializados
        private string jsonLabelsCat = "[]";
        private string jsonDataCat = "[]";
        private string jsonLabelsStock = "[]";
        private string jsonDataStock = "[]";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarDatos();
            }
        }

        private void CargarDatos()
        {
            try
            {
                // 1. Cargar el Carrusel Repeater (Productos activos)
                var productos = CN_Producto.Listar();
                rptCarousel.DataSource = productos;
                rptCarousel.DataBind();

                // 2. Cargar y preparar Estadísticas por Categoría
                var statsCat = CN_Producto.ObtenerEstadisticasCategoria();
                var labelsCat = statsCat.Select(s => s.Categoria).ToList();
                var dataCat = statsCat.Select(s => s.CantidadProductos).ToList();

                var serializer = new JavaScriptSerializer();
                jsonLabelsCat = serializer.Serialize(labelsCat);
                jsonDataCat = serializer.Serialize(dataCat);

                // 3. Cargar y preparar Estadísticas de Stock (Top 10)
                var statsStock = CN_Producto.ObtenerEstadisticasStock();
                var labelsStock = statsStock.Select(s => s.Producto).ToList();
                var dataStock = statsStock.Select(s => s.Stock).ToList();

                jsonLabelsStock = serializer.Serialize(labelsStock);
                jsonDataStock = serializer.Serialize(dataStock);
            }
            catch (Exception)
            {
                // Fallback silencioso para evitar romper la página
                jsonLabelsCat = "[]";
                jsonDataCat = "[]";
                jsonLabelsStock = "[]";
                jsonDataStock = "[]";
            }
        }

        // Métodos auxiliares públicos invocados en el front de la página (.aspx)
        public string ObtenerLabelCategorias()
        {
            return jsonLabelsCat;
        }

        public string ObtenerDataCategorias()
        {
            return jsonDataCat;
        }

        public string ObtenerLabelStock()
        {
            return jsonLabelsStock;
        }

        public string ObtenerDataStock()
        {
            return jsonDataStock;
        }

        public string ObtenerUrlImagen(object rutaFotoObj, object nombreObj)
        {
            string nombre = nombreObj != null ? nombreObj.ToString() : "Producto";
            string textParam = Uri.EscapeDataString(nombre);
            string fallbackUrl = "https://placehold.co/300x300/07070f/00f2ff?text=" + textParam;

            if (rutaFotoObj == null || DBNull.Value.Equals(rutaFotoObj))
            {
                return fallbackUrl;
            }

            string ruta = rutaFotoObj.ToString().Trim();
            if (string.IsNullOrEmpty(ruta))
            {
                return fallbackUrl;
            }

            try
            {
                if (ruta.StartsWith("~"))
                {
                    string physicalPath = Server.MapPath(ruta);
                    if (System.IO.File.Exists(physicalPath))
                    {
                        return ResolveUrl(ruta);
                    }
                }
                else
                {
                    if (ruta.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                        ruta.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                    {
                        return ruta;
                    }
                    
                    string physicalPath = Server.MapPath("~/" + ruta.TrimStart('/'));
                    if (System.IO.File.Exists(physicalPath))
                    {
                        return ResolveUrl("~/" + ruta.TrimStart('/'));
                    }
                }
            }
            catch
            {
                // Fallback silencioso en caso de error
            }

            return fallbackUrl;
        }
    }
}
