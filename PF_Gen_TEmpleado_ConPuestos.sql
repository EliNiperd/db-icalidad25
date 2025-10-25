USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PF_Gen_TEmpleado_ConPuestos]    Script Date: 24/10/2025 12:13:57 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PF_Gen_TEmpleado_ConPuestos]
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
