<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegistrarAgente.aspx.cs" Inherits="Monolito.Dashboard.RegistrarAgente" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX | Nuevo Agente</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        *{ margin:0; padding:0; box-sizing:border-box; }
        :root {
            --bg-dark: #05050b; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.75); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
        }
        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Outfit', sans-serif;
            background: var(--bg-dark) url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed;
            background-size: cover;
            padding: 30px 20px;
            overflow-x: hidden;
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
            position: relative;
            width: 100%;
            max-width: 800px;
            padding: 2.5rem;
            border-radius: 24px;
            background: var(--glass);
            border: 1px solid var(--glass-border);
            backdrop-filter: blur(20px);
            z-index: 10;
            color: white;
            box-shadow: var(--neon-shadow);
        }
        .header-title { 
            font-family: 'Orbitron'; 
            font-size: 24px; 
            font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 25px; 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .full { grid-column: span 2; }
        .label {
            display: block;
            font-family: 'Orbitron', monospace;
            font-size: 10px;
            letter-spacing: 2px;
            color: var(--accent);
            margin-bottom: 8px;
            text-transform: uppercase;
            text-shadow: 0 0 5px rgba(0, 242, 255, 0.3);
        }
        .input-style {
            width: 100%; padding: 14px 18px; border-radius: 12px;
            border: 1px solid rgba(0, 242, 255, 0.2);
            background: rgba(0,0,0,0.4);
            color: #fff; font-size: 0.95rem; font-family: 'Outfit', sans-serif;
            outline: none; transition: 0.3s;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .input-style:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        
        select.input-style option {
            background: #05050b;
            color: white;
            font-weight: bold;
        }
        
        .foto-zone {
            border: 2px dashed var(--glass-border);
            border-radius: 16px; padding: 20px;
            text-align: center; cursor: pointer;
            transition: 0.3s; background: rgba(0, 242, 255, 0.02);
        }
        .foto-zone:hover { border-color: var(--accent); background: rgba(0, 242, 255, 0.05); }
        .preview-area { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 15px; justify-content: center; }
        .img-preview { 
            width: 80px; height: 80px; border-radius: 12px; border: 2px solid var(--accent); 
            overflow: hidden; position: relative; box-shadow: 0 0 15px rgba(0, 242, 255, 0.4);
        }
        .img-preview img { width: 100%; height: 100%; object-fit: cover; }
        .remove-img {
            position: absolute; top: 2px; right: 2px; background: rgba(239, 68, 68, 0.8);
            border: none; color: white; border-radius: 50%; width: 18px; height: 18px;
            font-size: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center;
            z-index: 5;
        }

        .btn-main {
            width: 100%; padding: 18px; border: none; border-radius: 16px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: #fff; font-family: 'Orbitron', monospace;
            font-size: 0.9rem; font-weight: 900; letter-spacing: 3px;
            cursor: pointer; margin-top: 25px; transition: 0.3s;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-main:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); filter: brightness(1.1); }
        
        .btn-back {
            display: block; text-decoration: none; color: rgba(0, 242, 255, 0.6);
            font-family: 'Orbitron'; font-size: 11px; letter-spacing: 1px; margin-top: 20px; transition: 0.3s;
            text-align: center;
        }
        .btn-back:hover { color: white; text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="card">
        <h2 class="header-title"><i class="fas fa-user-plus"></i> REGISTRO DE AGENTE</h2>

        <div class="grid">
            <div class="input-group">
                <span class="label">Rol de Acceso</span>
                <asp:DropDownList ID="ddlRol" runat="server" CssClass="input-style">
                    <asp:ListItem Text="USUARIO (DEFINIDO)" Value="2" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="ADMINISTRADOR" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="input-group">
                <span class="label">C&eacute;dula</span>
                <asp:TextBox ID="txtCedula" runat="server" CssClass="input-style" placeholder="10 d&iacute;gitos"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Nickname</span>
                <asp:TextBox ID="txtNick" runat="server" CssClass="input-style" placeholder="ghost_agent"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Nombres</span>
                <asp:TextBox ID="txtNombre" runat="server" CssClass="input-style" placeholder="Nombres"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Apellidos</span>
                <asp:TextBox ID="txtApellido" runat="server" CssClass="input-style" placeholder="Apellidos"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Correo</span>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="input-style" placeholder="email@novax.com"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Contrase&ntilde;a Provisional</span>
                <div style="position:relative;">
                    <asp:TextBox ID="txtPass" runat="server" CssClass="input-style" TextMode="Password" placeholder="M&iacute;nimo 8 caracteres" style="padding-right:45px;"></asp:TextBox>
                    <button type="button" onclick="verPass('pass',this)" style="position:absolute; right:15px; top:50%; transform:translateY(-50%); background:none; border:none; color:rgba(127,119,221,0.6); cursor:pointer;"><i class="fas fa-eye"></i></button>
                </div>
            </div>

            <div class="input-group">
                <span class="label">Confirmar Contrase&ntilde;a</span>
                <div style="position:relative;">
                    <asp:TextBox ID="txtConf" runat="server" CssClass="input-style" TextMode="Password" placeholder="Repite la clave" style="padding-right:45px;"></asp:TextBox>
                    <button type="button" onclick="verPass('conf',this)" style="position:absolute; right:15px; top:50%; transform:translateY(-50%); background:none; border:none; color:rgba(127,119,221,0.6); cursor:pointer;"><i class="fas fa-eye"></i></button>
                </div>
            </div>

            <div class="input-group full">
                <span class="label">Fotos de Perfil (M&iacute;ltiples)</span>
                <div class="foto-zone" onclick="document.getElementById('<%= fuFoto.ClientID %>').click()">
                    <i class="fas fa-cloud-upload-alt" style="font-size: 24px; color: var(--accent); margin-bottom: 10px; text-shadow: 0 0 8px rgba(0, 242, 255, 0.5);"></i>
                    <p style="font-size: 12px; color: rgba(255,255,255,0.5);">Haz clic para seleccionar fotos</p>
                    <asp:FileUpload ID="fuFoto" runat="server" AllowMultiple="true" style="display:none;" onchange="previewImages(this)" />
                </div>
                <div id="previewContainer" class="preview-area"></div>
            </div>
        </div>

        <asp:Button ID="btnRegistrar" runat="server" Text="CREAR AGENTE" CssClass="btn-main" OnClientClick="return validarLocal()" OnClick="btnRegistrar_Click" />
        <a href="GestionarUsuarios.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> VOLVER A GESTI&Oacute;N</a>
    </div>
</form>

<script>
    function verPass(cual, btn) {
        const inp = document.getElementById(cual === 'pass' ? '<%= txtPass.ClientID %>' : '<%= txtConf.ClientID %>');
        const icon = btn.querySelector('i');
        if (inp.type === 'password') {
            inp.type = 'text';
            icon.className = 'fas fa-eye-slash';
        } else {
            inp.type = 'password';
            icon.className = 'fas fa-eye';
        }
    }

    function previewImages(input) {
        const container = document.getElementById('previewContainer');
        container.innerHTML = '';
        if (input.files) {
            Array.from(input.files).forEach((file, index) => {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const div = document.createElement('div');
                    div.className = 'img-preview';
                    div.innerHTML = `
                        <img src="${e.target.result}" />
                        <button type="button" class="remove-img" onclick="removeFile(${index})"><i class="fas fa-times"></i></button>
                    `;
                    container.appendChild(div);
                }
                reader.readAsDataURL(file);
            });
        }
    }

    function removeFile(index) {
        const input = document.getElementById('<%= fuFoto.ClientID %>');
        const dt = new DataTransfer();
        const { files } = input;
        
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            if (index !== i) dt.items.add(file);
        }
        
        input.files = dt.files; // Asignamos la nueva lista filtrada
        previewImages(input);   // Refrescamos la vista previa
    }

    function clearPhoto() {
        const input = document.getElementById('<%= fuFoto.ClientID %>');
        const container = document.getElementById('previewContainer');
        input.value = '';
        container.innerHTML = '';
    }

    function validarLocal() {
        const p = document.getElementById('<%= txtPass.ClientID %>').value;
        const c = document.getElementById('<%= txtConf.ClientID %>').value;
        if (p !== c) {
            Swal.fire('Error','Las contraseñas no coinciden','error');
            return false;
        }
        return true;
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
