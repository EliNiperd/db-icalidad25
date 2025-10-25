--Operaciones generales
SELECT * FROM Gen_TGerencia WHERE ClaveGerencia = 'ZZ3'
SELECT * FROM Gen_TDepartamento
SELECT * FROM Gen_TPuesto

SELECT * FROm Gen_REmpleadoPuesto WHERE IdEmpleado > 129
SELECT * FROM Gen_TEmpleado WHERE IdEmpleado > 129

SELECT * FROM Gen_TRol

SELECT * FROM Gen_REmpleadoRol WHERE IdEmpleado > 129

UPDATE Gen_TGerencia
SET IdEmpleadoAlta = 92
WHERE IdEmpleadoAlta = 0

SELECT * FROM Gen_TMenu WHERE Menu = 'Requisitos'
UPDATE Gen_TMenu
SET URL = '/icalidad/normativa'
WHERE IdMenu = 163

UPDATE Gen_TMenu
SET URL = '/icalidad/normativa'
WHERE IdMenu = 7

UPDATE Gen_TMenu
SET URL = '/icalidad/requisito'
WHERE IdMenu = 164

SELECT * FROM Gen_TEmpleado

SELECT * FROM Gen_TNormativa WHERE IdNormativa = 11
UPDATE Gen_TNormativa
SET NombreNormativa = 'Prueba normativa'
WHERE IdNormativa = 11

SELECT * FROM Gen_TRequisito

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
    WHERE (IdEstatusDepartamento LIKE '%' )
        AND (Gen_TDepartamento.IdGerencia LIKE '%' OR Gen_TDepartamento.IdGerencia IS NULL)
        AND (RTRIM(UPPER(NombreDepartamento)) LIKE '%' + UPPER(RTRIM('%') + '%'))
        AND (UPPER(ClaveDepartamento) LIKE '%' + RTRIM(UPPER('%') + '%'))
    ORDER BY RTRIM(NombreDepartamento), RTRIM(NombreGerencia)