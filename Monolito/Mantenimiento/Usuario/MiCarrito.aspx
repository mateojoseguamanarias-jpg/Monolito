<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MiCarrito.aspx.cs" Inherits="Monolito.Dashboard.MiCarrito" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Mi Lista de Productos</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        :root {
            --sidebar-w: 260px;
            --primary: #9d4edd;
            --accent: #00f2ff;
            --glass: rgba(8, 8, 20, 0.75);
            --glass-border: rgba(0, 242, 255, 0.25);
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
            --danger: #ef4444;
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

        /* PARTICLE BG */
        .skull-rain { position:fixed; inset:0; pointer-events:none; z-index:1; }
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

        .app-container { display:flex; height:100vh; position:relative; z-index:2; }

        /* SIDEBAR */
        .sidebar {
            width: var(--sidebar-w); background: rgba(5, 5, 15, 0.8); backdrop-filter: blur(25px);
            border-right: 1px solid var(--glass-border); display: flex; flex-direction: column; padding: 30px 0;
            box-shadow: 10px 0 30px rgba(0,0,0,0.5); flex-shrink: 0;
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
        .nav-menu { list-style:none; flex:1; }
        .nav-item  { margin-bottom:5px; }
        .nav-link {
            display:flex; align-items:center; gap:15px; padding:15px 30px;
            color:rgba(255,255,255,0.6); text-decoration:none;
            transition: all 0.3s ease; border-left: 3px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(0, 242, 255, 0.08); color: white; border-left-color: var(--accent);
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.5);
        }
        .nav-link i { font-size:20px; width:25px; }
        .logout-btn {
            margin:20px 30px; padding:15px;
            background:rgba(239,68,68,0.05); border:1px solid rgba(239,68,68,0.2);
            border-radius:12px; color:#fca5a5; text-align:center; text-decoration:none;
            font-weight:700; transition:0.3s; font-size:12px; letter-spacing:1px;
            display:flex; align-items:center; justify-content:center; gap:10px; cursor:pointer;
        }
        .logout-btn:hover { background:#ef4444; color:white; border-color:#ef4444; box-shadow:0 0 20px rgba(239,68,68,0.4); }

        /* MAIN */
        .main-content { flex:1; padding:40px; overflow-y:auto; display:flex; flex-direction:column; }

        .header-section {
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:30px; border-bottom:1px solid var(--glass-border); padding-bottom:15px;
        }
        .header-section h1 { font-family:'Orbitron'; font-size:28px; font-weight:900; color:white; text-shadow:0 0 20px rgba(0,242,255,0.3); margin:0; }
        .header-section h1 span { color:var(--accent); }

        /* SUMMARY BAR */
        .summary-bar {
            display:flex; gap:20px; margin-bottom:30px; flex-wrap:wrap;
        }
        .summary-card {
            background:var(--glass); border:1px solid var(--glass-border);
            border-radius:16px; padding:20px 28px; backdrop-filter:blur(10px);
            display:flex; align-items:center; gap:15px; flex:1; min-width:200px;
            box-shadow: inset 0 0 15px rgba(0,242,255,0.05);
        }
        .summary-card i { font-size:28px; color:var(--accent); text-shadow: 0 0 10px rgba(0,242,255,0.4); }
        .summary-card .s-label { font-size:11px; opacity:0.5; text-transform:uppercase; letter-spacing:1px; display:block; margin-bottom:4px; }
        .summary-card .s-value { font-family:'Orbitron'; font-size:22px; font-weight:700; color:var(--accent); }

        /* PRODUCT CARDS GRID */
        .products-grid {
            display:grid; grid-template-columns:repeat(auto-fill,minmax(290px,1fr));
            gap:30px; padding-bottom:40px;
        }
        .product-card {
            background: var(--glass); border:1px solid var(--glass-border);
            border-radius:24px; overflow:hidden; backdrop-filter:blur(20px);
            transition:0.3s cubic-bezier(0.175,0.885,0.32,1.275);
            display:flex; flex-direction:column; box-shadow:0 15px 35px rgba(0,0,0,0.3);
            position:relative;
        }
        .product-card:hover {
            transform:translateY(-8px); border-color:var(--accent);
            box-shadow:0 20px 45px rgba(0,242,255,0.25);
        }

        /* SAVED BADGE */
        .saved-badge {
            position:absolute; top:12px; left:12px; z-index:10;
            background:rgba(0,242,255,0.15); border:1px solid rgba(0,242,255,0.3);
            color:var(--accent); font-size:10px; font-weight:700;
            padding:4px 10px; border-radius:20px; letter-spacing:1px;
            display:flex; align-items:center; gap:5px;
        }

        /* CARD IMAGE */
        .card-img-wrap { width:100%; height:200px; overflow:hidden; background:#000; }
        .card-img-wrap img { width:100%; height:100%; object-fit:cover; transition:0.5s; }
        .product-card:hover .card-img-wrap img { transform:scale(1.06); }

        /* CARD BODY */
        .card-body-custom {
            padding:20px; display:flex; flex-direction:column; flex:1;
        }
        .product-title { font-family:'Orbitron'; font-size:15px; font-weight:700; margin-bottom:8px; color:white; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .product-meta  { display:flex; flex-direction:column; gap:5px; margin-bottom:15px; }
        .meta-item     { font-size:12px; color:rgba(255,255,255,0.5); display:flex; align-items:center; gap:8px; }
        .meta-item i   { color:var(--accent); width:16px; }
        .meta-item .accent { color:var(--accent); font-weight:600; }

        .card-footer-custom {
            display:flex; justify-content:space-between; align-items:center;
            border-top:1px solid rgba(255,255,255,0.05); padding-top:15px; margin-top:auto; gap:10px;
        }
        .product-price { font-family:'Orbitron'; font-size:20px; font-weight:900; color:var(--accent); text-shadow:0 0 10px rgba(0,242,255,0.2); }
        .product-stock { font-size:11px; padding:4px 10px; border-radius:20px; font-weight:700; text-transform:uppercase; }
        .stock-in  { background:rgba(16,185,129,0.1); color:#10b981; border:1px solid rgba(16,185,129,0.2); }
        .stock-out { background:rgba(239,68,68,0.1);  color:#ef4444; border:1px solid rgba(239,68,68,0.2); }

        /* REMOVE BUTTON */
        .btn-remove {
            background:rgba(239,68,68,0.08); border:1px solid rgba(239,68,68,0.25);
            color:#fca5a5; padding:8px 14px; border-radius:10px; cursor:pointer;
            font-size:12px; font-weight:700; transition:0.3s; display:flex; align-items:center; gap:6px;
            white-space:nowrap;
        }
        .btn-remove:hover { background:#ef4444; color:white; border-color:#ef4444; box-shadow:0 0 15px rgba(239,68,68,0.4); }

        /* EMPTY STATE */
        .empty-container {
            text-align:center; padding:80px 20px;
            background:var(--glass); border:1px solid var(--glass-border);
            border-radius:24px; margin-top:20px;
            box-shadow: var(--neon-shadow);
        }
        .empty-container i   { font-size:54px; color:var(--accent); margin-bottom:20px; opacity:0.7; display:block; text-shadow: 0 0 15px rgba(0,242,255,0.4); }
        .empty-container h3  { font-family:'Orbitron'; margin-bottom:10px; }
        .empty-container p   { opacity:0.6; margin-bottom:25px; }
        .btn-goto-products {
            display:inline-flex; align-items:center; gap:10px;
            background:linear-gradient(135deg,var(--primary),#5a52bb);
            color:white; padding:14px 28px; border-radius:12px;
            text-decoration:none; font-weight:700; font-size:14px;
            transition:0.3s; box-shadow:0 8px 25px rgba(127,119,221,0.3);
        }
        .btn-goto-products:hover { transform:translateY(-3px); box-shadow:0 12px 35px rgba(127,119,221,0.5); color:white; }

        /* DATE CHIP */
        .date-chip { font-size:10px; opacity:0.4; margin-top:6px; }

        /* TOAST */
        .toast-container { position:fixed; bottom:30px; right:30px; z-index:9999; }
        .toast-msg {
            background:rgba(239,68,68,0.9); backdrop-filter:blur(15px);
            border:1px solid rgba(239,68,68,0.4); color:white;
            padding:14px 22px; border-radius:14px; font-weight:600;
            display:flex; align-items:center; gap:10px; font-size:14px;
            animation:toastIn 0.4s ease; box-shadow:0 8px 30px rgba(239,68,68,0.3);
        }
        .toast-msg.success { background:rgba(16,185,129,0.9); border-color:rgba(16,185,129,0.4); box-shadow:0 8px 30px rgba(16,185,129,0.3); }
        @keyframes toastIn { from { opacity:0; transform:translateX(60px); } to { opacity:1; transform:translateX(0); } }
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
                    <div class="nav-item"><a href="VerProductos.aspx" class="nav-link"><i class="fas fa-box-open"></i> Productos</a></div>
                    <div class="nav-item"><a href="MiCarrito.aspx" class="nav-link active"><i class="fas fa-heart"></i> Mi Lista</a></div>
                    <div class="nav-item"><a href="Juego.aspx" class="nav-link"><i class="fas fa-gamepad"></i> Misiones</a></div>
                </nav>
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="logout-btn" OnClick="btnLogout_Click">
                    <i class="fas fa-power-off"></i> CERRAR SESI&Oacute;N
                </asp:LinkButton>
            </aside>

            <!-- MAIN CONTENT -->
            <main class="main-content">
                <asp:ScriptManager ID="ScriptManager1" runat="server" />
                <asp:UpdatePanel ID="upCarrito" runat="server">
                    <ContentTemplate>

                        <div class="header-section">
                            <h1>MI <span>LISTA</span></h1>
                        </div>

                        <!-- RESUMEN -->
                        <div class="summary-bar">
                            <div class="summary-card">
                                <i class="fas fa-heart"></i>
                                <div>
                                    <span class="s-label">Productos guardados</span>
                                    <asp:Label ID="lblTotalItems" runat="server" CssClass="s-value">0</asp:Label>
                                </div>
                            </div>
                            <div class="summary-card">
                                <i class="fas fa-dollar-sign"></i>
                                <div>
                                    <span class="s-label">Valor total</span>
                                    <asp:Label ID="lblTotalPrecio" runat="server" CssClass="s-value">$0.00</asp:Label>
                                </div>
                            </div>
                        </div>

                        <!-- LISTA DE PRODUCTOS GUARDADOS -->
                        <asp:Repeater ID="rptCarrito" runat="server" OnItemCommand="rptCarrito_ItemCommand">
                            <HeaderTemplate>
                                <div class="products-grid">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="product-card">
                                    <span class="saved-badge"><i class="fas fa-heart"></i> GUARDADO</span>

                                    <div class="card-img-wrap">
                                        <img src='<%# ObtenerUrlFoto((string)Eval("pro_ruta_foto"), (string)Eval("pro_nombre")) %>'
                                             alt='<%# Eval("pro_nombre") %>'
                                             onerror="this.src='https://placehold.co/400x300/07070f/7F77DD?text=NovaX'" />
                                    </div>

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

                                        <div class="date-chip">
                                            <i class="fas fa-clock"></i> Guardado el <%# Convert.ToDateTime(Eval("car_fecha")).ToString("dd/MM/yyyy HH:mm") %>
                                        </div>

                                        <div class="card-footer-custom">
                                            <div>
                                                <div class="product-price">$<%# Convert.ToDecimal(Eval("pro_precio")).ToString("N2") %></div>
                                                <div class='<%# Convert.ToInt32(Eval("pro_cantidad")) > 0 ? "product-stock stock-in" : "product-stock stock-out" %>' style="margin-top:6px;">
                                                    <%# Convert.ToInt32(Eval("pro_cantidad")) > 0 ? "Stock: " + Eval("pro_cantidad") : "Agotado" %>
                                                </div>
                                            </div>
                                            <asp:LinkButton ID="btnEliminar" runat="server"
                                                CommandName="Eliminar"
                                                CommandArgument='<%# Eval("car_id") %>'
                                                CssClass="btn-remove"
                                                OnClientClick="return confirm('¿Quitar este producto de tu lista?');">
                                                <i class="fas fa-trash"></i> Quitar
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- ESTADO VACÍO -->
                        <asp:Panel ID="pnlVacio" runat="server" Visible="false" CssClass="empty-container">
                            <i class="fas fa-heart-crack"></i>
                            <h3>Tu lista est&aacute; vac&iacute;a</h3>
                            <p>Explora el cat&aacute;logo y guarda los productos que te interesen.</p>
                            <a href="VerProductos.aspx" class="btn-goto-products">
                                <i class="fas fa-box-open"></i> Ver Catálogo
                            </a>
                        </asp:Panel>

                        <!-- TOAST -->
                        <asp:Panel ID="pnlToast" runat="server" Visible="false" CssClass="toast-container">
                            <div id="toastMsg" class="toast-msg success">
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
                const s = document.createElement('i');
                s.className = 'fas fa-heart falling-skull';
                s.style.left = Math.random() * 100 + 'vw';
                s.style.animationDuration = (Math.random() * 5 + 7) + 's';
                s.style.animationDelay   = (Math.random() * 5) + 's';
                s.style.fontSize = (Math.random() * 15 + 8) + 'px';
                rain.appendChild(s);
            }
        }
        initSkulls();
    </script>
</body>
</html>
