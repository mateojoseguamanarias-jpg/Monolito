-- 1. CREACIÓN DE LA BASE DE DATOS
-- CREATE DATABASE Monolito4am;
-- GO
-- USE Monolito4am;
-- GO

-- 2. TABLA DE TIPOS DE USUARIO
CREATE TABLE tbl_tipo_usuario
(
	tusu_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	tusu_nombre VARCHAR(50),
	tusu_estado CHAR(1)
);
GO

-- 3. TABLA DE USUARIOS
CREATE TABLE tbl_usuario
(
	usu_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	usu_cedula VARCHAR(10),
	usu_nombre VARCHAR(50),
	usu_apellidos VARCHAR(50),
	usu_direccion VARCHAR(50),
	usu_celular VARCHAR(10),
	usu_correo VARCHAR(150),
	usu_fecha_creacion DATETIME,
	usu_fecha_cumple DATE,
	usu_nick VARCHAR(50),
	usu_contraseña VARBINARY(MAX),
	usu_intentos INT,
	usu_codigo_OTP VARCHAR(10),
	usu_estado CHAR(1),
	tusu_id INT REFERENCES tbl_tipo_usuario(tusu_id)
);
GO

-- 4. FUNCIONES DE ENCRIPTACIÓN Y DESENCRIPTACIÓN
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

-- 5. ALTERACIÓN DE LA TABLA DE USUARIOS PARA AGREGAR LA FECHA DE ÚLTIMO INGRESO
ALTER TABLE tbl_usuario
ADD usu_fecha_Ultimo DATETIME;
GO

-- 6. TABLA DE PROVEEDORES
CREATE TABLE tbl_proveedor
(
	prov_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	prov_nombre VARCHAR(50),
	prov_estado CHAR(1)
);
GO

-- 7. TABLA DE PRODUCTOS (Incluye la ruta/path de la foto)
CREATE TABLE tbl_producto
(
	pro_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	pro_nombre VARCHAR(50),
	pro_cantidad INT,
	pro_precio DECIMAL(18,2),
	pro_estado CHAR(1),
	prov_id INT REFERENCES tbl_proveedor(prov_id),
	pro_ruta_foto VARCHAR(250) -- Campo para guardar la ruta física/virtual de la foto (Path)
);
GO
