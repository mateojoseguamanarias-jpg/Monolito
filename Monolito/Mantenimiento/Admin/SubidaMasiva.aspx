<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubidaMasiva.aspx.cs" Inherits="Monolito.Dashboard.SubidaMasiva" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Subida Masiva de Productos</title>
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
            --error: #f87171;
            --success: #4ade80;
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
            max-width: 1000px; 
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
            margin: 0 0 20px 0;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }

        .upload-section {
            background: rgba(0,0,0,0.3);
            border: 1px dashed var(--glass-border);
            border-radius: 16px;
            padding: 30px;
            text-align: center;
            margin-bottom: 30px;
            transition: 0.3s;
        }
        .upload-section:hover {
            border-color: var(--accent);
            background: rgba(0, 242, 255, 0.02);
        }

        .upload-icon {
            font-size: 40px;
            color: var(--accent);
            margin-bottom: 15px;
            text-shadow: 0 0 10px rgba(0,242,255,0.3);
        }

        .form-control-custom {
            background: rgba(0,0,0,0.4);
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 10px;
            color: white;
            padding: 12px 15px;
            font-size: 14px;
            transition: 0.3s;
            max-width: 350px;
            margin: 0 auto 20px auto;
            box-sizing: border-box;
            display: block;
            font-family: 'Outfit';
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }

        .btn-custom {
            font-family: 'Orbitron';
            font-weight: 700;
            font-size: 12px;
            padding: 12px 25px;
            border-radius: 10px;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: 0.3s;
        }

        .btn-preview {
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: white;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
        }
        .btn-preview:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5);
            filter: brightness(1.1);
        }

        .btn-commit {
            background: var(--accent);
            color: black;
            box-shadow: 0 0 15px rgba(0,242,255,0.3);
        }
        .btn-commit:hover {
            box-shadow: 0 0 25px rgba(0,242,255,0.6);
            transform: translateY(-2px);
        }

        /* Format Helper Box */
        .format-helper {
            background: rgba(0,0,0,0.3);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 30px;
            font-size: 13px;
            color: rgba(255,255,255,0.8);
            box-shadow: inset 0 0 15px rgba(0, 242, 255, 0.05);
        }
        .format-helper h3 {
            font-family: 'Orbitron';
            color: var(--accent);
            margin-top: 0;
            font-size: 14px;
            margin-bottom: 12px;
        }
        .format-code {
            background: rgba(0,0,0,0.4);
            border-radius: 8px;
            padding: 10px 15px;
            font-family: 'Courier New', Courier, monospace;
            color: #ff9d00;
            margin-top: 8px;
            white-space: pre-line;
            border: 1px solid rgba(0, 242, 255, 0.2);
            box-shadow: inset 0 0 10px rgba(0,0,0,0.8);
        }

        /* Grid View Custom Design */
        .grid-custom {
            width: 100% !important;
            border-collapse: collapse !important;
            border: none !important;
            margin-top: 25px;
        }
        .grid-custom th {
            text-align: left; 
            padding: 15px !important; 
            color: var(--accent) !important; 
            font-size: 12px !important; 
            text-transform: uppercase; 
            border-bottom: 2px solid var(--glass-border) !important;
            background: rgba(0,0,0,0.2) !important;
            font-family: 'Orbitron';
        }
        .grid-custom td {
            padding: 15px !important; 
            border-bottom: 1px solid rgba(255,255,255,0.05) !important; 
            font-size: 14px !important;
            color: rgba(255,255,255,0.9);
            vertical-align: middle;
            background: transparent !important;
        }
        .grid-custom tr:hover td {
            background: rgba(0, 242, 255, 0.05) !important;
        }

        /* BOTÓN EXPORTAR / PLANTILLA */
        .btn-excel {
            font-family: 'Orbitron';
            font-weight: 700;
            font-size: 12px;
            padding: 12px 22px;
            border-radius: 10px;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: 0.3s;
            background: linear-gradient(135deg, #10b981, #047857);
            color: white;
            box-shadow: 0 0 15px rgba(16,185,129,0.35);
            text-decoration: none;
        }
        .btn-excel:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 28px rgba(16,185,129,0.6);
            color: white;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div id="skullRain" class="skull-rain"></div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="container">
            <a href="DashboardAdmin.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD
            </a>

            <div class="glass-card">
                <div class="header">
                    <h1>CARGA MASIVA DE PRODUCTOS (CSV)</h1>
                </div>

                <!-- Helper de formato CSV -->
                <div class="format-helper">
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:15px; flex-wrap:wrap;">
                        <div style="flex:1">
                            <h3><i class="fas fa-file-csv"></i> Formato de Carga Requerido</h3>
                            Su archivo plano (CSV) debe contener una línea de cabecera y el separador debe ser coma (,) o punto y coma (;). El formato es:
                            <div class="format-code">
                                Nombre,Cantidad,Precio,Categoria,Proveedor,Foto
                                Teclado Mecánico RGB Pro,80,65.90,Tecnología,Distribuidora Nova S.A.,teclado.png
                                Zapatos Running Speed,120,49.99,Ropa y Calzado,MegaImportaciones Cia. Ltda.,zapatos.png
                            </div>
                        </div>
                        <div style="flex-shrink:0; display:flex; align-items:center;">
                            <asp:LinkButton ID="btnDescargarPlantilla" runat="server" OnClick="btnDescargarPlantilla_Click" CssClass="btn-excel">
                                <i class="fas fa-file-arrow-down"></i> DESCARGAR PLANTILLA
                            </asp:LinkButton>
                        </div>
                    </div>
                    <small style="display:block; margin-top:8px; opacity:0.6;">
                        * Nota: Si la categoría o el proveedor no existen, se crearán automáticamente al procesar el archivo plano (Se poblarán ambas tablas). La columna "Foto" es opcional.
                    </small>
                </div>

                <!-- Formulario de Selección de Archivo -->
                <div class="upload-section">
                    <div class="upload-icon">
                        <i class="fas fa-cloud-arrow-up"></i>
                    </div>
                    <p style="font-size:16px; margin-bottom:20px;">Seleccione su archivo plano .csv o .txt</p>
                    <asp:FileUpload ID="fuArchivo" runat="server" CssClass="form-control-custom" />
                    
                    <asp:LinkButton ID="btnProcesar" runat="server" OnClick="btnProcesar_Click" CssClass="btn-custom btn-preview">
                        <i class="fas fa-eye"></i> PROCESAR Y PREVISUALIZAR
                    </asp:LinkButton>
                </div>

                <!-- Sección de Previsualización y Envío -->
                <asp:Panel ID="pnlPreview" runat="server" Visible="false">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--glass-border); padding-bottom:15px; margin-top:35px;">
                        <h3 style="font-family:'Orbitron'; color:var(--accent); margin:0;">
                            <i class="fas fa-table-list"></i> Previsualización de Datos a Subir
                        </h3>
                        
                        <asp:LinkButton ID="btnEnviar" runat="server" OnClick="btnEnviar_Click" CssClass="btn-custom btn-commit">
                            <i class="fas fa-circle-check"></i> CONFIRMAR Y SUBIR A BASE DE DATOS
                        </asp:LinkButton>
                    </div>

                    <asp:GridView ID="gvPreview" runat="server" AutoGenerateColumns="False" CssClass="grid-custom">
                        <EmptyDataTemplate>
                            <div style="text-align:center; padding:20px; opacity:0.6;">
                                No se encontraron filas procesables en el archivo.
                            </div>
                        </EmptyDataTemplate>
                        <Columns>
                            <asp:BoundField DataField="pro_nombre" HeaderText="Producto" />
                            
                            <asp:BoundField DataField="pro_cantidad" HeaderText="Cantidad">
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>

                            <asp:TemplateField HeaderText="Precio">
                                <ItemTemplate>
                                    $<%# Convert.ToDecimal(Eval("pro_precio")).ToString("N2") %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="cat_nombre" HeaderText="Categoría a Asignar/Crear" />
                            <asp:BoundField DataField="prov_nombre" HeaderText="Proveedor a Asignar/Crear" />
                            <asp:BoundField DataField="pro_ruta_foto" HeaderText="Ruta/Nombre de Foto" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>
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
