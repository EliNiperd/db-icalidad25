USE [iCalidadCCMSLP22]
GO

/****** Object:  StoredProcedure [dbo].[PF_Gen_TRequisito]    Script Date: 24/10/2025 11:15:52 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PF_Gen_TRequisito]
	@p_SearchQuery          NVARCHAR(100) = NULL, -- Parámetro unificado para búsqueda
	@p_IdEstatus            NVARCHAR(5) = NULL,
    @p_PageNumber           INT = 1,
    @p_PageSize             INT = 10,
    @p_SortBy               NVARCHAR(50) = 'ClaveRequisito',
    @p_SortOrder            NVARCHAR(4) = 'ASC'
AS
-- PF_Gen_TRequisito @p_IdNormativa = 1


	 -- Consulta principal con Common Table Expression (CTE) para paginación
    WITH RequisitosCTE AS (
        SELECT
            IdRequisito,
            RTRIM(NombreRequisito) AS NombreRequisito,
            RTRIM(ClaveRequisito) AS ClaveRequisito,
            g.NombreNormativa NombreNormativa,
            IdEstatusRequisito,
            CASE IdEstatusRequisito
                WHEN 1 THEN 'Activo'
                WHEN 0 THEN 'Inactivo'
            END AS Estatus,
            -- Contar el total de registros que coinciden con el filtro
            COUNT(*) OVER() AS TotalRecords
        FROM
            Gen_TRequisito d
            LEFT JOIN Gen_TNormativa g ON d.IdNormativa = g.IdNormativa
			AND g.IdEstatusNormativa= 1
        WHERE
            (@p_IdEstatus IS NULL OR @p_IdEstatus = '%' OR IdEstatusRequisito LIKE @p_IdEstatus)
            
            AND
            (@p_SearchQuery IS NULL OR @p_SearchQuery = '' OR
             UPPER(RTRIM(ClaveNombreRequisito)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             UPPER(RTRIM(NombreNormativa)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             -- Añadida la búsqueda por estatus
             UPPER(CASE IdEstatusRequisito WHEN 1 THEN 'Activo' WHEN 0 THEN 'Inactivo' END) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%'
            )
    )
     -- Seleccionar los datos de la CTE con ordenamiento y paginación
    SELECT
        IdRequisito,
        NombreRequisito,
        ClaveRequisito,
        NombreNormativa,
        IdEstatusRequisito,
        Estatus,
        TotalRecords
    FROM RequisitosCTE
    ORDER BY
        CASE WHEN @p_SortBy = 'NombreRequisito' AND @p_SortOrder = 'ASC' THEN NombreRequisito END ASC,
        CASE WHEN @p_SortBy = 'NombreRequisito' AND @p_SortOrder = 'DESC' THEN NombreRequisito END DESC,
        CASE WHEN @p_SortBy = 'ClaveRequisito' AND @p_SortOrder = 'ASC' THEN ClaveRequisito END ASC,
        CASE WHEN @p_SortBy = 'ClaveRequisito' AND @p_SortOrder = 'DESC' THEN ClaveRequisito END DESC,
        CASE WHEN @p_SortBy = 'NombreNormativa' AND @p_SortOrder = 'ASC' THEN NombreNormativa END ASC,
        CASE WHEN @p_SortBy = 'NombreNormativa' AND @p_SortOrder = 'DESC' THEN NombreNormativa END DESC,
        CASE WHEN @p_SortBy = 'IdEstatusRequisito' AND @p_SortOrder = 'ASC' THEN IdEstatusRequisito END ASC,
        CASE WHEN @p_SortBy = 'IdEstatusRequisito' AND @p_SortOrder = 'DESC' THEN IdEstatusRequisito END DESC
    OFFSET (@p_PageNumber - 1) * @p_PageSize ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;


    /* Old versión
	SELECT IdRequisito
		, NombreRequisito
		, ClaveRequisito
		, NombreNormativa
		, Gen_TNormativa.IdNormativa
		, IdEstatusRequisito
		, CASE IdEstatusRequisito 
			WHEN 1 THEN 'Activo'
			WHEN 0 THEN 'Inactivo'
			END Estatus
		, TextoRequisito
		, 0 BorrarNormativa
		, TipoRequisito
		, ISNULL(Gen_TTipoRequisito.IdTipoRequisito, 1) IdTipoRequisito
		, ClaveRequisito + ' - ' + NombreRequisito ClaveNombre
    FROM   Gen_TRequisito
		INNER JOIN Gen_TNormativa ON Gen_TRequisito.IdNormativa = Gen_TNormativa.IDNormativa
		LEFT JOIN Gen_TTipoRequisito ON Gen_TRequisito.IdTipoRequisito = Gen_TTipoRequisito.IdTipoRequisito
    WHERE IdEstatusRequisito LIKE @p_IdEstatus 
        AND Gen_TNormativa.IdNormativa LIKE @p_IdNormativa
        AND NombreRequisito LIKE '%' + @p_NombreRequisito + '%'
        AND ClaveRequisito LIKE  '%'+ @p_ClaveRequisito + '%'
        AND ISNULL(Gen_TTipoRequisito.IdTipoRequisito, 0) LIKE @p_IdTipoRequisito
    ORDER BY ClaveRequisito, NombreRequisito, NombreNormativa
    */

	RETURN
GO

