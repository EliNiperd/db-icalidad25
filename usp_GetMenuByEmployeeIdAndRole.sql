USE [iCalidadCCMSLP22]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetMenuByEmployeeIdAndRole]    Script Date: 20/10/2025 03:04:31 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Autor:       El� Rodr�guez
-- Fecha:       2025-10-19
-- Descripci�n: Obtiene el men� din�mico para un empleado y un rol espec�fico.
--              Permite filtrar por un IdMenuPadre para submen�s.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMenuByEmployeeIdAndRole] (
    @p_IdEmpleado INT,
    @p_IdRolPrincipal INT, -- Se pasa el rol principal del empleado
    @p_ParentMenuId INT = NULL -- NULL para obtener men�s de nivel superior
)
AS
BEGIN
    SET NOCOUNT ON;
    -- usp_GetMenuByEmployeeIdAndRole 92, 1, 149

    INSERT INTO Sis_TPrueba(Texto, Entero)
    VALUES(@p_IdEmpleado, @p_IdRolPrincipal)

    -- Declarar constantes para mayor claridad
    DECLARE @ESTATUS_ACTIVO INT = 1;
    DECLARE @ESTATUS_VISIBLE_ESPECIAL INT = 2; -- Asumiendo que 2 es para men�s visibles bajo ciertas condiciones
    DECLARE @ROL_SUPER_ADMIN INT = 1;
    DECLARE @MENU_RAIZ_ID INT = 149; -- Asumiendo que 149 es el ID del men� ra�z 'iCalidad'

    -- Tabla temporal para almacenar los roles del empleado, incluyendo el rol de Super Administrador
    CREATE TABLE #EmployeeRoles (IdRol INT PRIMARY KEY);
    INSERT INTO #EmployeeRoles (IdRol)
    SELECT IdRol FROM Gen_REmpleadoRol WHERE IdEmpleado = @p_IdEmpleado GROUP BY IdRol;
    --UNION ALL
    --SELECT @ROL_SUPER_ADMIN ; -- Incluir el rol de Super Administrador

    -- L�gica para obtener el men�
    SELECT
        M.IdMenu AS id,
        M.Menu AS nombre,
        ISNULL(M.Icono, '') AS icono,
        ISNULL(M.URL, '') AS ruta,
        ISNULL(M.IdMenuPadre, 0) AS idPadre, -- Usar 0 para indicar que es un men� ra�z si es NULL
        M.OrdenMenu AS orden
    FROM
        Gen_TMenu AS M
    INNER JOIN
        #EmployeeRoles AS ER ON M.IdRol = ER.IdRol
    WHERE M.IdEstatusMenu IN (2)
        --M.IdEstatusMenu IN (@ESTATUS_ACTIVO, @ESTATUS_VISIBLE_ESPECIAL) -- Considerar ambos estatus si aplica
        AND (@p_ParentMenuId IS NULL OR ISNULL(M.IdMenuPadre, 0) = @p_ParentMenuId)
        -- Si necesitas l�gica espec�fica para el rol de administrador, hazlo aqu�
        -- Por ejemplo, si el rol principal es 'iCalidad Administrador' y quieres mostrar algo especial
        -- AND (
        --     (@p_IdRolPrincipal = (SELECT IdRol FROM Gen_TRol WHERE NombreRol = 'iCalidad Administrador') AND M.Menu = 'iCalidad')
        --     OR
        --     (@p_IdRolPrincipal != (SELECT IdRol FROM Gen_TRol WHERE NombreRol = 'iCalidad Administrador') AND M.Menu != 'Salir')
        --     OR
        --     (M.Menu = 'Salir')
        -- )
    ORDER BY
        m.IdMenuPadre,M.OrdenMenu, M.IdMenu;

    DROP TABLE #EmployeeRoles;
END
GO

