USE [iCalidadCCMSLP22]
GO
/****** Object:  StoredProcedure [dbo].[PI_Gen_TEmpleado]    Script Date: 23/10/2025 02:26:42 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Elí Rodríguez
-- Create date: Marzo 2009
-- Update: Octubre 2025
-- Se actualiza para cambiar la forma de recibir parámetros
-- Description:	Inserta un Empleado
-- =============================================
ALTER PROCEDURE [dbo].[PI_Gen_TEmpleado] 
	@p_NombreEmpleado	NVARCHAR(200)
	, @p_UserName		NVARCHAR(100)
	, @p_Password		NVARCHAR(50)
	, @p_Correo			NVARCHAR(100) = NULL
	, @p_IdEmpleadoAlta int = 0
	, @p_RelacionXML	nvarchar(MAX) = NULL
	, @p_ParametroControlXML nvarchar(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	-- PI_Gen_TEmpleado 'Elí Rodríguez', 'erodriguez', 'prueba1', 'eli.rodriguez@gmail.com', 92
-- PI_Gen_TEmpleado 'z', 'z', 'z', NULL, NULL, '<ParametroControl><IdEmpleado>1</IdEmpleado></ParametroControl>'
    DECLARE @v_IdEmpleado INT
		, @v_XML XML
		, @v_ParametroControlXML XML
	
		
	--SET @v_ParametroControlXML = CAST(@p_ParametroControlXML as XML)
	
	SELECT @v_IdEmpleado = COUNT(IdEmpleado)
    FROM Gen_TEmpleado
    WHERE UPPER(UserName) = UPPER(@p_UserName)
        --OR UPPER(NombreEmpleado) = UPPER(@p_NombreEmpleado))
        --AND IDEstatusEmpleado = 1

    IF @v_IDEmpleado > 0
		BEGIN
			SET @v_IDEmpleado = -1
			SELECT @v_IDEmpleado AS Resultado, 'El nombre de usuario ya existe' Mensaje
        END
    ELSE
		BEGIN
			BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO Gen_TEmpleado (NombreEmpleado, UserName, Password, Correo, IdEmpleadoAlta, FechaAlta)
				SELECT @p_NombreEmpleado, @p_UserName, @p_Password, @p_Correo, @p_IdEmpleadoAlta , GETDATE()
				--FROM @v_ParametroControlXML.nodes('//ParametroControl') AS x(item)

				SET @v_IDEmpleado = @@Identity

				--SET @v_XML = CAST(@p_RelacionXML as XML)

				/*
				INSERT INTO Gen_REmpleadoPuesto(IdEmpleado, IdPuesto)
				SELECT @v_IDEmpleado
						, x.item.value('IdPuesto[1]','int') AS IdPuesto
				FROM  @v_XML.nodes('//DS_Relacion/TPuesto') AS x(item)

				INSERT INTO Gen_REmpleadoRol(IdEmpleado, IdRol)
				SELECT @v_IDEmpleado
						, x.item.value('IdRol[1]','int') AS IdRol
				FROM  @v_XML.nodes('//DS_Relacion/TRol') AS x(item)
				*/
			SELECT @v_IdEmpleado AS Resultado, 'Insertado Correcto' Mensaje
				
			COMMIT TRANSACTION
			
			
		END TRY
		BEGIN CATCH
			SELECT -2 AS Resultado, 'Existe un Error' + ERROR_MESSAGE() + ', Error Número:' + CAST(@@ERROR as nvarchar) Mensaje
			ROLLBACK TRANSACTION
		END CATCH
			
        END
    
	
	

END