CREATE TABLE prods_relacionados (
    id_jgt_base NUMBER(7) NOT NULL,
    id_jgt_rela NUMBER(7) NOT NULL,

    CONSTRAINT pk_prods_rela
        PRIMARY KEY (id_jgt_base, id_jgt_rela)
);

ALTER TABLE prods_relacionados
ADD (
    CONSTRAINT fk_prods_relacionados_jgt_base
        FOREIGN KEY (id_jgt_base)
        REFERENCES JUGUETES(id),
        
    CONSTRAINT fk_prods_relacionados_jgt_rela
        FOREIGN KEY (id_jgt_rela)
        REFERENCES JUGUETES(id)
);

CREATE OR REPLACE TRIGGER trg_prods_relacionados_no_duplicados
BEFORE INSERT ON prods_relacionados
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Verificar si ya existe la relación INVERSA (4,1) cuando intentas (1,4)
    SELECT COUNT(*)
    INTO v_count
    FROM prods_relacionados 
    WHERE id_jgt_base = :NEW.id_jgt_rela 
      AND id_jgt_rela = :NEW.id_jgt_base;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Error: La relación inversa (' || :NEW.id_jgt_rela || ',' || :NEW.id_jgt_base || 
            ') ya existe. No se permiten duplicados bidireccionales.'
        );
    END IF;
    
    -- Verificar si ya existe la MISMA relación (1,4)
    SELECT COUNT(*)
    INTO v_count
    FROM prods_relacionados 
    WHERE id_jgt_base = :NEW.id_jgt_base 
      AND id_jgt_rela = :NEW.id_jgt_rela;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Error: La relación (' || :NEW.id_jgt_base || ',' || :NEW.id_jgt_rela || 
            ') ya existe.'
        );
    END IF;
END;
/



-- Star Wars: Millennium Falcon ↔ X-Wing (mismo universo)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (1, 4);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (4, 1);

-- Harry Potter: Hogwarts Castle ↔ Dementor Figure (mismo castillo)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (2, 5);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (5, 2);

-- Minecraft Nether: Fortress ↔ Zombie Pigman ↔ Micro Creeper
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (3, 6);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (6, 3);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (3, 7);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (7, 3);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (6, 7);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (7, 6);