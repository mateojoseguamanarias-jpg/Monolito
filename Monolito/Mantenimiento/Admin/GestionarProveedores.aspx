<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionarProveedores.aspx.cs" Inherits="Monolito.Dashboard.GestionarProveedores" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaX | Gestión de Proveedores</title>
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

        .header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 30px; 
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .header h1 { 
            font-family: 'Orbitron'; 
            font-size: 26px; 
            letter-spacing: 2px; 
            background: linear-gradient(45deg, #00f2ff, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 0;
            filter: drop-shadow(0 0 8px rgba(0,242,255,0.3));
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, #00f2ff, #7f00ff);
            color: white; 
            padding: 12px 24px; 
            border-radius: 12px; 
            border: none;
            cursor: pointer;
            font-family: 'Orbitron'; 
            font-size: 12px; 
            font-weight: 700; 
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 15px rgba(127, 0, 255, 0.4);
            transition: 0.3s;
        }
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 242, 255, 0.5);
            filter: brightness(1.1);
        }

        /* Grid View Custom Design */
        .grid-custom {
            width: 100% !important;
            border-collapse: collapse !important;
            border: none !important;
            margin-top: 15px;
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

        .status-badge { 
            padding: 5px 12px; 
            border-radius: 8px; 
            font-size: 10px; 
            font-weight: 800; 
            border: 1px solid transparent; 
            display: inline-block;
            font-family: 'Orbitron';
        }
        .status-A { background: rgba(34, 197, 94, 0.1); color: #4ade80; border-color: #4ade80; }
        .status-I { background: rgba(239, 68, 68, 0.1); color: #f87171; border-color: #f87171; }

        .btn-action { 
            background: none; 
            border: none; 
            color: white; 
            cursor: pointer; 
            font-size: 18px; 
            transition: 0.3s; 
        }
        .btn-action:hover { 
            transform: scale(1.2); 
            color: var(--accent); 
        }

        /* Modales / Formularios de edición */
        .editor-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            width: 90%;
            max-width: 500px;
            background: rgba(8, 5, 25, 0.96);
            backdrop-filter: blur(25px);
            border: 2px solid var(--accent);
            border-radius: 24px;
            padding: 35px;
            box-shadow: 0 0 50px rgba(0, 242, 255, 0.4);
            animation: modalFadeIn 0.3s ease-out;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translate(-50%, -45%); }
            to { opacity: 1; transform: translate(-50%, -50%); }
        }

        /* Modal Overlay Backdrop */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
            z-index: 999;
            animation: fadeIn 0.2s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .editor-title {
            font-family: 'Orbitron';
            font-size: 16px;
            color: var(--accent);
            margin-bottom: 20px;
            border-bottom: 1px solid var(--glass-border);
            padding-bottom: 10px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 20px;
        }
        .form-group label {
            font-size: 12px;
            color: rgba(255,255,255,0.7);
            font-weight: 600;
        }

        .form-control-custom {
            background: rgba(0,0,0,0.4);
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 10px;
            color: white;
            padding: 12px 15px;
            font-size: 14px;
            transition: 0.3s;
            width: 100%;
            box-sizing: border-box;
            font-family: 'Outfit';
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .form-control-custom:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 15px rgba(0, 242, 255, 0.2), inset 0 0 10px rgba(0,0,0,0.5);
            background: rgba(0,0,0,0.5);
        }

        .button-bar {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
        }

        .btn-cancel {
            background: rgba(255,255,255,0.05);
            color: white;
            border: 1px solid var(--glass-border);
            border-radius: 10px;
            padding: 10px 20px;
            cursor: pointer;
            font-family: 'Outfit';
            transition: 0.3s;
        }
        .btn-cancel:hover {
            background: rgba(255,255,255,0.1);
        }

        .btn-submit {
            background: var(--accent);
            color: black;
            border: none;
            border-radius: 10px;
            padding: 10px 25px;
            cursor: pointer;
            font-family: 'Orbitron';
            font-weight: 700;
            box-shadow: 0 0 15px rgba(0,242,255,0.3);
            transition: 0.3s;
        }
        .btn-submit:hover {
            box-shadow: 0 0 25px rgba(0,242,255,0.6);
            transform: translateY(-1px);
        }

        /* Alert message box */
        .info-box {
            background: rgba(0, 242, 255, 0.05);
            border: 1px solid rgba(0, 242, 255, 0.2);
            border-radius: 16px;
            padding: 15px 20px;
            font-size: 13px;
            color: rgba(255,255,255,0.8);
            margin-bottom: 25px;
            display: flex;
            gap: 15px;
            align-items: center;
            line-height: 1.5;
            box-shadow: inset 0 0 15px rgba(0, 242, 255, 0.05);
        }
        .info-box i {
            font-size: 24px;
            color: var(--accent);
            text-shadow: 0 0 8px rgba(0, 242, 255, 0.5);
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="skullRain" class="skull-rain"></div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="container">
            <a href="DashboardAdmin.aspx" class="btn-back">
                <i class="fas fa-arrow-left"></i> VOLVER AL DASHBOARD
            </a>

            <div class="glass-card">
                <div class="header">
                    <h1>MANTENIMIENTO DE PROVEEDORES</h1>
                    <asp:LinkButton ID="btnNuevo" runat="server" OnClick="btnNuevo_Click" CssClass="btn-primary-custom">
                        <i class="fas fa-truck"></i> NUEVO PROVEEDOR
                    </asp:LinkButton>
                </div>

                <!-- Info Box para el requerimiento especial de reversión de borrado lógico -->
                <div class="info-box">
                    <i class="fas fa-circle-info"></i>
                    <div>
                        <strong>Proceso de Reversión Padre-Hijo (Requisito 7):</strong> Al inactivar un proveedor, todos sus productos se desvinculan temporalmente de forma automática. Al restaurar el proveedor, el sistema ejecutará un rollback recuperando la conexión original de cada producto.
                    </div>
                </div>

                <asp:UpdatePanel ID="upProveedores" runat="server">
                    <ContentTemplate>
                        <!-- GridView de proveedores -->
                        <asp:GridView ID="gvProveedores" runat="server" AutoGenerateColumns="False" 
                            DataKeyNames="prov_id" CssClass="grid-custom"
                            OnRowCommand="gvProveedores_RowCommand">
                            
                            <EmptyDataTemplate>
                                <div style="text-align:center; padding:30px; opacity:0.6;">
                                    <i class="fas fa-truck-loading" style="font-size:32px; margin-bottom:10px; color:var(--primary);"></i><br />
                                    No se encontraron proveedores registrados.
                                </div>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:BoundField DataField="prov_id" HeaderText="ID">
                                    <HeaderStyle Width="80px" />
                                    <ItemStyle Font-Bold="True" ForeColor="#00f2ff" />
                                </asp:BoundField>

                                <asp:BoundField DataField="prov_nombre" HeaderText="Nombre del Proveedor" />

                                <asp:TemplateField HeaderText="Estado">
                                    <ItemTemplate>
                                        <span class='status-badge status-<%# Eval("prov_estado") %>'>
                                            <%# Eval("prov_estado").ToString() == "A" ? "ACTIVO" : "INACTIVO" %>
                                        </span>
                                    </ItemTemplate>
                                    <HeaderStyle Width="120px" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Acciones">
                                    <ItemTemplate>
                                        <!-- Editar (solo activos) -->
                                        <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("prov_id") %>' 
                                            CssClass="btn-action" style="margin-right:15px; color:#4ade80;"
                                            Visible='<%# Eval("prov_estado").ToString() == "A" %>'>
                                            <i class="fas fa-edit"></i>
                                        </asp:LinkButton>
                                        
                                        <!-- Eliminar / Inactivar (solo activos) -->
                                        <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("prov_id") %>' 
                                            CssClass="btn-action" style="margin-right:15px; color:#f87171;" 
                                            Visible='<%# Eval("prov_estado").ToString() == "A" %>'
                                            OnClientClick="return confirm('¿Está seguro de inactivar este proveedor? Se desvincularán sus productos temporalmente.');">
                                            <i class="fas fa-user-slash"></i>
                                        </asp:LinkButton>

                                        <!-- Restaurar / Activar (solo inactivos) -->
                                        <asp:LinkButton ID="btnRestaurar" runat="server" CommandName="Restaurar" CommandArgument='<%# Eval("prov_id") %>' 
                                            CssClass="btn-action" style="color:#00f2ff;" 
                                            Visible='<%# Eval("prov_estado").ToString() == "I" %>'
                                            OnClientClick="return confirm('¿Restaurar este proveedor? Se recuperará automáticamente la relación con sus productos originales.');">
                                            <i class="fas fa-arrow-rotate-left"></i> RESTAURAR Y REVERTIR
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderStyle Width="220px" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:Panel ID="pnlBackdrop" runat="server" CssClass="modal-overlay" Visible="false" />

                        <!-- Panel de Formulario CRUD (Añadir / Editar) -->
                        <asp:Panel ID="pnlEditor" runat="server" CssClass="editor-panel" Visible="false">
                            <div class="editor-title">
                                <asp:Literal ID="litTituloEditor" runat="server">Agregar Nuevo Proveedor</asp:Literal>
                            </div>

                            <asp:HiddenField ID="hfProvId" runat="server" />

                            <div class="form-group">
                                <label>Nombre del Proveedor / Distribuidora</label>
                                <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control-custom" placeholder="Nombre comercial" />
                            </div>

                            <div class="button-bar">
                                <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" OnClick="btnCancelar_Click" CssClass="btn-cancel" />
                                <asp:Button ID="btnGuardar" runat="server" Text="Guardar" OnClick="btnGuardar_Click" CssClass="btn-submit" />
                            </div>
                        </asp:Panel>
                    </ContentTemplate>
                </asp:UpdatePanel>
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
