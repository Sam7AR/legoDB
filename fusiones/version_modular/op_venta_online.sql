UNDEFINE v_cli_on_id
UNDEFINE v_prod_list_on
UNDEFINE v_cant_on

CLEAR SCREEN
PROMPT
PROMPT === [2] NUEVA VENTA ONLINE ===
PROMPT Nota: Se verificará si la venta es gratis por puntos.
PROMPT

-- 1. Mostrar Clientes Aptos
COLUMN p_nombre FORMAT A15
COLUMN p_apellido FORMAT A15
COLUMN edad_actual FORMAT 99

PROMPT --- Paso 1: Seleccione Cliente (Solo mayores de 21) ---

-- Consulta unificada en una sola línea
SELECT id_lego, p_nombre, p_apellido, TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) as edad_actual FROM clientes WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) >= 21 ORDER BY id_lego;

PROMPT
ACCEPT v_cli_on_id PROMPT '>> Ingrese ID Cliente Online: ' DEFAULT 0

CLEAR SCREEN
PROMPT === [2] NUEVA VENTA ONLINE ===
PROMPT Cliente Seleccionado: &v_cli_on_id
PROMPT

-- 2. Mostrar Catálogo del País
COLUMN desc_juguete FORMAT A35
COLUMN precio FORMAT 999.99 HEADING 'Precio'
COLUMN limite FORMAT 99 HEADING 'Lim. Max'

PROMPT --- Paso 2: Catálogo Disponible para el País del Cliente ---

-- Consulta unificada en una sola línea
SELECT j.id, j.nombre as desc_juguete, c.lim_compra_ol as limite, h.precio FROM juguetes j JOIN hist_precios h ON j.id = h.id_juguete JOIN catalogos c ON j.id = c.id_juguete WHERE h.fecha_fin IS NULL AND c.id_pais = (SELECT id_pais_resi FROM clientes WHERE id_lego = &v_cli_on_id) ORDER BY j.id;

PROMPT
ACCEPT v_prod_list_on PROMPT '>> IDs Juguetes (separados por coma, ej: 1,5): ' DEFAULT '0'
ACCEPT v_cant_on      PROMPT '>> Cantidad (para cada producto): ' DEFAULT 0

CLEAR SCREEN
-- 3. Procesar
DECLARE
    v_detalles    det_fac_tab := det_fac_tab();
    v_input_str   VARCHAR2(400);
    v_temp_str    VARCHAR2(100);
    v_comma_pos   NUMBER;
    v_temp_id     NUMBER;
BEGIN
    v_input_str := '&v_prod_list_on' || ',';
    WHILE INSTR(v_input_str, ',') > 0 LOOP
        v_comma_pos := INSTR(v_input_str, ',');
        v_temp_str := TRIM(SUBSTR(v_input_str, 1, v_comma_pos - 1));
        BEGIN
            v_temp_id := TO_NUMBER(v_temp_str);
            IF v_temp_id > 0 THEN
                v_detalles.extend;
                v_detalles(v_detalles.LAST) := det_fac_params(v_temp_id, &v_cant_on, 'MA');
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL; END;
        v_input_str := SUBSTR(v_input_str, v_comma_pos + 1);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Procesando Venta Online...');
    registrar_factura_online(&v_cli_on_id, v_detalles);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('>> ¡Venta Online Exitosa!');
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