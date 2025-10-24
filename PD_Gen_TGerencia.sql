USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PD_Gen_TGerencia]    Script Date: 22/10/2025 09:50:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Elí Rodriguez
-- Create date: Febrero 2009
-- Description:	Eliminar una Gerencia
-- =============================================
ALTER PROCEDURE [dbo].[PD_Gen_TGerencia] 
	@p_IdGerencia Int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_result INT = -1
		, @v_mensaje nvarchar(50) = 'Ocurrió un error al eliminar'
	BEGIN
		BEGIN TRANSACTION
		DELETE FROM Gen_TGerencia
		WHERE IdGerencia = @p_IdGerencia

		SET @v_result = 0;
		SET @v_mensaje = 'Creación exitosa';
		COMMIT TRANSACTION
	END 

	SELECT @v_result AS Resultado
			 , @v_mensaje as Mensaje

END