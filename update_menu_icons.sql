-- Script para actualizar los iconos de Gen_TMenu a nombres compatibles con Lucide-React

-- Acciones
UPDATE Gen_TMenu
SET Icono = 'Users'
WHERE Menu = 'Acciones';

-- Auditor�as
UPDATE Gen_TMenu
SET Icono = 'ClipboardList'
WHERE Menu = 'Auditor�as';

-- Carpetas
UPDATE Gen_TMenu
SET Icono = 'Folder'
WHERE Menu = 'Carpetas';

-- Cat�logos (MdAdminPanelSettings)
UPDATE Gen_TMenu
SET Icono = 'Settings'
WHERE Menu = 'Cat�logos' AND Icono = 'MdAdminPanelSettings'; -- Aseg�rate de que esta condici�n sea espec�fica si tienes varios 'Cat�logos'

-- Cat�logos (RiArchiveDrawerFill)
UPDATE Gen_TMenu
SET Icono = 'Archive'
WHERE Menu = 'Cat�logos' AND Icono = 'RiArchiveDrawerFill'; -- Aseg�rate de que esta condici�n sea espec�fica si tienes varios 'Cat�logos'

-- Configuraci�n iCalidad
UPDATE Gen_TMenu
SET Icono = 'Settings'
WHERE Menu = 'Configuraci�n iCalidad';

-- Documentos Admin
UPDATE Gen_TMenu
SET Icono = 'UserCog'
WHERE Menu = 'Documentos Admin';

-- iCalidad
UPDATE Gen_TMenu
SET Icono = 'Home'
WHERE Menu = 'iCalidad';

-- Normativas
UPDATE Gen_TMenu
SET Icono = 'Ruler'
WHERE Menu = 'Normativas';

-- Personal Competente
UPDATE Gen_TMenu
SET Icono = 'Users'
WHERE Menu = 'Personal Competente';

-- Poder Documental
UPDATE Gen_TMenu
SET Icono = 'MessageSquare'
WHERE Menu = 'Poder Documental';

-- Procesos
UPDATE Gen_TMenu
SET Icono = 'Layers'
WHERE Menu = 'Procesos';

-- Registros
UPDATE Gen_TMenu
SET Icono = 'ClipboardCheck'
WHERE Menu = 'Registros';

-- Reportes
UPDATE Gen_TMenu
SET Icono = 'FileText'
WHERE Menu = 'Reportes';

-- Requisitos
UPDATE Gen_TMenu
SET Icono = 'Notebook'
WHERE Menu = 'Requisitos';

-- Salir
UPDATE Gen_TMenu
SET Icono = 'LogOut'
WHERE Menu = 'Salir';

-- Solicitudes
UPDATE Gen_TMenu
SET Icono = 'CheckSquare'
WHERE Menu = 'Solicitudes';

-- Opcional: Limpiar iconos para IdEstatusMenu = 1 o donde no se desee icono
-- UPDATE Gen_TMenu
-- SET Icono = NULL -- O Icono = ''
-- WHERE IdEstatusMenu = 1;

-- Confirmaci�n
SELECT Menu, Icono FROM Gen_TMenu WHERE Menu IN (
    'Acciones', 'Auditor�as', 'Carpetas', 'Cat�logos', 'Configuraci�n iCalidad',
    'Documentos Admin', 'iCalidad', 'Normativas', 'Personal Competente',
    'Poder Documental', 'Procesos', 'Registros', 'Reportes', 'Requisitos',
    'Salir', 'Solicitudes'
);
