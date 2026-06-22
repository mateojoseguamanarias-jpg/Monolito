-- ============================================================
--  TABLA: tbl_carrito
--  Guarda los productos seleccionados por cada usuario.
--  Un usuario NO puede agregar el mismo producto dos veces.
-- ============================================================
USE Monolito4to;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tbl_carrito' AND xtype='U')
BEGIN
    CREATE TABLE tbl_carrito (
        car_id    INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        usu_id    INT NOT NULL,
        pro_id    INT NOT NULL,
        car_fecha DATETIME DEFAULT GETDATE(),

        CONSTRAINT FK_Carrito_Usuario  FOREIGN KEY (usu_id) REFERENCES tbl_usuario(usu_id),
        CONSTRAINT FK_Carrito_Producto FOREIGN KEY (pro_id) REFERENCES tbl_producto(pro_id),

        -- Evita duplicados: un usuario no puede guardar el mismo producto dos veces
        CONSTRAINT UQ_Carrito_UsuPro UNIQUE (usu_id, pro_id)
    );
END
GO
