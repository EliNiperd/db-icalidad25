USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PF_Gen_TDepartamento]    Script Date: 23/10/2025 01:53:33 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Elí Rodríguez
-- Create date: Febrero 2009
-- Description:	Recupera las Área o Departamentos
-- =============================================
ALTER PROCEDURE [dbo].[PF_Gen_TDepartamento] 
	@p_SearchQuery          NVARCHAR(100) = NULL, -- Parámetro unificado para búsqueda
	@p_IdEstatus            NVARCHAR(5) = NULL,
    @p_PageNumber           INT = 1,
    @p_PageSize             INT = 10,
    @p_SortBy               NVARCHAR(50) = 'NombreDepartamento',
    @p_SortOrder            NVARCHAR(4) = 'ASC'
AS
BEGIN
	SET NOCOUNT ON;
-- PF_Gen_TDepartamento @p_IdEstatus = 1
-- PF_Gen_TDepartamento @p_IdGerencia = 1


	 -- Consulta principal con Common Table Expression (CTE) para paginación
    WITH DepartamentosCTE AS (
        SELECT
            IdDepartamento,
            RTRIM(NombreDepartamento) AS NombreDepartamento,
            RTRIM(ClaveDepartamento) AS ClaveDepartamento,
            g.NombreGerencia as NombreGerencia,
            IdEstatusDepartamento,
            CASE IdEstatusDepartamento
                WHEN 1 THEN 'Activo'
                WHEN 0 THEN 'Inactivo'
            END AS Estatus,
            -- Contar el total de registros que coinciden con el filtro
            COUNT(*) OVER() AS TotalRecords
        FROM
            Gen_TDepartamento d
            LEFT JOIN Gen_TGerencia g ON d.IDGerencia = g.IDGerencia 
			AND g.IdEstatusGerencia = 1
        WHERE
            (@p_IdEstatus IS NULL OR @p_IdEstatus = '%' OR IdEstatusDepartamento LIKE @p_IdEstatus)
            
            AND
            (@p_SearchQuery IS NULL OR @p_SearchQuery = '' OR
             UPPER(RTRIM(ClaveNombreDepartamento)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             UPPER(RTRIM(NombreGerencia)) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%' OR
             -- Añadida la búsqueda por estatus
             UPPER(CASE IdEstatusDepartamento WHEN 1 THEN 'Activo' WHEN 0 THEN 'Inactivo' END) LIKE '%' + UPPER(RTRIM(@p_SearchQuery)) + '%'
            )
    )
     -- Seleccionar los datos de la CTE con ordenamiento y paginación
    SELECT
        IdDepartamento,
        NombreDepartamento,
        ClaveDepartamento,
        NombreGerencia,
        IdEstatusDepartamento,
        Estatus,
        TotalRecords
    FROM DepartamentosCTE
    ORDER BY
        CASE WHEN @p_SortBy = 'NombreDepartamento' AND @p_SortOrder = 'ASC' THEN NombreDepartamento END ASC,
        CASE WHEN @p_SortBy = 'NombreDepartamento' AND @p_SortOrder = 'DESC' THEN NombreDepartamento END DESC,
        CASE WHEN @p_SortBy = 'ClaveDepartamento' AND @p_SortOrder = 'ASC' THEN ClaveDepartamento END ASC,
        CASE WHEN @p_SortBy = 'ClaveDepartamento' AND @p_SortOrder = 'DESC' THEN ClaveDepartamento END DESC,
        CASE WHEN @p_SortBy = 'NombreGerencia' AND @p_SortOrder = 'ASC' THEN NombreGerencia END ASC,
        CASE WHEN @p_SortBy = 'NombreGerencia' AND @p_SortOrder = 'DESC' THEN NombreGerencia END DESC,
        CASE WHEN @p_SortBy = 'IdEstatusDepartamento' AND @p_SortOrder = 'ASC' THEN IdEstatusDepartamento END ASC,
        CASE WHEN @p_SortBy = 'IdEstatusDepartamento' AND @p_SortOrder = 'DESC' THEN IdEstatusDepartamento END DESC
    OFFSET (@p_PageNumber - 1) * @p_PageSize ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;

    /* Old Version
	SELECT IdDepartamento
		, RTRIM(NombreDepartamento) AS NombreDepartamento
		, RTRIM(ClaveDepartamento) AS ClaveDepartamento
		, RTRIM(ISNULL(NombreGerencia, 'Sin Asignar')) AS NombreGerencia
		, IdEstatusDepartamento
		, CASE IdEstatusDepartamento
			WHEN 1 THEN 'Activo'
			WHEN 0 THEN 'Inactivo'
			END As Estatus
		, ISNULL(Gen_TGerencia.IdGerencia, 0) IdGerencia
		, CASE WHEN ClaveDepartamento = ClaveGerencia THEN 'NoBorrar' ELSE 'Borrar' END BorrarGerencia
    FROM  Gen_TDepartamento
		LEFT JOIN Gen_TGerencia ON Gen_TDepartamento.IDGerencia = Gen_TGerencia.IDGerencia 
			AND Gen_TGerencia.IdEstatusGerencia = 1
    WHERE (IdEstatusDepartamento LIKE @p_IdEstatus )
        AND (Gen_TDepartamento.IdGerencia LIKE @p_IdGerencia OR Gen_TDepartamento.IdGerencia IS NULL)
        AND (RTRIM(UPPER(NombreDepartamento)) LIKE '%' + UPPER(RTRIM(@p_NombreDepartamento) + '%'))
        AND (UPPER(ClaveDepartamento) LIKE '%' + RTRIM(UPPER(@p_ClaveDepartamento) + '%'))
    ORDER BY RTRIM(NombreDepartamento), RTRIM(NombreGerencia)
    */

END