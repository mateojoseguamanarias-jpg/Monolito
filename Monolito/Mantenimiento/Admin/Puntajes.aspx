<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Puntajes.aspx.cs" Inherits="Monolito.Dashboard.Puntajes" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX | Ranking de Agentes</title>
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
        
        .header-section { text-align: center; margin-bottom: 50px; }
        .header-section h1 { 
            font-family: 'Orbitron'; 
            font-size: 36px; 
            letter-spacing: 5px; 
            text-transform: uppercase;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 10px rgba(0,242,255,0.3));
        }

        .table-card { 
            background: var(--glass); backdrop-filter: blur(25px); border: 1px solid var(--glass-border); 
            border-radius: 30px; padding: 30px; overflow: hidden;
            box-shadow: var(--neon-shadow);
        }

        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { 
            font-family: 'Orbitron'; font-size: 12px; letter-spacing: 2px; color: var(--accent); 
            padding: 20px; border-bottom: 2px solid var(--glass-border); text-transform: uppercase;
        }
        td { padding: 15px 20px; border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: rgba(0, 242, 255, 0.05) !important; }

        .user-photo { width: 45px; height: 45px; border-radius: 50%; border: 2px solid var(--accent); object-fit: cover; box-shadow: 0 0 15px rgba(0, 242, 255, 0.4); }
        .badge-id { background: rgba(0, 242, 255, 0.1); color: var(--accent); padding: 5px 12px; border-radius: 50px; font-family: 'Orbitron'; font-size: 11px; }
        .score-val { font-family: 'Orbitron'; font-size: 18px; font-weight: 900; color: #fbbf24; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }

        .btn-back { 
            display: inline-block; margin-top: 40px; color: rgba(0, 242, 255, 0.6); text-decoration: none; 
            font-size: 13px; font-family: 'Orbitron'; letter-spacing: 2px; transition: 0.3s;
        }
        .btn-back:hover { color: white; transform: translateX(-5px); text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="container">
            <div class="header-section">
                <h1>RANKING DE <span id="titleSpan">OPERACIONES</span></h1>
                <p style="opacity:0.5; font-size:12px; letter-spacing:2px; margin-top:10px;">LISTADO MAESTRO DE AGENTES Y CR&Eacute;DITOS</p>
            </div>

            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>IDENTIDAD</th>
                            <th>NOMBRE COMPLETO</th>
                            <th>NICKNAME</th>
                            <th style="text-align:right;">PUNTUACI&Oacute;N</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptRanking" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class="badge-id">#<%# Eval("usu_id") %></span></td>
                                    <td>
                                        <img src='../../Seguridad/ImageHandler.ashx?id=<%# Eval("usu_id") %>&t=<%# DateTime.Now.Ticks %>' class="user-photo" />
                                    </td>
                                    <td style="font-weight:600;"><%# Eval("usu_nombre") %></td>
                                    <td style="color:var(--primary);">@<%# Eval("usu_nick") %></td>
                                    <td style="text-align:right;"><span class="score-val"><%# Eval("usu_puntos") %></span> <small style="font-size:10px; opacity:0.5;">PTS</small></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <div style="text-align:center;">
                <a href="DashboardAdmin.aspx" class="btn-back">
                    <i class="fas fa-arrow-left"></i> VOLVER AL CENTRO DE MANDO
                </a>
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
