-- Script para corregir los productos con acentos corruptos y asignarles sus imágenes
USE Monolito4to;
GO

-- 1. Actualizar pro_ruta_foto con comodines para evitar fallas de codificación
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/audifonos_estudio.png' WHERE pro_nombre LIKE '%Aud%fonos%Estudio%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/teclado_gamer.jpg' WHERE pro_nombre LIKE '%Teclado%Num%rico%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/pantalon_buzo.jpg' WHERE pro_nombre LIKE '%Pantal%n%Buzo%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/panuelo_seda.jpg' WHERE pro_nombre LIKE '%Pa%uelo%Seda%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/sueter_tejido.jpg' WHERE pro_nombre LIKE '%Su%ter%Tejido%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/munequeras_soporte.jpg' WHERE pro_nombre LIKE '%Mu%equeras%Soporte%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/cinta_elastica.jpg' WHERE pro_nombre LIKE '%Cinta%El%stica%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/mosqueton_montanismo.jpg' WHERE pro_nombre LIKE '%Mosquet%n%Monta%ismo%' AND pro_estado = 'A';
GO

-- 2. Insertar las 5 fotos de carrusel correspondientes para estos 8 productos
DECLARE @id INT, @nombre VARCHAR(200), @rutaBase VARCHAR(300), @ext VARCHAR(5), @sinExt VARCHAR(290);

DECLARE cur CURSOR FOR
    SELECT pro_id, pro_nombre, pro_ruta_foto
    FROM tbl_producto
    WHERE pro_estado = 'A'
      AND pro_id IN (6, 7, 15, 18, 19, 40, 41, 44)
      AND pro_id NOT IN (SELECT DISTINCT pro_id FROM tbl_producto_fotos);

OPEN cur;
FETCH NEXT FROM cur INTO @id, @nombre, @rutaBase;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ext = RIGHT(@rutaBase, CHARINDEX('.', REVERSE(@rutaBase)));
    SET @sinExt = LEFT(@rutaBase, LEN(@rutaBase) - LEN(@ext));

    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@id, @sinExt + '_1' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@id, @sinExt + '_2' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@id, @sinExt + '_3' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@id, @sinExt + '_4' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto) VALUES (@id, @sinExt + '_5' + @ext);

    FETCH NEXT FROM cur INTO @id, @nombre, @rutaBase;
END;

CLOSE cur;
DEALLOCATE cur;
GO

-- Verificar que ahora todos los productos del 1 al 45 tengan su carrusel
SELECT p.pro_id, p.pro_nombre, p.pro_ruta_foto, COUNT(f.pfot_id) AS total_fotos_carrusel
FROM tbl_producto p
LEFT JOIN tbl_producto_fotos f ON p.pro_id = f.pro_id
WHERE p.pro_estado = 'A'
GROUP BY p.pro_id, p.pro_nombre, p.pro_ruta_foto
ORDER BY p.pro_id;
GO
