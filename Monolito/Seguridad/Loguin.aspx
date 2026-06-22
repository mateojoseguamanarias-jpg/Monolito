<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Loguin.aspx.cs" Inherits="Monolito.Seguridad.Loguin" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>NovaX PRO | Acceso</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
    <script src="https://accounts.google.com/gsi/client" async defer></script>
    <script async defer crossorigin="anonymous" src="https://connect.facebook.net/es_LA/sdk.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root { 
            --purple: #9d4edd; 
            --purple-dark: #5a189a; 
            --accent: #00f2ff;
            --glass: rgba(8, 8, 20, 0.75);
            --glass-border: rgba(0, 242, 255, 0.25);
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #05050b url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed;
            background-size: cover; display: flex; justify-content: center; align-items: center;
            min-height: 100vh; font-family: 'Outfit', sans-serif; color: white;
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
            background: var(--glass); 
            border: 1px solid var(--glass-border);
            padding: 2.5rem 2.2rem 2rem; border-radius: 20px; width: 380px;
            position: relative; z-index: 2; backdrop-filter: blur(25px);
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
        }
        .card::before {
            content: ''; position: absolute; top: 0; left: 15%; right: 15%; height: 1px;
            background: linear-gradient(90deg, transparent, var(--accent), transparent);
        }
        .logo { 
            font-family: 'Orbitron', monospace; font-size: 1.8rem; font-weight: 900;
            letter-spacing: 6px; text-align: center; margin-bottom: 0.3rem; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }
        .logo span { color: var(--accent); }
        .sub-logo { text-align: center; font-size: 0.72rem; color: rgba(0, 242, 255, 0.6);
                    letter-spacing: 3px; margin-bottom: 1.8rem; font-family: 'Orbitron', monospace;
                    text-shadow: 0 0 5px rgba(0, 242, 255, 0.3); }
        .field { position: relative; margin-bottom: 0.85rem; }
        .field input {
            width: 100%; padding: 12px 40px 12px 14px; border-radius: 10px;
            border: 1px solid rgba(0, 242, 255, 0.2); background: rgba(0, 0, 0, 0.4);
            color: white; font-size: 0.9rem; font-family: 'Outfit', sans-serif; outline: none;
            transition: all 0.3s ease;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .field input:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }
        .field input::placeholder { color: rgba(255,255,255,0.3); font-size: 0.82rem; letter-spacing: 1px; }
        .progress-bar { position: absolute; bottom: -1px; left: 0; height: 2px; width: 0%;
                        background: linear-gradient(90deg, var(--accent), #a89dff);
                        border-radius: 0 0 2px 2px; transition: width 0.4s ease; }
        .toggle-pass { position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
                       cursor: pointer; background: none; border: none; color: rgba(0, 242, 255, 0.6); font-size: 14px; padding: 0; }
        .strength-bar { height: 3px; border-radius: 2px; margin: 4px 0 10px; background: rgba(0, 242, 255, 0.05); overflow: hidden; }
        .strength-fill { height: 100%; width: 0%; border-radius: 2px; transition: width 0.3s, background 0.3s; }
        .options-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem; }
        .remember { display: flex; align-items: center; gap: 6px; font-size: 0.8rem; color: rgba(255,255,255,0.45); cursor: pointer; }
        .remember input { accent-color: var(--accent); cursor: pointer; }
        .forgot { font-size: 0.78rem; color: var(--accent); text-decoration: none; text-shadow: 0 0 5px rgba(0, 242, 255, 0.3); }
        .forgot:hover { color: #a89dff; }
        .btn-main {
            width: 100%; padding: 13px; 
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            border: none; color: white; font-family: 'Orbitron', monospace; font-size: 0.75rem;
            font-weight: 700; letter-spacing: 2px; border-radius: 10px; cursor: pointer; 
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-main:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); 
            filter: brightness(1.1); 
        }
        .btn-main:disabled { opacity: 0.5; cursor: not-allowed; }
        .divider { display: flex; align-items: center; gap: 10px; margin: 1.2rem 0;
                   color: rgba(255,255,255,0.25); font-size: 0.75rem; letter-spacing: 1px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: rgba(0, 242, 255, 0.15); }
        .social-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 1rem; }
        .social-btn {
            padding: 10px 8px; border: 1px solid rgba(0, 242, 255, 0.2); border-radius: 9px;
            background: rgba(0, 242, 255, 0.05); color: white; font-size: 0.78rem;
            font-family: 'Outfit', sans-serif; font-weight: 600; letter-spacing: 0.5px;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            gap: 7px; transition: all 0.3s ease;
        }
        .social-btn:hover { background: rgba(0, 242, 255, 0.15); border-color: var(--accent); box-shadow: 0 0 10px rgba(0, 242, 255, 0.25); }
        .register-text { text-align: center; font-size: 0.8rem; color: rgba(255,255,255,0.38); margin-top: 1rem; }
        .register-text a { color: var(--accent); text-decoration: none; font-weight: 600; }
        .register-text a:hover { color: #a89dff; text-shadow: 0 0 5px rgba(0, 242, 255, 0.5); }
        .btn-qr {
            position: absolute; top: 14px; right: 14px; background: rgba(0, 242, 255, 0.05);
            border: 1px solid rgba(0, 242, 255, 0.25); border-radius: 8px; color: var(--accent);
            font-size: 0.68rem; font-family: 'Orbitron', monospace; letter-spacing: 1px;
            padding: 6px 10px; cursor: pointer; display: flex; align-items: center; gap: 5px;
            transition: all 0.3s ease;
        }
        .btn-qr:hover { background: rgba(0, 242, 255, 0.2); color: white; box-shadow: 0 0 10px rgba(0, 242, 255, 0.3); }
        .qr-overlay {
            position: absolute; inset: 0; background: rgba(5,2,20,0.97); border-radius: 20px;
            display: none; flex-direction: column; align-items: center; justify-content: center;
            gap: 14px; z-index: 10;
        }
        .qr-overlay.active { display: flex; }
        .qr-frame { position: relative; width: 240px; height: 240px; }
        .qr-video { width: 240px; height: 240px; border: 2px solid rgba(0, 242, 255, 0.4);
                    border-radius: 14px; object-fit: cover; background: #000; }
        .corner { position: absolute; width: 20px; height: 20px; border-color: var(--accent); border-style: solid; }
        .tl { top:0;left:0;border-width:3px 0 0 3px;border-radius:4px 0 0 0; }
        .tr { top:0;right:0;border-width:3px 3px 0 0;border-radius:0 4px 0 0; }
        .bl { bottom:0;left:0;border-width:0 0 3px 3px;border-radius:0 0 0 4px; }
        .br { bottom:0;right:0;border-width:0 3px 3px 0;border-radius:0 0 4px 0; }
        .scan-line {
            position: absolute; top: 0; left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--accent), transparent);
            animation: scan 2s linear infinite;
        }
        @keyframes scan { 0% { top: 0; } 100% { top: 100%; } }
        .qr-label { font-family: 'Orbitron', monospace; font-size: 0.65rem; letter-spacing: 2px; color: var(--accent); }
        .btn-close-qr {
            font-size: 0.78rem; color: var(--accent); background: none;
            border: 1px solid rgba(0, 242, 255, 0.25); border-radius: 7px;
            padding: 8px 20px; cursor: pointer; font-family: 'Outfit', sans-serif; font-weight: 600; letter-spacing: 1px;
            transition: all 0.3s ease;
        }
        .btn-close-qr:hover { color: white; border-color: var(--accent); box-shadow: 0 0 10px rgba(0, 242, 255, 0.25); }
    </style>
</head>
<body>
<form id="formLogin" runat="server" autocomplete="off">
    <asp:ScriptManager ID="sm1" runat="server" EnablePageMethods="true" />
    <div id="skullRain" class="skull-rain"></div>
    <div class="card">
        <div class="qr-overlay" id="qrOverlay">
            <p class="qr-label">ESCANEO QR ACTIVO</p>
            <div class="qr-frame">
                <video class="qr-video" id="qrVideo" autoplay="autoplay" playsinline="playsinline" muted="muted"></video>
                <div class="corner tl"></div><div class="corner tr"></div>
                <div class="corner bl"></div><div class="corner br"></div>
                <div class="scan-line"></div>
            </div>
            <p style="font-size:0.78rem;color:rgba(255,255,255,0.4);">Apunta la cámara al código QR</p>
            <button type="button" class="btn-close-qr" id="btnCerrarQR">CERRAR CÁMARA</button>
        </div>

        <button type="button" class="btn-qr" id="btnAbrirQR">QR</button>
        <h2 class="logo">Nova<span>X</span></h2>
        <p class="sub-logo">SISTEMA DE ACCESO</p>

        <div class="field">
            <input type="email" id="txtEmail" placeholder="CORREO ELECTR&Oacute;NICO"
                   oninput="actualizarBarra('barEmail',this.value,'email')" autocomplete="off" />
            <div class="progress-bar" id="barEmail"></div>
        </div>

        <div class="field">
            <input type="password" id="txtPass" placeholder="CONTRASE&Ntilde;A"
                   oninput="actualizarBarra('barPass',this.value,'pass')" autocomplete="off" />
            <button type="button" class="toggle-pass" id="btnOjo"><i class="fas fa-eye"></i></button>
            <div class="progress-bar" id="barPass"></div>
        </div>
        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>

        <div class="options-row">
            <label class="remember"><input type="checkbox" id="chkRecordar" /> Recu&eacute;rdame</label>
            <a href="Recuperar.aspx" class="forgot" id="lnkOlvido">&iquest;Olvidaste tu contrase&ntilde;a?</a>
        </div>

        <button type="button" class="btn-main" id="btnIngresar">INGRESAR AL SISTEMA</button>

        <div class="divider">O CONTIN&Uacute;A CON</div>
        <div class="social-grid">
            <button type="button" class="social-btn" id="btnGoogleAuth">
                <svg width="16" height="16" viewBox="0 0 24 24">
                    <path fill="#EA4335" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
                    <path fill="#4285F4" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                Google
            </button>
            <button type="button" class="social-btn" id="btnFacebookAuth">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="#1877F2">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
                Facebook
            </button>
        </div>

        <p class="register-text">&iquest;Sin cuenta a&uacute;n? <a href="Registrar.aspx">Reg&iacute;strate aqu&iacute;</a></p>
    </div>
</form>

<script>
// @ts-nocheck
/* eslint-disable */
(function() {
    var _w = window;
    var Swal = _w.Swal;
    // No guardamos google ni FB aquí porque pueden cargar después

    function initSkulls() {
        var rain = document.getElementById('skullRain');
        if (!rain) return;
        for (var i = 0; i < 15; i++) {
            var skull = document.createElement('i');
            skull.className = 'fas fa-skull falling-skull';
            skull.style.left = Math.random() * 100 + 'vw';
            skull.style.animationDuration = (Math.random() * 5 + 5) + 's';
            skull.style.animationDelay = (Math.random() * 5) + 's';
            skull.style.fontSize = (Math.random() * 20 + 10) + 'px';
            rain.appendChild(skull);
        }
    }
    initSkulls();

    // --- GOOGLE AUTH INITIALIZATION ---
    window.onload = function () {
        if (window.google) {
            google.accounts.id.initialize({
                client_id: "368267137864-gp73i968ot1ref561obn02ut51e99ihc.apps.googleusercontent.com",
                callback: handleGoogleResponse,
                auto_select: false
            });
        }
    };

    var btnGoogle = document.getElementById('btnGoogleAuth');
    if (btnGoogle) {
        btnGoogle.onclick = function() {
            if (window.google && window.google.accounts) {
                window.google.accounts.id.prompt();
            } else {
                Swal.fire({ title: 'Google no listo', text: 'Esperando conexión con Google. Reintenta en un momento.', icon: 'info' });
            }
        };
    }

    function handleGoogleResponse(response) {
        // Decodificamos el token de Google para obtener el email
        var base64Url = response.credential.split('.')[1];
        var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        var jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        var googleData = JSON.parse(jsonPayload);

        Swal.fire({ title: 'Procesando Google...', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });
        invocarWebMethod('AutenticarGoogle', { 
            id_token: response.credential, 
            email: googleData.email,
            googleId: googleData.sub,
            nombre: googleData.name,
            foto: googleData.picture
        }, 
            function(res) {
                var urlFinal = construirUrlDashboard(res);
                Swal.fire({ title: 'Bienvenido', text: 'Entrando con Google...', icon: 'success', timer: 1000, showConfirmButton: false, didClose: function() { window.location.href = urlFinal; } });
            }, 
            function(err) {
                Swal.fire({ title: 'Error Google', text: err.get_message ? err.get_message() : 'Error', icon: 'error', background: '#0a0a19', color: '#fff' });
            }
        );
    }

    // --- FACEBOOK AUTH ---
    window.fbAsyncInit = function() {
        if (window.FB) {
            window.FB.init({
              appId      : '1713280346335979', 
              cookie     : true,
              xfbml      : true,
              version    : 'v18.0'
            });
        }
    };

    var btnFB = document.getElementById('btnFacebookAuth');
    if (btnFB) {
        btnFB.onclick = function() {
            if (window.FB) {
                window.FB.login(function(response) {
                    if (response.status === 'connected') {
                        window.FB.api('/me', {fields: 'name,email,picture'}, function(userData) {
                            invocarWebMethod('AutenticarFacebook', { 
                                fbId: userData.id, 
                                email: userData.email, 
                                nombre: userData.name,
                                foto: userData.picture.data.url 
                            }, function(res) {
                                window.location.href = construirUrlDashboard(res);
                            }, function(err) {
                                Swal.fire({ title: 'Error FB', text: err.get_message(), icon: 'error' });
                            });
                        });
                    }
                }, { scope: 'public_profile,email', auth_type: 'reauthenticate' });
            } else {
                Swal.fire({ title: 'Facebook no listo', text: 'Esperando conexión con Facebook. Reintenta.', icon: 'info' });
            }
        };
    }
    
    function construirUrlDashboard(resultado) {
        var ruta = (resultado || '').trim();
        if (!ruta || pareceHtml(ruta)) return '';
        if (/^https?:\/\//i.test(ruta)) return ruta;
        if (ruta.indexOf('~/') === 0) return ruta.replace(/^~\//, '../');
        return ruta; // El backend ya manda la ruta relativa correcta (../Mantenimiento/...)
    }
    
    function pareceHtml(valor) {
        return /<\s*!doctype|<\s*html|<\s*head|<\s*body/i.test(valor || '');
    }
    
    function invocarWebMethod(metodo, payload, onSuccess, onError) {
        payload = payload || {};
        payload.action = metodo;

        // URL relativa directa al handler en la misma carpeta
        var endpoint = 'Auth.ashx';

        fetch(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(function(r) { 
            const contentType = r.headers.get("content-type");
            if (contentType && contentType.indexOf("application/json") !== -1) {
                return r.json();
            } else {
                return r.text().then(text => { throw new Error(text || r.statusText); });
            }
        })
        .then(function(json) {
            var res = json && typeof json.d === 'string' ? json.d : '';
            if (res.toUpperCase().indexOf('ERROR') === 0) {
                onError({ get_message: function() { return res; } });
            } else {
                onSuccess(res);
            }
        })
        .catch(function(err) {
            console.error("Auth Error Detail:", err);
            var msg = err.message || 'Error de conexion';
            if (msg.indexOf('<!DOCTYPE') !== -1 || msg.indexOf('<html') !== -1) {
                msg = 'Error critico en el servidor (C#). Re-compila el proyecto.';
            }
            Swal.fire({ title: 'Error de Conexión', text: msg, icon: 'error', background: '#0a0a19', color: '#fff' });
            onError({ get_message: function() { return msg; } });
        });
    }

    // ── Barras de progreso ──────────────────────────────────────
    /**
     * @param {string} barId
     * @param {string} valor
     * @param {'email'|'pass'} tipo
     */
    window.actualizarBarra = function (barId, valor, tipo) {
        var bar = document.getElementById(barId);
        if (!bar) return;
        var pct = 0;
        if (tipo === 'email') {
            if (valor.length > 0) pct = 30;
            if (valor.indexOf('@') >= 0) pct = 65;
            if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(valor)) pct = 100;
        } else {
            if (valor.length >= 1) pct = 20;
            if (valor.length >= 6) pct = 45;
            if (valor.length >= 8 && /[A-Z]/.test(valor)) pct = 70;
            if (valor.length >= 8 && /[A-Z]/.test(valor) && /[0-9]/.test(valor)) pct = 85;
            if (valor.length >= 8 && /[A-Z]/.test(valor) && /[0-9]/.test(valor) && /\W/.test(valor)) pct = 100;
            var sf = document.getElementById('strengthFill');
            if (sf) {
                sf.style.width = pct + '%';
                sf.style.background = pct < 50 ? '#E24B4A' : pct < 80 ? '#BA7517' : '#1D9E75';
            }
        }
        bar.style.width = pct + '%';
        bar.style.background = pct < 50
            ? 'linear-gradient(90deg,#E24B4A,#f07070)'
            : pct < 100 ? 'linear-gradient(90deg,#BA7517,#efbf60)'
                : 'linear-gradient(90deg,#1D9E75,#5dcaa5)';
    };

    // ── Ver/ocultar contraseña ──────────────────────────────────
    var btnOjo = document.getElementById('btnOjo');
    if (btnOjo) {
        btnOjo.addEventListener('click', function () {
            var p = /** @type {HTMLInputElement | null} */ (document.getElementById('txtPass'));
            if (p) {
                p.type = p.type === 'password' ? 'text' : 'password';
                var icon = btnOjo.querySelector('i');
                if (icon) icon.className = p.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
            }
        });
    }

    // ── Olvidé contraseña ───────────────────────────────────────
    var lnkOlvido = document.getElementById('lnkOlvido');
    if (lnkOlvido) {
        lnkOlvido.addEventListener('click', function (e) {
            e.preventDefault();
            var emailEl = document.getElementById('txtEmail');
            var email = emailEl ? emailEl['value'].trim() : '';
            if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                Swal.fire({ title: 'Ingresa tu correo', text: 'Escribe tu correo registrado para enviarte una clave temporal.', icon: 'info', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                if (emailEl) emailEl.focus();
                return;
            }

            Swal.showLoading();
            invocarWebMethod('RecuperarPass', { email: email }, function(res) {
                if (res && res.indexOf('OK') === 0) {
                    var parts = res.split('|');
                    var waData = parts[1]; // Puede ser el link o el texto "ENVIADO_AUTO"

                    var htmlMsg = '';
                    if (waData === "ENVIADO_AUTO") {
                        htmlMsg = '<div style="color:#fff; text-align:center;">'
                            + '<i class="fab fa-whatsapp" style="font-size:3rem; color:#25D366;"></i><br><br>'
                            + '¡Clave enviada **automáticamente** a tu WhatsApp!<br>'
                            + '<small style="color:rgba(255,255,255,0.5);">También revisa tu correo: <b>' + email + '</b></small>'
                            + '</div>';
                    } else {
                        htmlMsg = '<div style="color:#fff; text-align:center;">'
                            + 'Clave enviada a <b>' + email + '</b><br><br>'
                            + (waData ? '<a href="' + waData + '" target="_blank" '
                            + 'style="display:inline-block;background:#25D366;color:#fff;padding:12px 24px;'
                            + 'border-radius:12px;text-decoration:none;font-weight:700;font-size:1rem;margin-bottom:8px;">'
                            + '📲 ABRIR WHATSAPP MANUALMENTE</a><br><br>' : '')
                            + '<small style="color:rgba(255,255,255,0.5);">Nota: Para que sea automático, configura Twilio.</small>'
                            + '</div>';
                    }

                    Swal.fire({
                        title: '¡Clave Generada!',
                        html: htmlMsg,
                        icon: 'success',
                        background: '#0a0a19',
                        color: '#fff',
                        confirmButtonText: '📧 IR A CAMBIAR CONTRASEÑA',
                        confirmButtonColor: '#7F77DD',
                        allowOutsideClick: false
                    }).then(function() {
                        window.location.href = 'CambiarPass.aspx?email=' + encodeURIComponent(email);
                    });
                } else {
                    Swal.fire({ title: 'Error', text: res, icon: 'error', background: '#0a0a19', color: '#fff' });
                }
            }, function(err) {
                Swal.fire({ title: 'Error', text: 'No se pudo procesar la solicitud.', icon: 'error', background: '#0a0a19', color: '#fff' });
            });
        });
    }

    // ── Login principal ─────────────────────────────────────────
    var btnIngresar = document.getElementById('btnIngresar');
    if (btnIngresar) {
        btnIngresar.addEventListener('click', function () {
            var emailEl = document.getElementById('txtEmail');
            var passEl = document.getElementById('txtPass');
            var remEl = document.getElementById('chkRecordar');
            var email = emailEl ? emailEl['value'].trim() : '';
            var pass = passEl ? passEl['value'] : '';
            var remember = remEl ? remEl['checked'] : false;
            var btn = btnIngresar;

            if (!email || !pass) {
                Swal.fire({ title: 'Campos vacíos', text: 'Completa todos los campos.', icon: 'warning', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                return;
            }

            if (btn) {
                btn['disabled'] = true;
                btn['textContent'] = 'VERIFICANDO...';
            }

            invocarWebMethod('Autenticar', { email: email, pass: pass, remember: remember },
                
                function(resultado) {
                    if (btn) {
                        btn['disabled'] = false;
                        btn['textContent'] = 'INGRESAR AL SISTEMA';
                    }
                    var res = (resultado || '').trim();
                    
                    if (res.indexOf('OTP_REQUIRED') === 0) {
                        Swal.fire({ 
                            title: 'Seguridad NovaX', 
                            html: '<div style="color:#fff">Se ha enviado un c&oacute;digo QR a tu correo.<br><b>Escan&eacute;alo para completar el acceso.</b></div>', 
                            icon: 'info', 
                            background: '#0a0a19', 
                            color: '#fff', 
                            confirmButtonColor: '#7F77DD' 
                        }).then(function() {
                             // Abre la cámara automáticamente
                             document.getElementById('btnAbrirQR').click();
                        });
                    } else if (res.indexOf('BLOCKED') === 0) {
                        Swal.fire({ title: 'Acceso Bloqueado', text: 'Demasiados intentos fallidos. Intenta m&aacute;s tarde.', icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                    } else if (res.toUpperCase().indexOf('ERROR') === 0) {
                        Swal.fire({ title: 'Acceso denegado', text: res, icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                    } else {
                        var urlFinal = pareceHtml(res) ? 'Loguin.aspx' : construirUrlDashboard(res);
                        Swal.fire({ title: 'Bienvenido', text: 'Entrando al sistema...', icon: 'success', timer: 1000, showConfirmButton: false, background: '#0a0a19', color: '#fff', didClose: function() { window.location.href = urlFinal; } });
                        setTimeout(function() { window.location.href = urlFinal; }, 1100);
                    }
                },
                function(err) {
                    btn.disabled = false;
                    btn.textContent = 'INGRESAR AL SISTEMA';
                    Swal.fire({ title: 'Error de servidor', text: err.get_message ? err.get_message() : 'Error inesperado.', icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                }
            );
        });
    }

    // ── QR / Cámara ─────────────────────────────────────────────
    /** @type {MediaStream | null} */
    var camStream = null;
    var qrLeyendo = false;
    var qrCanvas = document.createElement('canvas');
    var qrCtx = qrCanvas.getContext('2d');

    function cerrarCamaraQR() {
        var overlay = document.getElementById('qrOverlay');
        var video = document.getElementById('qrVideo');
        if (overlay) overlay['classList']['remove']('active');
        qrLeyendo = false;
        if (camStream) {
            camStream['getTracks']().forEach(function (t) { t['stop'](); });
            camStream = null;
        }
        if (video) video['srcObject'] = null;
    }

    function procesarQrDetectado(qrData) {
        var onSuccess = function(resultado) {
            var resultadoLimpio = (resultado || '').trim();
            if (resultadoLimpio.toUpperCase().indexOf('ERROR') === 0) {
                Swal.fire({ title: 'QR inv&aacute;lido', text: resultadoLimpio, icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' })
                    .then(function () {
                        qrLeyendo = true;
                        requestAnimationFrame(loopScanQR);
                    });
            } else if (resultadoLimpio === 'OTP_REQUIRED') {
                // NUEVO: Manejar el flujo de 2 pasos para el QR
                Swal.fire({ 
                    title: 'Seguridad NovaX', 
                    html: '<div style="color:#fff">QR de Registro reconocido.<br><b>Se ha enviado un nuevo c&oacute;digo OTP a tu correo.</b><br>Escan&eacute;alo para completar el acceso.</div>', 
                    icon: 'info', 
                    background: '#0a0a19', 
                    color: '#fff', 
                    confirmButtonColor: '#7F77DD' 
                }).then(function() {
                     // Reabre la cámara automáticamente para el OTP
                     document.getElementById('btnAbrirQR').click();
                });
            } else {
                var urlFinal = pareceHtml(resultadoLimpio)
                    ? 'Loguin.aspx'
                    : construirUrlDashboard(resultadoLimpio);
                if (!urlFinal) {
                    Swal.fire({ title: 'Error de redirección', text: 'No se pudo obtener la ruta del dashboard.', icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                    return;
                }

                Swal.fire({ 
                    title: 'Acceso concedido', 
                    text: 'Cargando ' + resultadoLimpio,
                    icon: 'success', 
                    timer: 1000, 
                    showConfirmButton: false, 
                    background: '#0a0a19', 
                    color: '#fff',
                    didClose: function() {
                        window.location.href = urlFinal;
                    }
                });
                // Redirección de respaldo
                setTimeout(function() { window.location.href = urlFinal; }, 1100);
            }
        };

        var onError = function (err) {
            Swal.fire({ title: 'Error de servidor', text: err && err.get_message ? err.get_message() : 'No se pudo validar el QR.', icon: 'error', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' })
                .then(function () {
                    qrLeyendo = true;
                    requestAnimationFrame(loopScanQR);
                });
        };

        var remEl = /** @type {HTMLInputElement | null} */ (document.getElementById('chkRecordar'));
        var remember = remEl ? remEl.checked : false;
        invocarWebMethod('AutenticarQR', { qrData: qrData, remember: remember }, onSuccess, onError);
    }

    function loopScanQR() {
        if (!qrLeyendo) return;
        var video = document.getElementById('qrVideo');
        if (!video || !qrCtx || video['readyState'] !== video['HAVE_ENOUGH_DATA']) {
            requestAnimationFrame(loopScanQR);
            return;
        }
        
        qrCanvas['width'] = video['videoWidth'] || 320;
        qrCanvas['height'] = video['videoHeight'] || 240;
        qrCtx['drawImage'](video, 0, 0, qrCanvas['width'], qrCanvas['height']);
        var imageData = qrCtx['getImageData'](0, 0, qrCanvas['width'], qrCanvas['height']);
        var _w = window;
        if (_w['jsQR']) {
            var code = _w['jsQR'](imageData['data'], imageData['width'], imageData['height'], { inversionAttempts: 'attemptBoth' });
            if (code && code['data']) {
                qrLeyendo = false;
                cerrarCamaraQR();
                procesarQrDetectado(code['data']);
                return;
            }
        }
        requestAnimationFrame(loopScanQR);
    }

    var btnAbrirQR = document.getElementById('btnAbrirQR');
    if (btnAbrirQR) {
        btnAbrirQR.addEventListener('click', function () {
            var overlay = document.getElementById('qrOverlay');
            var video = /** @type {HTMLVideoElement | null} */ (document.getElementById('qrVideo'));
            if (overlay) overlay.classList.add('active');
            if (navigator['mediaDevices'] && navigator['mediaDevices']['getUserMedia']) {
                navigator['mediaDevices']['getUserMedia']({ video: { facingMode: 'environment', width: { ideal: 640 }, height: { ideal: 480 } } })
                    .then(function (stream) {
                        camStream = stream;
                        if (video) {
                            video['srcObject'] = stream;
                            video['onloadedmetadata'] = function() {
                                video['play']()['catch'](function(e) { console.error("Error play video:", e); });
                                qrLeyendo = true;
                                requestAnimationFrame(loopScanQR);
                            };
                        }
                    })
                    .catch(function (err) {
                        var msg = err && err.message
                            ? err.message
                            : 'Permiso denegado o cámara en uso por otra app.';
                        Swal.fire({ title: 'Cámara no disponible', text: msg, icon: 'warning', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                        if (overlay) overlay.classList.remove('active');
                    });
            } else {
                Swal.fire({ title: 'Cámara no compatible', text: 'Este navegador no soporta acceso a cámara.', icon: 'warning', background: '#0a0a19', color: '#fff', confirmButtonColor: '#7F77DD' });
                if (overlay) overlay.classList.remove('active');
            }
        });
    }

    var btnCerrarQR = document.getElementById('btnCerrarQR');
    if (btnCerrarQR) {
        btnCerrarQR.addEventListener('click', function () {
            cerrarCamaraQR();
        });
    }
    // ── Protección de Navegación (Flechas del navegador) ────────
    history.pushState(null, null, location.href);
    window.onpopstate = function () {
        history.go(1);
    };
})();
</script>
</body>
</html>