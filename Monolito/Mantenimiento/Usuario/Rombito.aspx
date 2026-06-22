<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Rombito.aspx.cs" Inherits="Monolito.Dashboard.Rombito" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Rombito Dinámico</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Outfit:wght@300;400;600&family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root { 
            --bg-dark: #05050b; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.7); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
        }
        body { 
            background: var(--bg-dark) url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; 
            font-family: 'Outfit', sans-serif; 
            color: white; 
            min-height: 100vh;
            display: flex; 
            align-items: center; 
            justify-content: center; 
            padding: 20px; 
            margin: 0;
        }
        body::before { 
            content: ''; 
            position: fixed; 
            inset: 0; 
            background: radial-gradient(circle at center, rgba(13, 10, 36, 0.85) 0%, rgba(5, 5, 11, 0.96) 100%); 
            z-index: -1; 
        }
        
        /* --- ANIMACIÓN DE CALAVERAS --- */
        .skull-rain { 
            position: fixed; 
            inset: 0; 
            pointer-events: none; 
            z-index: 1; 
        }
        .falling-skull {
            position: absolute; 
            color: rgba(0, 242, 255, 0.08);
            font-size: 20px; 
            animation: skullFall linear infinite;
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.3);
        }
        @keyframes skullFall {
            0% { transform: translateY(-50px) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(110vh) rotate(360deg); opacity: 0; }
        }

        .rombito-card { 
            position: relative; 
            z-index: 2;
            background: var(--glass); 
            backdrop-filter: blur(25px); 
            border: 1px solid var(--glass-border);
            border-radius: 24px; 
            padding: 40px; 
            width: 100%; 
            max-width: 900px; 
            box-sizing: border-box;
            box-shadow: var(--neon-shadow), inset 0 0 20px rgba(255,255,255,0.02);
            display: flex;
            flex-direction: column;
            gap: 30px;
        }
        .header { 
            text-align: center; 
            border-bottom: 1px solid rgba(0, 242, 255, 0.15);
            padding-bottom: 20px;
        }
        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 28px; 
            font-weight: 900;
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 4px; 
            text-transform: uppercase; 
            margin: 0; 
            filter: drop-shadow(0 0 10px rgba(0,242,255,0.3));
        }
        .header p {
            color: #b0b0d0;
            opacity: 0.8; 
            font-size: 12px; 
            letter-spacing: 2px; 
            margin-top: 10px;
            text-transform: uppercase;
        }

        .control-panel {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            align-items: flex-end;
            justify-content: center;
        }
        .input-group {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .input-group label { 
            font-size: 11px; 
            color: var(--accent); 
            text-transform: uppercase; 
            letter-spacing: 2px; 
            font-weight: 700; 
            text-shadow: 0 0 5px rgba(0, 242, 255, 0.4);
        }
        .pro-input { 
            background: rgba(0,0,0,0.4); 
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 12px; 
            padding: 14px; 
            color: white; 
            outline: none; 
            transition: all 0.3s ease;
            font-family: 'Outfit'; 
            font-size: 15px;
            width: 220px;
            text-align: center;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .pro-input:focus { 
            border-color: var(--accent); 
            background: rgba(0, 242, 255, 0.05); 
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5); 
        }

        .btn-generate { 
            padding: 14px 32px;
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            border: none; 
            border-radius: 12px; 
            color: white; 
            font-weight: 800; 
            font-family: 'Orbitron';
            cursor: pointer; 
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); 
            letter-spacing: 2px; 
            font-size: 13px;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .btn-generate i {
            font-size: 14px;
        }
        .btn-generate:hover { 
            transform: translateY(-3px); 
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5); 
            filter: brightness(1.1);
        }

        /* --- VISUALIZADOR DEL ROMBO --- */
        .viewer-container {
            background: #020205;
            border: 1px solid rgba(0, 242, 255, 0.3);
            border-radius: 16px;
            padding: 0;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.8), inset 0 0 30px rgba(0, 242, 255, 0.05);
            min-height: 200px;
        }

        /* Terminal Window Header */
        .terminal-header {
            background: #0b0b14;
            border-bottom: 1px solid rgba(0, 242, 255, 0.15);
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .terminal-header .dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
        }
        .terminal-header .dot.red { background: #ff5f56; }
        .terminal-header .dot.yellow { background: #ffbd2e; }
        .terminal-header .dot.green { background: #27c93f; }
        .terminal-header .terminal-title {
            margin-left: 10px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: rgba(0, 242, 255, 0.6);
            letter-spacing: 1.5px;
        }

        .diamond-display-wrapper {
            padding: 30px;
            overflow-x: auto;
            display: flex;
            width: 100%;
            box-sizing: border-box;
        }

        .diamond-display {
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 15px;
            line-height: 1.25;
            color: #00f2ff;
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.8), 0 0 2px rgba(0, 242, 255, 0.3);
            margin: 0;
            white-space: pre;
        }

        .btn-back { 
            display: inline-flex; 
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-align: center; 
            color: rgba(255, 255, 255, 0.5); 
            text-decoration: none; 
            font-size: 13px; 
            letter-spacing: 1px; 
            transition: all 0.3s ease;
            width: fit-content;
            margin: 0 auto;
        }
        .btn-back:hover {
            color: var(--accent);
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.6);
            transform: translateX(-3px);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="rombito-card">
            <div class="header">
                <h1>Rombito Din&aacute;mico Conc&eacute;ntrico</h1>
                <p>Generador Hologr&aacute;fico Vectorial &bull; NovaX Engine</p>
            </div>

            <div class="control-panel">
                <div class="input-group">
                    <label for="txtNumero">Tama&ntilde;o del Rombo</label>
                    <input type="number" id="txtNumero" class="pro-input" placeholder="Ej. 19 o 20" />
                </div>
                <button type="button" class="btn-generate" onclick="generateAndAnimate()"><i class="fas fa-microchip"></i> GENERAR ROMBO</button>
            </div>

            <div class="viewer-container" id="divViewer" style="display:none;">
                <div class="terminal-header">
                    <span class="dot red"></span>
                    <span class="dot yellow"></span>
                    <span class="dot green"></span>
                    <span class="terminal-title">NOVAX_DIAMOND_MATRIX_OUTPUT</span>
                </div>
                <div class="diamond-display-wrapper" id="divDisplayWrapper">
                    <pre id="preDiamond" class="diamond-display"></pre>
                </div>
            </div>

            <a href="DashboardUsuario.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD</a>
        </div>
    </form>
 
    <script>
        // @ts-nocheck
        let animationTimer = null;

        function initSkulls() {
            const rain = document.getElementById('skullRain');
            if (!rain) return;
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

        function mostrarError(mensaje) {
            const mySwal = window.Swal || { fire: function(opt) { alert(opt.text); } };
            mySwal.fire({
                title: 'Error de Validación',
                text: mensaje,
                icon: 'error',
                background: '#07070f',
                confirmButtonColor: '#7F77DD'
            });
        }

        function generateAndAnimate() {
            if (animationTimer) {
                clearInterval(animationTimer);
                animationTimer = null;
            }

            const inputEl = document.getElementById('txtNumero');
            const viewerContainer = document.getElementById('divViewer');
            const displayWrapper = document.getElementById('divDisplayWrapper');
            const preElement = document.getElementById('preDiamond');

            if (!inputEl || !viewerContainer || !preElement || !displayWrapper) return;

            let valStr = inputEl.value.trim();
            if (!valStr) {
                mostrarError("Por favor ingrese un número.");
                return;
            }

            let num = parseInt(valStr, 10);
            if (isNaN(num)) {
                mostrarError("Por favor ingrese un número válido.");
                return;
            }

            let originalNum = num;
            let esNegativo = num < 0;
            let absNum = Math.abs(num);

            if (absNum <= 3) {
                mostrarError("El tamaño del rombo debe ser mayor a 3.");
                return;
            }

            const proceedWithGeneration = () => {
                viewerContainer.style.display = 'flex';
                
                // Alineación del contenido del wrapper:
                // Si es par: alinear a la izquierda (flex-start)
                // Si es impar: alinear a la derecha (flex-end)
                if (absNum % 2 === 0) {
                    displayWrapper.style.justifyContent = 'flex-start';
                } else {
                    displayWrapper.style.justifyContent = 'flex-end';
                }

                preElement.textContent = '';

                // Build diamond lines
                const lines = buildDiamondLines(absNum);
                let currentLine = 0;

                animationTimer = setInterval(() => {
                    if (currentLine < lines.length) {
                        preElement.textContent += lines[currentLine] + '\n';
                        currentLine++;
                        viewerContainer.scrollTop = viewerContainer.scrollHeight;
                    } else {
                        clearInterval(animationTimer);
                        animationTimer = null;
                    }
                }, 40);
            };

            if (esNegativo) {
                const mySwal = window.Swal || { fire: function(opt) { alert(opt.text); } };
                mySwal.fire({
                    title: 'Número Negativo Detectado',
                    text: `Se convertirá el valor ${originalNum} a su valor absoluto ${absNum}.`,
                    icon: 'warning',
                    background: '#07070f',
                    confirmButtonColor: '#00f2ff',
                    confirmButtonText: 'Aceptar'
                }).then(() => {
                    proceedWithGeneration();
                });
            } else {
                proceedWithGeneration();
            }
        }

        function buildDiamondLines(n) {
            let tamano = n;
            let dimensionesMatriz = tamano * 2 - 1;
            
            // Inicializamos toda la matriz con espacios vacíos
            let matriz = Array.from({ length: dimensionesMatriz }, () => Array(dimensionesMatriz).fill(' '));

            // --- ALGORITMO VECTORIAL OPTIMIZADO PARA EL CENTRO ---
            // Configuración por defecto para IMPARES
            let f = tamano - 1;
            let c = dimensionesMatriz - 1;
            let dir = 1;

            // Vectores de movimiento (0: Abajo-Der, 1: Abajo-Izq, 2: Arriba-Izq, 3: Arriba-Der)
            let df = [ 1, 1, -1, -1 ];
            let dc = [ 1, -1, -1, 1 ];

            // === INVERSIÓN DE SENTIDO PARA NÚMEROS PARES ===
            if (tamano % 2 === 0)
            {
                // Cambiamos el orden de las columnas para que la espiral camine al revés (en espejo)
                dc = [ -1, 1, 1, -1 ];
                c = 0;
                dir = 1;
            }

            // El bucle correrá de forma segura basándose en los límites de la espiral
            while (true)
            {
                matriz[f][c] = '*';

                // 1. Calculamos el siguiente paso inmediato
                let sigF = f + df[dir];
                let sigC = c + dc[dir];

                // 2. Evaluamos si es necesario cambiar de dirección o frenar
                let debeGirar = false;

                if (sigF < 0 || sigF >= dimensionesMatriz || sigC < 0 || sigC >= dimensionesMatriz)
                {
                    debeGirar = true;
                }
                else
                {
                    let f2 = sigF + df[dir];
                    let c2 = sigC + dc[dir];

                    if (f2 >= 0 && f2 < dimensionesMatriz && c2 >= 0 && c2 < dimensionesMatriz && matriz[f2][c2] === '*')
                    {
                        debeGirar = true;
                    }

                    let dirSiguiente = (dir + 1) % 4;
                    let ladoF = sigF + df[dirSiguiente];
                    let ladoC = sigC + dc[dirSiguiente];

                    if (ladoF >= 0 && ladoF < dimensionesMatriz && ladoC >= 0 && ladoC < dimensionesMatriz && matriz[ladoF][ladoC] === '*')
                    {
                        // Condición original del núcleo
                        let enElNucleo = sigF >= tamano - 2 && sigF <= tamano && sigC >= tamano - 2 && sigC <= tamano;

                        if (!(sigF === tamano - 1 && sigC === tamano - 1) && !enElNucleo)
                        {
                            debeGirar = true;
                        }
                    }
                }

                if (debeGirar)
                {
                    dir = (dir + 1) % 4;
                    sigF = f + df[dir];
                    sigC = c + dc[dir];
                }

                // --- DETECTOR DIAGONAL ORIGINAL ---
                if (tamano % 2 !== 0)
                {
                    let diagonalFrenadoF = sigF + df[dir];
                    let diagonalFrenadoC = sigC + dc[dir];

                    if (diagonalFrenadoF >= 0 && diagonalFrenadoF < dimensionesMatriz &&
                        diagonalFrenadoC >= 0 && diagonalFrenadoC < dimensionesMatriz)
                    {
                        if (matriz[diagonalFrenadoF][diagonalFrenadoC] === '*' && sigF >= tamano - 3 && sigF <= tamano + 1)
                        {
                            break;
                        }
                    }
                }
                else
                {
                    // === FRENO DE ULTRA PRECISIÓN PARA EL PAR ===
                    let fAvance = sigF + df[dir];
                    let cAvance = sigC + dc[dir];
                    if (fAvance >= 0 && fAvance < dimensionesMatriz && cAvance >= 0 && cAvance < dimensionesMatriz)
                    {
                        if (matriz[fAvance][cAvance] === '*' && sigF >= tamano - 2 && sigF <= tamano + 2)
                        {
                            break;
                        }
                    }
                }

                // Condición de parada estándar de seguridad
                if (sigF < 0 || sigF >= dimensionesMatriz || sigC < 0 || sigC >= dimensionesMatriz || matriz[sigF][sigC] === '*')
                {
                    break;
                }

                f = sigF;
                c = sigC;
            }

            // === IMPRESIÓN DEL MARCO ===
            const lines = [];
            let anchoMarco = (tamano * 4) - 3;

            // Línea superior (Unicode)
            lines.push("\u2554" + "\u2550".repeat(anchoMarco) + "\u2557");

            for (let i = 0; i < dimensionesMatriz; i++)
            {
                let rowLine = "\u2551";

                let elementosEnFila = (i < tamano) ? (i + 1) : (dimensionesMatriz - i);
                let espaciosIzquierda = (tamano - elementosEnFila) * 2;
                rowLine += " ".repeat(espaciosIzquierda);

                for (let j = 0; j < elementosEnFila; j++)
                {
                    let columnaMatriz = (tamano - elementosEnFila) + (j * 2);
                    rowLine += matriz[i][columnaMatriz];

                    if (j < elementosEnFila - 1)
                        rowLine += "   ";
                }

                let usados = espaciosIzquierda + elementosEnFila + (elementosEnFila - 1) * 3;
                rowLine += " ".repeat(anchoMarco - usados);
                rowLine += "\u2551";
                lines.push(rowLine);
            }

            // Línea inferior (Unicode)
            lines.push("\u255a" + "\u2550".repeat(anchoMarco) + "\u255d");

            return lines;
        }
    </script>
</body>
</html>
