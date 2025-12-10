-- Limpiamos variables locales de este proceso
UNDEFINE v_tienda_id
UNDEFINE v_nombre_tienda_disp
UNDEFINE v_cli_id
UNDEFINE v_prod_list_fis
UNDEFINE v_cant_fis

PROMPT
PROMPT === [1] NUEVA VENTA EN TIENDA FÍSICA ===

-- 1. Mostrar Tiendas
COLUMN nombre FORMAT A30 HEADING 'Nombre Tienda'
COLUMN ciudad FORMAT A20 HEADING 'Ciudad'
SELECT id_tienda, nombre, 
       (SELECT nombre FROM ciudades c WHERE c.id_ciudad = t.id_ciudad AND c.id_estado = t.id_estado AND c.id_pais = t.id_pais) as ciudad
FROM tiendas_fisicas t
ORDER BY id_tienda;

ACCEPT v_tienda_id PROMPT '>> Ingrese ID de la Tienda: ' DEFAULT 0

COLUMN nombre_real NEW_VALUE v_nombre_tienda_disp
SELECT nombre as nombre_real FROM tiendas_fisicas WHERE id_tienda = &v_tienda_id;

-- 2. Mostrar Clientes
PROMPT --- Clientes Sugeridos ---
COLUMN cliente_nombre FORMAT A30 HEADING 'Cliente'
SELECT id_lego, p_nombre || ' ' || p_apellido as cliente_nombre 
FROM clientes;

ACCEPT v_cli_id PROMPT '>> Ingrese ID del Cliente: ' DEFAULT 0

-- 3. Mostrar Stock
PROMPT --- Stock Disponible en: &v_nombre_tienda_disp ---
COLUMN juguete FORMAT A30
COLUMN stock_total FORMAT 999
SELECT j.id, j.nombre as juguete, SUM(l.cant_stock) as stock_total, h.precio
FROM juguetes j
JOIN lotes_inventarios l ON j.id = l.id_juguete
JOIN hist_precios h ON j.id = h.id_juguete
WHERE l.id_tienda = &v_tienda_id 
  AND h.fecha_fin IS NULL 
GROUP BY j.id, j.nombre, h.precio
HAVING SUM(l.cant_stock) > 0;

ACCEPT v_prod_list_fis PROMPT '>> IDs Juguetes (separados por coma, ej: 1,5): ' DEFAULT '0'
ACCEPT v_cant_fis      PROMPT '>> Cantidad (para cada producto): ' DEFAULT 0

-- 4. Procesar PL/SQL
DECLARE
    v_detalles    det_fac_tab := det_fac_tab();
    v_input_str   VARCHAR2(400);
    v_temp_str    VARCHAR2(100);
    v_comma_pos   NUMBER;
    v_temp_id     NUMBER;
BEGIN
    v_input_str := '&v_prod_list_fis' || ',';
    
    WHILE INSTR(v_input_str, ',') > 0 LOOP
        v_comma_pos := INSTR(v_input_str, ',');
        v_temp_str := TRIM(SUBSTR(v_input_str, 1, v_comma_pos - 1));
        BEGIN
            v_temp_id := TO_NUMBER(v_temp_str);
            IF v_temp_id > 0 THEN
                v_detalles.extend;
                v_detalles(v_detalles.LAST) := det_fac_params(v_temp_id, &v_cant_fis, 'MA');
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL; END;
        v_input_str := SUBSTR(v_input_str, v_comma_pos + 1);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Procesando Venta Física...');
    registrar_factura_tienda(&v_tienda_id, &v_cli_id, v_detalles);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('>> ¡Venta Física Exitosa!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('!!! ERROR: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT Presione ENTER para volver al menú...
PAUSE
@@menu_LEGO.sql