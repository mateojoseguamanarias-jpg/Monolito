<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RepararBD.aspx.cs" Inherits="Monolito.Dashboard.RepararBD" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX | Reparar BD</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@700&family=Outfit:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root { 
            --bg-dark: #05050b; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.75); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
        }
        body { 
            background: var(--bg-dark) url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; font-family: 'Outfit', sans-serif; color: white; min-height: 100vh;
            padding: 40px; margin: 0; overflow-x: hidden;
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
            max-width: 1000px; 
            margin: 0 auto; 
            position: relative;
            z-index: 2;
        }

        h1 { 
            font-family: 'Orbitron'; 
            font-size: 28px; 
            font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 30px; 
            filter: drop-shadow(0 0 10px rgba(0,242,255,0.3));
        }

        .card { 
            background: var(--glass); backdrop-filter: blur(25px); border: 1px solid var(--glass-border); 
            border-radius: 24px; padding: 25px; margin-bottom: 20px;
            box-shadow: var(--neon-shadow);
        }

        .btn { 
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: white; border: none; padding: 14px 30px; border-radius: 10px; font-family: 'Orbitron'; font-weight: 700; font-size: 13px; cursor: pointer; margin-right: 10px; transition: 0.3s;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn:hover { box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); transform: translateY(-2px); filter: brightness(1.1); }
        .btn-secondary { background: rgba(255,255,255,0.05); color: white; border: 1px solid var(--glass-border); }
        .btn-secondary:hover { background: rgba(255,255,255,0.1); }

        .output { background: #000; border: 1px solid rgba(0, 242, 255, 0.2); border-radius: 10px; padding: 20px; font-size: 13px; line-height: 1.8; white-space: pre-wrap; margin-top: 20px; max-height: 500px; overflow-y: auto; box-shadow: inset 0 0 10px rgba(0,0,0,0.8); }
        .ok  { color: #4ade80; text-shadow: 0 0 5px rgba(74, 222, 128, 0.4); }
        .err { color: #f87171; text-shadow: 0 0 5px rgba(248, 113, 113, 0.4); }
        .info { color: #00f2ff; text-shadow: 0 0 5px rgba(0, 242, 255, 0.4); }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { color: var(--accent); font-size: 12px; text-transform: uppercase; border-bottom: 2px solid var(--glass-border); padding: 10px; text-align: left; font-family: 'Orbitron'; }
        td { padding: 10px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 13px; }
        tr:hover td { background: rgba(0, 242, 255, 0.05) !important; }

        .btn-back { 
            display: inline-block; margin-top: 20px; color: rgba(0, 242, 255, 0.6); text-decoration: none; 
            font-size: 13px; font-family: 'Orbitron'; letter-spacing: 2px; transition: 0.3s;
        }
        .btn-back:hover { color: white; transform: translateX(-5px); text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div id="skullRain" class="skull-rain"></div>
    <div class="container">
        <h1>🔧 Reparar Base de Datos — Carrusel NovaX</h1>

        <div class="card">
            <p style="opacity:0.7;margin-bottom:20px;">Esta p&aacute;gina crea la tabla <code>tbl_producto_fotos</code>, corrige las rutas de fotos y registra las fotos existentes en el carrusel. &Uacute;sala una sola vez.</p>
            <asp:Button ID="btnReparar" runat="server" Text="▶ EJECUTAR REPARACIÓN COMPLETA" CssClass="btn" OnClick="btnReparar_Click" />
            <asp:Button ID="btnVerEstado" runat="server" Text="🔍 VER ESTADO ACTUAL" CssClass="btn btn-secondary" OnClick="btnVerEstado_Click" />
        </div>

        <asp:Panel ID="pnlResultado" runat="server" Visible="false">
            <div class="card">
                <h3 style="color:#00f2ff;margin-bottom:15px;font-family:'Orbitron';">Resultado</h3>
                <div class="output">
                    <asp:Literal ID="litResultado" runat="server" />
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlTabla" runat="server" Visible="false">
            <div class="card">
                <h3 style="color:#00f2ff;margin-bottom:5px;font-family:'Orbitron';">Estado del Carrusel por Producto</h3>
                <asp:Literal ID="litTabla" runat="server" />
            </div>
        </asp:Panel>

        <div style="margin-top:20px; text-align: center;">
            <a href="GestionarProductos.aspx" class="btn-back">← Volver a Gestionar Productos</a>
        </div>
    </div>
</form>
<script>
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
