USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PF_Gen_TPuesto]    Script Date: 23/10/2025 12:36:16 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PF_Gen_TPuesto]
	@p_SearchQuery          NVARCHAR(100) = NULL, -- Parámetro unificado para búsqueda
    @p_IdEstatus            NVARCHAR(5) = NULL,
    @p_PageNumber           INT = 1,
    @p_PageSize             INT = 10,
    @p_SortBy               NVARCHAR(50) = 'NombrePuesto',
    @p_SortOrder            NVARCHAR(4) = 'ASC'
AS
BEGIN
	SET NOCOUNT ON;
    -- PF_Gen_TPuesto
	 -- Consulta principal con Common Table Expression (CTE) para paginación
    WITH GerenciasCTE AS (
        SELECT
            IdPuesto,
            RTRIM(NombrePuesto) AS NombrePuesto,
            RTRIM(NombreDepartamento) AS NombreDepartamento,
            IdEstatusPuesto,
            CASE IdEstatusPuesto
                WHEN 1 THEN 'Activo'
                WHEN 0 THEN 'Inactivo'
            END AS Estatus,
            -- Contar el total de registros que coinciden con el filtro
            COUNT(*) OVER() AS TotalRecords
        FROM
            Gen_TPuesto p
		LEFT JOIN Gen_TDepartamento d ON p.IdDepartamento = d.IdDepartamento
			AND d.IdEstatusDepartamento = 1
        WHERE
            (@p_IdEstatus IS NULL OR @p_IdEstatus = '%' OR IdEstatusPuesto LIKE @p_IdEstatus)
            AND 
            (@p_SearchQuery IS NULL OR @p_SearchQuery = '' OR
             UPPER(RTRIM(NombrePuesto)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             UPPER(RTRIM(NombreDepartamento)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             -- Añadida la búsqueda por estatus
             UPPER(CASE IdEstatusPuesto WHEN 1 THEN 'Activo' WHEN 0 THEN 'Inactivo' END) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%'
            )
    )
    -- Seleccionar los datos de la CTE con ordenamiento y paginación
    SELECT
        IdPuesto,
        NombrePuesto,
        NombreDepartamento,
        IdEstatusPuesto,
        Estatus,
        TotalRecords
    FROM GerenciasCTE
    ORDER BY
        CASE WHEN @p_SortBy = 'NombrePuesto' AND @p_SortOrder = 'ASC' THEN NombrePuesto END ASC,
        CASE WHEN @p_SortBy = 'NombrePuesto' AND @p_SortOrder = 'DESC' THEN NombrePuesto END DESC,
        CASE WHEN @p_SortBy = 'NombreDepartamento' AND @p_SortOrder = 'ASC' THEN NombreDepartamento END ASC,
        CASE WHEN @p_SortBy = 'NombreDepartamento' AND @p_SortOrder = 'DESC' THEN NombreDepartamento END DESC,
        CASE WHEN @p_SortBy = 'IdEstatusPuesto' AND @p_SortOrder = 'ASC' THEN IdEstatusPuesto END ASC,
        CASE WHEN @p_SortBy = 'IdEstatusPuesto' AND @p_SortOrder = 'DESC' THEN IdEstatusPuesto END DESC
    OFFSET (@p_PageNumber - 1) * @p_PageSize ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;

	
END