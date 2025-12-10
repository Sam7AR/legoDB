-- Limpiamos variables locales
UNDEFINE v_tienda_id
UNDEFINE v_nombre_tienda_disp
UNDEFINE v_cli_id
UNDEFINE v_items_fis

CLEAR SCREEN
PROMPT
PROMPT === [1] NUEVA VENTA EN TIENDA FÍSICA ===

-- 1. Mostrar Tiendas
COLUMN nombre FORMAT A30 HEADING 'Nombre Tienda'
COLUMN ciudad FORMAT A20 HEADING 'Ciudad'

PROMPT
PROMPT --- Paso 1: Seleccione una Tienda ---

SELECT t.id_tienda,
       t.nombre,
       (SELECT c.nombre
          FROM ciudades c
         WHERE c.id_ciudad = t.id_ciudad
           AND c.id_estado = t.id_estado
           AND c.id_pais   = t.id_pais) ciudad
  FROM tiendas_fisicas t
 ORDER BY t.id_tienda;

PROMPT
ACCEPT v_tienda_id PROMPT '>> Ingrese ID de la Tienda: ' DEFAULT 0

-- Ocultamos la consulta interna
SET TERM OFF
COLUMN nombre_real NEW_VALUE v_nombre_tienda_disp
SELECT nombre AS nombre_real
  FROM tiendas_fisicas
 WHERE id_tienda = &v_tienda_id;
SET TERM ON

CLEAR SCREEN
PROMPT === [1] NUEVA VENTA EN TIENDA FÍSICA ===
PROMPT Tienda Seleccionada: &v_nombre_tienda_disp
PROMPT

-- 2. Mostrar Clientes
COLUMN cliente_nombre FORMAT A30 HEADING 'Cliente'

PROMPT --- Paso 2: Identifique al Cliente ---

SELECT id_lego,
       p_nombre || ' ' || p_apellido AS cliente_nombre
  FROM clientes
 WHERE ROWNUM <= 15;

PROMPT
ACCEPT v_cli_id PROMPT '>> Ingrese ID del Cliente: ' DEFAULT 0

CLEAR SCREEN
PROMPT === [1] NUEVA VENTA EN TIENDA FÍSICA ===
PROMPT Tienda: &v_nombre_tienda_disp | Cliente ID: &v_cli_id
PROMPT

-- 3. Mostrar Stock disponible en la tienda seleccionada
COLUMN juguete     FORMAT A30
COLUMN stock_total FORMAT 999
COLUMN precio      FORMAT 999990.99

PROMPT --- Paso 3: Selección de Productos ---

SELECT j.id,
       j.nombre AS juguete,
       SUM(l.cant_stock) AS stock_total,
       h.precio
  FROM juguetes j
  JOIN lotes_inventarios l
    ON j.id = l.id_juguete
  JOIN hist_precios h
    ON j.id = h.id_juguete
 WHERE l.id_tienda = &v_tienda_id
   AND h.fecha_fin IS NULL
 GROUP BY j.id, j.nombre, h.precio
HAVING SUM(l.cant_stock) > 0;

PROMPT
PROMPT Formato de entrada: id_juguete:cantidad,id_juguete:cantidad,...
PROMPT Ejemplo: 1:2,5:1,7:3
ACCEPT v_items_fis PROMPT '>> Productos y cantidades: ' DEFAULT ''

CLEAR SCREEN

-- 4. Procesar PL/SQL
DECLARE
    v_detalles    det_fac_tab := det_fac_tab();
    v_input_str   VARCHAR2(4000);
    v_pair        VARCHAR2(200);
    v_comma_pos   PLS_INTEGER;
    v_colon_pos   PLS_INTEGER;
    v_id_jug      NUMBER;
    v_cant        NUMBER;
BEGIN
    v_input_str := TRIM('&v_items_fis');

    IF v_input_str IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('No se indicó ningún producto. Operación cancelada.');
        RETURN;
    END IF;

    -- Normalizamos agregando coma final para simplificar el loop
    v_input_str := v_input_str || ',';

    WHILE INSTR(v_input_str, ',') > 0 LOOP
        v_comma_pos := INSTR(v_input_str, ',');
        v_pair      := TRIM(SUBSTR(v_input_str, 1, v_comma_pos - 1)); -- "id:cant"
        v_input_str := SUBSTR(v_input_str, v_comma_pos + 1);

        IF v_pair IS NOT NULL THEN
            v_colon_pos := INSTR(v_pair, ':');

            IF v_colon_pos = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Aviso: par ignorado por formato inválido -> ' || v_pair);
            ELSE
                BEGIN
                    v_id_jug := TO_NUMBER(TRIM(SUBSTR(v_pair, 1, v_colon_pos - 1)));
                    v_cant   := TO_NUMBER(TRIM(SUBSTR(v_pair, v_colon_pos + 1)));

                    IF v_id_jug > 0 AND v_cant > 0 THEN
                        v_detalles.EXTEND;
                        v_detalles(v_detalles.LAST) :=
                            det_fac_params(v_id_jug, v_cant, 'MA');  -- tipo_clien fijo 'MA'
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('Aviso: id o cantidad inválidos en ' || v_pair);
                    END IF;
                EXCEPTION
                    WHEN VALUE_ERROR THEN
                        DBMS_OUTPUT.PUT_LINE('Aviso: no se pudo convertir id o cantidad en ' || v_pair);
                END;
            END IF;
        END IF;
    END LOOP;

    IF v_detalles.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se pudo construir ningún detalle válido. Operación cancelada.');
        RETURN;
    END IF;

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
