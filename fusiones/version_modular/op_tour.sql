UNDEFINE v_tour_fecha_str
UNDEFINE v_tour_cli
UNDEFINE v_tour_fans_str

PROMPT
PROMPT === [3] INSCRIPCIÓN INSIDE TOUR ===

-- 1. Mostrar Tours
COLUMN fec_inic HEADING 'Fecha Inicio'
COLUMN cupos_disp HEADING 'Cupos Disp.'
COLUMN precio_ent HEADING 'Precio Entrada'

SELECT 
    TO_CHAR(t.fec_inic, 'DD/MM/YY') AS fec_inic, 
    (t.cupos_tot - NVL((SELECT COUNT(*) FROM inscritos i WHERE i.id_tour = t.fec_inic), 0)) AS cupos_disp,
    t.precio_ent 
FROM tours t
WHERE t.fec_inic > SYSDATE;

PROMPT (Formato Fecha: DD/MM/YY)
ACCEPT v_tour_fecha_str PROMPT '>> Ingrese Fecha del Tour (Ej. 01/10/26): ' DEFAULT '01/01/00'

-- 2. Mostrar Adultos
PROMPT --- Clientes Adultos (Mayores de 21 años) ---
COLUMN cliente_nombre FORMAT A30 HEADING 'Nombre'
COLUMN edad_actual FORMAT 99 HEADING 'Edad'

SELECT id_lego, p_nombre || ' ' || p_apellido as cliente_nombre, TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) as edad_actual
FROM clientes 
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci)/12) >= 21
ORDER BY id_lego;

ACCEPT v_tour_cli PROMPT '>> ID Cliente que asiste (Adulto): ' DEFAULT 0

-- 3. Mostrar Fans
PROMPT --- Fans Menores Disponibles ---
COLUMN fan_nombre FORMAT A30 HEADING 'Fan Menor'
COLUMN rep_id FORMAT 9999 HEADING 'ID Rep.'
COLUMN rep_nombre FORMAT A25 HEADING 'Nombre Rep.'

SELECT f.id_fan, f.p_nombre || ' ' || f.p_apellido as fan_nombre, 
       f.id_representante as rep_id, 
       c.p_nombre || ' ' || c.p_apellido as rep_nombre
FROM fans_menores f
JOIN clientes c ON f.id_representante = c.id_lego;

ACCEPT v_tour_fans_str PROMPT '>> IDs Fans Menores (separados por coma, ej: 203,205 / 0 si ninguno): ' DEFAULT '0'

-- 4. Procesar
DECLARE
    v_clientes_tour id_tab;            
    v_fans_tour     id_tab;
    v_fecha_tour    DATE;
    v_input_str     VARCHAR2(400);
    v_temp_str      VARCHAR2(100);
    v_comma_pos     NUMBER;
    v_temp_id       NUMBER;
BEGIN
    v_fecha_tour := TO_DATE('&v_tour_fecha_str', 'DD/MM/YY'); 
    
    v_clientes_tour := id_tab();
    v_clientes_tour.extend;
    v_clientes_tour(1) := &v_tour_cli; 
    
    v_fans_tour := id_tab();
    v_input_str := '&v_tour_fans_str' || ',';
    
    WHILE INSTR(v_input_str, ',') > 0 LOOP
        v_comma_pos := INSTR(v_input_str, ',');
        v_temp_str := TRIM(SUBSTR(v_input_str, 1, v_comma_pos - 1));
        BEGIN
            v_temp_id := TO_NUMBER(v_temp_str);
            IF v_temp_id > 0 THEN
                v_fans_tour.extend;
                v_fans_tour(v_fans_tour.LAST) := v_temp_id;
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL; END;
        v_input_str := SUBSTR(v_input_str, v_comma_pos + 1);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Inscribiendo en Tour...');
    registrar_inscripcion_tour(v_fecha_tour, v_clientes_tour, v_fans_tour);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('>> ¡Inscripción Registrada! Recibo generado en estado pendiente.');
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