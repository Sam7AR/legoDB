CREATE OR REPLACE TRIGGER trg_temas_serie_padre_insert
    BEFORE INSERT OR UPDATE OF id_serie_padre ON TEMAS
    FOR EACH ROW
DECLARE
    v_tipo_padre TEMAS.tipo%TYPE;
BEGIN
    IF :NEW.id_serie_padre IS NOT NULL THEN
        SELECT tipo
        INTO v_tipo_padre
        FROM TEMAS
        WHERE id = :NEW.id_serie_padre;

        IF v_tipo_padre = 'tema' THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Error: No se puede referenciar a un tema como padre'
            );
        ELSIF :NEW.tipo = 'serie' AND v_tipo_padre = 'serie' THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Error: Una serie no puede referenciar a otra serie como padre'
            );
        END IF;
    END IF;
END;
/
