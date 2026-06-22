<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CambiarPass.aspx.cs" Inherits="Monolito.Seguridad.CambiarPass" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX PRO | Recuperar Acceso</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
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
            color: white;
            padding: 20px;
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
            width: 100%;
            max-width: 450px;
            padding: 3rem;
            border-radius: 24px;
            background: var(--glass);
            border: 1px solid var(--glass-border);
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
            text-align: center;
            position: relative; z-index: 2;
            backdrop-filter: blur(25px);
        }
        .card::before {
            content: ''; position: absolute; top: 0; left: 15%; right: 15%; height: 1px;
            background: linear-gradient(90deg, transparent, var(--accent), transparent);
        }
        .logo { 
            font-family: 'Orbitron', sans-serif; font-size: 2rem; margin-bottom: 0.5rem; letter-spacing: 5px; font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        .logo span { color: var(--accent); }
        .sub-title { color: rgba(0, 242, 255, 0.6); font-size: 0.75rem; letter-spacing: 3px; font-family: 'Orbitron'; margin-bottom: 2rem; text-shadow: 0 0 5px rgba(0, 242, 255, 0.3); }
        .input-group { text-align: left; margin-bottom: 1.2rem; }
        .label { display: block; font-size: 10px; font-family: 'Orbitron'; color: var(--accent); margin-bottom: 8px; letter-spacing: 2px; text-shadow: 0 0 5px rgba(0, 242, 255, 0.4); }
        .input-style {
            width: 100%;
            padding: 14px;
            background: rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 12px;
            color: white;
            font-family: 'Outfit', sans-serif;
            font-size: 1rem;
            outline: none;
            transition: all 0.3s ease;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .input-style:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        .btn-main {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            border: none;
            border-radius: 14px;
            color: white;
            font-family: 'Orbitron';
            font-weight: 700;
            font-size: 0.78rem;
            letter-spacing: 2px;
            cursor: pointer;
            margin-top: 1rem;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-main:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); 
            filter: brightness(1.1); 
        }
        .btn-wa {
            width: 100%;
            padding: 14px;
            background: #25D366;
            border: none;
            border-radius: 14px;
            color: white;
            font-family: 'Orbitron';
            font-weight: 700;
            font-size: 0.72rem;
            letter-spacing: 2px;
            cursor: pointer;
            margin-top: 10px;
            display: none;
            box-shadow: 0 4px 15px rgba(37, 211, 102, 0.4);
            transition: all 0.3s ease;
        }
        .btn-wa:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(37, 211, 102, 0.6);
        }
        .btn-back { display: inline-flex; align-items: center; gap: 8px; margin-top: 20px; color: var(--accent); font-size: 0.8rem; text-decoration: none; transition: all 0.3s ease; }
        .btn-back:hover { text-shadow: 0 0 8px rgba(0, 242, 255, 0.6); transform: translateX(-3px); }
        
        /* Ojitos y Progress Bar */
        .pass-container { position: relative; }
        .toggle-pass { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); cursor: pointer; color: rgba(0, 242, 255, 0.6); transition: 0.3s; z-index: 10; }
        .toggle-pass:hover { color: var(--accent); }
        .strength-meter { height: 4px; background: rgba(255,255,255,0.05); border-radius: 2px; margin-top: -10px; margin-bottom: 20px; overflow: hidden; display: none; }
        .strength-bar { height: 100%; width: 0; transition: 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
    <div id="skullRain" class="skull-rain"></div>
    <div class="card">
        <h2 class="logo">Nova<span>X</span></h2>
        <p class="sub-title">RESTABLECER CONTRASE&Ntilde;A</p>

        <div id="step1">
            <div class="input-group">
                <span class="label">CORREO ELECTR&Oacute;NICO</span>
                <input type="email" id="txtEmail" class="input-style" placeholder="Tu correo registrado" readonly />
            </div>

            <div class="input-group">
                <span class="label">CLAVE TEMPORAL (6 D&Iacute;GITOS)</span>
                <input type="text" id="txtKey" class="input-style" placeholder="Ej: 123456" maxlength="6" />
            </div>

            <button type="button" class="btn-main" id="btnVerificar">VERIFICAR CLAVE</button>
        </div>

        <div id="step2" style="display: none;">
            <div class="input-group">
                <span class="label">NUEVA CONTRASE&Ntilde;A</span>
                <div class="pass-container">
                    <input type="password" id="txtPass" class="input-style" placeholder="M&iacute;n. 8 caracteres" />
                    <i class="fas fa-eye toggle-pass" onclick="togglePass('txtPass', this)"></i>
                </div>
            </div>
            
            <div class="strength-meter" id="strengthMeter">
                <div class="strength-bar" id="strengthBar"></div>
            </div>

            <div class="input-group">
                <span class="label">CONFIRMAR NUEVA CONTRASE&Ntilde;A</span>
                <div class="pass-container">
                    <input type="password" id="txtPassConfirm" class="input-style" placeholder="Repite la contrase&ntilde;a" />
                    <i class="fas fa-eye toggle-pass" onclick="togglePass('txtPassConfirm', this)"></i>
                </div>
            </div>

            <button type="button" class="btn-main" id="btnCambiar">ACTUALIZAR CONTRASE&Ntilde;A</button>
        </div>

        <button type="button" class="btn-wa" id="btnWhatsApp">📲 VER CLAVE EN WHATSAPP</button>
        <a href="Loguin.aspx" class="btn-back">&larr; Volver al login</a>
    </div>

<script>
// @ts-nocheck
(function() {
    var Swal = window['Swal'];
    var waLink = null;

    // Auto-poblar el correo desde la URL
    var urlParams = new URLSearchParams(window.location.search);
    var emailEl = document.getElementById('txtEmail');
    if (emailEl && urlParams.has('email')) {
        emailEl.value = urlParams.get('email');
    }

    // Función para llamar Auth.ashx (igual que en Loguin.aspx)
    function invocarAuth(action, payload, onOk, onErr) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'Auth.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var obj = JSON.parse(xhr.responseText);
                        onOk(obj.d || '');
                    } catch(e) { onOk(xhr.responseText); }
                } else { if (onErr) onErr(); }
            }
        };
        payload.action = action;
        xhr.send(JSON.stringify(payload));
    }

    // Botón WhatsApp
    var btnWa = document.getElementById('btnWhatsApp');
    if (btnWa) {
        btnWa.addEventListener('click', function() {
            if (waLink) window.open(waLink, '_blank');
        });
    }

    // Botón verificar clave (Paso 1)
    var btnVerificar = document.getElementById('btnVerificar');
    if (btnVerificar) {
        btnVerificar.addEventListener('click', function() {
            var email = emailEl ? emailEl.value.trim() : '';
            var keyEl = document.getElementById('txtKey');
            var key = keyEl ? keyEl.value.trim() : '';
            
            if (!key) {
                Swal.fire({ title: 'Clave requerida', text: 'Ingresa la clave de 6 dígitos.', icon: 'warning', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                return;
            }

            btnVerificar.disabled = true;
            btnVerificar.textContent = 'VALIDANDO...';

            invocarAuth('validarkeytemporal', { email: email, key: key }, function(res) {
                btnVerificar.disabled = false;
                btnVerificar.textContent = 'VERIFICAR CLAVE';

                if (res === 'OK') {
                    // "Salto" al paso 2
                    document.getElementById('step1').style.display = 'none';
                    document.getElementById('step2').style.display = 'block';
                    
                    // Ocultamos el botón de WA en el paso 2 para que no estorbe
                    if (btnWa) btnWa.style.display = 'none';
                } else {
                    Swal.fire({ title: 'Error', text: res, icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                }
            }, function() {
                btnVerificar.disabled = false;
                btnVerificar.textContent = 'VERIFICAR CLAVE';
                Swal.fire({ title: 'Error de servidor', icon: 'error', background: '#0a0a19', color: '#fff' });
            });
        });
    }

    window.togglePass = function(id, icon) {
        var el = document.getElementById(id);
        if (el.type === 'password') {
            el.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            el.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    };

    var txtPass = document.getElementById('txtPass');
    if (txtPass) {
        txtPass.addEventListener('input', function() {
            var val = this.value;
            var meter = document.getElementById('strengthMeter');
            var bar = document.getElementById('strengthBar');
            if (val.length === 0) { meter.style.display = 'none'; return; }
            meter.style.display = 'block';
            
            var score = 0;
            if (val.length > 7) score += 25;
            if (/[A-Z]/.test(val)) score += 25;
            if (/[0-9]/.test(val)) score += 25;
            if (/[^A-Za-z0-9]/.test(val)) score += 25;

            var color = '#ff4444';
            if (score > 25) color = '#ffbb33';
            if (score > 50) color = '#00C851';
            if (score > 75) color = '#00f2ff';

            bar.style.width = score + '%';
            bar.style.backgroundColor = color;
        });
    }

    // Botón cambiar contraseña (Paso 2)
    var btnCambiar = document.getElementById('btnCambiar');
    if (btnCambiar) {
        btnCambiar.addEventListener('click', function() {
            var email = emailEl ? emailEl.value.trim() : '';
            var key = document.getElementById('txtKey').value.trim();
            var pass = txtPass ? txtPass.value : '';
            var passConfirm = document.getElementById('txtPassConfirm').value;

            if (!pass || !passConfirm) {
                Swal.fire({ title: 'Campos vac\u00EDos', text: 'Escribe y confirma tu nueva contrase\u00F1a.', icon: 'warning', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                return;
            }

            if (pass !== passConfirm) {
                Swal.fire({ title: 'No coinciden', text: 'Las contrase\u00F1as no son iguales.', icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                return;
            }

            btnCambiar.disabled = true;
            btnCambiar.textContent = 'ACTUALIZANDO...';

            invocarAuth('ConfirmarCambio', { email: email, key: key, pass: pass }, function(res) {
                btnCambiar.disabled = false;
                btnCambiar.textContent = 'ACTUALIZAR CONTRASE\u00D1A';

                if (res === 'OK') {
                    Swal.fire({
                        title: '\u00A1\u00C9xito!',
                        text: 'Contrase\u00F1a actualizada correctamente.',
                        icon: 'success',
                        background: '#0a0a19',
                        color: '#fff',
                        confirmButtonColor: '#7F77DD'
                    }).then(function() {
                        window.location.href = 'Loguin.aspx';
                    });
                } else {
                    Swal.fire({ title: 'Error', text: res, icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                }
            }, function() {
                btnCambiar.disabled = false;
                btnCambiar.textContent = 'ACTUALIZAR CONTRASE\u00D1A';
                Swal.fire({ title: 'Error de servidor', icon: 'error', background: '#0a0a19', color: '#fff' });
            });
        });
    }
})();
</script>
</body>
</html>
