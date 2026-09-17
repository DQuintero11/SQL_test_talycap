CREATE TABLE Clientes
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Identificacion VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Correo VARCHAR(150) NOT NULL,
    Telefono VARCHAR(20) NOT NULL
);
GO

ALTER TABLE Clientes
ADD CONSTRAINT UQ_Clientes_Identificacion
UNIQUE (Identificacion);
GO


INSERT INTO Clientes
(
    Identificacion,
    Nombre,
    Correo,
    Telefono
)
VALUES
('1001001001', 'Carlos Gomez', 'carlos.gomez@gmail.com', '3001111111'),
('1001001002', 'Ana Martinez', 'ana.martinez@gmail.com', '3002222222'),
('1001001003', 'Luis Rodriguez', 'luis.rodriguez@gmail.com', '3003333333'),
('1001001004', 'Maria Perez', 'maria.perez@gmail.com', '3004444444'),
('1001001005', 'Juan Lopez', 'juan.lopez@gmail.com', '3005555555');
GO



CREATE PROCEDURE sp_ObtenerCliente
    @Identificacion VARCHAR(20)
AS
BEGIN
    SELECT
        Id,
        Identificacion,
        Nombre,
        Correo,
        Telefono
    FROM Clientes
    WHERE Identificacion = @Identificacion;
END;
GO