<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionarProductos.aspx.cs" Inherits="Monolito.Dashboard.GestionarProductos" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Gestión de Productos</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <style>
        :root { 
            --bg-dark: #05050b; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.75); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
            --error: #f87171;
            --success: #4ade80;
        }
        
        body { 
            background: var(--bg-dark) url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; 
            font-family: 'Outfit', sans-serif; 
            color: white; 
            min-height: 100vh; 
            padding: 40px 20px;
            margin: 0;
            overflow-x: hidden;
        }
        
        body::before { 
            content: ''; 
            position: fixed; 
            inset: 0; 
            background: radial-gradient(circle at center, rgba(13, 10, 36, 0.85) 0%, rgba(5, 5, 11, 0.96) 100%); 
            z-index: -1; 
        }

        /* --- ANIMACIÓN DE CALAVERAS --- */
        .skull-rain { position: fixed; inset: 0; pointer-events: none; z-index: 1; }
        .falling-skull {
            position: absolute; color: rgba(0, 242, 255, 0.08);
            font-size: 20px; animation: skullFall linear infinite;
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.3);
        }
        @keyframes skullFall {
            0% { transform: translateY(-50px) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(110vh) rotate(360deg); opacity: 0; }
        }

        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            position: relative;
            z-index: 2;
        }

        .btn-back { 
            text-decoration: none; 
            color: rgba(0,242,255,0.6); 
            font-size: 14px; 
            display: inline-flex; 
            align-items: center; 
            gap: 10px; 
            margin-bottom: 20px; 
            transition: 0.3s;
            font-family: 'Orbitron';
        }
        .btn-back:hover { 
            color: white; 
            transform: translateX(-5px);
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.6);
        }

        .glass-card { 
            background: var(--glass); 
            backdrop-filter: blur(20px); 
            border: 1px solid var(--glass-border); 
            border-radius: 24px; 
            padding: 30px; 
            box-shadow: var(--neon-shadow);
            margin-bottom: 30px;
        }

        .header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 30px; 
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 26px; 
            letter-spacing: 2px; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 0;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: white; 
            padding: 12px 24px; 
            border-radius: 12px; 
            border: none;
            cursor: pointer;
            font-family: 'Orbitron'; 
            font-size: 12px; 
            font-weight: 700; 
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
            transition: 0.3s;
        }
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5);
            filter: brightness(1.1);
        }

        /* BOTÓN EXPORTAR EXCEL */
        .btn-excel {
            background: linear-gradient(135deg, #10b981, #047857);
            color: white;
            padding: 12px 24px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-family: 'Orbitron';
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 0 20px rgba(16,185,129,0.35);
            transition: 0.3s;
            text-decoration: none;
        }
        .btn-excel:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 30px rgba(16,185,129,0.6);
            color: white;
        }

        /* Search Section styling */
        .search-panel {
            display: grid;
            grid-template-columns: 1fr auto auto auto;
            gap: 15px;
            align-items: center;
            margin-bottom: 25px;
            padding: 20px;
            background: rgba(0,0,0,0.3);
            border-radius: 16px;
            border: 1px solid var(--glass-border);
        }

        @media (max-width: 768px) {
            .search-panel {
                grid-template-columns: 1fr;
            }
        }

        .form-control-custom {
            background: rgba(0,0,0,0.4);
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 10px;
            color: white;
            padding: 10px 15px;
            font-size: 14px;
            transition: 0.3s;
            width: 100%;
            box-sizing: border-box;
            font-family: 'Outfit';
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .form-control-custom:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5);
            background: rgba(0,0,0,0.5);
        }

        .ddl-custom {
            min-width: 160px;
        }

        /* Grid View Custom Design */
        .grid-custom {
            width: 100% !important;
            border-collapse: collapse !important;
            border: none !important;
            margin-top: 15px;
        }
        .grid-custom th {
            text-align: left; 
            padding: 15px !important; 
            color: var(--accent) !important; 
            font-size: 12px !important; 
            text-transform: uppercase; 
            border-bottom: 2px solid var(--glass-border) !important;
            background: rgba(0,0,0,0.2) !important;
            font-family: 'Orbitron';
        }
        .grid-custom td {
            padding: 15px !important; 
            border-bottom: 1px solid rgba(255,255,255,0.05) !important; 
            font-size: 14px !important;
            color: rgba(255,255,255,0.9);
            vertical-align: middle;
            background: transparent !important;
        }
        .grid-custom tr:hover td {
            background: rgba(0, 242, 255, 0.05) !important;
        }

        /* Paging Custom Styles */
        .grid-custom .pager-row td {
            padding: 15px 0 0 0 !important;
            border: none !important;
        }
        .grid-custom .pager-row table {
            margin: 0 auto;
        }
        .grid-custom .pager-row span {
            background: var(--accent) !important;
            color: black !important;
            border-radius: 6px;
            padding: 5px 12px;
            font-weight: bold;
            margin: 0 4px;
            border: 1px solid var(--accent);
            font-family: 'Orbitron';
        }
        .grid-custom .pager-row a {
            background: rgba(255,255,255,0.05) !important;
            color: white !important;
            border-radius: 6px;
            padding: 5px 12px;
            margin: 0 4px;
            text-decoration: none;
            border: 1px solid var(--glass-border);
            transition: 0.3s;
            font-family: 'Orbitron';
        }
        .grid-custom .pager-row a:hover {
            background: var(--accent) !important;
            color: black !important;
            border-color: var(--accent);
        }

        /* Modales / Formularios de edición */
        .editor-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            width: 90%;
            max-width: 650px;
            background: rgba(8, 5, 25, 0.96);
            backdrop-filter: blur(25px);
            border: 2px solid var(--accent);
            border-radius: 24px;
            padding: 35px;
            box-shadow: 0 0 50px rgba(0, 242, 255, 0.4);
            animation: modalFadeIn 0.3s ease-out;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translate(-50%, -45%); }
            to { opacity: 1; transform: translate(-50%, -50%); }
        }

        /* Modal Overlay Backdrop */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
            z-index: 999;
            animation: fadeIn 0.2s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .editor-title {
            font-family: 'Orbitron';
            font-size: 16px;
            color: var(--accent);
            margin-bottom: 20px;
            border-bottom: 1px solid var(--glass-border);
            padding-bottom: 10px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .form-group label {
            font-size: 12px;
            color: rgba(255,255,255,0.7);
            font-weight: 600;
        }

        .button-bar {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 20px;
        }

        .btn-cancel {
            background: rgba(255,255,255,0.05);
            color: white;
            border: 1px solid var(--glass-border);
            border-radius: 10px;
            padding: 10px 20px;
            cursor: pointer;
            font-family: 'Outfit';
            transition: 0.3s;
        }
        .btn-cancel:hover {
            background: rgba(255,255,255,0.1);
        }

        .btn-submit {
            background: var(--accent);
            color: black;
            border: none;
            border-radius: 10px;
            padding: 10px 25px;
            cursor: pointer;
            font-family: 'Orbitron';
            font-weight: 700;
            box-shadow: 0 0 15px rgba(0,242,255,0.3);
            transition: 0.3s;
        }
        .btn-submit:hover {
            box-shadow: 0 0 25px rgba(0,242,255,0.6);
            transform: translateY(-1px);
        }

        .product-image {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 10px;
            border: 1px solid var(--glass-border);
        }
        
        select.form-control-custom option {
            background: #07070f;
            color: white;
            font-weight: bold;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div id="skullRain" class="skull-rain"></div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="container">
            <a href="DashboardAdmin.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD
            </a>

            <div class="glass-card">
                <div class="header">
                    <h1>SISTEMA DE GESTI&Oacute;N DE PRODUCTOS</h1>
                    <div style="display:flex; gap:12px; flex-wrap:wrap;">
                        <asp:LinkButton ID="btnExportarExcel" runat="server" OnClick="btnExportarExcel_Click" CssClass="btn-excel">
                            <i class="fas fa-file-excel"></i> EXPORTAR EXCEL
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnNuevo" runat="server" OnClick="btnNuevo_Click" CssClass="btn-primary-custom">
                            <i class="fas fa-box-open"></i> AGREGAR PRODUCTO
                        </asp:LinkButton>
                    </div>
                </div>

                <!-- UpdatePanel para búsqueda rápida sin recargar la página entera (Estilo Facebook) -->
                <asp:UpdatePanel ID="upSearch" runat="server">
                    <ContentTemplate>
                        <div class="search-panel">
                            <!-- Input de búsqueda rápido -->
                            <asp:TextBox ID="txtBusqueda" runat="server" CssClass="form-control-custom" 
                                placeholder="Búsqueda rápida de productos... (estilo Facebook)" 
                                AutoPostBack="true" OnTextChanged="txtBusqueda_TextChanged" />
                            
                            <!-- Filtrado por Categoría -->
                            <asp:DropDownList ID="ddlCategoriaFiltro" runat="server" CssClass="form-control-custom ddl-custom" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlCategoriaFiltro_SelectedIndexChanged" />

                            <!-- Filtrado por Proveedor -->
                            <asp:DropDownList ID="ddlProveedorFiltro" runat="server" CssClass="form-control-custom ddl-custom" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlProveedorFiltro_SelectedIndexChanged" />

                            <!-- Botón para limpiar filtros -->
                            <asp:LinkButton ID="btnLimpiar" runat="server" OnClick="btnLimpiar_Click" CssClass="btn-cancel" style="padding:10px 15px;">
                                <i class="fas fa-filter-circle-xmark"></i>
                            </asp:LinkButton>
                        </div>

                        <!-- GridView de productos -->
                        <asp:GridView ID="gvProductos" runat="server" AutoGenerateColumns="False" 
                            DataKeyNames="pro_id" CssClass="grid-custom"
                            AllowPaging="True" PageSize="5" OnPageIndexChanging="gvProductos_PageIndexChanging"
                            OnRowCommand="gvProductos_RowCommand">
                            
                            <PagerStyle CssClass="pager-row" />
                            <EmptyDataTemplate>
                                <div style="text-align:center; padding:30px; opacity:0.6;">
                                    <i class="fas fa-search" style="font-size:32px; margin-bottom:10px; color:var(--primary);"></i><br />
                                    No se encontraron productos con los criterios ingresados.
                                </div>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:BoundField DataField="pro_id" HeaderText="ID">
                                    <HeaderStyle Width="60px" />
                                    <ItemStyle Font-Bold="True" ForeColor="#00f2ff" />
                                </asp:BoundField>

                                <asp:TemplateField HeaderText="Imagen">
                                    <ItemTemplate>
                                         <img src='<%# ObtenerUrlImagen(Eval("pro_ruta_foto"), Eval("pro_nombre")) %>' class="product-image" />
                                    </ItemTemplate>
                                    <HeaderStyle Width="80px" />
                                </asp:TemplateField>

                                <asp:BoundField DataField="pro_nombre" HeaderText="Producto" />
                                <asp:BoundField DataField="cat_nombre" HeaderText="Categoría" />
                                <asp:BoundField DataField="prov_nombre" HeaderText="Proveedor" />

                                <asp:BoundField DataField="pro_cantidad" HeaderText="Stock">
                                    <HeaderStyle Width="80px" />
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:BoundField>

                                <asp:TemplateField HeaderText="Precio">
                                    <ItemTemplate>
                                        $<%# Convert.ToDecimal(Eval("pro_precio")).ToString("N2") %>
                                    </ItemTemplate>
                                    <HeaderStyle Width="100px" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Acciones">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("pro_id") %>' 
                                            CssClass="btn-action" style="margin-right:12px; color:#4ade80;">
                                            <i class="fas fa-edit"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("pro_id") %>' 
                                            CssClass="btn-action" style="color:#f87171;" 
                                            OnClientClick="return confirm('¿Está seguro de eliminar este producto de forma lógica?');">
                                            <i class="fas fa-trash-alt"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderStyle Width="100px" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:Panel ID="pnlBackdrop" runat="server" CssClass="modal-overlay" Visible="false" />

                        <!-- Panel de Formulario CRUD (Añadir / Editar) -->
                        <asp:Panel ID="pnlEditor" runat="server" CssClass="editor-panel" Visible="false">
                            <div class="editor-title">
                                <asp:Literal ID="litTituloEditor" runat="server">Agregar Nuevo Producto</asp:Literal>
                            </div>

                            <asp:HiddenField ID="hfProId" runat="server" />

                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Nombre del Producto</label>
                                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control-custom" placeholder="Nombre completo" />
                                </div>
                                <div class="form-group">
                                    <label>Cantidad (Stock)</label>
                                    <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control-custom" placeholder="Stock" TextMode="Number" />
                                </div>
                                <div class="form-group">
                                    <label>Precio Unitario</label>
                                    <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control-custom" placeholder="0.00" />
                                </div>
                                <div class="form-group">
                                    <label>Categoría</label>
                                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-control-custom" />
                                </div>
                                <div class="form-group">
                                    <label>Proveedor</label>
                                    <asp:DropDownList ID="ddlProveedor" runat="server" CssClass="form-control-custom" />
                                </div>
                                <div class="form-group" style="grid-column: 1 / -1;">
                                    <label><i class="fas fa-images" style="color:var(--accent)"></i>  Imágenes del Producto — <span style="color:var(--accent)">selecciona 1 o más para el carrusel automático</span></label>
                                    <asp:FileUpload ID="fuFoto" runat="server" CssClass="form-control-custom" AllowMultiple="true"
                                        style="padding:8px; cursor:pointer;"
                                        onchange="previewFotos(this)" />
                                    <asp:Label ID="lblRutaActual" runat="server" style="font-size:11px; color:rgba(255,255,255,0.5);" />
                                    <!-- Preview de imágenes seleccionadas -->
                                    <div id="previewContainer" style="display:flex;flex-wrap:wrap;gap:10px;margin-top:12px;"></div>
                                </div>
                            </div>

                            <div class="button-bar">
                                <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" OnClick="btnCancelar_Click" CssClass="btn-cancel" />
                                <asp:Button ID="btnGuardar" runat="server" Text="Guardar" OnClick="btnGuardar_Click" CssClass="btn-submit" />
                            </div>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnGuardar" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </form>
    <style>
        /* Thumbnails preview de fotos seleccionadas */
        .preview-thumb {
            position: relative;
            width: 80px;
            height: 80px;
            border-radius: 10px;
            overflow: hidden;
            border: 2px solid var(--primary);
            box-shadow: 0 0 12px rgba(127,119,221,0.4);
            animation: thumbIn 0.3s ease-out;
        }
        .preview-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .preview-thumb .thumb-num {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0,0,0,0.65);
            color: var(--accent);
            font-size: 9px;
            text-align: center;
            padding: 2px;
            font-family: 'Orbitron';
        }
        @keyframes thumbIn {
            from { opacity: 0; transform: scale(0.7); }
            to   { opacity: 1; transform: scale(1); }
        }
    </style>
    <script>
        function previewFotos(input) {
            var container = document.getElementById('previewContainer');
            container.innerHTML = '';
            if (!input.files || input.files.length === 0) return;

            var files = Array.from(input.files);
            files.forEach(function(file, idx) {
                if (!file.type.startsWith('image/')) return;
                var reader = new FileReader();
                reader.onload = function(e) {
                    var wrap = document.createElement('div');
                    wrap.className = 'preview-thumb';
                    var img = document.createElement('img');
                    img.src = e.target.result;
                    var num = document.createElement('div');
                    num.className = 'thumb-num';
                    num.textContent = (idx === 0 ? '★ Principal' : 'Foto ' + (idx + 1));
                    wrap.appendChild(img);
                    wrap.appendChild(num);
                    container.appendChild(wrap);
                };
                reader.readAsDataURL(file);
            });
        }

        function initSkulls() {
            const rain = document.getElementById('skullRain');
            for (let i = 0; i < 20; i++) {
                const skull = document.createElement('i');
                skull.className = 'fas fa-skull falling-skull';
                skull.style.left = Math.random() * 100 + 'vw';
                skull.style.animationDuration = (Math.random() * 5 + 7) + 's';
                skull.style.animationDelay = (Math.random() * 5) + 's';
                skull.style.fontSize = (Math.random() * 20 + 10) + 'px';
                rain.appendChild(skull);
            }
        }
        initSkulls();
    </script>
</body>
</html>
