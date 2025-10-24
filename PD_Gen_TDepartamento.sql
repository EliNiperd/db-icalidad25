USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PD_Gen_TDepartamento]    Script Date: 22/10/2025 10:45:59 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PD_Gen_TDepartamento]
@p_IdDepartamento INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_result INT = -1
		, @v_mensaje nvarchar(50) = 'Ocurrió un error al eliminar'
	BEGIN
		BEGIN TRANSACTION

		DELETE FROM Gen_TDepartamento
		WHERE IdDepartamento = @p_IdDepartamento
		SET @v_result = 0;
		SET @v_mensaje = 'Creación exitosa';
		COMMIT TRANSACTION
	END 

	SELECT @v_result AS Resultado
			 , @v_mensaje as Mensaje
END

