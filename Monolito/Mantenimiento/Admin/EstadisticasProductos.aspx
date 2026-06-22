<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EstadisticasProductos.aspx.cs" Inherits="Monolito.Dashboard.EstadisticasProductos" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Estadísticas y Visualización</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root { 
            --bg-dark: #05050b; 
            --primary: #9d4edd; 
            --accent: #00f2ff; 
            --glass: rgba(8, 8, 20, 0.75); 
            --glass-border: rgba(0, 242, 255, 0.25); 
            --neon-shadow: 0 0 35px rgba(0, 242, 255, 0.15);
            --accent-pink: #ff007f;
        }
        
        body { 
            background: var(--bg-dark) url('https://i.postimg.cc/7hxyKpgC/skulls.jpg') no-repeat center center fixed; 
            background-size: cover; 
            font-family: 'Outfit', sans-serif; 
            color: white; 
            min-height: 100vh; 
            padding: 40px 20px;
            margin: 0;
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

        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            position: relative;
            z-index: 2;
        }

        .btn-back { 
            text-decoration: none; 
            color: rgba(0,242,255,0.6); 
            font-size: 14px; 
            display: inline-flex; 
            align-items: center; 
            gap: 10px; 
            margin-bottom: 20px; 
            transition: 0.3s;
            font-family: 'Orbitron';
        }
        .btn-back:hover { 
            color: white; 
            transform: translateX(-5px);
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.6);
        }

        .glass-card { 
            background: var(--glass); 
            backdrop-filter: blur(20px); 
            border: 1px solid var(--glass-border); 
            border-radius: 24px; 
            padding: 30px; 
            box-shadow: var(--neon-shadow);
            margin-bottom: 30px;
        }

        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 26px; 
            letter-spacing: 2px; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 0 0 30px 0;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
            text-align: center;
        }

        /* 1. CAROUSEL REPEATER STYLING */
        .section-title {
            font-family: 'Orbitron';
            font-size: 18px;
            color: var(--accent);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid var(--glass-border);
            padding-bottom: 10px;
        }

        .carousel-wrapper {
            position: relative;
            margin-bottom: 50px;
            overflow: hidden;
            border-radius: 20px;
            padding: 10px 0;
        }

        .carousel-track {
            display: flex;
            gap: 20px;
            overflow-x: auto;
            scroll-behavior: smooth;
            padding: 10px 5px;
        }
        .carousel-track::-webkit-scrollbar {
            height: 8px;
        }
        .carousel-track::-webkit-scrollbar-track {
            background: rgba(255,255,255,0.01);
            border-radius: 10px;
        }
        .carousel-track::-webkit-scrollbar-thumb {
            background: var(--glass-border);
            border-radius: 10px;
        }
        .carousel-track::-webkit-scrollbar-thumb:hover {
            background: var(--primary);
        }

        .product-card {
            background: var(--glass);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            width: 220px;
            flex-shrink: 0;
            overflow: hidden;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            transition: 0.3s;
            position: relative;
        }
        .product-card:hover {
            transform: translateY(-5px);
            border-color: var(--accent);
            box-shadow: 0 8px 32px 0 rgba(0, 242, 255, 0.2);
            background: rgba(255, 255, 255, 0.04);
        }

        .card-img-wrapper {
            width: 100%;
            height: 160px;
            overflow: hidden;
            background: #000;
            position: relative;
        }
        .card-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: 0.5s;
        }
        .product-card:hover .card-img {
            transform: scale(1.1);
        }

        .card-content {
            padding: 15px;
        }

        .card-category {
            font-size: 10px;
            text-transform: uppercase;
            color: var(--accent);
            font-weight: 700;
            letter-spacing: 1px;
            margin-bottom: 5px;
            display: block;
        }

        .card-title {
            font-size: 14px;
            font-weight: 600;
            margin: 0 0 10px 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .card-footer-custom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid rgba(255,255,255,0.05);
            padding-top: 10px;
        }

        .card-price {
            font-family: 'Orbitron';
            color: var(--accent-pink);
            font-weight: 700;
            font-size: 14px;
        }

        .card-stock {
            font-size: 11px;
            color: rgba(255,255,255,0.6);
        }

        /* 2. CHARTS SECTION STYLING */
        .charts-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        @media (max-width: 850px) {
            .charts-container {
                grid-template-columns: 1fr;
            }
        }

        .chart-box {
            background: rgba(0,0,0,0.3);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 25px;
            box-shadow: inset 0 0 15px rgba(255,255,255,0.01);
            min-height: 320px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .chart-canvas-wrapper {
            position: relative;
            width: 100%;
            height: 250px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <div class="container">
            <a href="DashboardAdmin.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD
            </a>

            <div class="glass-card">
                <div class="header">
                    <h1>ESTAD&Iacute;STICAS Y CAT&Aacute;LOGO M&Oacute;VIL</h1>
                </div>

                <!-- SECCIÓN 1: CARRUSEL REPEATER (Requisito 6) -->
                <div class="section-title">
                    <i class="fas fa-images"></i> Carrusel de Productos Activos
                </div>

                <div class="carousel-wrapper">
                    <div class="carousel-track" id="carouselTrack">
                        <asp:Repeater ID="rptCarousel" runat="server">
                            <ItemTemplate>
                                <div class="product-card">
                                     <div class="card-img-wrapper">
                                         <img src='<%# ObtenerUrlImagen(Eval("pro_ruta_foto"), Eval("pro_nombre")) %>' class="card-img" alt="Foto Producto" />
                                     </div>
                                    <div class="card-content">
                                        <span class="card-category"><%# Eval("cat_nombre") %></span>
                                        <h3 class="card-title"><%# Eval("pro_nombre") %></h3>
                                        <div class="card-footer-custom">
                                            <span class="card-price">$<%# Convert.ToDecimal(Eval("pro_precio")).ToString("N2") %></span>
                                            <span class="card-stock"><i class="fas fa-boxes-stacked"></i> <%# Eval("pro_cantidad") %></span>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- SECCIÓN 2: CHARTS ESTADÍSTICOS (Requisito 6) -->
                <div class="section-title">
                    <i class="fas fa-chart-pie"></i> Análisis de Inventario
                </div>

                <div class="charts-container">
                    <!-- Gráfico 1: Categorías -->
                    <div class="chart-box">
                        <h4 style="font-family:'Orbitron'; font-size:14px; margin:0 0 20px 0; color:rgba(255,255,255,0.8); text-align:center;">
                            DISTRIBUCI&Oacute;N POR CATEGOR&Iacute;AS
                        </h4>
                        <div class="chart-canvas-wrapper">
                            <canvas id="chartCategorias"></canvas>
                        </div>
                    </div>

                    <!-- Gráfico 2: Stock Niveles -->
                    <div class="chart-box">
                        <h4 style="font-family:'Orbitron'; font-size:14px; margin:0 0 20px 0; color:rgba(255,255,255,0.8); text-align:center;">
                            NIVELES DE STOCK POR PRODUCTO (TOP 10)
                        </h4>
                        <div class="chart-canvas-wrapper">
                            <canvas id="chartStock"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Script de configuración de Chart.js -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // 1. Obtener y parsear los datos inyectados desde el servidor
            const labelCategorias = <%= ObtenerLabelCategorias() %>;
            const dataCategorias = <%= ObtenerDataCategorias() %>;

            const labelStock = <%= ObtenerLabelStock() %>;
            const dataStock = <%= ObtenerDataStock() %>;

            // 2. Renderizar Gráfico 1: Distribución por Categoría (Doughnut Chart)
            const ctxCat = document.getElementById('chartCategorias').getContext('2d');
            new Chart(ctxCat, {
                type: 'doughnut',
                data: {
                    labels: labelCategorias,
                    datasets: [{
                        data: dataCategorias,
                        backgroundColor: [
                            'rgba(127, 119, 221, 0.75)', // Primary color neon
                            'rgba(0, 242, 255, 0.75)',   // Accent cyan
                            'rgba(255, 0, 127, 0.75)',   // Pink neon
                            'rgba(74, 222, 128, 0.75)',   // Success green
                            'rgba(251, 191, 36, 0.75)'    // Orange/Yellow
                        ],
                        borderColor: '#07070f',
                        borderWidth: 2,
                        hoverOffset: 12
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                color: 'rgba(255,255,255,0.8)',
                                font: { family: 'Outfit', size: 11 }
                            }
                        }
                    }
                }
            });

            // 3. Renderizar Gráfico 2: Niveles de Stock por Producto (Bar Chart)
            const ctxStock = document.getElementById('chartStock').getContext('2d');
            new Chart(ctxStock, {
                type: 'bar',
                data: {
                    labels: labelStock,
                    datasets: [{
                        label: 'Unidades Disponibles',
                        data: dataStock,
                        backgroundColor: 'rgba(0, 242, 255, 0.4)',
                        borderColor: '#00f2ff',
                        borderWidth: 1.5,
                        borderRadius: 6,
                        hoverBackgroundColor: 'rgba(0, 242, 255, 0.7)'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            grid: {
                                color: 'rgba(255,255,255,0.05)'
                            },
                            ticks: {
                                color: 'rgba(255,255,255,0.6)',
                                font: { family: 'Outfit' }
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                color: 'rgba(255,255,255,0.6)',
                                font: { family: 'Outfit', size: 9 },
                                maxRotation: 45,
                                minRotation: 45
                            }
                        }
                    }
                }
            });

            // 4. Initialize Skull Rain Particles
            initSkulls();
        });

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
    </script>
</body>
</html>
