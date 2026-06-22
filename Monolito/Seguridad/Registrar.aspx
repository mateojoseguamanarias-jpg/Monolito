<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registrar.aspx.cs" Inherits="Monolito.Seguridad.Registrar" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX PRO | Registro</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        *{ margin:0; padding:0; box-sizing:border-box; }
        :root {
            --purple: #9d4edd;
            --purple-dark: #5a189a;
            --accent: #00f2ff;
            --glass: rgba(8, 8, 20, 0.75);
            --glass-border: rgba(0, 242, 255, 0.25);
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
            --input-bg: rgba(0, 0, 0, 0.4);
        }
        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            font-family: 'Outfit', sans-serif;
            background: #05050b url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed;
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
            backdrop-filter: blur(25px);
            z-index: 10;
            color: white;
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
        }
        .logo {
            text-align: center;
            font-family: 'Orbitron', monospace;
            font-size: 2rem;
            font-weight: 900;
            letter-spacing: 8px;
            margin-bottom: 0.5rem;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        .logo span { color: var(--accent); }
        .sub-logo {
            text-align: center;
            font-family: 'Orbitron', monospace;
            font-size: 0.7rem;
            letter-spacing: 4px;
            color: rgba(0, 242, 255, 0.6);
            margin-bottom: 2.5rem;
            text-transform: uppercase;
            text-shadow: 0 0 5px rgba(0, 242, 255, 0.3);
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
            text-shadow: 0 0 5px rgba(0, 242, 255, 0.4);
        }
        .input-style {
            width: 100%;
            padding: 14px 18px;
            border-radius: 12px;
            border: 1px solid rgba(0, 242, 255, 0.2);
            background: var(--input-bg);
            color: #fff;
            font-size: 0.95rem;
            font-family: 'Outfit', sans-serif;
            outline: none;
            transition: all 0.3s ease;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .input-style:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        
        .pass-wrap { position: relative; }
        .toggle-pass {
            position: absolute; right: 15px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none;
            color: rgba(0, 242, 255, 0.6);
            cursor: pointer; font-size: 18px; padding: 0;
        }
        
        .strength-row { display: flex; gap: 4px; margin-top: 8px; }
        .strength-seg {
            flex: 1; height: 4px; border-radius: 2px;
            background: rgba(255,255,255,0.05);
            transition: 0.4s;
        }
        .req-list { font-size: 0.75rem; color: rgba(255,255,255,0.3); margin-top: 10px; display: grid; grid-template-columns: 1fr 1fr; }
        .req-ok { color: #4ade80 !important; }
        .req-no { color: rgba(255,255,255,0.2); }
        
        .foto-zone {
            border: 2px dashed rgba(0, 242, 255, 0.3);
            border-radius: 16px; padding: 30px;
            text-align: center; cursor: pointer;
            transition: all 0.3s ease; background: rgba(0, 242, 255, 0.02);
        }
        .foto-zone:hover { border-color: var(--accent); background: rgba(0, 242, 255, 0.05); box-shadow: 0 0 10px rgba(0, 242, 255, 0.1); }
        
        .preview-area { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 15px; justify-content: center; }
        .img-preview {
            width: 80px; height: 80px; border-radius: 12px;
            border: 2px solid var(--accent); overflow: hidden;
            position: relative; box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .img-preview img { width: 100%; height: 100%; object-fit: cover; }

        .btn-main {
            width: 100%; padding: 18px; border: none; border-radius: 16px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: #fff; font-family: 'Orbitron', monospace;
            font-size: 0.9rem; font-weight: 900; letter-spacing: 3px;
            cursor: pointer; margin-top: 25px; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-main:hover { 
            transform: translateY(-3px); 
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5);
            filter: brightness(1.1);
        }
        
        .btn-back {
            width: 100%; padding: 15px; border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 16px; background: transparent;
            color: rgba(0, 242, 255, 0.6); font-family: 'Orbitron', monospace;
            font-size: 0.8rem; letter-spacing: 2px; cursor: pointer; margin-top: 15px;
            transition: all 0.3s ease;
        }
        .btn-back:hover { color: white; background: rgba(0, 242, 255, 0.1); border-color: var(--accent); box-shadow: 0 0 10px rgba(0, 242, 255, 0.2); }

        select.input-style option { background: #05050b; color: white; }
    </style>
</head>
<body>
<form id="form1" runat="server" autocomplete="off">
    <div id="skullRain" class="skull-rain"></div>
    <asp:ScriptManager ID="sm1" runat="server" />

    <div class="card">
        <h2 class="logo">Nova<span>X</span></h2>
        <p class="sub-logo">Registro de Nuevo Acceso</p>

        <div class="grid">
            <div class="input-group">
                <span class="label">ID Sistema</span>
                <asp:TextBox ID="regId" runat="server" CssClass="input-style" ReadOnly="true" style="opacity:0.6;" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group" style="display:none;">
                <span class="label">Tipo de Cuenta</span>
                <asp:DropDownList ID="ddlTipoUsuario" runat="server" CssClass="input-style"></asp:DropDownList>
            </div>

            <div class="input-group">
                <span class="label">C&eacute;dula</span>
                <asp:TextBox ID="regCedula" runat="server" CssClass="input-style" placeholder="10 d&iacute;gitos" MaxLength="10" onkeypress="return soloNumeros(event)" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Nickname</span>
                <asp:TextBox ID="regNick" runat="server" CssClass="input-style" placeholder="Ghost_Agent" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Nombres</span>
                <asp:TextBox ID="regNom" runat="server" CssClass="input-style" placeholder="Ej: Mateo Jose" onkeypress="return soloLetras(event)" onblur="sugerirNick()" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Apellidos</span>
                <asp:TextBox ID="regApe" runat="server" CssClass="input-style" placeholder="Ej: Perez Sosa" onkeypress="return soloLetras(event)" onblur="sugerirNick()" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Celular</span>
                <asp:TextBox ID="regCelular" runat="server" CssClass="input-style" placeholder="09XXXXXXXX" MaxLength="10" onkeypress="return soloNumeros(event)" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Fecha Nacimiento</span>
                <asp:TextBox ID="regFecha" runat="server" CssClass="input-style" TextMode="Date" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group full">
                <span class="label">Direcci&oacute;n</span>
                <asp:TextBox ID="regDireccion" runat="server" CssClass="input-style" placeholder="Direcci&oacute;n completa (M&aacute;x 100)" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group full">
                <span class="label">Correo Electr&oacute;nico</span>
                <asp:TextBox ID="regEmail" runat="server" CssClass="input-style" TextMode="Email" placeholder="agente@novax.com" autocomplete="off"></asp:TextBox>
            </div>

            <div class="input-group">
                <span class="label">Contrase&ntilde;a</span>
                <div class="pass-wrap">
                    <asp:TextBox ID="regPass" runat="server" CssClass="input-style" TextMode="Password" placeholder="M&iacute;nimo 8 caracteres" style="padding-right:45px;" onfocus="sugerirPass()" autocomplete="new-password"></asp:TextBox>
                    <button type="button" class="toggle-pass" onclick="verPass('pass',this)"><i class="fas fa-eye"></i></button>
                </div>
                <div class="strength-row">
                    <div class="strength-seg" id="seg1"></div>
                    <div class="strength-seg" id="seg2"></div>
                    <div class="strength-seg" id="seg3"></div>
                    <div class="strength-seg" id="seg4"></div>
                </div>
                <div class="req-list">
                    <span id="r1" class="req-no"><i class="fas fa-circle-dot"></i> 8+ Caracteres</span>
                    <span id="r2" class="req-no"><i class="fas fa-circle-dot"></i> May&uacute;scula</span>
                    <span id="r3" class="req-no"><i class="fas fa-circle-dot"></i> N&uacute;mero</span>
                    <span id="r4" class="req-no"><i class="fas fa-circle-dot"></i> S&iacute;mbolo</span>
                </div>
            </div>

            <div class="input-group">
                <span class="label">Confirmar Contrase&ntilde;a</span>
                <div class="pass-wrap">
                    <asp:TextBox ID="regConf" runat="server" CssClass="input-style" TextMode="Password" placeholder="Repite la contrase&ntilde;a" style="padding-right:45px;" autocomplete="new-password"></asp:TextBox>
                    <button type="button" class="toggle-pass" onclick="verPass('conf',this)"><i class="fas fa-eye"></i></button>
                </div>
            </div>

            <div class="input-group full">
                <span class="label">Fotos de Perfil (M&iacute;n. 1)</span>
                <div class="foto-zone" onclick="document.getElementById('<%= fuFotos.ClientID %>').click()">
                    <i class="fas fa-cloud-upload-alt" style="font-size:2rem; color:var(--purple); margin-bottom:10px;"></i>
                    <p style="font-family:'Orbitron'; font-size:12px;">CLIC PARA SELECCIONAR FOTOS</p>
                </div>
                <asp:FileUpload ID="fuFotos" runat="server" AllowMultiple="true" accept="image/*" style="display:none;" onchange="previewImages(this)" />
                <div id="previewContainer" class="preview-area"></div>
            </div>
        </div>

        <asp:Button ID="btnCrear" runat="server" Text="CREAR CUENTA" CssClass="btn-main"
            OnClientClick="return validarFormulario();" OnClick="btnCrear_Click" />

        <asp:Button ID="btnVolverLogin" runat="server" Text="&larr; VOLVER AL LOGIN" CssClass="btn-back"
            OnClick="btnVolverLogin_Click" CausesValidation="false" />
    </div>
</form>

<script>
// @ts-nocheck
/* eslint-disable */
(function() {
    var _w = window;
    var Swal = _w.Swal;

    function soloNumeros(e) {
        var key = e.keyCode || e.which;
        var tecla = String.fromCharCode(key);
        if (!/[0-9]/.test(tecla)) return false;
    }

    function soloLetras(e) {
        var key = e.keyCode || e.which;
        var tecla = String.fromCharCode(key);
        if (!/[a-zA-Z\s]/.test(tecla)) return false;
    }

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

    window.previewImages = function(input) {
        debugger; // PUNTO DE QUIEBRE: Selección de imágenes
        const container = document.getElementById('previewContainer');
        if (!container || !input.files) return;
        container.innerHTML = '';
        Array.from(input.files).forEach((file, index) => {
            const reader = new FileReader();
            reader.onload = function(e) {
                if (!e.target) return;
                const div = document.createElement('div');
                div.className = 'img-preview';
                div.style.position = 'relative';
                div.innerHTML = `
                    <img src="${e.target.result}" />
                    <button type="button" onclick="removeImage(${index})" 
                        style="position:absolute; top:-5px; right:-5px; background:#ff4444; color:white; width:20px; height:20px; border-radius:50%; border:none; cursor:pointer; font-size:10px; display:flex; align-items:center; justify-content:center; box-shadow:0 0 5px rgba(0,0,0,0.5);">
                        <i class="fas fa-times"></i>
                    </button>`;
                container.appendChild(div);
            }
            reader.readAsDataURL(file);
        });
    }

    window.removeImage = function(index) {
        debugger; // PUNTO DE QUIEBRE: Eliminación de imagen de la lista
        const input = document.getElementById('<%= fuFotos.ClientID %>');
        if (!input) return;
        const dt = new DataTransfer();
        const files = input['files'];
        if (!files) return;
        
        for (let i = 0; i < files['length']; i++) {
            if (i !== index) dt['items']['add'](files[i]);
        }
        
        input['files'] = dt['files'];
        previewImages(input);
    }

    window.sugerirNick = function() {
        const input = document.getElementById('<%= regNick.ClientID %>');
        const elNom = document.getElementById('<%= regNom.ClientID %>');
        const elApe = document.getElementById('<%= regApe.ClientID %>');
        if (!input || !elNom || !elApe || input.value.trim() !== "") return;

        const nom = elNom.value.trim().split(' ')[0];
        const ape = elApe.value.trim().split(' ')[0];
        if (nom && ape) {
            const nick = nom.substring(0,3).toLowerCase() + ape.toLowerCase() + Math.floor(Math.random()*99);
            input.value = nick;
        }
    }

    window.sugerirPass = function() {
        const input = document.getElementById('<%= regPass.ClientID %>');
        const conf = document.getElementById('<%= regConf.ClientID %>');
        if (!input || !conf || input.value.trim() !== "") return;
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        let pass = "";
        for (let i = 0; i < 12; i++) pass += chars.charAt(Math.floor(Math.random() * chars.length));
        input.value = pass;
        conf.value = pass;
        verificarPass(pass);
    }

    window.verPass = function(cual, btn) {
        const inp = document.getElementById(cual === 'pass' ? '<%= regPass.ClientID %>' : '<%= regConf.ClientID %>');
        if (!inp || !btn) return;
        const icon = btn.querySelector('i');
        if (!icon) return;
        if (inp.type === 'password') {
            inp.type = 'text';
            icon.className = 'fas fa-eye-slash';
        } else {
            inp.type = 'password';
            icon.className = 'fas fa-eye';
        }
    }

    function verificarPass(val) {
        const r = [val.length >= 8, /[A-Z]/.test(val), /[0-9]/.test(val), /[\W_]/.test(val)];
        const colors = ['#ff4444', '#ffbb33', '#00C851', '#7F77DD'];
        const score = r.filter(Boolean).length;
        for (let i = 1; i <= 4; i++) {
            const seg = document.getElementById('seg' + i);
            if (seg) seg.style.background = (i <= score) ? colors[score-1] : 'rgba(255,255,255,0.05)';
        }
        ['r1','r2','r3','r4'].forEach((id, i) => {
            const req = document.getElementById(id);
            if (req) req.className = r[i] ? 'req-ok' : 'req-no';
        });
    }

    const elPassInput = document.getElementById('<%= regPass.ClientID %>');
    if (elPassInput) {
        elPassInput.addEventListener('input', function() { verificarPass(this.value); });
    }

    function validarFormulario() {
        const elCed = document.getElementById('<%= regCedula.ClientID %>');
        const elNom = document.getElementById('<%= regNom.ClientID %>');
        const elApe = document.getElementById('<%= regApe.ClientID %>');
        const elDir = document.getElementById('<%= regDireccion.ClientID %>');
        const elCel = document.getElementById('<%= regCelular.ClientID %>');
        const elMail = document.getElementById('<%= regEmail.ClientID %>');
        const elPass = document.getElementById('<%= regPass.ClientID %>');
        const elConf = document.getElementById('<%= regConf.ClientID %>');

        if (!elCed || !elNom || !elApe || !elDir || !elCel || !elMail || !elPass || !elConf) return false;

        const cedula = elCed.value.trim();
        const nom = elNom.value.trim();
        const ape = elApe.value.trim();
        const dir = elDir.value.trim();
        const cel = elCel.value.trim();
        const email = elMail.value.trim();
        const pass = elPass.value.trim();
        const conf = elConf.value.trim();

        if (!cedula || !nom || !ape || !dir || !cel || !email || !pass) {
            Swal.fire({ title: 'Campos Vac\u00EDos', text: 'Todos los campos son obligatorios.', icon: 'warning' });
            return false;
        }
        if (cedula.length !== 10 || !/^\d+$/.test(cedula)) {
            Swal.fire({ title: 'C\u00E9dula Inv\u00E1lida', text: 'Debe tener exactamente 10 d\u00EDgitos num\u00E9ricos.', icon: 'error' });
            return false;
        }
        if (/(\d)\1{6,}/.test(cedula)) {
            Swal.fire({ title: 'C\u00E9dula Inv\u00E1lida', text: 'La c\u00E9dula no puede contener el mismo n\u00FAmero 7 veces seguidas.', icon: 'error' });
            return false;
        }
        if (nom.split(' ').filter(x => x.length > 0).length < 2) {
            Swal.fire({ title: 'Nombres Incompletos', text: 'Ingresa tus 2 nombres. Si solo tienes uno, rep\u00EDtelo (ej: Mateo Mateo).', icon: 'info' });
            return false;
        }
        if (ape.split(' ').filter(x => x.length > 0).length < 2) {
            Swal.fire({ title: 'Apellidos Incompletos', text: 'Ingresa tus 2 apellidos. Si solo tienes uno, rep\u00EDtelo.', icon: 'info' });
            return false;
        }
        if (cel.length !== 10 || !/^\d+$/.test(cel)) {
            Swal.fire({ title: 'Celular Inv\u00E1lido', text: 'Debe tener 10 d\u00EDgitos num\u00E9ricos.', icon: 'error' });
            return false;
        }
        if (pass !== conf) {
            Swal.fire({ title: 'Error de Clave', text: 'Las contrase\u00F1as no coinciden.', icon: 'error' });
            return false;
        }
        return true;
    }

    // Exponer funciones globales para controladores de eventos inline
    window.soloNumeros = soloNumeros;
    window.soloLetras = soloLetras;
    window.validarFormulario = validarFormulario;
})();
</script>
</body>
</html>