<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UsuariosBloqueados.aspx.cs" Inherits="Monolito.Mantenimiento.Admin.UsuariosBloqueados" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX PRO | Desbloqueo de Usuarios</title>
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
            max-width: 900px; 
            margin: 0 auto; 
            background: var(--glass); 
            padding: 40px; 
            border-radius: 24px; 
            border: 1px solid var(--glass-border);
            box-shadow: var(--neon-shadow);
            position: relative;
            z-index: 2;
        }
        
        h1 { 
            font-family: 'Orbitron'; 
            font-size: 26px; 
            letter-spacing: 2px; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 0 0 30px 0;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
            display: flex; 
            align-items: center; 
            gap: 15px;
        }

        .grid-style { width: 100%; border-collapse: collapse; margin-top: 20px; color: #e2e8f0; }
        .grid-style th { 
            text-align: left; 
            padding: 15px; 
            color: var(--accent); 
            font-size: 12px; 
            text-transform: uppercase; 
            border-bottom: 2px solid var(--glass-border);
            font-family: 'Orbitron';
        }
        .grid-style td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 14px; }
        .grid-style tr:hover td { background: rgba(0, 242, 255, 0.05) !important; }

        .btn-unlock { 
            background: linear-gradient(135deg, #10b981, #059669);
            color: #fff; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 8px; 
            cursor: pointer; 
            transition: 0.3s; 
            font-weight: 600; 
            font-family: 'Orbitron';
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
        }
        .btn-unlock:hover { 
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.5);
            transform: translateY(-1px);
        }
        
        .empty-msg { 
            text-align: center; 
            padding: 40px; 
            color: #94a3b8; 
            font-style: italic; 
            background: rgba(0,0,0,0.2); 
            border-radius: 16px;
            margin-top: 20px;
            border: 1px solid var(--glass-border);
        }

        .back-btn { 
            display: inline-block; 
            margin-bottom: 20px; 
            color: rgba(0, 242, 255, 0.6); 
            text-decoration: none; 
            transition: 0.3s; 
            font-family: 'Orbitron';
        }
        .back-btn:hover { color: #fff; text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="container">
            <a href="DashboardAdmin.aspx" class="back-btn"><i class="fas fa-chevron-left"></i> Volver al Dashboard</a>
            <h1><i class="fas fa-user-lock"></i> Gestión de Usuarios Bloqueados</h1>
            
            <asp:GridView ID="gvBloqueados" runat="server" AutoGenerateColumns="False" CssClass="grid-style" 
                OnRowCommand="gvBloqueados_RowCommand" DataKeyNames="usu_id">
                <Columns>
                    <asp:BoundField DataField="usu_id" HeaderText="ID" />
                    <asp:BoundField DataField="usu_nombre" HeaderText="Nombre" />
                    <asp:BoundField DataField="usu_nick" HeaderText="Nickname" />
                    <asp:BoundField DataField="usu_correo" HeaderText="Correo" />
                    <asp:TemplateField HeaderText="Acción">
                        <ItemTemplate>
                            <asp:Button ID="btnUnlock" runat="server" Text="DESBLOQUEAR" CssClass="btn-unlock" 
                                CommandName="Desbloquear" CommandArgument='<%# Eval("usu_id") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            
            <asp:Panel ID="pnlVacio" runat="server" Visible="false" CssClass="empty-msg">
                <i class="fas fa-check-circle fa-3x mb-3" style="color: #10b981; text-shadow: 0 0 10px rgba(16,185,129,0.4); margin-bottom: 15px;"></i>
                <p>No hay usuarios bloqueados en este momento.</p>
            </asp:Panel>
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
