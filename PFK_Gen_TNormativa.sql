USE [iCalidadCCMSLP22]
GO

/****** Object:  StoredProcedure [dbo].[PFK_Gen_TNormativa]    Script Date: 24/10/2025 05:59:20 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Elí Rodríguez
-- Create date: Julio 2011
-- Description:	Recupera las Normativas por datakey
-- =============================================
ALTER PROCEDURE [dbo].[PFK_Gen_TNormativa] 
	@p_IdNormativa Int
AS
BEGIN
	-- PFK_Gen_TNormativa 11
	SET NOCOUNT ON;

    SELECT ISNULL(Gen_TNormativa.IdNormativa, 0) IdNormativa
		, NombreNormativa
		, ClaveNormativa
		, IdEstatusNormativa
    FROM Gen_TNormativa
	WHERE IdNormativa = @p_IdNormativa
END
GO

