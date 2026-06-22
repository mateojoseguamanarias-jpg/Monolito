<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Recuperar.aspx.cs" Inherits="Monolito.Seguridad.Recuperar" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX PRO | Recuperación</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
            background-size: cover; color: #fff; font-family: 'Outfit', sans-serif;
            display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0;
            overflow: hidden;
        }
        body::before { 
            content: ''; 
            position: fixed; 
            inset: 0; 
            background: radial-gradient(circle at center, rgba(13, 10, 36, 0.85) 0%, rgba(5, 5, 11, 0.96) 100%); 
            z-index: 0; 
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
        .card {
            background: var(--glass); border: 1px solid var(--glass-border);
            padding: 40px; border-radius: 20px; width: 400px; backdrop-filter: blur(25px);
            text-align: center; position: relative; z-index: 2;
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
        }
        .card::before {
            content: ''; position: absolute; top: 0; left: 15%; right: 15%; height: 1px;
            background: linear-gradient(90deg, transparent, var(--accent), transparent);
        }
        .logo { 
            font-family: 'Orbitron', sans-serif; font-size: 24px; margin-bottom: 30px; letter-spacing: 3px; font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        .logo span { color: var(--accent); }
        .input-style {
            width: 100%; padding: 12px; border-radius: 10px;
            border: 1px solid rgba(0, 242, 255, 0.2); background: rgba(0, 0, 0, 0.4);
            color: white; font-size: 0.9rem; font-family: 'Outfit', sans-serif; outline: none;
            transition: all 0.3s ease; margin-bottom: 20px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .input-style:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        .btn-send {
            width: 100%; padding: 12px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            border: none; color: white; font-family: 'Orbitron', monospace;
            font-weight: 700; border-radius: 10px; cursor: pointer; 
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-send:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); 
            filter: brightness(1.1);
        }
        .back-link { display: inline-flex; align-items: center; gap: 8px; margin-top: 20px; color: var(--accent); text-decoration: none; font-size: 14px; transition: all 0.3s ease; }
        .back-link:hover { text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); transform: translateX(-3px); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="card">
            <div class="logo">Nova<span>X</span> REC</div>
            <h2 style="margin-bottom: 10px;">Recuperar Acceso</h2>
            <p style="color: #94a3b8; font-size: 14px; margin-bottom: 30px;">Ingresa tu correo para recibir una clave temporal.</p>
            
            <asp:TextBox ID="txtEmail" runat="server" CssClass="input-style" placeholder="Correo electr&oacute;nico" TextMode="Email"></asp:TextBox>
            
            <asp:Button ID="btnRecuperar" runat="server" Text="ENVIAR CLAVE TEMPORAL" CssClass="btn-send" OnClick="btnRecuperar_Click" />
            
            <a href="Loguin.aspx" class="back-link"><i class="fas fa-arrow-left"></i> Volver al Login</a>
        </div>
    </form>
    <script>
        function initSkulls() {
            const rain = document.getElementById('skullRain');
            if (!rain) return;
            for (let i = 0; i < 15; i++) {
                const skull = document.createElement('i');
                skull.className = 'fas fa-skull falling-skull';
                skull.style.left = Math.random() * 100 + 'vw';
                skull.style.animationDuration = (Math.random() * 5 + 5) + 's';
                skull.style.animationDelay = (Math.random() * 5) + 's';
                skull.style.fontSize = (Math.random() * 20 + 10) + 'px';
                rain.appendChild(skull);
            }
        }
        initSkulls();
    </script>
</body>
</html>
