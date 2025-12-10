UNDEFINE v_cli_on_id
UNDEFINE v_items_on

CLEAR SCREEN
PROMPT
PROMPT === [2] NUEVA VENTA ONLINE ===
PROMPT Nota: Se verificará si la venta es gratis por puntos.
PROMPT

-- 1. Mostrar Clientes Aptos
COLUMN p_nombre    FORMAT A15
COLUMN p_apellido  FORMAT A15
COLUMN edad_actual FORMAT 99

PROMPT --- Paso 1: Seleccione Cliente (Solo mayores de 21) ---

SELECT id_lego,
       p_nombre,
       p_apellido,
       TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) AS edad_actual
  FROM clientes
 WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) >= 21
 ORDER BY id_lego;

PROMPT
ACCEPT v_cli_on_id PROMPT '>> Ingrese ID Cliente Online: ' DEFAULT 0

CLEAR SCREEN
PROMPT === [2] NUEVA VENTA ONLINE ===
PROMPT Cliente Seleccionado: &v_cli_on_id
PROMPT

-- 2. Mostrar Catálogo del País
COLUMN desc_juguete FORMAT A35
COLUMN precio       FORMAT 999.99 HEADING 'Precio'
COLUMN limite       FORMAT 99     HEADING 'Lim. Max'

PROMPT --- Paso 2: Catálogo Disponible para el País del Cliente ---

SELECT j.id,
       j.nombre AS desc_juguete,
       c.lim_compra_ol AS limite,
       h.precio
  FROM juguetes j
  JOIN hist_precios h
    ON j.id = h.id_juguete
  JOIN catalogos c
    ON j.id = c.id_juguete
 WHERE h.fecha_fin IS NULL
   AND c.id_pais = (SELECT id_pais_resi
                      FROM clientes
                     WHERE id_lego = &v_cli_on_id)
 ORDER BY j.id;

PROMPT
PROMPT Formato de entrada: id_juguete:cantidad,id_juguete:cantidad,...
PROMPT Ejemplo: 1:2,5:1,7:3
ACCEPT v_items_on PROMPT '>> Productos y cantidades: ' DEFAULT ''

CLEAR SCREEN

-- 3. Procesar
DECLARE
    v_detalles    det_fac_tab := det_fac_tab();
    v_input_str   VARCHAR2(4000);
    v_pair        VARCHAR2(200);
    v_comma_pos   PLS_INTEGER;
    v_colon_pos   PLS_INTEGER;
    v_id_jug      NUMBER;
    v_cant        NUMBER;
BEGIN
    v_input_str := TRIM('&v_items_on');

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
                            det_fac_params(v_id_jug, v_cant, 'MA'); -- tipo_clien fijo 'MA'
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
