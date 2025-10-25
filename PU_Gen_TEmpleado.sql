USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PU_Gen_TEmpleado]    Script Date: 24/10/2025 12:36:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Elí Rodríguez
-- Create date: Marzo 2009
-- Description:	Actualiza la información del empleado
-- =============================================
ALTER PROCEDURE [dbo].[PU_Gen_TEmpleado] 
	@p_IdEmpleado			INT
	, @p_NombreEmpleado		NVARCHAR(200)
	, @p_UserName			NVARCHAR(100)
	, @p_Password			NVARCHAR(50)
	, @p_Correo				NVARCHAR(100) = NULL
	, @p_IdEstatusEmpleado  bit
	, @p_RelacionXML		nvarchar(MAX) = NULL
	, @p_ReasignarEvaluacion bit
	, @p_ParametroControlXML nvarchar(MAX) = NULL
	, @p_IdEmpleadoActualiza int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_Result	INT
		, @v_XML XML
		, @v_ParametroControlXML XML
	
	SELECT @v_Result = Count(IdEmpleado)
	FROM Gen_TEmpleado
	WHERE UPPER(UserName) = UPPER(@p_Username)
		AND IdEstatusEmpleado = 1
		AND IdEmpleado <> @p_idEmpleado;
		
		
	SET @v_ParametroControlXML = CAST(@p_ParametroControlXML as XML)
	
	IF @v_Result > 0
		SET @v_Result = -1
	ELSE
		BEGIN 	
			BEGIN TRY
			BEGIN TRANSACTION
				UPDATE Gen_TEmpleado
				SET NombreEmpleado = @p_NombreEmpleado
					, UserName = @p_UserName
					, Password = @p_Password
					, Correo = @p_Correo
					, IdEstatusEmpleado = @p_IdEstatusEmpleado
					--, IdEmpleadoActualiza = (SELECT x.item.value('IdEmpleado[1]','int') 
					--					FROM @v_ParametroControlXML.nodes('//ParametroControl') AS x(item))
					, FechaActualiza = GETDATE()
					, IdEmpleadoActualiza = @p_IdEmpleadoActualiza
				WHERE IdEmpleado = @p_IdEmpleado;

				SET ARITHABORT ON
				SET @v_XML = CAST(@p_RelacionXML as XML)
		
				--- Se elimina por que se hace en forma individual
				/*
				DELETE FROM Gen_REmpleadoPuesto 
				WHERE IdEmpleado = @p_IdEmpleado

				INSERT INTO Gen_REmpleadoPuesto(IdEmpleado, IdPuesto)
				SELECT @p_IDEmpleado
						, x.item.value('IdPuesto[1]','int') AS IdPuesto
				FROM  @v_XML.nodes('//DS_Relacion/TPuesto') AS x(item)


				DELETE FROM Gen_REmpleadoRol 
				WHERE IdEmpleado = @p_IdEmpleado

				INSERT INTO Gen_REmpleadoRol(IdEmpleado, IdRol)
				SELECT @p_IDEmpleado
						, x.item.value('IdRol[1]','int') AS IdRol
				FROM  @v_XML.nodes('//DS_Relacion/TRol') AS x(item)
				*/

				-- Opción cuando se marca para que se reasignen los Examenes
				-- Cuando Actualizan el Nombre del Empleado y marca la opción correspondiente
				If @p_ReasignarEvaluacion = 1
					UPDATE doc_RExamenEmpleado
					SET Intentos = 0
						, Aprobo = 0
						, Calificacion = 0
						, FechaUltimoIntento = NULL
					WHERE IdEmpleado = @p_IdEmpleado


			COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
			END CATCH
			
			SET @v_result = @p_IdEmpleado
		END
	
	SELECT @v_Result As Resultado

END