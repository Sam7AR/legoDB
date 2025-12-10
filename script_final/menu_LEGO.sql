SET SERVEROUTPUT ON SIZE 1000000
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 50

UNDEFINE v_opcion_menu
UNDEFINE v_tienda_id
UNDEFINE v_cli_id
UNDEFINE v_cli_on_id
UNDEFINE v_prod_id_fis
UNDEFINE v_cant_fis
UNDEFINE v_prod_id_on
UNDEFINE v_cant_on
UNDEFINE v_tour_fecha_str
UNDEFINE v_tour_cli
UNDEFINE v_tour_fan

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
PROMPT

ACCEPT v_opcion_menu PROMPT '>> Su elección (1-3): '

PROMPT
BEGIN
    IF &v_opcion_menu = 1 THEN
        DBMS_OUTPUT.PUT_LINE('=== [1] NUEVA VENTA EN TIENDA FÍSICA ===');
    END IF;
END;
/

COLUMN nombre FORMAT A30 HEADING 'Nombre Tienda'
COLUMN ciudad FORMAT A20 HEADING 'Ciudad'
SELECT id_tienda, nombre, (SELECT nombre FROM ciudades c WHERE c.id_ciudad = t.id_ciudad AND c.id_estado = t.id_estado AND c.id_pais = t.id_pais) as ciudad
FROM tiendas_fisicas t
WHERE &v_opcion_menu = 1
ORDER BY id_tienda;

ACCEPT v_tienda_id PROMPT '>> Ingrese ID de la Tienda: ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 1 THEN
        DBMS_OUTPUT.PUT_LINE('--- Clientes Sugeridos ---');
    END IF;
END;
/
COLUMN cliente_nombre FORMAT A30 HEADING 'Cliente'
SELECT id_lego, p_nombre || ' ' || p_apellido as cliente_nombre 
FROM clientes 
WHERE &v_opcion_menu = 1 AND ROWNUM <= 5;

ACCEPT v_cli_id PROMPT '>> Ingrese ID del Cliente: ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 1 THEN
        DBMS_OUTPUT.PUT_LINE('--- Stock Disponible en Tienda ' || &v_tienda_id || ' ---');
    END IF;
END;
/
COLUMN juguete FORMAT A30
COLUMN stock_total FORMAT 999
SELECT j.id, j.nombre as juguete, SUM(l.cant_stock) as stock_total, h.precio
FROM juguetes j
JOIN lotes_inventarios l ON j.id = l.id_juguete
JOIN hist_precios h ON j.id = h.id_juguete
WHERE l.id_tienda = &v_tienda_id 
  AND h.fecha_fin IS NULL 
  AND &v_opcion_menu = 1
GROUP BY j.id, j.nombre, h.precio
HAVING SUM(l.cant_stock) > 0;

ACCEPT v_prod_id_fis PROMPT '>> ID Juguete a vender: ' DEFAULT 0
ACCEPT v_cant_fis    PROMPT '>> Cantidad: ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 2 THEN
        DBMS_OUTPUT.PUT_LINE('=== [2] NUEVA VENTA ONLINE ===');
        DBMS_OUTPUT.PUT_LINE('Nota: Se verificará si la venta es gratis por puntos.');
    END IF;
END;
/

SELECT id_lego, p_nombre, p_apellido, TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) as edad_actual
FROM clientes 
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) >= 21
  AND &v_opcion_menu = 2
FETCH FIRST 10 ROWS ONLY;

ACCEPT v_cli_on_id PROMPT '>> Ingrese ID Cliente Online: ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 2 THEN
        DBMS_OUTPUT.PUT_LINE('--- Catálogo Disponible para el País del Cliente &v_cli_on_id ---');
    END IF;
END;
/
COLUMN desc_juguete FORMAT A35
COLUMN precio FORMAT 999.99 HEADING 'Precio'
COLUMN limite FORMAT 99 HEADING 'Lim. Max'

SELECT j.id, j.nombre as desc_juguete, c.lim_compra_ol as limite, h.precio
FROM juguetes j
JOIN hist_precios h ON j.id = h.id_juguete
JOIN catalogos c ON j.id = c.id_juguete 
WHERE h.fecha_fin IS NULL
  AND &v_opcion_menu = 2
  AND c.id_pais = (SELECT id_pais_resi FROM clientes WHERE id_lego = &v_cli_on_id)
ORDER BY j.id;

ACCEPT v_prod_id_on PROMPT '>> ID Juguete a enviar: ' DEFAULT 0
ACCEPT v_cant_on    PROMPT '>> Cantidad: ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 3 THEN
        DBMS_OUTPUT.PUT_LINE('=== [3] INSCRIPCIÓN INSIDE TOUR ===');
    END IF;
END;
/

COLUMN fec_inic HEADING 'Fecha Inicio'
COLUMN cupos_disp HEADING 'Cupos Disp.'
COLUMN precio_ent HEADING 'Precio Entrada'

SELECT 
    TO_CHAR(t.fec_inic, 'DD/MM/YY') AS fec_inic, 
    (t.cupos_tot - NVL((SELECT COUNT(*) FROM inscritos i WHERE i.id_tour = t.fec_inic), 0)) AS cupos_disp,
    t.precio_ent 
FROM tours t
WHERE t.fec_inic > SYSDATE 
  AND &v_opcion_menu = 3;

PROMPT (Formato Fecha: DD/MM/YY)
ACCEPT v_tour_fecha_str PROMPT '>> Ingrese Fecha del Tour (Ej. 01/10/26): ' DEFAULT '01/01/00'

PROMPT
BEGIN
    IF &v_opcion_menu = 3 THEN
        DBMS_OUTPUT.PUT_LINE('--- Clientes Adultos (Mayores de 21 años) ---');
        DBMS_OUTPUT.PUT_LINE('(Estos ID pueden asistir o ser Representantes)');
    END IF;
END;
/
COLUMN cliente_nombre FORMAT A30 HEADING 'Nombre'
COLUMN edad_actual FORMAT 99 HEADING 'Edad'

SELECT id_lego, p_nombre || ' ' || p_apellido as cliente_nombre, TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) as edad_actual
FROM clientes 
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) >= 21
  AND &v_opcion_menu = 3
ORDER BY id_lego;

ACCEPT v_tour_cli PROMPT '>> ID Cliente que asiste (Adulto): ' DEFAULT 0

PROMPT
BEGIN
    IF &v_opcion_menu = 3 THEN
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('--- Fans Menores Disponibles ---');
        DBMS_OUTPUT.PUT_LINE('IMPORTANTE: El Fan Menor debe estar asociado al Adulto seleccionado arriba.');
    END IF;
END;
/
COLUMN fan_nombre FORMAT A30 HEADING 'Fan Menor'
COLUMN rep_id FORMAT 9999 HEADING 'ID Rep.'
COLUMN rep_nombre FORMAT A25 HEADING 'Nombre Rep.'

SELECT f.id_fan, f.p_nombre || ' ' || f.p_apellido as fan_nombre, 
       f.id_representante as rep_id, 
       c.p_nombre || ' ' || c.p_apellido as rep_nombre
FROM fans_menores f
JOIN clientes c ON f.id_representante = c.id_lego
WHERE &v_opcion_menu = 3;

ACCEPT v_tour_fan PROMPT '>> ID Fan Menor a inscribir (0 si ninguno): ' DEFAULT 0


DECLARE
    v_opcion      NUMBER := &v_opcion_menu;
    
    v_detalles    det_fac_tab;         
    
    v_clientes_tour id_tab;            
    v_fans_tour     id_tab;
    v_fecha_tour    DATE;
    
BEGIN
    IF v_opcion NOT IN (1, 2, 3) THEN
        DBMS_OUTPUT.PUT_LINE('Opción no válida. Intente de nuevo o detenga el script.');
        RETURN; 
    END IF;

    IF v_opcion = 1 THEN
        v_detalles := det_fac_tab();
        v_detalles.extend; 
        
        v_detalles(1) := det_fac_params(&v_prod_id_fis, &v_cant_fis, 'MA'); 
        
        DBMS_OUTPUT.PUT_LINE('Procesando Venta Física...');
        
        registrar_factura_tienda(
            p_id_tienda  => &v_tienda_id,
            p_id_cliente => &v_cli_id,
            p_detalles   => v_detalles
        );
        
        COMMIT;
    END IF;

    IF v_opcion = 2 THEN
        v_detalles := det_fac_tab();
        v_detalles.extend;
        
        v_detalles(1) := det_fac_params(&v_prod_id_on, &v_cant_on, 'MA');
        
        DBMS_OUTPUT.PUT_LINE('Procesando Venta Online...');
        
        registrar_factura_online(
            p_id_cliente => &v_cli_on_id,
            p_detalles   => v_detalles
        );
        
        COMMIT;
    END IF;

    IF v_opcion = 3 THEN
        v_fecha_tour := TO_DATE('&v_tour_fecha_str', 'DD/MM/YY'); 
        
        v_clientes_tour := id_tab();
        v_clientes_tour.extend;
        v_clientes_tour(1) := &v_tour_cli; 
        
        v_fans_tour := id_tab();
        IF &v_tour_fan > 0 THEN
            v_fans_tour.extend;
            v_fans_tour(1) := &v_tour_fan;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Inscribiendo en Tour...');
        
        registrar_inscripcion_tour(
            p_fec_tour => v_fecha_tour,
            p_clientes => v_clientes_tour,
            p_fans     => v_fans_tour
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('>> ¡Inscripción Registrada! Recibo generado en estado pendiente.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('!!! ERROR EN LA TRANSACCIÓN !!!');
        DBMS_OUTPUT.PUT_LINE('Mensaje Oracle: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT Presione ENTER para volver al menú...
PAUSE

@@menu_LEGO.sql