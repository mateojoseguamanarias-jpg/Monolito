-- ============================================================
-- SCRIPT DE REPARACIÓN: Carrusel de Productos NovaX
-- Ejecutar en SQL Server Management Studio sobre: Monolito4to
-- ============================================================

USE Monolito4to;
GO

-- 1. CREAR TABLA tbl_producto_fotos si no existe
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_producto_fotos' AND xtype='U')
BEGIN
    CREATE TABLE tbl_producto_fotos (
        pfot_id      INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        pro_id       INT NOT NULL,
        pfot_ruta_foto VARCHAR(500) NOT NULL,
        pfot_fecha   DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Foto_Producto FOREIGN KEY (pro_id) REFERENCES tbl_producto(pro_id)
    );
    PRINT 'Tabla tbl_producto_fotos creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla tbl_producto_fotos ya existe.';
END
GO

-- 2. CORREGIR las rutas de foto de los productos semilla
--    (apuntaban a ~/Uploads/ pero las fotos están en ~/wwwroot/imagen/)
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/teclado.jpg'
WHERE pro_nombre LIKE '%Teclado%' AND (pro_ruta_foto LIKE '%Uploads%' OR pro_ruta_foto IS NULL);

UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/smartphone.jpg'
WHERE pro_nombre LIKE '%Smartphone%' AND (pro_ruta_foto LIKE '%Uploads%' OR pro_ruta_foto IS NULL);

UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/camiseta.jpg'
WHERE pro_nombre LIKE '%Camiseta%' AND (pro_ruta_foto LIKE '%Uploads%' OR pro_ruta_foto IS NULL);

UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/aceite.jpg'
WHERE pro_nombre LIKE '%Aceite%' AND (pro_ruta_foto LIKE '%Uploads%' OR pro_ruta_foto IS NULL);

UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/vajilla.jpg'
WHERE pro_nombre LIKE '%Vajilla%' AND (pro_ruta_foto LIKE '%Uploads%' OR pro_ruta_foto IS NULL);

PRINT 'Rutas de productos semilla corregidas.';
GO

-- 3. POBLAR tbl_producto_fotos con las fotos principales de cada producto
--    (para que el carrusel tenga datos desde ya)
INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
SELECT pro_id, pro_ruta_foto
FROM tbl_producto
WHERE pro_estado = 'A'
  AND pro_ruta_foto IS NOT NULL
  AND pro_ruta_foto <> ''
  AND pro_id NOT IN (SELECT DISTINCT pro_id FROM tbl_producto_fotos);

PRINT 'Fotos principales registradas en tbl_producto_fotos.';
GO

-- 4. VERIFICACIÓN FINAL
SELECT 
    p.pro_id,
    p.pro_nombre,
    p.pro_ruta_foto AS foto_principal,
    COUNT(f.pfot_id) AS total_fotos_carrusel
FROM tbl_producto p
LEFT JOIN tbl_producto_fotos f ON p.pro_id = f.pro_id
WHERE p.pro_estado = 'A'
GROUP BY p.pro_id, p.pro_nombre, p.pro_ruta_foto
ORDER BY p.pro_id;
GO
