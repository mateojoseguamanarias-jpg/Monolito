/* 
   BASE DE DATOS: Monolito4to
   PROYECTO: NovaX PRO - Módulo de Seguridad y Mantenimiento de Productos/Proveedores
   DESCRIPCIÓN: Script completo de base de datos que incluye la creación de la base Monolito4to,
                todas las tablas de seguridad existentes, funciones de cifrado, las tablas
                de Proveedores, Categorías y Productos, y la tabla de fotos de productos
                para soporte del carrusel multidispositivo con rollback y rutas físicas.
*/

-- 1. CREACIÓN E INICIALIZACIÓN DE LA BASE DE DATOS
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Monolito4to')
BEGIN
    CREATE DATABASE Monolito4to;
END
GO

USE Monolito4to;
GO

-- 2. TABLA DE TIPOS DE USUARIO (ROLES)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_tipo_usuario' and xtype='U')
BEGIN
    CREATE TABLE tbl_tipo_usuario (
        tusu_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        tusu_nombre VARCHAR(50) NOT NULL,
        tusu_estado CHAR(1) DEFAULT 'A' -- A: Activo, I: Inactivo
    );
    -- Insertar roles por defecto
    INSERT INTO tbl_tipo_usuario (tusu_nombre, tusu_estado) VALUES ('Administrador', 'A'), ('Usuario', 'A');
END
GO

-- 3. TABLA DE USUARIOS
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_usuario' and xtype='U')
BEGIN
    CREATE TABLE tbl_usuario (
        usu_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        usu_cedula VARCHAR(10) NULL,
        usu_nombre VARCHAR(50) NOT NULL,
        usu_apellidos VARCHAR(50) NOT NULL,
        usu_direccion VARCHAR(250) NULL,
        usu_celular VARCHAR(15) NULL,
        usu_correo VARCHAR(150) NOT NULL UNIQUE,
        usu_fecha_creacion DATETIME DEFAULT GETDATE(),
        usu_fecha_cumple DATE NULL,
        usu_nick VARCHAR(50) NOT NULL UNIQUE,
        usu_contrasena VARBINARY(MAX) NOT NULL, -- Clave cifrada
        usu_intentos INT DEFAULT 0,
        usu_codigo_OTP VARCHAR(100) NULL,
        usu_otp_hash VARCHAR(500) NULL,
        usu_google_id VARCHAR(100) NULL,
        usu_facebook_id VARCHAR(100) NULL,
        usu_fecha_Ultimo DATETIME NULL,
        usu_puntos INT DEFAULT 0,
        usu_estado CHAR(1) DEFAULT 'A', -- A: Activo, B: Bloqueado, I: Inactivo, X: Eliminado
        tusu_id INT NOT NULL,
        CONSTRAINT FK_Usuario_Tipo FOREIGN KEY (tusu_id) REFERENCES tbl_tipo_usuario(tusu_id)
    );
END
GO

-- 4. TABLA DE FOTOS DE USUARIO (Soporta múltiples imágenes)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_usuario_fotos' and xtype='U')
BEGIN
    CREATE TABLE tbl_usuario_fotos (
        foto_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        usu_id INT NOT NULL,
        foto_data VARBINARY(MAX) NOT NULL, -- Imagen en binario
        foto_fecha DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Fotos_Usuario FOREIGN KEY (usu_id) REFERENCES tbl_usuario (usu_id)
    );
END
GO

-- 5. FUNCIONES DE ENCRIPTACIÓN Y DESENCRIPTACIÓN
IF OBJECT_ID('encriptacon', 'FN') IS NOT NULL  
    DROP FUNCTION encriptacon;  
GO
CREATE FUNCTION encriptacon
(
    @clave VARCHAR(50)
)
RETURNS VARBINARY(MAX)
AS
BEGIN
    DECLARE @pass VARBINARY(MAX)
    SET @pass = ENCRYPTBYPASSPHRASE('cl@ve', @clave)
    RETURN @pass
END;
GO

IF OBJECT_ID('desencriptacon', 'FN') IS NOT NULL  
    DROP FUNCTION desencriptacon;  
GO
CREATE FUNCTION desencriptacon
(
    @clave VARBINARY(MAX)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @pass VARCHAR(50)
    SET @pass = CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('cl@ve', @clave))
    RETURN @pass
END;
GO

-- 6. TABLA DE CATEGORÍAS (Para filtrado rápido estilo Facebook)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_categoria' and xtype='U')
BEGIN
    CREATE TABLE tbl_categoria
    (
        cat_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        cat_nombre VARCHAR(50) NOT NULL,
        cat_estado CHAR(1) DEFAULT 'A' -- A: Activo, I: Inactivo
    );

    -- Insertar categorías semilla
    INSERT INTO tbl_categoria (cat_nombre, cat_estado) VALUES 
    ('Tecnología', 'A'),
    ('Ropa y Calzado', 'A'),
    ('Alimentos y Bebidas', 'A'),
    ('Hogar y Cocina', 'A'),
    ('Deportes', 'A');
END
GO

-- 7. TABLA DE PROVEEDORES (Tabla Padre)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_proveedor' and xtype='U')
BEGIN
    CREATE TABLE tbl_proveedor
    (
        prov_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        prov_nombre VARCHAR(50) NOT NULL,
        prov_estado CHAR(1) DEFAULT 'A' -- A: Activo, I: Inactivo (Borrado lógico)
    );

    -- Insertar proveedores semilla
    INSERT INTO tbl_proveedor (prov_nombre, prov_estado) VALUES 
    ('Distribuidora Nova S.A.', 'A'),
    ('MegaImportaciones Cia. Ltda.', 'A'),
    ('Alimentos del Campo S.A.', 'A'),
    ('Textiles del Pacífico', 'A');
END
GO

-- 8. TABLA DE PRODUCTOS (Tabla Hijo)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_producto' and xtype='U')
BEGIN
    CREATE TABLE tbl_producto
    (
        pro_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        pro_nombre VARCHAR(100) NOT NULL,
        pro_cantidad INT NOT NULL DEFAULT 0,
        pro_precio DECIMAL(18,2) NOT NULL DEFAULT 0.00,
        pro_estado CHAR(1) DEFAULT 'A', -- A: Activo, I: Inactivo (Borrado lógico)
        prov_id INT NULL, -- Permite NULL si el proveedor se elimina
        pro_ruta_foto VARCHAR(250) NULL, -- Guarda el path virtual de la imagen (ej: ~/wwwroot/imagen/teclado.jpg)
        cat_id INT NULL, -- Categoría para filtrados rápidos
        pro_prev_prov_id INT NULL, -- Guarda el prov_id anterior por si se borra el proveedor

        CONSTRAINT FK_Producto_Proveedor FOREIGN KEY (prov_id) REFERENCES tbl_proveedor(prov_id),
        CONSTRAINT FK_Producto_Categoria FOREIGN KEY (cat_id) REFERENCES tbl_categoria(cat_id)
    );

    -- Insertar productos semilla apuntando directamente a la carpeta física de imágenes
    INSERT INTO tbl_producto (pro_nombre, pro_cantidad, pro_precio, pro_estado, prov_id, pro_ruta_foto, cat_id) VALUES
    ('Smartphone X100 Pro', 50, 499.99, 'A', 1, '~/wwwroot/imagen/smartphone.jpg', 1),
    ('Teclado Mecánico RGB', 120, 75.50, 'A', 1, '~/wwwroot/imagen/teclado.jpg', 1),
    ('Camiseta Deportiva Algodón', 200, 19.99, 'A', 4, '~/wwwroot/imagen/camiseta.jpg', 2),
    ('Aceite de Girasol 1L', 80, 3.25, 'A', 3, '~/wwwroot/imagen/aceite.jpg', 3),
    ('Juego de Vajilla de Cerámica (18pcs)', 30, 45.00, 'A', 2, '~/wwwroot/imagen/vajilla.jpg', 4);
END
GO

-- 9. TABLA DE FOTOS DE PRODUCTOS (Para Carrusel / Soporte multi-imagen)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_producto_fotos' AND xtype='U')
BEGIN
    CREATE TABLE tbl_producto_fotos (
        pfot_id      INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        pro_id       INT NOT NULL,
        pfot_ruta_foto VARCHAR(500) NOT NULL,
        pfot_fecha   DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Foto_Producto FOREIGN KEY (pro_id) REFERENCES tbl_producto(pro_id)
    );
END
GO

-- Sembrar fotos de carrusel iniciales basadas en el producto base
INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
SELECT pro_id, pro_ruta_foto
FROM tbl_producto
WHERE pro_estado = 'A'
  AND pro_ruta_foto IS NOT NULL
  AND pro_ruta_foto <> ''
  AND pro_id NOT IN (SELECT DISTINCT pro_id FROM tbl_producto_fotos);
GO

-- 10. SEMBRADO ADICIONAL SEGURO (EN CASO DE TABLAS EXISTENTES VACÍAS)
IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario)
BEGIN
    SET IDENTITY_INSERT tbl_tipo_usuario ON;
    INSERT INTO tbl_tipo_usuario (tusu_id, tusu_nombre, tusu_estado) VALUES 
    (1, 'Administrador', 'A'), 
    (2, 'Usuario', 'A');
    SET IDENTITY_INSERT tbl_tipo_usuario OFF;
END
GO

-- Sembrar Administrador por defecto si la tabla de usuarios está vacía
IF NOT EXISTS (SELECT 1 FROM tbl_usuario)
BEGIN
    DECLARE @AdminRoleId INT;
    SELECT @AdminRoleId = tusu_id FROM tbl_tipo_usuario WHERE tusu_nombre = 'Administrador';
    
    INSERT INTO tbl_usuario (
        usu_cedula, usu_nombre, usu_apellidos, usu_direccion, usu_celular, 
        usu_correo, usu_nick, usu_contrasena, tusu_id, usu_estado
    ) VALUES (
        '1712345678', 'Admin', 'Sistema', 'Quito', '0999999999',
        'admin@novax.com', 'admin', dbo.encriptacon('admin123'), @AdminRoleId, 'A'
    );
END
GO

-- 11. TRIGGER PARA OBLIGAR A TENER EXACTAMENTE UN ADMINISTRADOR ACTIVO
IF OBJECT_ID('trg_Enforce_Single_Admin', 'TR') IS NOT NULL
    DROP TRIGGER trg_Enforce_Single_Admin;
GO

CREATE TRIGGER trg_Enforce_Single_Admin
ON tbl_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdminRoleId INT;
    SELECT @AdminRoleId = tusu_id FROM tbl_tipo_usuario WHERE tusu_nombre = 'Administrador';

    IF @AdminRoleId IS NULL
        RETURN;

    -- Contar administradores activos (usu_estado = 'A')
    DECLARE @AdminCount INT;
    SELECT @AdminCount = COUNT(*) FROM tbl_usuario WHERE tusu_id = @AdminRoleId AND usu_estado = 'A';

    -- Contar usuarios totales activos (usu_estado = 'A')
    DECLARE @ActiveUserCount INT;
    SELECT @ActiveUserCount = COUNT(*) FROM tbl_usuario WHERE usu_estado = 'A';

    -- 1. Evitar tener más de un administrador activo
    IF @AdminCount > 1
    BEGIN
        RAISERROR ('Error: No se permite tener más de un usuario activo con el rol de Administrador.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 2. Evitar quedarse sin administrador si hay usuarios activos en el sistema
    IF @ActiveUserCount > 0 AND @AdminCount = 0
    BEGIN
        RAISERROR ('Error: Debe existir exactamente un usuario activo con el rol de Administrador en el sistema.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
