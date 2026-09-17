/* CREACION BASE DE DATOS*/

CREATE DATABASE EmpresaDB;
GO

/* CREACION TABLAS (DPTOS, EMPLEADOS, PROYECTOS)*/

USE EmpresaDB;
GO

CREATE TABLE Departamentos
(
    IdDepartamento INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Empleados
(
    IdEmpleado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    FechaIngreso DATE NOT NULL,
    IdDepartamento INT NOT NULL,

    CONSTRAINT FK_Empleados_Departamentos
        FOREIGN KEY (IdDepartamento)
        REFERENCES Departamentos(IdDepartamento)
);
GO


CREATE TABLE Proyectos
(
    IdProyecto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(150) NOT NULL,
    Presupuesto DECIMAL(15,2) NOT NULL
);
GO



CREATE TABLE EmpleadoProyecto
(
    IdEmpleado INT NOT NULL,
    IdProyecto INT NOT NULL,

    CONSTRAINT PK_EmpleadoProyecto
        PRIMARY KEY (IdEmpleado, IdProyecto),

    CONSTRAINT FK_EmpleadoProyecto_Empleado
        FOREIGN KEY (IdEmpleado)
        REFERENCES Empleados(IdEmpleado),

    CONSTRAINT FK_EmpleadoProyecto_Proyecto
        FOREIGN KEY (IdProyecto)
        REFERENCES Proyectos(IdProyecto)
);
GO

/* INSERCION DATA EN  TABLAS (DPTOS, EMPLEADOS, PROYECTOS)*/

 INSERT INTO Empleados
(
    Nombre,
    Apellido,
    Email,
    FechaIngreso,
    IdDepartamento
)
VALUES
('Carlos', 'Gomez', 'carlos.gomez@empresa.com', '2020-01-15', 1),
('Ana', 'Martinez', 'ana.martinez@empresa.com', '2021-03-10', 1),
('Luis', 'Rodriguez', 'luis.rodriguez@empresa.com', '2019-07-20', 2),
('Maria', 'Perez', 'maria.perez@empresa.com', '2022-02-01', 3),
('Juan', 'Lopez', 'juan.lopez@empresa.com', '2023-05-15', 4),
('Laura', 'Torres', 'laura.torres@empresa.com', '2021-11-10', 5);
GO
 
 INSERT INTO Departamentos (Nombre)
VALUES
('Tecnología'),
('Recursos Humanos'),
('Finanzas'),
('Ventas'),
('Marketing'),
('Administración');
GO

INSERT INTO Proyectos (Nombre, Presupuesto)
VALUES
('Sistema Web', 50000000.00),
('Aplicación Móvil', 35000000.00),
('Migración de Datos', 20000000.00),
('Portal Clientes', 45000000.00),
('Proyecto BI', 30000000.00),
('Automatización', 25000000.00);
GO


INSERT INTO EmpleadoProyecto (IdEmpleado, IdProyecto)
VALUES
(1, 1),
(1, 2),
(1, 3),

(2, 1),
(2, 2),

(3, 2),
(3, 4),

(4, 3),

(5, 4),
(5, 5),

(6, 5),
(6, 6);
GO



/* Listar todos los empleados con el nombre de su departamento. */


SELECT
    E.IdEmpleado,
    E.Nombre,
    E.Apellido,
    E.Email,
    E.FechaIngreso,
    D.Nombre AS Departamento
FROM Empleados E
INNER JOIN Departamentos D
    ON E.IdDepartamento = D.IdDepartamento;
	

/*  Mostrar los proyectos con su presupuesto y la cantidad de empleados asignados. */

	SELECT
    P.IdProyecto,
    P.Nombre AS Proyecto,
    P.Presupuesto,
    COUNT(EP.IdEmpleado) AS CantidadEmpleados
FROM Proyectos P
LEFT JOIN EmpleadoProyecto EP
    ON P.IdProyecto = EP.IdProyecto
GROUP BY
    P.IdProyecto,
    P.Nombre,
    P.Presupuesto;
	

/* Obtener el top 3 de empleados con más proyectos asignados.  */

SELECT TOP 3
    E.IdEmpleado,
    E.Nombre,
    E.Apellido,
    COUNT(EP.IdProyecto) AS CantidadProyectos
FROM Empleados E
INNER JOIN EmpleadoProyecto EP
    ON E.IdEmpleado = EP.IdEmpleado
GROUP BY
    E.IdEmpleado,
    E.Nombre,
    E.Apellido
ORDER BY CantidadProyectos DESC;

/* Listar los departamentos que no tienen empleados. */


SELECT
    D.IdDepartamento,
    D.Nombre
FROM Departamentos D
LEFT JOIN Empleados E
    ON D.IdDepartamento = E.IdDepartamento
WHERE E.IdEmpleado IS NULL;

/* Consultar todos los empleados que participan en más de un proyecto. */

SELECT
    E.IdEmpleado,
    E.Nombre,
    E.Apellido,
    COUNT(EP.IdProyecto) AS CantidadProyectos
FROM Empleados E
INNER JOIN EmpleadoProyecto EP
    ON E.IdEmpleado = EP.IdEmpleado
GROUP BY
    E.IdEmpleado,
    E.Nombre,
    E.Apellido
HAVING COUNT(EP.IdProyecto) > 1;

/* Crear un procedimiento almacenado sp_buscar_empleado que reciba el nombre del empleado y retorne sus datos completos, incluyendo departamento. */

CREATE PROCEDURE sp_buscar_empleado
    @Nombre VARCHAR(100)
AS
BEGIN

    SELECT
        E.IdEmpleado,
        E.Nombre,
        E.Apellido,
        E.Email,
        E.FechaIngreso,
        D.IdDepartamento,
        D.Nombre AS Departamento
    FROM Empleados E
    INNER JOIN Departamentos D
        ON E.IdDepartamento = D.IdDepartamento
    WHERE E.Nombre LIKE '%' + @Nombre + '%';

END;
GO

EXEC sp_buscar_empleado 'Carlos';

/* Crear una función escalar fn_total_proyectos que dado el IdEmpleado devuelva el total de proyectos asignados. */

CREATE FUNCTION fn_total_proyectos
(
    @IdEmpleado INT
)
RETURNS INT
AS
BEGIN

    DECLARE @Total INT;

    SELECT @Total = COUNT(*)
    FROM EmpleadoProyecto
    WHERE IdEmpleado = @IdEmpleado;

    RETURN @Total;

END;
GO


SELECT dbo.fn_total_proyectos(1) AS TotalProyectos;

/* Crear un índice no cluster en la columna Apellido de la tabla Empleados para optimizar búsquedas. */

CREATE NONCLUSTERED INDEX IX_Empleados_Apellido
ON Empleados(Apellido);
GO




/* Explicar en máximo 5 líneas cómo implementarías un backup y restore de la base de datos en SQL Server. */


 /* "Implementaría backups completos periódicos de la base de datos y almacenaría los archivos .bak en una ubicación segura y diferente al servidor de producción.
 Dependiendo del nivel de disponibilidad requerido, complementaría con backups diferenciales y de log. 
 Para restaurar, utilizaría RESTORE DATABASE indicando el archivo de backup y la ubicación de los archivos MDF/LDF.
 También realizaría pruebas periódicas de restauración para verificar que los backups sean válidos." */

