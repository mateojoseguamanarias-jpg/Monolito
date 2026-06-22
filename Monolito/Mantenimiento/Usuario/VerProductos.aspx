<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerProductos.aspx.cs" Inherits="Monolito.Dashboard.VerProductos" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Catálogo de Productos</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Bootstrap para carrusel -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        :root { 
            --sidebar-w: 260px; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.75); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            background: #05050b url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; 
            font-family: 'Outfit', sans-serif; 
            color: white; 
            min-height: 100vh; 
            overflow: hidden;
        }
        body::before { 
            content: ''; 
            position: fixed; 
            inset: 0; 
            background: radial-gradient(circle at center, rgba(13, 10, 36, 0.85) 0%, rgba(5, 5, 11, 0.96) 100%); 
            z-index: -1; 
        }

        /* --- ANIMACIÓN DE PARTÍCULAS --- */
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

        .app-container { display: flex; height: 100vh; position: relative; z-index: 2; }

        /* SIDEBAR */
        .sidebar { 
            width: var(--sidebar-w); background: rgba(5, 5, 15, 0.8); backdrop-filter: blur(25px);
            border-right: 1px solid var(--glass-border); display: flex; flex-direction: column; padding: 30px 0;
            flex-shrink: 0;
            box-shadow: 10px 0 30px rgba(0,0,0,0.5);
        }
        .logo { 
            padding: 0 30px 40px; font-family: 'Orbitron'; font-size: 24px; font-weight: 900; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 2px; 
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        .logo span { color: var(--accent); }
        
        .nav-menu { list-style: none; flex: 1; }
        .nav-item { margin-bottom: 5px; }
        .nav-link { 
            display: flex; align-items: center; gap: 15px; padding: 15px 30px; color: rgba(255,255,255,0.6);
            text-decoration: none; transition: all 0.3s ease; border-left: 3px solid transparent;
        }
        .nav-link:hover, .nav-link.active { 
            background: rgba(0, 242, 255, 0.08); color: white; border-left-color: var(--accent); 
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.5);
        }
        .nav-link i { font-size: 20px; width: 25px; }

        /* MAIN CONTENT */
        .main-content { flex: 1; padding: 40px; overflow-y: auto; display: flex; flex-direction: column; }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            border-bottom: 1px solid rgba(0, 242, 255, 0.15);
            padding-bottom: 20px;
        }
        .header-section h1 {
            font-family: 'Orbitron';
            font-size: 28px;
            font-weight: 900;
            color: white;
            text-shadow: 0 0 20px rgba(0, 242, 255, 0.3);
            margin: 0;
            text-transform: uppercase;
        }
        .header-section h1 span { 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent; 
        }

        /* SEARCH BAR */
        .search-container {
            display: flex;
            gap: 15px;
            margin-bottom: 35px;
            background: var(--glass);
            border: 1px solid var(--glass-border);
            padding: 15px;
            border-radius: 16px;
            backdrop-filter: blur(25px);
            flex-wrap: wrap;
            box-shadow: var(--neon-shadow), inset 0 0 10px rgba(255,255,255,0.01);
        }
        .form-control-custom {
            background: rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(0, 242, 255, 0.2);
            color: white;
            padding: 12px 20px;
            border-radius: 10px;
            outline: none;
            transition: 0.3s;
            font-size: 14px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
            font-family: 'Outfit';
        }
        .form-control-custom:focus {
            border-color: var(--accent);
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5);
            background: rgba(0, 0, 0, 0.5);
        }
        .txt-search { flex: 1; min-width: 200px; }
        .ddl-custom { width: 200px; }
        .btn-cancel {
            background: rgba(0, 242, 255, 0.05);
            border: 1px solid rgba(0, 242, 255, 0.2);
            color: var(--accent);
            padding: 12px 20px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn-cancel:hover { background: rgba(0, 242, 255, 0.15); border-color: var(--accent); box-shadow: 0 0 10px rgba(0, 242, 255, 0.2); }

        select.form-control-custom option {
            background: #05050b;
            color: white;
            font-weight: bold;
        }

        /* PRODUCT CARDS GRID */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 30px;
            padding-bottom: 40px;
        }
        .product-card {
            background: var(--glass);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            overflow: hidden;
            backdrop-filter: blur(25px);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            display: flex;
            flex-direction: column;
            box-shadow: 0 15px 35px rgba(0,0,0,0.3), inset 0 0 15px rgba(255,255,255,0.01);
        }
        .product-card:hover {
            transform: translateY(-8px);
            border-color: var(--accent);
            box-shadow: var(--neon-shadow), 0 20px 45px rgba(0, 242, 255, 0.15);
        }

        /* CAROUSEL IN CARD */
        .carousel-container {
            position: relative;
            width: 100%;
            height: 220px;
            background: #000;
            overflow: hidden;
            border-bottom: 1px solid rgba(0, 242, 255, 0.15);
        }
        .product-card-img {
            width: 100%;
            height: 220px;
            object-fit: cover;
            transition: 0.5s;
        }
        .carousel-control-prev, .carousel-control-next {
            opacity: 0;
            transition: 0.3s;
        }
        .carousel-container:hover .carousel-control-prev,
        .carousel-container:hover .carousel-control-next {
            opacity: 0.8;
        }

        /* CARD BODY */
        .card-body-custom {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex: 1;
            justify-content: space-between;
        }
        .product-title {
            font-family: 'Orbitron';
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 8px;
            color: white;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .product-meta {
            display: flex;
            flex-direction: column;
            gap: 5px;
            margin-bottom: 15px;
        }
        .meta-item {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.5);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .meta-item i { color: var(--accent); width: 16px; }
        .meta-item span.accent { color: var(--accent); font-weight: 600; }
        .card-footer-custom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding-top: 15px;
            margin-top: auto;
        }
        .product-price {
            font-family: 'Orbitron';
            font-size: 20px;
            font-weight: 900;
            color: var(--accent);
            text-shadow: 0 0 10px rgba(0, 242, 255, 0.4);
        }
        .product-stock {
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .stock-in {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        .stock-out {
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        .empty-container {
            text-align: center;
            padding: 80px 20px;
            background: var(--glass);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            margin-top: 20px;
            box-shadow: var(--neon-shadow);
        }
        .empty-container i { font-size: 54px; color: var(--accent); margin-bottom: 20px; opacity: 0.7; }
        .empty-container h3 { font-family: 'Orbitron'; margin-bottom: 10px; }

        .logout-btn { margin: 20px 30px; padding: 15px; background: rgba(239, 68, 68, 0.05); border: 1px solid rgba(239, 68, 68, 0.2); border-radius: 12px; color: #fca5a5; text-align: center; text-decoration: none; font-weight: 700; transition: all 0.3s ease; font-size: 12px; letter-spacing: 1px; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .logout-btn:hover { background: #ef4444; color: white; border-color: #ef4444; box-shadow: 0 0 20px rgba(239,68,68,0.4); }

        /* BOTÓN AGREGAR A MI LISTA */
        .btn-add-cart {
            display: flex; align-items: center; gap: 6px;
            background: rgba(0,242,255,0.05); border: 1px solid rgba(0,242,255,0.25);
            color: var(--accent); padding: 8px 14px; border-radius: 10px;
            cursor: pointer; font-size: 12px; font-weight: 700;
            transition: all 0.3s ease; white-space: nowrap;
        }
        .btn-add-cart:hover { background: var(--accent); color: #000; box-shadow: 0 0 15px rgba(0,242,255,0.5); }
        .btn-add-cart.saved {
            background: rgba(0,242,255,0.15); border-color: rgba(0,242,255,0.4);
            color: var(--accent);
        }
        .btn-add-cart.saved:hover { background: rgba(0,242,255,0.2); color: var(--accent); box-shadow: none; cursor: default; }

        /* TOAST NOTIFICATION */
        .toast-wrap { position: fixed; bottom: 30px; right: 30px; z-index: 9999; pointer-events: none; }
        .toast-pill {
            background: rgba(16,185,129,0.92); backdrop-filter: blur(15px);
            border: 1px solid rgba(16,185,129,0.4); color: white;
            padding: 13px 22px; border-radius: 14px; font-weight: 600;
            display: flex; align-items: center; gap: 10px; font-size: 14px;
            animation: toastIn 0.4s ease; box-shadow: 0 8px 30px rgba(16,185,129,0.3);
            margin-top: 10px;
        }
        .toast-pill.warn { background: rgba(234,179,8,0.92); border-color: rgba(234,179,8,0.4); box-shadow: 0 8px 30px rgba(234,179,8,0.3); }
        @keyframes toastIn { from { opacity:0; transform:translateX(60px); } to { opacity:1; transform:translateX(0); } }

        /* Badge de fotos en carrusel */
        .carousel-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(0,0,0,0.6);
            border: 1px solid var(--glass-border);
            color: white;
            font-size: 10px;
            padding: 3px 8px;
            border-radius: 20px;
            z-index: 10;
            backdrop-filter: blur(5px);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="app-container">
            <!-- SIDEBAR -->
            <aside class="sidebar">
                <div class="logo">Nova<span>X</span></div>
                <nav class="nav-menu">
                    <div class="nav-item"><a href="DashboardUsuario.aspx" class="nav-link"><i class="fas fa-home"></i> Inicio</a></div>
                    <div class="nav-item"><a href="MiPerfil.aspx" class="nav-link"><i class="fas fa-user-circle"></i> Mi Perfil</a></div>
                    <div class="nav-item"><a href="VerProductos.aspx" class="nav-link active"><i class="fas fa-box-open"></i> Productos</a></div>
                    <div class="nav-item"><a href="MiCarrito.aspx" class="nav-link"><i class="fas fa-heart"></i> Mi Lista</a></div>
                    <div class="nav-item"><a href="Juego.aspx" class="nav-link"><i class="fas fa-gamepad"></i> Misiones</a></div>
                </nav>
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="logout-btn" OnClick="btnLogout_Click">
                    <i class="fas fa-power-off"></i> CERRAR SESI&Oacute;N
                </asp:LinkButton>
            </aside>

            <!-- MAIN CONTENT -->
            <main class="main-content">
                <asp:ScriptManager ID="ScriptManager1" runat="server" />
                <asp:UpdatePanel ID="upProducts" runat="server">
                    <ContentTemplate>
                        
                        <div class="header-section">
                            <h1>CAT&Aacute;LOGO DE <span>PRODUCTOS</span></h1>
                        </div>

                        <!-- Filtros de Búsqueda -->
                        <div class="search-container">
                            <asp:TextBox ID="txtBusqueda" runat="server" CssClass="form-control-custom txt-search" 
                                placeholder="Buscar productos..." AutoPostBack="true" OnTextChanged="txtBusqueda_TextChanged" />
                            
                            <asp:DropDownList ID="ddlCategoriaFiltro" runat="server" CssClass="form-control-custom ddl-custom" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlCategoriaFiltro_SelectedIndexChanged" />

                            <asp:DropDownList ID="ddlProveedorFiltro" runat="server" CssClass="form-control-custom ddl-custom" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlProveedorFiltro_SelectedIndexChanged" />

                            <asp:LinkButton ID="btnLimpiar" runat="server" OnClick="btnLimpiar_Click" CssClass="btn-cancel">
                                <i class="fas fa-filter-circle-xmark"></i>
                            </asp:LinkButton>
                        </div>

                        <!-- Grid de Tarjetas de Productos (SIN evento ItemDataBound) -->
                        <asp:Repeater ID="rptProductos" runat="server" OnItemCommand="rptProductos_ItemCommand">
                            <HeaderTemplate>
                                <div class="products-grid">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="product-card">
                                    
                                    <!-- Carrusel generado 100% desde code-behind para evitar errores de compilación -->
                                    <div class="carousel-container">
                                        <%# GenerarCarrusel((int)Eval("pro_id"), (string)Eval("pro_nombre"), (string)Eval("pro_ruta_foto")) %>
                                    </div>

                                    <!-- Detalles del Producto -->
                                    <div class="card-body-custom">
                                        <h3 class="product-title"><%# Eval("pro_nombre") %></h3>
                                        
                                        <div class="product-meta">
                                            <div class="meta-item">
                                                <i class="fas fa-tags"></i> Categor&iacute;a: <span class="accent"><%# Eval("cat_nombre") %></span>
                                            </div>
                                            <div class="meta-item">
                                                <i class="fas fa-truck"></i> Proveedor: <span class="accent"><%# Eval("prov_nombre") %></span>
                                            </div>
                                        </div>

                                        <div class="card-footer-custom">
                                            <div>
                                                <div class="product-price">$<%# Convert.ToDecimal(Eval("pro_precio")).ToString("N2") %></div>
                                                <div class='<%# Convert.ToInt32(Eval("pro_cantidad")) > 0 ? "product-stock stock-in" : "product-stock stock-out" %>' style="margin-top:5px;">
                                                    <%# Convert.ToInt32(Eval("pro_cantidad")) > 0 ? "Stock: " + Eval("pro_cantidad") : "Agotado" %>
                                                </div>
                                            </div>
                                            <asp:LinkButton ID="btnAgregar" runat="server"
                                                CommandName="AgregarCarrito"
                                                CommandArgument='<%# Eval("pro_id") %>'
                                                CssClass='<%# EsProductoGuardado((int)Eval("pro_id")) ? "btn-add-cart saved" : "btn-add-cart" %>'>
                                                <i class='<%# EsProductoGuardado((int)Eval("pro_id")) ? "fas fa-heart" : "far fa-heart" %>'></i>
                                                <%# EsProductoGuardado((int)Eval("pro_id")) ? "Guardado" : "Mi Lista" %>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- Mensaje en caso de no haber productos -->
                        <asp:Panel ID="pnlVacio" runat="server" Visible="false" CssClass="empty-container">
                            <i class="fas fa-box-open"></i>
                            <h3>No se encontraron productos</h3>
                            <p style="opacity: 0.6;">Intenta ajustar los criterios de búsqueda o filtros.</p>
                        </asp:Panel>
                        <!-- TOAST NOTIFICATION -->
                        <asp:Panel ID="pnlToast" runat="server" Visible="false" CssClass="toast-wrap">
                            <div class="toast-pill">
                                <i class="fas fa-check-circle"></i>
                                <asp:Label ID="lblToast" runat="server"></asp:Label>
                            </div>
                        </asp:Panel>

                    </ContentTemplate>
                </asp:UpdatePanel>
            </main>
        </div>
    </form>

    <script>
        function initSkulls() {
            const rain = document.getElementById('skullRain');
            if (!rain) return;
            for (let i = 0; i < 15; i++) {
                const skull = document.createElement('i');
                skull.className = 'fas fa-box falling-skull';
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
