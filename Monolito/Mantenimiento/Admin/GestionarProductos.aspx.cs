using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio; 

namespace Monolito.Dashboard
{
    public partial class GestionarProductos : System.Web.UI.Page
    {
       
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!IsPostBack)
            {
                CargarDropdowns(); // Llena (Categorías y Proveedores)
                CargarProductos(); //  tabla (GridView)
            }
        }

      
        private void CargarDropdowns()
        {
            try
            {
                
                var categorias = CN_Categoria.Listar();
                
                
                ddlCategoriaFiltro.Items.Clear();
                ddlCategoriaFiltro.Items.Add(new ListItem("Todas las Categorías", "0"));
                
            
                ddlCategoria.Items.Clear();
                ddlCategoria.Items.Add(new ListItem("-- Seleccionar Categoría --", ""));

              
                foreach (var cat in categorias)
                {
                    ddlCategoriaFiltro.Items.Add(new ListItem(cat.cat_nombre, cat.cat_id.ToString()));
                    ddlCategoria.Items.Add(new ListItem(cat.cat_nombre, cat.cat_id.ToString()));
                }

               
                var proveedores = CN_Proveedor.ListarActivos();
                
               
                ddlProveedorFiltro.Items.Clear();
                ddlProveedorFiltro.Items.Add(new ListItem("Todos los Proveedores", "0"));

                
                ddlProveedor.Items.Clear();
                ddlProveedor.Items.Add(new ListItem("-- Seleccionar Proveedor --", ""));

             
                foreach (var prov in proveedores)
                {
                    ddlProveedorFiltro.Items.Add(new ListItem(prov.prov_nombre, prov.prov_id.ToString()));
                    ddlProveedor.Items.Add(new ListItem(prov.prov_nombre, prov.prov_id.ToString()));
                }
            }
            catch (Exception ex)
            {
               
                MostrarAlerta("error", "Error", "No se pudieron cargar los catálogos: " + ex.Message);
            }
        }

       
        private void CargarProductos()
        {
            try
            {
            
                string busqueda = txtBusqueda.Text.Trim();
                
               
                int catId = int.Parse(ddlCategoriaFiltro.SelectedValue);
                int provId = int.Parse(ddlProveedorFiltro.SelectedValue);

                var lista = CN_Producto.Listar(busqueda, catId > 0 ? (int?)catId : null, provId > 0 ? (int?)provId : null);
                
              
                gvProductos.DataSource = lista;
                gvProductos.DataBind();
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error", "No se pudieron cargar los productos: " + ex.Message);
            }
        }

        
        protected void txtBusqueda_TextChanged(object sender, EventArgs e)
        {
            CargarProductos(); // Refresca la lista automáticamente
        }


        protected void ddlCategoriaFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarProductos(); 
        }

     
        protected void ddlProveedorFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarProductos(); 
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBusqueda.Text = string.Empty; 
            ddlCategoriaFiltro.SelectedValue = "0"; 
            ddlProveedorFiltro.SelectedValue = "0";
            CargarProductos(); 
        }

 
        protected void gvProductos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProductos.PageIndex = e.NewPageIndex;
            CargarProductos(); 
        }

       
        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
            litTituloEditor.Text = "Agregar Nuevo Producto"; 
            hfProId.Value = string.Empty; 
            pnlEditor.Visible = true; 
            pnlBackdrop.Visible = true; 
        }

       
        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            pnlEditor.Visible = false; 
            pnlBackdrop.Visible = false; 
        }

        
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                
                string nombre = txtNombre.Text.Trim();
                string strCantidad = txtCantidad.Text.Trim();
                string strPrecio = txtPrecio.Text.Trim().Replace(",", ".");

            
                if (string.IsNullOrWhiteSpace(nombre) || string.IsNullOrWhiteSpace(strCantidad) || string.IsNullOrWhiteSpace(strPrecio))
                {
                    MostrarAlerta("warning", "Advertencia", "Por favor complete todos los campos obligatorios.");
                    return; 
                }

                
                int cantidad = int.Parse(strCantidad);
                decimal precio = decimal.Parse(strPrecio, System.Globalization.CultureInfo.InvariantCulture);

               
                int? catId = null;
                if (!string.IsNullOrWhiteSpace(ddlCategoria.SelectedValue))
                    catId = int.Parse(ddlCategoria.SelectedValue);

                int? provId = null;
                if (!string.IsNullOrWhiteSpace(ddlProveedor.SelectedValue))
                    provId = int.Parse(ddlProveedor.SelectedValue);

                
                List<string> rutasFotos = new List<string>();
                string rutaFotoPrincipal = string.Empty;

                if (fuFoto.HasFiles) 
                {
                   
                    string uploadFolder = Server.MapPath("~/wwwroot/imagen/");
                    if (!Directory.Exists(uploadFolder))
                    {
                        Directory.CreateDirectory(uploadFolder);
                    }

                  
                    foreach (var file in fuFoto.PostedFiles)
                    {
                        if (file.ContentLength > 0)
                        {
                            string extension = Path.GetExtension(file.FileName).ToLower(); 
                          
                            if (extension == ".jpg" || extension == ".png" || extension == ".jpeg" || extension == ".webp")
                            {
                                
                                string fileName = Guid.NewGuid().ToString() + extension;
                                string physicalPath = Path.Combine(uploadFolder, fileName); 
                                file.SaveAs(physicalPath); 
                                
                                string rutaVirtual = "~/wwwroot/imagen/" + fileName;
                                rutasFotos.Add(rutaVirtual); 
                            }
                            else
                            {
                                MostrarAlerta("warning", "Formato Inválido", "Todas las fotos deben ser JPG, JPEG, PNG o WEBP.");
                                return;
                            }
                        }
                    }

                    
                    if (rutasFotos.Count > 0)
                    {
                        rutaFotoPrincipal = rutasFotos[0];
                    }
                }

                
                if (string.IsNullOrEmpty(hfProId.Value))
                {
                    int nuevoProId = CN_Producto.Insertar(nombre, cantidad, precio, provId, catId, rutaFotoPrincipal);

                    if (rutasFotos.Count > 0)
                    {
                        
                        foreach (var ruta in rutasFotos)
                            CN_Producto.InsertarFoto(nuevoProId, ruta);
                    }
                    else if (!string.IsNullOrWhiteSpace(rutaFotoPrincipal))
                    {
                        
                        CN_Producto.InsertarFoto(nuevoProId, rutaFotoPrincipal);
                    }

                    MostrarAlerta("success", "Éxito", "El producto ha sido guardado exitosamente.");
                }
                else
                {
                    
                    int id = int.Parse(hfProId.Value);

                    if (rutasFotos.Count > 0)
                    {
                      
                        CN_Producto.Actualizar(id, nombre, cantidad, precio, provId, catId, rutasFotos[0]);
                        CN_Producto.EliminarFotos(id);
                        foreach (var ruta in rutasFotos)
                            CN_Producto.InsertarFoto(id, ruta);
                    }
                    else
                    {
                       
                        CN_Producto.Actualizar(id, nombre, cantidad, precio, provId, catId, string.Empty);
                    }

                    MostrarAlerta("success", "Éxito", "El producto ha sido actualizado exitosamente.");
                }

                pnlEditor.Visible = false; 
                pnlBackdrop.Visible = false; 
                CargarProductos(); 
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error", "No se pudo guardar el producto: " + ex.Message);
            }
        }

        
        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                
                int id = int.Parse(e.CommandArgument.ToString());
                var prod = CN_Producto.ObtenerPorId(id); 
                if (prod != null)
                {
                   
                    hfProId.Value = prod.pro_id.ToString();
                    txtNombre.Text = prod.pro_nombre;
                    txtCantidad.Text = prod.pro_cantidad.ToString();
                    txtPrecio.Text = prod.pro_precio.ToString("F2", System.Globalization.CultureInfo.InvariantCulture);
                    
                    ddlCategoria.SelectedValue = prod.cat_id.HasValue ? prod.cat_id.Value.ToString() : "";
                    ddlProveedor.SelectedValue = prod.prov_id.HasValue ? prod.prov_id.Value.ToString() : "";
                    lblRutaActual.Text = "Foto actual: " + (string.IsNullOrWhiteSpace(prod.pro_ruta_foto) ? "Por defecto" : prod.pro_ruta_foto);

                    litTituloEditor.Text = "Editar Producto #" + prod.pro_id; // Cambia título
                    pnlEditor.Visible = true; // Abre modal
                    pnlBackdrop.Visible = true;
                }
            }
            else if (e.CommandName == "Eliminar")
            {
                try
                {
                    int id = int.Parse(e.CommandArgument.ToString());
                    CN_Producto.Eliminar(id);
                    CargarProductos(); 
                    MostrarAlerta("success", "Eliminado", "El producto ha sido eliminado de forma lógica.");
                }
                catch (Exception ex)
                {
                    MostrarAlerta("error", "Error", "No se pudo eliminar el producto: " + ex.Message);
                }
            }
        }

        
        private void LimpiarFormulario()
        {
            txtNombre.Text = string.Empty;
            txtCantidad.Text = string.Empty;
            txtPrecio.Text = string.Empty;
            ddlCategoria.SelectedIndex = 0;
            ddlProveedor.SelectedIndex = 0;
            lblRutaActual.Text = string.Empty;
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
                
            }

            return fallbackUrl;
        }

   
        private void MostrarAlerta(string tipo, string titulo, string mensaje)
        {
           
            string script = string.Format("Swal.fire({{ icon: '{0}', title: '{1}', text: '{2}', confirmButtonColor: '#7F77DD', background: '#07070f', color: '#fff' }});", tipo, titulo, mensaje);
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }

       
        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            try
            {
               
                var lista = CN_Producto.Listar();
                if (lista == null || lista.Count == 0)
                {
                    MostrarAlerta("info", "Sin datos", "No hay productos activos para exportar.");
                    return;
                }

                var sb = new StringBuilder();

                
                sb.AppendLine("ID,Nombre,Categoría,Proveedor,Stock,Precio,Ruta Foto");

             
                foreach (var p in lista)
                {
                   
                    string nombre   = "\"" + (p.pro_nombre   ?? "").Replace("\"", "\"\"") + "\"";
                    string cat      = "\"" + (p.cat_nombre   ?? "").Replace("\"", "\"\"") + "\"";
                    string prov     = "\"" + (p.prov_nombre  ?? "").Replace("\"", "\"\"") + "\"";
                    string foto     = "\"" + (p.pro_ruta_foto ?? "").Replace("\"", "\"\"") + "\"";

                    sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6}",
                        p.pro_id,
                        nombre,
                        cat,
                        prov,
                        p.pro_cantidad,
                        p.pro_precio.ToString("F2", System.Globalization.CultureInfo.InvariantCulture),
                        foto));
                }

             
                byte[] completo = new System.Text.UTF8Encoding(true).GetBytes(sb.ToString());

                string fileName = "productos_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv";

        
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
                Response.AddHeader("Content-Length", completo.Length.ToString());
                Response.BinaryWrite(completo); 
                Response.Flush();
                Response.End(); 
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error al exportar", ex.Message);
            }
        }
    }
}
