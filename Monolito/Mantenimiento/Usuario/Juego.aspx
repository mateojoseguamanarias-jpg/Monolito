<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Juego.aspx.cs" Inherits="Monolito.Dashboard.Juego" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <title>NovaX | El Ahorcado de Seiya</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Rajdhani:wght@400;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root { --purple: #7F77DD; --neon: #00f2ff; --bg: #050014; }
        body { 
            background: var(--bg); color: white; font-family: 'Rajdhani', sans-serif; 
            margin: 0; overflow: hidden; display: flex; align-items: center; justify-content: center; height: 100vh;
            background-image: url('seiya_background_1778723796675.png');
            background-size: cover;
            background-position: center;
        }
        body::before { content: ''; position: fixed; inset: 0; background: rgba(5,0,20,0.8); z-index: -1; }
        
        #gameContainer {
            position: relative;
            width: 850px;
            height: 500px;
            border: 2px solid var(--purple);
            border-radius: 20px;
            backdrop-filter: blur(15px);
            background: rgba(0,0,0,0.6);
            padding: 30px;
            display: flex;
            gap: 30px;
            box-shadow: 0 0 50px rgba(127, 119, 221, 0.4);
        }

        /* --- LADO IZQUIERDO: DIBUJO --- */
        .drawing-side {
            flex: 1;
            position: relative;
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 15px;
            background: linear-gradient(180deg, rgba(0,0,0,0.4) 0%, rgba(127,119,221,0.05) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .gallows { position: absolute; inset: 0; pointer-events: none; }
        .gallows .base { position: absolute; bottom: 40px; left: 40px; width: 120px; height: 10px; background: #5d4037; border-radius: 5px; box-shadow: 0 0 10px #000; }
        .gallows .pole { position: absolute; bottom: 50px; left: 95px; width: 10px; height: 350px; background: #5d4037; }
        .gallows .top-bar { position: absolute; top: 100px; left: 95px; width: 150px; height: 10px; background: #5d4037; }
        .gallows .rope { position: absolute; top: 110px; left: 235px; width: 4px; height: 50px; background: #d7ccc8; border-radius: 2px; box-shadow: 0 0 5px rgba(0,0,0,0.5); }

        .seiya-container {
            position: relative;
            width: 320px;
            height: 420px;
            z-index: 2;
            margin-left: 100px;
            margin-top: 50px;
            background: radial-gradient(circle, rgba(0,0,0,0.8) 20%, transparent 70%); /* Oculta el fondo de cuadritos si el PNG no es perfecto */
            border-radius: 50%;
        }

        .seiya-base {
            width: 100%;
            height: 100%;
            opacity: 0.15;
            filter: grayscale(1) brightness(0.2);
            transition: 0.5s;
            object-fit: contain;
        }
        .seiya-part {
            position: absolute;
            inset: 0;
            background-image: url('seiya_character_1778723826091.png');
            background-size: contain;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0;
            transition: 1s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            transform: scale(0.9) translateY(10px);
            filter: drop-shadow(0 0 15px var(--purple));
        }
        .seiya-part.show { opacity: 1; transform: scale(1) translateY(0); }

        /* --- LADO DERECHO: INTERFAZ --- */
        .game-side {
            flex: 1.2;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .header { display: flex; justify-content: space-between; font-family: 'Orbitron'; font-size: 14px; }
        .stat { color: var(--neon); text-shadow: 0 0 5px var(--neon); }

        .word-container {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 40px 0;
        }
        .letter-slot {
            width: 40px;
            height: 50px;
            border-bottom: 3px solid var(--purple);
            font-family: 'Orbitron';
            font-size: 32px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            text-transform: uppercase;
        }

        .keyboard {
            display: grid;
            grid-template-columns: repeat(9, 1fr);
            gap: 8px;
        }
        .key {
            background: rgba(127,119,221,0.1);
            border: 1px solid var(--purple);
            color: white;
            padding: 10px 5px;
            font-family: 'Orbitron';
            font-size: 14px;
            cursor: pointer;
            border-radius: 5px;
            transition: 0.2s;
        }
        .key:hover:not(:disabled) { background: var(--purple); box-shadow: 0 0 15px var(--purple); transform: translateY(-2px); }
        .key:disabled { opacity: 0.3; cursor: default; }
        .key.hit { background: #4ade80; border-color: #4ade80; box-shadow: 0 0 10px #4ade80; }
        .key.miss { background: #ef4444; border-color: #ef4444; box-shadow: 0 0 10px #ef4444; }

        .lives-container {
            display: flex;
            gap: 5px;
            margin-top: 20px;
        }
        .life-icon { color: #ef4444; font-size: 20px; text-shadow: 0 0 10px #ef4444; }
        .life-icon.lost { opacity: 0.2; filter: grayscale(1); }

        #overlay {
            position: absolute; inset: 0; background: rgba(5,0,20,0.95);
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            z-index: 100; text-align: center; border-radius: 20px;
        }
        .btn-start {
            padding: 15px 40px; background: var(--purple); border: none; border-radius: 50px;
            color: white; font-family: 'Orbitron'; font-weight: 900; font-size: 22px; cursor: pointer;
            box-shadow: 0 0 30px var(--purple); transition: 0.3s; margin-top: 20px;
        }
        .btn-start:hover { transform: scale(1.05); box-shadow: 0 0 50px var(--purple); }

        .back-link { position: absolute; bottom: 20px; right: 20px; color: rgba(255,255,255,0.4); text-decoration: none; font-size: 12px; font-family: 'Orbitron'; z-index: 10; }
        .back-link:hover { color: white; }

        .cosmo-bar {
            height: 4px; background: rgba(255,255,255,0.1); border-radius: 2px; overflow: hidden; margin-top: 5px;
        }
        .cosmo-fill { height: 100%; background: linear-gradient(90deg, var(--purple), var(--neon)); width: 100%; transition: 0.5s; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" EnablePageMethods="true" />
        
        <div id="gameContainer">
            <div id="overlay">
                <h1 style="font-family:'Orbitron'; font-size:48px; margin-bottom:10px;">SAINT <span style="color:var(--purple)">SEIYA</span></h1>
                <p style="color:var(--neon); letter-spacing:3px;">EL JUEGO DEL AHORCADO</p>
                <div style="margin: 20px 0; font-size: 14px; opacity: 0.7;">
                    2 RONDAS &bull; 5 VIDAS &bull; PUNTOS ACUMULABLES<br>
                    ELEVA TU COSMOS HASTA EL S&Eacute;PTIMO SENTIDO
                </div>
                <div style="display:flex; gap:15px; margin-top:20px;">
                    <button type="button" class="btn-start" onclick="startGame()">¡ELEVAR COSMOS!</button>
                    <a href="DashboardUsuario.aspx" class="btn-start" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.2); text-decoration:none; display:flex; align-items:center; justify-content:center;">VOLVER</a>
                </div>
            </div>

            <div class="drawing-side">
                <!-- HORCA -->
                <div class="gallows">
                    <div class="base"></div>
                    <div class="pole"></div>
                    <div class="top-bar"></div>
                    <div class="rope"></div>
                </div>

                <div class="seiya-container">
                    <img src="seiya_character_1778723826091.png" class="seiya-base" />
                    <div id="part1" class="seiya-part" style="clip-path: inset(0 0 80% 0);"></div>
                    <div id="part2" class="seiya-part" style="clip-path: inset(20% 0 50% 0);"></div>
                    <div id="part3" class="seiya-part" style="clip-path: inset(50% 50% 20% 0);"></div>
                    <div id="part4" class="seiya-part" style="clip-path: inset(50% 0 20% 50%);"></div>
                    <div id="part5" class="seiya-part" style="clip-path: inset(80% 0 0 0);"></div>
                </div>
            </div>

            <div class="game-side">
                <div class="header">
                    <div>RONDA: <span id="roundNum" class="stat">1/2</span></div>
                    <div>PUNTOS: <span id="gameScore" class="stat">0</span></div>
                    <div>TOTAL: <asp:Label ID="lblPuntos" runat="server" Text="0" CssClass="stat"></asp:Label></div>
                </div>

                <div class="word-container" id="wordDisplay"></div>

                <div>
                    <div class="keyboard" id="keyboard"></div>
                    <div class="lives-container" id="livesDisplay"></div>
                    <div class="cosmo-bar"><div id="cosmoFill" class="cosmo-fill"></div></div>
                </div>
            </div>

            <a href="DashboardUsuario.aspx" class="back-link">ABORTAR MISIÓN</a>
        </div>

        <audio id="bgMusic" loop>
            <source src="https://archive.org/download/tvtunes_22041/Saint%20Seiya%20-%20Opening%201%20-%20Pegasus%20Fantasy.mp3" type="audio/mpeg">
        </audio>
    </form>

    <script>
        // @ts-nocheck
        const words = ["SEIYA", "SHIRYU", "HYOGA", "SHUN", "IKKI", "SAORI", "PEGASO", "DRAGON", "CISNE", "ANDROMEDA", "FENIX", "METEORO", "COSMOS", "SANTUARIO", "ATENA", "DORADO", "PLATA", "BRONCE"];
        let currentWord = "";
        let guessedLetters = [];
        let lives = 5;
        let score = 0;
        let round = 1;
        let gameActive = false;

        function startGame() {
            const overlay = document.getElementById('overlay');
            if (overlay) overlay.style.display = 'none';
            
            const music = document.getElementById('bgMusic');
            if (music && typeof music.play === 'function') {
                music.play().catch(e => console.log("Audio play deferred:", e));
            }
            
            gameActive = true;
            nextWord();
        }

        function nextWord() {
            currentWord = words[Math.floor(Math.random() * words.length)];
            guessedLetters = [];
            lives = 5;
            updateUI();
            renderKeyboard();
            renderWord();
            
            // Reset Seiya parts
            document.querySelectorAll('.seiya-part').forEach(p => p.classList.remove('show'));
        }

        function renderWord() {
            const container = document.getElementById('wordDisplay');
            if (!container) return;
            container.innerHTML = '';
            currentWord.split('').forEach(letter => {
                const slot = document.createElement('div');
                slot.className = 'letter-slot';
                slot.textContent = guessedLetters.includes(letter) ? letter : '';
                container.appendChild(slot);
            });
        }

        function renderKeyboard() {
            const container = document.getElementById('keyboard');
            if (!container) return;
            container.innerHTML = '';
            const alphabet = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
            alphabet.split('').forEach(char => {
                const btn = document.createElement('button');
                btn.className = 'key';
                btn.textContent = char;
                btn.onclick = () => handleGuess(char, btn);
                container.appendChild(btn);
            });
        }

        function handleGuess(char, btn) {
            if (!gameActive || guessedLetters.includes(char)) return;
            
            guessedLetters.push(char);
            btn.disabled = true;

            if (currentWord.includes(char)) {
                btn.classList.add('hit');
                renderWord();
                checkWin();
            } else {
                btn.classList.add('miss');
                lives--;
                document.getElementById(`part${5 - lives}`).classList.add('show');
                updateUI();
                checkLose();
            }
        }

        function updateUI() {
            const rn = document.getElementById('roundNum');
            if (rn) rn.textContent = round + "/2";
            
            const gs = document.getElementById('gameScore');
            if (gs) gs.textContent = score.toString();
            
            const livesCont = document.getElementById('livesDisplay');
            if (!livesCont) return;
            
            livesCont.innerHTML = '';
            for(let i=0; i<5; i++) {
                const icon = document.createElement('i');
                icon.className = `fas fa-heart life-icon ${i >= lives ? 'lost' : ''}`;
                livesCont.appendChild(icon);
            }

            const cf = document.getElementById('cosmoFill');
            if (cf) cf.style.width = (lives * 20) + '%';
        }

        function checkWin() {
            const won = currentWord.split('').every(l => guessedLetters.includes(l));
            if (won) {
                score += (lives * 20) + 100;
                updateUI();
                if (round < 2) {
                    round++;
                    const mySwal = window.Swal || { fire: (opt) => { alert(opt.title + ": " + opt.text); return Promise.resolve(); } };
                    mySwal.fire({
                        title: '\u00A1SANTUARIO SUPERADO!',
                        html: `<div style="color:#fff">Has adivinado "<b>${currentWord}</b>".<br>\u00A1Siguiente ronda!</div>`,
                        icon: 'success',
                        background: '#050014', color: '#fff', confirmButtonColor: '#7F77DD'
                    }).then(nextWord);
                } else {
                    finishGame(true);
                }
            }
        }

        function checkLose() {
            if (lives <= 0) {
                finishGame(false);
            }
        }

        function finishGame(win) {
            gameActive = false;
            const mySwal = window.Swal || { fire: (opt) => { alert(opt.title + ": " + opt.text); return Promise.resolve(); } };

            if (win) {
                mySwal.fire({
                    title: '\u00A1CABALLERO LEGENDARIO!',
                    html: `<div style="color:#fff">Has protegido a Atena.<br>Cr&eacute;ditos ganados: <b>${score}</b></div>`,
                    imageUrl: 'seiya_character_1778723826091.png',
                    imageWidth: 200,
                    background: '#050014', color: '#fff',
                    confirmButtonText: 'GUARDAR Y SALIR',
                    confirmButtonColor: '#7F77DD'
                }).then(savePoints);
            } else {
                // Si perdió pero tiene puntos (pasó al menos la ronda 1), los guardamos
                if (score > 0) {
                    mySwal.fire({
                        title: 'COSMOS AGOTADO',
                        html: `<div style="color:#fff">La palabra era "<b>${currentWord}</b>".<br>Has ca&iacute;do, pero salvaremos tus cr&eacute;ditos: <b>${score}</b></div>`,
                        icon: 'warning',
                        background: '#050014', color: '#fff',
                        confirmButtonText: 'GUARDAR PUNTOS Y SALIR',
                        confirmButtonColor: '#7F77DD'
                    }).then(savePoints);
                } else {
                    mySwal.fire({
                        title: 'COSMOS AGOTADO',
                        html: `<div style="color:#fff">La palabra era "<b>${currentWord}</b>".<br>Has ca&iacute;do en batalla sin cr&eacute;ditos.</div>`,
                        icon: 'error',
                        background: '#050014', color: '#fff',
                        confirmButtonText: 'REINTENTAR',
                        confirmButtonColor: '#ef4444'
                    }).then(() => location.reload());
                }
            }
        }

        function savePoints() {
            if (window.PageMethods) {
                window.PageMethods.GuardarPuntos(score, (res) => {
                    window.location.href = 'DashboardUsuario.aspx';
                }, (err) => {
                    console.error(err);
                    window.location.href = 'DashboardUsuario.aspx';
                });
            } else {
                window.location.href = 'DashboardUsuario.aspx';
            }
        }
    </script>
</body>
</html>
