-- =====================================================
-- SCRIPT SQL PARA AGREGAR SOPORTE DE HISTORIAL
-- Sistema de Gestión de Empleados y Puestos
-- =====================================================

-- 1. Crear tabla de historial de puestos
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Gen_TEmpleadoPuestoHistorial]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Gen_TEmpleadoPuestoHistorial](
        [IdHistorial] [int] IDENTITY(1,1) NOT NULL,
        [IdEmpleado] [int] NOT NULL,
        [IdPuesto] [int] NOT NULL,
        [TipoAccion] [nvarchar](20) NOT NULL, -- 'ASIGNADO' o 'REMOVIDO'
        [FechaAccion] [datetime] NOT NULL DEFAULT GETDATE(),
        [UsuarioAccion] [nvarchar](100) NULL,
        [Comentario] [nvarchar](500) NULL,
        CONSTRAINT [PK_Gen_TEmpleadoPuestoHistorial] PRIMARY KEY CLUSTERED 
        (
            [IdHistorial] ASC
        ),
        CONSTRAINT [FK_EmpleadoPuestoHistorial_Empleado] FOREIGN KEY([IdEmpleado])
            REFERENCES [dbo].[Gen_TEmpleado] ([IdEmpleado]),
        CONSTRAINT [FK_EmpleadoPuestoHistorial_Empleado] FOREIGN KEY([IdEmpleado])
            REFERENCES [dbo].[Gen_TEmpleado] ([IdEmpleado])
                ON DELETE CASCADE
        CONSTRAINT [FK_EmpleadoPuestoHistorial_Puesto] FOREIGN KEY([IdPuesto])
            REFERENCES [dbo].[Gen_TPuesto] ([IdPuesto]),
        CONSTRAINT [CK_TipoAccion] CHECK ([TipoAccion] IN ('ASIGNADO', 'REMOVIDO'))
    )
    
    PRINT 'Tabla Gen_TEmpleadoPuestoHistorial creada exitosamente'
END
ELSE
BEGIN
    PRINT 'La tabla Gen_TEmpleadoPuestoHistorial ya existe'
END
GO

-- 2. Crear índices para mejorar el rendimiento
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EmpleadoPuestoHistorial_Empleado' AND object_id = OBJECT_ID('Gen_TEmpleadoPuestoHistorial'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_EmpleadoPuestoHistorial_Empleado]
    ON [dbo].[Gen_TEmpleadoPuestoHistorial] ([IdEmpleado], [FechaAccion] DESC)
    PRINT 'Índice IX_EmpleadoPuestoHistorial_Empleado creado'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_EmpleadoPuestoHistorial_Puesto' AND object_id = OBJECT_ID('Gen_TEmpleadoPuestoHistorial'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_EmpleadoPuestoHistorial_Puesto]
    ON [dbo].[Gen_TEmpleadoPuestoHistorial] ([IdPuesto], [FechaAccion] DESC)
    PRINT 'Índice IX_EmpleadoPuestoHistorial_Puesto creado'
END
GO

-- 3. Agregar constraint a la tabla Gen_REmpleadoPuesto si no existe
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_REmpleadoPuesto_Empleado')
BEGIN
    ALTER TABLE [dbo].[Gen_REmpleadoPuesto]
    ADD CONSTRAINT [FK_REmpleadoPuesto_Empleado] FOREIGN KEY([IdEmpleado])
        REFERENCES [dbo].[Gen_TEmpleado] ([IdEmpleado])
        ON DELETE CASCADE
    PRINT 'Foreign key FK_REmpleadoPuesto_Empleado creada'
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_REmpleadoPuesto_Puesto')
BEGIN
    ALTER TABLE [dbo].[Gen_REmpleadoPuesto]
    ADD CONSTRAINT [FK_REmpleadoPuesto_Puesto] FOREIGN KEY([IdPuesto])
        REFERENCES [dbo].[Gen_TPuesto] ([IdPuesto])
        ON DELETE CASCADE
    PRINT 'Foreign key FK_REmpleadoPuesto_Puesto creada'
END
GO

-- 4. Stored Procedure para obtener empleados con sus puestos (mejorado)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'PF_Gen_TEmpleado_ConPuestos')
    DROP PROCEDURE [dbo].[PF_Gen_TEmpleado_ConPuestos]
GO

CREATE PROCEDURE [dbo].[PF_Gen_TEmpleado_ConPuestos]
    @p_SearchQuery NVARCHAR(100) = NULL,
    @p_IdEstatus NVARCHAR(5) = '%',
    @p_PageNumber INT = 1,
    @p_PageSize INT = 10,
    @p_SortBy NVARCHAR(50) = 'NombreEmpleado'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@p_PageNumber - 1) * @p_PageSize;
    
    -- Query principal con paginación
    WITH EmpleadosPage AS (
        SELECT 
            e.IdEmpleado,
            e.NombreEmpleado,
            e.UserName,
            e.Password,
            e.Correo,
            e.IdEstatusEmpleado,
            CASE WHEN e.IdEstatusEmpleado = 1 THEN 'Activo' ELSE 'Inactivo' END AS Estatus,
            COUNT(*) OVER() AS TotalRecords
        FROM Gen_TEmpleado e
        WHERE 
            (@p_SearchQuery IS NULL OR 
             e.NombreEmpleado LIKE '%' + @p_SearchQuery + '%' OR
             e.UserName LIKE '%' + @p_SearchQuery + '%' OR
             e.Correo LIKE '%' + @p_SearchQuery + '%')
            AND CAST(e.IdEstatusEmpleado AS NVARCHAR(5)) LIKE @p_IdEstatus
        ORDER BY 
            CASE WHEN @p_SortBy = 'NombreEmpleado' THEN e.NombreEmpleado END,
            CASE WHEN @p_SortBy = 'UserName' THEN e.UserName END
        OFFSET @Offset ROWS
        FETCH NEXT @p_PageSize ROWS ONLY
    )
    SELECT * FROM EmpleadosPage;
    
    -- Devolver los puestos de los empleados en la página actual
    SELECT 
        ep.IdEmpleado,
        p.IdPuesto,
        p.NombrePuesto,
        ISNULL(h.FechaAsignacion, GETDATE()) as FechaAsignacion
    FROM Gen_REmpleadoPuesto ep
    INNER JOIN Gen_TPuesto p ON ep.IdPuesto = p.IdPuesto
    LEFT JOIN (
        SELECT IdEmpleado, IdPuesto, MAX(FechaAccion) as FechaAsignacion
        FROM Gen_TEmpleadoPuestoHistorial
        WHERE TipoAccion = 'ASIGNADO'
        GROUP BY IdEmpleado, IdPuesto
    ) h ON ep.IdEmpleado = h.IdEmpleado AND ep.IdPuesto = h.IdPuesto
    WHERE ep.IdEmpleado IN (
        SELECT IdEmpleado FROM (
            SELECT 
                e.IdEmpleado
            FROM Gen_TEmpleado e
            WHERE 
                (@p_SearchQuery IS NULL OR 
                 e.NombreEmpleado LIKE '%' + @p_SearchQuery + '%' OR
                 e.UserName LIKE '%' + @p_SearchQuery + '%' OR
                 e.Correo LIKE '%' + @p_SearchQuery + '%')
                AND CAST(e.IdEstatusEmpleado AS NVARCHAR(5)) LIKE @p_IdEstatus
            ORDER BY 
                CASE WHEN @p_SortBy = 'NombreEmpleado' THEN e.NombreEmpleado END,
                CASE WHEN @p_SortBy = 'UserName' THEN e.UserName END
            OFFSET @Offset ROWS
            FETCH NEXT @p_PageSize ROWS ONLY
        ) sub
    )
    ORDER BY p.NombrePuesto;
END
GO

PRINT '? Scripts ejecutados exitosamente'
PRINT '? Tabla de historial creada'
PRINT '? Índices agregados'
PRINT '? Stored Procedures actualizados'
GO