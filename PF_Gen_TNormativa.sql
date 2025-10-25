USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PF_Gen_TNormativa]    Script Date: 24/10/2025 05:39:19 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PF_Gen_TNormativa]
	@p_SearchQuery          NVARCHAR(100) = NULL, -- Parámetro unificado para búsqueda
	@p_IdEstatus            NVARCHAR(5) = NULL,
    @p_PageNumber           INT = 1,
    @p_PageSize             INT = 10,
    @p_SortBy               NVARCHAR(50) = 'NombreNormativa',
    @p_SortOrder            NVARCHAR(4) = 'ASC'
AS

	SET NOCOUNT ON;

	 -- Consulta principal con Common Table Expression (CTE) para paginación
    WITH NormativasCTE AS (
        SELECT
            IdNormativa,
            RTRIM(NombreNormativa) AS NombreNormativa,
            RTRIM(ClaveNormativa) AS ClaveNormativa,
            IdEstatusNormativa,
            CASE IdEstatusNormativa
                WHEN 1 THEN 'Activo'
                WHEN 0 THEN 'Inactivo'
            END AS Estatus,
            -- Contar el total de registros que coinciden con el filtro
            COUNT(*) OVER() AS TotalRecords
        FROM Gen_TNormativa 
        WHERE
            (@p_IdEstatus IS NULL OR @p_IdEstatus = '%' OR IdEstatusNormativa LIKE @p_IdEstatus)
            AND
            (@p_SearchQuery IS NULL OR @p_SearchQuery = '' OR
             UPPER(RTRIM(ClaveNombreNormativa)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             --UPPER(RTRIM(NombreNormativa)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             -- Añadida la búsqueda por estatus
             UPPER(CASE IdEstatusNormativa WHEN 1 THEN 'Activo' WHEN 0 THEN 'Inactivo' END) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%'
            )
    )
     -- Seleccionar los datos de la CTE con ordenamiento y paginación
    SELECT
        IdNormativa,
        NombreNormativa,
        ClaveNormativa,
        IdEstatusNormativa,
        Estatus,
        TotalRecords
    FROM NormativasCTE
    ORDER BY
        CASE WHEN @p_SortBy = 'NombreNormativa' AND @p_SortOrder = 'ASC' THEN NombreNormativa END ASC,
        CASE WHEN @p_SortBy = 'NombreNormativa' AND @p_SortOrder = 'DESC' THEN NombreNormativa END DESC,
        CASE WHEN @p_SortBy = 'ClaveNormativa' AND @p_SortOrder = 'ASC' THEN ClaveNormativa END ASC,
        CASE WHEN @p_SortBy = 'ClaveNormativa' AND @p_SortOrder = 'DESC' THEN ClaveNormativa END DESC,
        CASE WHEN @p_SortBy = 'IdEstatusNormativa' AND @p_SortOrder = 'ASC' THEN IdEstatusNormativa END ASC,
        CASE WHEN @p_SortBy = 'IdEstatusNormativa' AND @p_SortOrder = 'DESC' THEN IdEstatusNormativa END DESC
    OFFSET (@p_PageNumber - 1) * @p_PageSize ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;
    /* Old versión
		SELECT IdNormativa
			, NombreNormativa
			, ClaveNormativa
			, IdEstatusNormativa
			, CASE IdEstatusNormativa
				WHEN 1 THEN 'Activo'
				WHEN 0 THEN 'Inactivo'
			END AS Estatus
		FROM   Gen_TNormativa
		WHERE (IdEstatusNormativa LIKE @p_IdEstatus AND IdEstatusNormativa <> 3 )
			AND NombreNormativa LIKE '%' + @p_NombreNormativa + '%'
			AND ClaveNormativa LIKE  '%' + @p_ClaveNormativa + '%'
		ORDER BY NombreNormativa
	RETURN
    */