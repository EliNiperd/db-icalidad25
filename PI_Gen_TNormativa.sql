USE [iCalidadCCMSLP22]
GO

/****** Object:  StoredProcedure [dbo].[PI_Gen_TNormativa]    Script Date: 24/10/2025 05:45:21 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PI_Gen_TNormativa]
	@p_NombreNormativa NVARCHAR (100)
	, @p_ClaveNormativa NVARCHAR (50)
	, @p_IdEmpleadoAlta int
AS
	DECLARE @v_result	INT = 200,
		@v_mensaje nvarchar(50) = 'Ocurrió un error en PI_Gen_TNormativa'
	
	SELECT @v_result = COUNT(IdNormativa)
    FROM Gen_TNormativa
    WHERE (UPPER(NombreNormativa) = UPPER(@p_NombreNormativa)
        OR UPPER(ClaveNormativa) = UPPER(@p_ClaveNormativa))
        AND IdEstatusNormativa = 1

    IF @v_result > 0
        SET @v_result = 500
    ELSE
		BEGIN
			BEGIN TRANSACTION
				INSERT INTO Gen_TNormativa (NombreNormativa, ClaveNormativa, IdEmpleadoAlta)
				VALUES (@p_NombreNormativa, @p_ClaveNormativa, @p_IdEmpleadoAlta);
				SET @v_result = @@Identity
			COMMIT TRANSACTION
			SET @v_mensaje = 'Nomativa creada con éxito'
		END
    
	SELECT @v_result AS Resultado
		, @v_mensaje
GO

