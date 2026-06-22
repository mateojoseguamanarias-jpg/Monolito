USE Monolito4to;
GO

-- 1. Eliminar datos del carrito (Mi Lista)
DELETE FROM tbl_carrito;
DBCC CHECKIDENT ('tbl_carrito', RESEED, 0);
GO

-- 2. Eliminar fotos de productos
DELETE FROM tbl_producto_fotos;
DBCC CHECKIDENT ('tbl_producto_fotos', RESEED, 0);
GO

-- 3. Eliminar productos
DELETE FROM tbl_producto;
DBCC CHECKIDENT ('tbl_producto', RESEED, 0);
GO

-- 4. Eliminar categorías y re-sembrar las iniciales
DELETE FROM tbl_categoria;
DBCC CHECKIDENT ('tbl_categoria', RESEED, 0);
GO

INSERT INTO tbl_categoria (cat_nombre, cat_estado) VALUES 
('Tecnología', 'A'),
('Ropa y Calzado', 'A'),
('Alimentos y Bebidas', 'A'),
('Hogar y Cocina', 'A'),
('Deportes', 'A');
GO

-- 5. Eliminar proveedores y re-sembrar los iniciales
DELETE FROM tbl_proveedor;
DBCC CHECKIDENT ('tbl_proveedor', RESEED, 0);
GO

INSERT INTO tbl_proveedor (prov_nombre, prov_estado) VALUES 
('Distribuidora Nova S.A.', 'A'),
('MegaImportaciones Cia. Ltda.', 'A'),
('Alimentos del Campo S.A.', 'A'),
('Textiles del Pacífico', 'A');
GO

-- 6. Eliminar fotos de usuarios
DELETE FROM tbl_usuario_fotos;
DBCC CHECKIDENT ('tbl_usuario_fotos', RESEED, 0);
GO

-- 7. Eliminar usuarios excepto el administrador del sistema
DELETE FROM tbl_usuario WHERE usu_nick <> 'admin';
GO

-- Reajustar el consecutivo de autoincremento para usuarios
DECLARE @maxId INT;
SELECT @maxId = ISNULL(MAX(usu_id), 0) FROM tbl_usuario;
IF @maxId > 0
    DBCC CHECKIDENT ('tbl_usuario', RESEED, @maxId);
ELSE
    DBCC CHECKIDENT ('tbl_usuario', RESEED, 0);
GO

PRINT '¡Base de datos limpiada con éxito! Se mantuvo al usuario administrador intacto.';
