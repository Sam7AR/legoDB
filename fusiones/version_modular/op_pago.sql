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

-- Consulta unificada
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
PROMPT Presione ENTER para volver al menú...
PAUSE
@@menu_LEGO.sql