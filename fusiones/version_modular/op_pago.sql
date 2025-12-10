UNDEFINE v_pago_fecha_str
UNDEFINE v_pago_nro

CLEAR SCREEN
PROMPT
PROMPT === [4] CONFIRMACIÓN DE PAGO DE TOUR ===
PROMPT Lista de Recibos actuales:
PROMPT

COLUMN "Fecha del Tour" FORMAT A25
COLUMN "Nro. Recibo" FORMAT A12
COLUMN "Importe Total" FORMAT A15
COLUMN "Estado del Pago" FORMAT A15
COLUMN "Fecha de Emisión" FORMAT A20

SELECT * FROM v_recibos_detallados;

PROMPT
PROMPT Ingrese los datos para confirmar el pago:
ACCEPT v_pago_fecha_str PROMPT '>> Fecha del Tour (DD/MM/YY): ' DEFAULT '01/01/00'
ACCEPT v_pago_nro       PROMPT '>> Nro. Recibo (Solo el número): ' DEFAULT 0

CLEAR SCREEN
DECLARE
    v_fecha_pago DATE;
BEGIN
    v_fecha_pago := TO_DATE('&v_pago_fecha_str', 'DD/MM/YY');
    
    DBMS_OUTPUT.PUT_LINE('Procesando confirmación de pago...');
    confirmar_pago(v_fecha_pago, &v_pago_nro);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('>> ¡Pago Confirmado Exitosamente!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('!!! ERROR: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT
PROMPT === ENTRADAS GENERADAS ===

COLUMN fecha_tour HEADING 'Fecha Tour' FORMAT A15
COLUMN recibo HEADING 'Recibo' FORMAT A10
COLUMN nro_entrada HEADING 'Nro. Entrada' FORMAT 9999
COLUMN tipo HEADING 'Tipo Asistente' FORMAT A15

SELECT TO_CHAR(id_tour, 'DD/MM/YYYY') AS fecha_tour,
       '#' || LPAD(nro_reci, 4, '0') AS recibo,
       nro_ent AS nro_entrada,
       UPPER(tipo_asis) AS tipo
FROM entradas 
WHERE id_tour = TO_DATE('&v_pago_fecha_str', 'DD/MM/YY') 
  AND nro_reci = &v_pago_nro
ORDER BY nro_ent;

PROMPT
PROMPT Presione ENTER para volver al menú...
PAUSE
@@menu_LEGO.sql