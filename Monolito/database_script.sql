/* 
   BASE DE DATOS: Monolito4to
   PROYECTO: NovaX PRO - Módulo de Seguridad
*/

CREATE DATABASE Monolito4to;
GO

USE Monolito4to;
GO

-- 1. TABLA DE TIPOS DE USUARIO (ROLES)
CREATE TABLE tbl_tipo_usuario (
    tusu_id INT PRIMARY KEY IDENTITY(1,1),
    tusu_nombre VARCHAR(50) NOT NULL,
    tusu_estado CHAR(1) DEFAULT 'A' -- A: Activo, I: Inactivo
);

INSERT INTO tbl_tipo_usuario (tusu_nombre) VALUES ('Administrador'), ('Usuario'), ('Agente');
GO

-- 2. TABLA DE USUARIOS
CREATE TABLE tbl_usuario (
    usu_id INT PRIMARY KEY IDENTITY(1,1),
    usu_cedula VARCHAR(10) NULL,
    usu_nombre VARCHAR(100) NOT NULL,
    usu_apellidos VARCHAR(100) NOT NULL,
    usu_correo VARCHAR(150) NOT NULL UNIQUE,
    usu_nick VARCHAR(50) NOT NULL UNIQUE,
    usu_contraseña VARBINARY(MAX) NOT NULL, -- Almacena clave cifrada con ENCRYPTBYPASSPHRASE
    tusu_id INT NOT NULL,
    usu_celular VARCHAR(15) NULL,
    usu_direccion VARCHAR(250) NULL,
    usu_fecha_cumple DATE NULL,
    usu_fecha_creacion DATETIME DEFAULT GETDATE(),
    usu_estado CHAR(1) DEFAULT 'A', -- A: Activo, B: Bloqueado, I: Inactivo
    usu_codigo_OTP VARCHAR(100) NULL, -- Para QR permanente
    usu_otp_hash VARCHAR(500) NULL,   -- Para OTP temporal y recuperación
    usu_google_id VARCHAR(100) NULL,
    usu_facebook_id VARCHAR(100) NULL,
    usu_fecha_ultimo_acceso DATETIME NULL,
    usu_puntos INT DEFAULT 0,
    
    CONSTRAINT FK_Usuario_Tipo FOREIGN KEY (tusu_id) REFERENCES tbl_tipo_usuario(tusu_id)
);
GO

-- 3. TABLA DE FOTOS DE USUARIO (Soporta múltiples imágenes)
CREATE TABLE tbl_usuario_fotos (
    foto_id INT PRIMARY KEY IDENTITY(1,1),
    usu_id INT NOT NULL,
    foto_data VARBINARY(MAX) NOT NULL, -- Imagen en binario
    foto_fecha DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Fotos_Usuario FOREIGN KEY (usu_id) REFERENCES tbl_usuario (usu_id)
);
GO

-- PROCEDIMIENTO PARA DESBLOQUEAR (Opcional, se puede hacer por SQL directo)
CREATE PROCEDURE sp_DesbloquearUsuario
    @id INT
AS
BEGIN
    UPDATE tbl_usuario SET usu_estado = 'A' WHERE usu_id = @id;
END;
GO
