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
PROMPT Formato de entrada: id_juguete:cantidad:tipo, id_juguete:cantidad:tipo
PROMPT Ejemplo: 1:2:MA, 5:1:ME, 7:3:MA (Tipos validos: MA / ME)
ACCEPT v_items_on PROMPT '>> Productos: ' DEFAULT ''

CLEAR SCREEN

-- 3. Procesar
DECLARE
    v_detalles    det_fac_tab := det_fac_tab();
    v_input_str   VARCHAR2(4000);
    v_pair        VARCHAR2(200);
    v_comma_pos   PLS_INTEGER;
    
    -- Variables para manejar los DOS puntos (:)
    v_colon1_pos  PLS_INTEGER;
    v_colon2_pos  PLS_INTEGER;
    
    v_id_jug      NUMBER;
    v_cant        NUMBER;
    v_tipo_item   VARCHAR2(2); -- Aquí guardaremos el MA o ME
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
        v_pair      := TRIM(SUBSTR(v_input_str, 1, v_comma_pos - 1)); -- "id:cant:tipo"
        v_input_str := SUBSTR(v_input_str, v_comma_pos + 1);

        IF v_pair IS NOT NULL THEN
            -- Buscamos el PRIMER ':'
            v_colon1_pos := INSTR(v_pair, ':');
            
            -- Buscamos el SEGUNDO ':' (Empezando a buscar después del primero)
            v_colon2_pos := INSTR(v_pair, ':', v_colon1_pos + 1);

            IF v_colon1_pos = 0 OR v_colon2_pos = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Aviso: Formato inválido (faltan dos puntos) en -> ' || v_pair);
            ELSE
                BEGIN
                    -- 1. Extraer ID (desde el inicio hasta antes del primer :)
                    v_id_jug := TO_NUMBER(TRIM(SUBSTR(v_pair, 1, v_colon1_pos - 1)));
                    
                    -- 2. Extraer Cantidad (entre el primer y segundo :)
                    -- La longitud es: posición_2 - posición_1 - 1
                    v_cant   := TO_NUMBER(TRIM(SUBSTR(v_pair, v_colon1_pos + 1, v_colon2_pos - v_colon1_pos - 1)));
                    
                    -- 3. Extraer Tipo (desde después del segundo : hasta el final)
                    v_tipo_item := UPPER(TRIM(SUBSTR(v_pair, v_colon2_pos + 1)));

                    -- Validación básica del tipo
                    IF v_tipo_item NOT IN ('MA', 'ME') THEN
                        DBMS_OUTPUT.PUT_LINE('Aviso: Tipo "'||v_tipo_item||'" desconocido en item '||v_id_jug||'. Se forzará a MA.');
                        v_tipo_item := 'MA';
                    END IF;

                    IF v_id_jug > 0 AND v_cant > 0 THEN
                        v_detalles.EXTEND;
                        -- Aquí pasamos la variable v_tipo_item que acabamos de leer
                        v_detalles(v_detalles.LAST) := 
                            det_fac_params(v_id_jug, v_cant, v_tipo_item); 
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('Aviso: id o cantidad inválidos en ' || v_pair);
                    END IF;
                EXCEPTION
                    WHEN VALUE_ERROR THEN
                        DBMS_OUTPUT.PUT_LINE('Aviso: error numérico al leer ' || v_pair);
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