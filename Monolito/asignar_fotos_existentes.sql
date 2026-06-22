-- Script para asignar fotos a productos existentes en la base de datos
-- Ejecutar en SQL Server Management Studio sobre la base de datos Monolito4to

USE Monolito4to;
GO

-- =====================================================
-- PASO 1: Ver todos los productos que faltan fotos
-- =====================================================
SELECT pro_id, pro_nombre, pro_ruta_foto 
FROM tbl_producto
WHERE pro_estado = 'A'
ORDER BY pro_id;
GO

-- =====================================================
-- PASO 2: Asignar imagen principal a cada producto existente
-- Actualiza pro_ruta_foto en tbl_producto
-- =====================================================
-- Tecnología
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/audifonos_estudio.png' WHERE pro_nombre LIKE '%Audífonos de Estudio%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/teclado_gamer.jpg' WHERE pro_nombre LIKE '%Teclado Numérico%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/disco_duro_ssd.jpg' WHERE pro_nombre LIKE '%Disco Duro SSD%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/lente_macro.jpg' WHERE pro_nombre LIKE '%Lente Macro%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/soporte_escritorio.jpg' WHERE pro_nombre LIKE '%Soporte de Escritorio%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/almohadilla_termica.jpg' WHERE pro_nombre LIKE '%Almohadilla%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/adaptador_bluetooth.jpg' WHERE pro_nombre LIKE '%Adaptador Bluetooth%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/mini_ventilador.jpg' WHERE pro_nombre LIKE '%Ventilador%' AND pro_estado = 'A';
-- Ropa y Calzado
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/chaleco_cortavientos.jpg' WHERE pro_nombre LIKE '%Chaleco%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/pantalon_buzo.jpg' WHERE pro_nombre LIKE '%Pantalón de Buzo%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/mocacines_gamuza.jpg' WHERE pro_nombre LIKE '%Mocasines%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/sombrero_paja.jpg' WHERE pro_nombre LIKE '%Sombrero%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/panuelo_seda.jpg' WHERE pro_nombre LIKE '%Pañuelo%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/sueter_tejido.jpg' WHERE pro_nombre LIKE '%Suéter%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/bolsa_tela.jpg' WHERE pro_nombre LIKE '%Bolsa de Tela%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/sandalias_casa.jpg' WHERE pro_nombre LIKE '%Sandalias%' AND pro_estado = 'A';
-- Alimentos y Bebidas
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/granola_artesanal.jpg' WHERE pro_nombre LIKE '%Granola%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/harina_avena.jpg' WHERE pro_nombre LIKE '%Harina de Avena%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/pasta_dientes.jpg' WHERE pro_nombre LIKE '%Pasta de Dientes%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/te_jengibre.jpg' WHERE pro_nombre LIKE '%Jengibre%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/aceite.jpg' WHERE pro_nombre LIKE '%Aceite de Coco%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/garbanzos_conserva.jpg' WHERE pro_nombre LIKE '%Garbanzos%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/salsa_tomate.jpg' WHERE pro_nombre LIKE '%Salsa de Tomate%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/mix_semillas.jpg' WHERE pro_nombre LIKE '%Semillas%' AND pro_estado = 'A';
-- Hogar y Cocina
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/prensa_francesa.jpg' WHERE pro_nombre LIKE '%Prensa Francesa%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/espumador_leche.jpg' WHERE pro_nombre LIKE '%Espumador%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/temporizador_digital.jpg' WHERE pro_nombre LIKE '%Temporizador%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/molde_silicona.jpg' WHERE pro_nombre LIKE '%Molde de Silicona%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/tabla_picar.jpg' WHERE pro_nombre LIKE '%Tabla para Picar%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/tazas_ceramica.jpg' WHERE pro_nombre LIKE '%Tazas%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/ganchos_adhesivos.jpg' WHERE pro_nombre LIKE '%Ganchos%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/alfombra_puerta.jpg' WHERE pro_nombre LIKE '%Alfombra%' AND pro_estado = 'A';
-- Deportes
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/rueda_masaje.jpg' WHERE pro_nombre LIKE '%Foam Roller%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/bloque_espuma.jpg' WHERE pro_nombre LIKE '%Bloque de Espuma%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/munequeras_soporte.jpg' WHERE pro_nombre LIKE '%Muñequeras%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/cinta_elastica.jpg' WHERE pro_nombre LIKE '%Cinta Elástica%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/silbato_arbitro.jpg' WHERE pro_nombre LIKE '%Silbato%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/parche_reparacion.jpg' WHERE pro_nombre LIKE '%Parche%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/mosqueton_montanismo.jpg' WHERE pro_nombre LIKE '%Mosquetón%' AND pro_estado = 'A';
UPDATE tbl_producto SET pro_ruta_foto = '~/wwwroot/imagen/luz_led.jpg' WHERE pro_nombre LIKE '%Luz LED%' AND pro_estado = 'A';
GO

-- =====================================================
-- PASO 3: Insertar las 5 fotos de carrusel para cada producto
-- Solo para los que aun no tienen fotos en tbl_producto_fotos
-- =====================================================
DECLARE @id INT, @nombre VARCHAR(200), @rutaBase VARCHAR(300), @ext VARCHAR(5), @sinExt VARCHAR(290);

DECLARE cur CURSOR FOR
    SELECT pro_id, pro_nombre, pro_ruta_foto
    FROM tbl_producto
    WHERE pro_estado = 'A'
      AND pro_ruta_foto != '~/wwwroot/imagen/default.png'
      AND pro_id NOT IN (SELECT DISTINCT pro_id FROM tbl_producto_fotos);

OPEN cur;
FETCH NEXT FROM cur INTO @id, @nombre, @rutaBase;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Determinar extension
    SET @ext = RIGHT(@rutaBase, CHARINDEX('.', REVERSE(@rutaBase)));
    SET @sinExt = LEFT(@rutaBase, LEN(@rutaBase) - LEN(@ext));

    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
    VALUES (@id, @sinExt + '_1' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
    VALUES (@id, @sinExt + '_2' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
    VALUES (@id, @sinExt + '_3' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
    VALUES (@id, @sinExt + '_4' + @ext);
    INSERT INTO tbl_producto_fotos (pro_id, pfot_ruta_foto)
    VALUES (@id, @sinExt + '_5' + @ext);

    FETCH NEXT FROM cur INTO @id, @nombre, @rutaBase;
END;

CLOSE cur;
DEALLOCATE cur;
GO

-- Verificar resultados
SELECT p.pro_id, p.pro_nombre, COUNT(f.pfot_id) AS total_fotos_carrusel
FROM tbl_producto p
LEFT JOIN tbl_producto_fotos f ON p.pro_id = f.pro_id
WHERE p.pro_estado = 'A'
GROUP BY p.pro_id, p.pro_nombre
ORDER BY p.pro_id;
GO
