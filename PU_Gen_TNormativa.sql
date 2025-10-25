USE [iCalidadCCMSLP22]
GO

/****** Object:  StoredProcedure [dbo].[PU_Gen_TNormativa]    Script Date: 24/10/2025 05:51:59 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PU_Gen_TNormativa]
	@p_IdNormativa INT
	, @p_NombreNormativa NVARCHAR (100)
	, @p_ClaveNormativa NVARCHAR (50)
	, @p_IdEstatusNormativa BIT
	, @p_IdEmpleadoActualiza Int
AS
	DECLARE @v_result	INT
		, @v_mensaje nvarchar(50) 
	
	SELECT @v_result = COUNT(IdNormativa)
	FROM Gen_TNormativa
	WHERE (UPPER(NombreNormativa) = UPPER(@p_NombreNormativa)
                OR UPPER(ClaveNormativa) = UPPER(@p_ClaveNormativa))
                AND IdNormativa <> @p_IdNormativa
                AND IdEstatusNormativa = 1;
    
    IF @v_result > 0
	BEGIN
		SET @v_Result = 500
		SET @v_mensaje = 'Se está duplicando la normativa'
	END
	ELSE
		BEGIN
			BEGIN TRANSACTION
				UPDATE Gen_TNormativa
				SET NombreNormativa = @p_NombreNormativa
					, ClaveNormativa = @p_ClaveNormativa
					, IdEstatusNormativa = @p_IdEstatusNormativa
					, IdEmpleadoActualiza = @p_IdEmpleadoActualiza
					, FechaActualiza = GETDATE()
				WHERE IdNormativa = @p_IdNormativa;
            COMMIT TRANSACTION
			SET @v_result = @p_idNormativa
			SET @v_mensaje = 'Actualización exitosa de la normativa'
		END
	
	SELECT @v_result AS Resultado
		, @v_mensaje as Mensaje
	RETURN

GO

