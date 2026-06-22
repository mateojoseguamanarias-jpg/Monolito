<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionarUsuarios.aspx.cs" Inherits="Monolito.Dashboard.GestionarUsuarios" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Gesti&oacute;n de Usuarios</title>
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
        .glass-card { 
            background: var(--glass); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); 
            border-radius: 24px; padding: 40px; box-shadow: var(--neon-shadow);
        }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 24px; 
            letter-spacing: 2px; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        
        .pro-table { width: 100%; border-collapse: collapse; }
        .pro-table th { 
            text-align: left; 
            padding: 15px; 
            color: var(--accent); 
            font-size: 12px; 
            text-transform: uppercase; 
            border-bottom: 2px solid var(--glass-border);
            font-family: 'Orbitron';
        }
        .pro-table td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 14px; }
        .pro-table tr:hover td { background: rgba(0, 242, 255, 0.05) !important; }
        
        .status-badge { padding: 5px 12px; border-radius: 8px; font-size: 10px; font-weight: 800; border: 1px solid transparent; font-family: 'Orbitron'; }
        .status-A { background: rgba(34, 197, 94, 0.1); color: #4ade80; border-color: #4ade80; }
        .status-B { background: rgba(239, 68, 68, 0.1); color: #f87171; border-color: #f87171; }

        .btn-action { background: none; border: none; color: white; cursor: pointer; font-size: 18px; transition: 0.3s; }
        .btn-action:hover { transform: scale(1.2); color: var(--accent); }
        
        .btn-back { 
            text-decoration: none; color: rgba(0, 242, 255, 0.6); font-size: 14px; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; 
            transition: 0.3s; font-family: 'Orbitron';
        }
        .btn-back:hover { color: white; text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="container">
            <a href="DashboardAdmin.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD</a>
            
            <div class="glass-card">
                <div class="header">
                    <h1>GESTI&Oacute;N DE USUARIOS</h1>
                    <div style="display:flex; align-items:center; gap:20px;">
                        <a href="RegistrarAgente.aspx" style="background: linear-gradient(135deg, #00f2ff, #7f00ff); color:white; padding:10px 20px; border-radius:12px; text-decoration:none; font-family:'Orbitron'; font-size:12px; font-weight:700; box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4); transition: 0.3s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 25px rgba(0, 242, 255, 0.5)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 4px 15px rgba(127, 0, 255, 0.4)';">
                            <i class="fas fa-user-plus"></i> NUEVO USUARIO
                        </a>
                        <div class="stats">
                            <asp:Label ID="lblTotal" runat="server" style="color:var(--accent); font-weight:800;">0</asp:Label> Usuarios Registrados
                        </div>
                    </div>
                </div>

                <table class="pro-table" id="tablaUsuarios">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Foto</th>
                            <th>Usuario</th>
                            <th>Nickname</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptUsuarios" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td style="color:var(--accent); font-weight:700;">#<%# Eval("usu_id") %></td>
                                    <td>
                                        <img src='<%# Eval("tiene_foto") != DBNull.Value ? "../../Seguridad/ImageHandler.ashx?id=" + Eval("usu_id") : "https://ui-avatars.com/api/?name=" + Eval("usu_nombre") + "&background=random" %>' 
                                             style="width:40px; height:40px; border-radius:10px; object-fit:cover; border:1px solid var(--glass-border);" />
                                    </td>
                                    <td>
                                        <strong><%# Eval("usu_nombre") %></strong><br />
                                        <small style="opacity:0.6"><%# Eval("usu_correo") %></small>
                                    </td>
                                    <td><span style="color:var(--primary)">@<%# Eval("usu_nick") %></span></td>
                                    <td><%# Eval("tusu_nombre") %></td>
                                    <td>
                                        <span class="status-badge status-<%# Eval("usu_estado") %>">
                                            <%# Eval("usu_estado").ToString() == "A" ? "ACTIVO" : "BLOQUEADO" %>
                                        </span>
                                    </td>
                                    <td>
                                        <asp:LinkButton runat="server" CssClass="btn-action" OnCommand="Accion_Command" CommandName="Toggle" CommandArgument='<%# Eval("usu_id") + "|" + Eval("usu_estado") %>'>
                                            <i class="fas <%# Eval("usu_estado").ToString() == "A" ? "fa-user-slash" : "fa-user-check" %>" 
                                               style="color: <%# Eval("usu_estado").ToString() == "A" ? "#f87171" : "#4ade80" %>"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
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
