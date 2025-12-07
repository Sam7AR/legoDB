CREATE OR REPLACE TRIGGER trg_relacion_set_juguetes
    BEFORE INSERT OR UPDATE OF id_set_padre ON JUGUETES
    FOR EACH ROW
DECLARE
    v_es_set_padre JUGUETES.es_set%TYPE;
BEGIN
    
    IF :NEW.es_set = 'S' AND :NEW.id_set_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'Error: Un set no puede tener un producto padre (id_set_padre debe ser NULL)'
        );
    END IF;

    
    IF :NEW.es_set = 'N' AND :NEW.id_set_padre IS NOT NULL THEN
        
        SELECT es_set INTO v_es_set_padre FROM JUGUETES WHERE id = :NEW.id_set_padre;

        IF v_es_set_padre != 'S' THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'Error: El producto padre debe ser un set (es_set = ''S'')'
            );
        END IF;
    END IF;
END;

