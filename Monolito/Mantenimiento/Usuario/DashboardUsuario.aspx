<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DashboardUsuario.aspx.cs" Inherits="Monolito.Dashboard.DashboardUsuario" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Panel de Agente</title>
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
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            background: #05050b url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; font-family: 'Outfit', sans-serif; color: white; min-height: 100vh; overflow: hidden;
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
 
        .app-container { display: flex; height: 100vh; position: relative; z-index: 2; }
 
        /* SIDEBAR */
        .sidebar { 
            width: var(--sidebar-w); background: rgba(5, 5, 15, 0.8); backdrop-filter: blur(25px);
            border-right: 1px solid var(--glass-border); display: flex; flex-direction: column; padding: 30px 0;
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
        .main-content { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px; }
         
        .profile-card {
            background: var(--glass); border: 1px solid var(--glass-border);
            backdrop-filter: blur(30px); border-radius: 40px; padding: 40px;
            width: 100%; max-width: 800px; text-align: center;
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
            position: relative; overflow: hidden;
            display: flex; flex-direction: column; align-items: center; gap: 20px;
        }
        .profile-card::before {
            content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
            background: radial-gradient(circle, rgba(0, 242, 255, 0.05) 0%, transparent 70%);
            z-index: -1;
        }
 
        .avatar-container { position: relative; display: inline-block; }
        .avatar-container img { 
            width: 140px; height: 140px; border-radius: 50%; 
            border: 4px solid var(--accent); box-shadow: 0 0 30px rgba(0, 242, 255, 0.4);
            object-fit: cover;
        }
        .status-dot {
            position: absolute; bottom: 8px; right: 8px; width: 22px; height: 22px;
            background: #4ade80; border: 4px solid #05050b; border-radius: 50%;
            box-shadow: 0 0 15px #4ade80;
        }
 
        .profile-info h1 { font-family: 'Orbitron'; font-size: 32px; margin-bottom: 5px; letter-spacing: 2px; text-transform: lowercase; }
        .profile-info p { color: var(--accent); font-family: 'Orbitron'; font-size: 11px; letter-spacing: 3px; font-weight: 700; margin-bottom: 15px; text-shadow: 0 0 5px rgba(0, 242, 255, 0.4); }
 
        .info-boxes { display: flex; gap: 15px; margin-bottom: 25px; flex-wrap: wrap; justify-content: center; }
        .info-box { 
            background: rgba(0,0,0,0.3); border: 1px solid rgba(0, 242, 255, 0.15); 
            padding: 10px 20px; border-radius: 12px; min-width: 180px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .info-box span { display: block; font-size: 9px; opacity: 0.6; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; color: var(--accent); }
        .info-box strong { font-size: 13px; color: white; font-family: 'Outfit'; }
 
        .score-container {
            background: rgba(0, 242, 255, 0.03); border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 30px; padding: 30px; width: 100%; max-width: 500px;
            position: relative; overflow: hidden;
            box-shadow: inset 0 0 15px rgba(0,242,255,0.05);
        }
        .score-container::after { content: ''; position: absolute; inset: 0; background: linear-gradient(45deg, transparent, rgba(255,255,255,0.02), transparent); transform: translateX(-100%); animation: shine 3s infinite; }
        @keyframes shine { 100% { transform: translateX(100%); } }
 
        .score-label { font-family: 'Orbitron'; font-size: 10px; letter-spacing: 5px; opacity: 0.8; margin-bottom: 10px; display: block; color: var(--accent); text-shadow: 0 0 5px rgba(0, 242, 255, 0.3); }
        .score-value { font-family: 'Orbitron'; font-size: 72px; font-weight: 900; color: white; text-shadow: 0 0 30px rgba(0, 242, 255, 0.6); line-height: 1; }
        .score-footer { font-size: 11px; opacity: 0.4; margin-top: 15px; letter-spacing: 1px; }
 
        .logout-btn { margin: 20px 30px; padding: 15px; background: rgba(239, 68, 68, 0.05); border: 1px solid rgba(239, 68, 68, 0.2); border-radius: 12px; color: #fca5a5; text-align: center; text-decoration: none; font-weight: 700; transition: all 0.3s ease; font-size: 12px; letter-spacing: 1px; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .logout-btn:hover { background: #ef4444; color: white; border-color: #ef4444; box-shadow: 0 0 20px rgba(239,68,68,0.4); }
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
                    <div class="nav-item"><a href="DashboardUsuario.aspx" class="nav-link active"><i class="fas fa-home"></i> Inicio</a></div>
                    <div class="nav-item"><a href="MiPerfil.aspx" class="nav-link"><i class="fas fa-user-circle"></i> Mi Perfil</a></div>
                    <div class="nav-item"><a href="VerProductos.aspx" class="nav-link"><i class="fas fa-box-open"></i> Productos</a></div>
                    <div class="nav-item"><a href="MiCarrito.aspx" class="nav-link"><i class="fas fa-heart"></i> Mi Lista</a></div>
                    <div class="nav-item"><a href="Juego.aspx" class="nav-link"><i class="fas fa-gamepad"></i> Misiones</a></div>
                    <div class="nav-item"><a href="Rombito.aspx" class="nav-link"><i class="fas fa-shapes"></i> Rombito</a></div>
                </nav>
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="logout-btn" OnClick="btnLogout_Click">
                    <i class="fas fa-power-off"></i> CERRAR SESI&Oacute;N
                </asp:LinkButton>
            </aside>

            <!-- MAIN CONTENT -->
            <main class="main-content">
                <div class="profile-card">
                    <div class="avatar-container">
                        <img src="../../Seguridad/ImageHandler.ashx" alt="Perfil" />
                        <div class="status-dot"></div>
                    </div>

                    <div class="profile-info">
                        <h1 id="lblNombre" runat="server">Agente Usuario</h1>
                        <p id="lblRol" runat="server">AGENTE OPERATIVO</p>

                        <div class="info-boxes">
                            <div class="info-box">
                                <span>Canal de Comunicaci&oacute;n</span>
                                <asp:Label ID="lblMail" runat="server" CssClass="val-style">---</asp:Label>
                            </div>
                            <div class="info-box">
                                <span>Identificador de Agente</span>
                                <asp:Label ID="lblCedula" runat="server" CssClass="val-style">---</asp:Label>
                            </div>
                        </div>
                    </div>

                    <div class="score-container">
                        <span class="score-label">CR&Eacute;DITOS TOTALES</span>
                        <asp:Label ID="lblPuntos" runat="server" CssClass="score-value">0</asp:Label>
                        <p class="score-footer">OPERACIONES EXITOSAS EN EL CAMPO</p>
                    </div>
                </div>
            </main>
        </div>
    </form>
    <script>
        function initSkulls() {
            const rain = document.getElementById('skullRain');
            if (!rain) return;
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