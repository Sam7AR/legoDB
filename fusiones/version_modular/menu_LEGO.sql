SET SERVEROUTPUT ON SIZE 1000000
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 50

-- Limpieza de variables globales
UNDEFINE v_opcion_menu
UNDEFINE v_next_script

CLEAR SCREEN
PROMPT
PROMPT ######################################################################
PROMPT #                 SISTEMA LEGO - MENÚ DE TRANSACCIONES               #
PROMPT ######################################################################
PROMPT
PROMPT Seleccione la transacción a realizar:
PROMPT
PROMPT   1. VENTA EN TIENDA FÍSICA
PROMPT   2. VENTA ONLINE
PROMPT   3. INSCRIPCIÓN INSIDE TOUR
PROMPT   4. CONFIRMAR PAGO
PROMPT   5. SALIR
PROMPT

ACCEPT v_opcion_menu PROMPT '>> Su elección (1-5): '

-- Lógica Mágica: Definimos qué archivo ejecutar según la opción
COLUMN script_name NEW_VALUE v_next_script

SELECT CASE &v_opcion_menu
       WHEN 1 THEN 'op_venta_fisica.sql'
       WHEN 2 THEN 'op_venta_online.sql'
       WHEN 3 THEN 'op_tour.sql'
       WHEN 4 THEN 'op_pago.sql'
       WHEN 5 THEN 'op_salir.sql'
       ELSE 'menu_LEGO.sql'  -- Si se equivoca, recarga el menú
       END AS script_name 
FROM DUAL;

-- Ejecutamos el script seleccionado dinámicamente
@@&v_next_script