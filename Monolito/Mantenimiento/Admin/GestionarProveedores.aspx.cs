using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio; 

namespace Monolito.Dashboard
{
    
    public partial class GestionarProveedores : System.Web.UI.Page
    {
    
        protected void Page_Load(object sender, EventArgs e)
        {
            // if (!IsPostBack): Pregunta si es la primera vez que se carga la página
            if (!IsPostBack)
            {
                CargarProveedores(); 
            }
        }

       
        private void CargarProveedores()
        {
            try
            {
             
                var lista = CN_Proveedor.ListarTodos();
                
                
                gvProveedores.DataSource = lista;
                gvProveedores.DataBind();
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error", "No se pudieron cargar los proveedores: " + ex.Message);
            }
        }

       
        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            txtNombre.Text = string.Empty; // Limpia 
            hfProvId.Value = string.Empty; // Vacía el ID oculto 
            litTituloEditor.Text = "Agregar Nuevo Proveedor"; // Cambia 
            pnlEditor.Visible = true; 
            pnlBackdrop.Visible = true; 
        }

     
        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            pnlEditor.Visible = false; // Oculta el modal
            pnlBackdrop.Visible = false; // Oculta el fondo oscuro
        }

     
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                // 1. Obtener y limpiar 
                string nombre = txtNombre.Text.Trim();
                
                
                if (string.IsNullOrWhiteSpace(nombre))
                {
                    MostrarAlerta("warning", "Advertencia", "Por favor complete el nombre del proveedor.");
                    return; // Detiene 
                }

               
                if (string.IsNullOrEmpty(hfProvId.Value))
                {
                  
                    CN_Proveedor.Insertar(nombre); //  insertarlo en SQL
                    MostrarAlerta("success", "Éxito", "El proveedor ha sido registrado exitosamente.");
                }
                else
                {
                    
                    int id = int.Parse(hfProvId.Value); // Obtiene 
                    CN_Proveedor.Actualizar(id, nombre); 
                    MostrarAlerta("success", "Éxito", "El proveedor ha sido actualizado exitosamente.");
                }

                pnlEditor.Visible = false; 
                pnlBackdrop.Visible = false; 
                CargarProveedores(); // proveedores actualizados
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error", "No se pudo guardar el proveedor: " + ex.Message);
            }
        }

        
        protected void gvProveedores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
             
                if (e.CommandName == "Editar")
                {
               
                    int id = int.Parse(e.CommandArgument.ToString());
                    
                    // buscar el correspondiente al ID
                    var list = CN_Proveedor.ListarTodos();
                    var prov = list.Find(p => p.prov_id == id);
                    
                    if (prov != null)
                    {
                        // no ayuda a movificarlos modificarlos
                        hfProvId.Value = prov.prov_id.ToString();
                        txtNombre.Text = prov.prov_nombre;
                        
                        litTituloEditor.Text = "Editar Proveedor #" + prov.prov_id; 
                        pnlEditor.Visible = true;
                        pnlBackdrop.Visible = true;
                    }
                }
              
                else if (e.CommandName == "Eliminar")
                {
                    int id = int.Parse(e.CommandArgument.ToString());
                    
                   
                    CN_Proveedor.Eliminar(id); 
                    CargarProveedores(); 
                    MostrarAlerta("success", "Inactivado", "El proveedor ha sido inactivado. Sus productos fueron desvinculados.");
                }
                
                else if (e.CommandName == "Restaurar")
                {
                    int id = int.Parse(e.CommandArgument.ToString());
                    
                    
                    CN_Proveedor.Restaurar(id);
                    CargarProveedores(); // Recarga la tabla
                    MostrarAlerta("success", "Restaurado con Éxito", "El proveedor ha sido reactivado. Los productos originales han recuperado su vinculación automáticamente.");
                }
            }
            catch (Exception ex)
            {
                MostrarAlerta("error", "Error", "No se pudo completar la acción: " + ex.Message);
            }
        }

        private void MostrarAlerta(string tipo, string titulo, string mensaje)
        {
            // Construye el código JavaScript para invocar la ventana animada SweetAlert2
            string script = string.Format("Swal.fire({{ icon: '{0}', title: '{1}', text: '{2}', confirmButtonColor: '#7F77DD', background: '#07070f', color: '#fff' }});", tipo, titulo, mensaje);
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }
    }
}
