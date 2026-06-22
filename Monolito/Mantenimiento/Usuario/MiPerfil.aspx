<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MiPerfil.aspx.cs" Inherits="Monolito.Dashboard.MiPerfilUsuario" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX | Mi Perfil de Agente</title>
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
            display: flex; align-items: center; justify-content: center; padding: 20px; margin:0;
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

        .profile-card { 
            position: relative; z-index: 2;
            background: var(--glass); backdrop-filter: blur(25px); border: 1px solid var(--glass-border);
            border-radius: 32px; padding: 35px; width: 100%; max-width: 900px; box-sizing: border-box;
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
        }
        .header { text-align: center; margin-bottom: 35px; }
        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 28px; 
            font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 3px; 
            text-transform: uppercase; 
            margin:0; 
            filter: drop-shadow(0 0 10px rgba(0,242,255,0.3));
        }

        .profile-layout { display: grid; grid-template-columns: 260px 1fr; gap: 35px; }
        .photo-section { text-align: center; }
        .profile-img { 
            width: 220px; height: 220px; border-radius: 24px; object-fit: cover;
            border: 2px solid var(--accent); margin-bottom: 18px; box-shadow: 0 0 30px rgba(0, 242, 255, 0.4);
            background: #111;
        }
        .fu-label { 
            display: inline-block; padding: 14px 24px; background: rgba(0, 242, 255, 0.05); 
            border: 1px solid var(--accent); border-radius: 14px; cursor: pointer; font-size: 11px;
            font-family: 'Orbitron'; letter-spacing: 1px; color: white; transition: 0.3s;
        }
        .fu-label:hover { background: var(--accent); color: #000; transform: translateY(-2px); box-shadow: 0 0 15px rgba(0, 242, 255, 0.4); }

        .fields-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .input-group { margin-bottom: 5px; }
        .input-group label { display: block; font-size: 10px; color: var(--accent); text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 8px; font-weight: 600; text-shadow: 0 0 5px rgba(0, 242, 255, 0.3); }
        .pro-input { 
            width: 100%; background: rgba(0,0,0,0.4); border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 12px; padding: 14px; color: white; outline: none; transition: 0.3s;
            box-sizing: border-box; font-family: 'Outfit'; font-size: 14px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .pro-input:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        .pro-input:disabled { opacity: 0.6; background: rgba(0,0,0,0.3); border-color: transparent; }

        .btn-save { 
            grid-column: span 2; margin-top: 20px; padding: 18px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            border: none; border-radius: 16px; color: white; font-weight: 800; font-family: 'Orbitron';
            cursor: pointer; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
            letter-spacing: 2px; font-size: 14px;
        }
        .btn-save:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); filter: brightness(1.1); }
        .btn-back { display: block; text-align: center; margin-top: 30px; color: rgba(0, 242, 255, 0.6); text-decoration: none; font-size: 12px; letter-spacing: 1px; transition: all 0.3s ease; }
        .btn-back:hover { color: white; text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
        
        @media (max-width: 850px) {
            .profile-layout { grid-template-columns: 1fr; }
            .fields-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div id="skullRain" class="skull-rain"></div>
        <div class="profile-card">
            <div class="header">
                <h1>Perfil de Agente NovaX</h1>
                <p style="opacity:0.5; font-size:11px; letter-spacing:1px; margin-top:8px;">NovaX Pro - Panel de Usuario</p>
            </div>

            <div class="profile-layout">
                <div class="photo-section">
                    <asp:Image ID="imgPerfil" runat="server" CssClass="profile-img" ImageUrl="../../Seguridad/ImageHandler.ashx" />
                    <label class="fu-label">
                        <i class="fas fa-camera"></i> CAMBIAR FOTO
                        <asp:FileUpload ID="fuFoto" runat="server" style="display:none" onchange="this.form.submit();" />
                    </label>
                </div>

                <div class="fields-grid">
                    <div class="input-group">
                        <label>C&eacute;dula</label>
                        <asp:TextBox ID="txtCedula" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group">
                        <label>Correo</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group">
                        <label>Nombres</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group">
                        <label>Apellidos</label>
                        <asp:TextBox ID="txtApellido" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group">
                        <label>Nickname</label>
                        <asp:TextBox ID="txtNick" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group">
                        <label>WhatsApp</label>
                        <asp:TextBox ID="txtCelular" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group" style="grid-column: span 2;">
                        <label>Direcci&oacute;n</label>
                        <asp:TextBox ID="txtDireccion" runat="server" CssClass="pro-input"></asp:TextBox>
                    </div>
                    <div class="input-group" style="grid-column: span 2;">
                        <label>Fecha de Nacimiento</label>
                        <asp:TextBox ID="txtFecha" runat="server" CssClass="pro-input" TextMode="Date"></asp:TextBox>
                    </div>

                    <asp:Button ID="btnGuardar" runat="server" Text="ACTUALIZAR DATOS" CssClass="btn-save" OnClick="btnGuardar_Click" />
                </div>
            </div>

            <div class="photos-gallery" style="margin-top: 40px; border-top: 1px solid var(--glass-border); padding-top: 20px;">
                <h3 style="font-family:'Orbitron'; font-size:14px; color:var(--accent); margin-bottom:15px;">GALER&Iacute;A DE IDENTIDAD (Varbinary MAX)</h3>
                <div style="display:flex; gap:15px; flex-wrap:wrap;">
                    <asp:Repeater ID="rptFotos" runat="server" OnItemCommand="rptFotos_ItemCommand">
                        <ItemTemplate>
                            <div style="position:relative; width:80px; height:80px;">
                                <img src='../../Seguridad/ImageHandler.ashx?fotoId=<%# Eval("foto_id") %>' 
                                     style="width:100%; height:100%; border-radius:10px; border:1px solid var(--primary); object-fit:cover;" />
                                <asp:LinkButton ID="btnEliminar" runat="server" 
                                    CommandName="Eliminar" CommandArgument='<%# Eval("foto_id") %>'
                                    OnClientClick="return confirm('¿Seguro que deseas eliminar esta imagen?');"
                                    style="position:absolute; top:-5px; right:-5px; background:#ff4444; color:white; width:20px; height:20px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:10px; border:none; text-decoration:none; box-shadow:0 0 5px rgba(0,0,0,0.5);">
                                    <i class="fas fa-times"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
            
            <a href="DashboardUsuario.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD</a>
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
