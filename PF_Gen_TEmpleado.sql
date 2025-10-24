USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PF_Gen_TEmpleado]    Script Date: 23/10/2025 03:18:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PF_Gen_TEmpleado]
	@p_SearchQuery          NVARCHAR(100) = NULL, -- Parámetro unificado para búsqueda
	@p_IdEstatus            NVARCHAR (8) = NULL,
	@p_PageNumber           INT = 1,
    @p_PageSize             INT = 10,
    @p_SortBy               NVARCHAR(50) = 'NombreEmpleado',
    @p_SortOrder            NVARCHAR(4) = 'ASC'
	--, @p_IdDepartamento NVARCHAR (50)='%'
	--, @p_IdGerencia NVARCHAR (50)='%'
	--, @p_IdPuesto NVARCHAR (50)='%'
	--, @p_Auditor NVARCHAR (10)='%'
AS
BEGIN
	SET NOCOUNT ON;
-- PF_Gen_TEmpleado '%', '%', '%', '%', '%', '%'
-- PF_Gen_TEmpleado @p_IdEstatusEmpleado ='1', @p_NombreEmpleado ='loa'
	
	
	 -- Consulta principal con Common Table Expression (CTE) para paginación
    WITH EmpleadosCTE AS (
        SELECT
            IdEmpleado,
            RTRIM(NombreEmpleado) AS NombreEmpleado,
            RTRIM(UserName) AS UserName,
            Correo,
            IdEstatusEmpleado,
            CASE IdEstatusEmpleado
                WHEN 1 THEN 'Activo'
                WHEN 0 THEN 'Inactivo'
            END AS Estatus,
            -- Contar el total de registros que coinciden con el filtro
            COUNT(*) OVER() AS TotalRecords
        FROM Gen_TEmpleado
        WHERE
            (@p_IdEstatus IS NULL OR @p_IdEstatus = '%' OR IdEstatusEmpleado LIKE @p_IdEstatus)
            AND
            (@p_SearchQuery IS NULL OR @p_SearchQuery = '' OR
             UPPER(RTRIM(NombreEmpleado)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             --UPPER(RTRIM(NombreGerencia)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             -- Añadida la búsqueda por estatus
             UPPER(CASE IdEstatusEmpleado WHEN 1 THEN 'Activo' WHEN 0 THEN 'Inactivo' END) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%'
            )
    )
     -- Seleccionar los datos de la CTE con ordenamiento y paginación
    SELECT
        IdEmpleado,
        NombreEmpleado,
        UserName,
        Correo,
        IdEstatusEmpleado,
        Estatus,
        TotalRecords
    FROM EmpleadosCTE
    ORDER BY
        CASE WHEN @p_SortBy = 'NombreEmpleado' AND @p_SortOrder = 'ASC' THEN NombreEmpleado END ASC,
        CASE WHEN @p_SortBy = 'NombreEmpleado' AND @p_SortOrder = 'DESC' THEN NombreEmpleado END DESC,
        --CASE WHEN @p_SortBy = 'ClaveDepartamento' AND @p_SortOrder = 'ASC' THEN ClaveDepartamento END ASC,
        --CASE WHEN @p_SortBy = 'ClaveDepartamento' AND @p_SortOrder = 'DESC' THEN ClaveDepartamento END DESC,
        --CASE WHEN @p_SortBy = 'NombreGerencia' AND @p_SortOrder = 'ASC' THEN NombreGerencia END ASC,
        --CASE WHEN @p_SortBy = 'NombreGerencia' AND @p_SortOrder = 'DESC' THEN NombreGerencia END DESC,
        CASE WHEN @p_SortBy = 'IdEstatusEmpleado' AND @p_SortOrder = 'ASC' THEN IdEstatusEmpleado END ASC,
        CASE WHEN @p_SortBy = 'IdEstatusEmpleado' AND @p_SortOrder = 'DESC' THEN IdEstatusEmpleado END DESC
    OFFSET (@p_PageNumber - 1) * @p_PageSize ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;
    
    /* Old version
	
	SELECT DISTINCT(Gen_TEmpleado.IDEmpleado)
		, NombreEmpleado
		, UserName
		, PassWord
		, CAST(FechaAlta AS CHAR(11))  FechaAlta
		, Correo
		, IDEstatusEmpleado
		, '' NombrePuesto
		, CASE IDEstatusEmpleado
			WHEN 1 THEN 'Activo'
			WHEN 0 THEN 'Inactivo'
			END AS Estatus
		, Password
	--	, Gen_rEmpleadoPuesto.IdPuesto
	FROM Gen_TEmpleado
		LEFT JOIN Gen_REmpleadoPuesto ON Gen_TEmpleado.IdEmpleado = Gen_REmpleadoPuesto.IdEmpleado
		--INNER JOIN Gen_TPuesto ON Gen_REmpleadoPuesto.IdPuesto = Gen_TPuesto.IdPuesto
	WHERE (IDEstatusEmpleado LIKE @p_IdEstatusEmpleado AND IDEstatusEmpleado <> 3 )
		AND UPPER(NombreEmpleado) LIKE '%' + UPPER(@p_NombreEmpleado) + '%'
		AND UPPER(Username) LIKE '%' + UPPER(@p_UserName) + '%'
		AND UPPER(UserName) <> 'ADMIN'
		AND ISNULL(Gen_REmpleadoPuesto.IdPuesto, 0) LIKE @p_IdPuesto
	ORDER BY NombreEmpleado
    */
END

