CREATE TABLE juguetes (
    id NUMBER(7)
        CONSTRAINT pk_juguetes PRIMARY KEY,
    
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT chk_juguetes_nombre CHECK (LENGTH(nombre) >= 8)
        CONSTRAINT uq_juguetes_nombre UNIQUE,
    
    rgo_edad VARCHAR2(7) NOT NULL
        CONSTRAINT chk_juguetes_rgo_edad CHECK (rgo_edad IN ('0-2', '3-4', '5-6', '7-8', '9-11', '12+', 'adultos')),
    
    rgo_precio CHAR NOT NULL
        CONSTRAINT chk_juguetes_rgo_precio CHECK (rgo_precio IN ('A', 'B', 'C', 'D')),
    
    cant_pzas NUMBER
        CONSTRAINT chk_juguetes_cant_pzas CHECK (cant_pzas > 0),
    
    descripcion VARCHAR2(450) NOT NULL,
    
    instrucciones VARCHAR2(260),
    
    es_set BOOLEAN NOT NULL,
    
    id_set_padre NUMBER
);

ALTER TABLE juguetes
  ADD (
    CONSTRAINT fk_juguetes_set_padre
    FOREIGN KEY (id_set_padre)
    REFERENCES juguetes (id)
  );

CREATE OR REPLACE TRIGGER trg_relacion_set_juguetes
BEFORE INSERT OR UPDATE OF es_set, id_set_padre
ON JUGUETES
FOR EACH ROW
DECLARE
    v_es_set_padre JUGUETES.es_set%TYPE;
BEGIN
    
    IF :NEW.es_set = TRUE AND :NEW.id_set_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(
            -20104,
            'Error: Un SET no puede tener id_set_padre (debe ser NULL)'
        );
    END IF;

    
    IF :NEW.es_set = FALSE AND :NEW.id_set_padre IS NOT NULL THEN
        
        SELECT es_set 
        INTO v_es_set_padre 
        FROM JUGUETES 
        WHERE id = :NEW.id_set_padre;

        
        IF v_es_set_padre != TRUE THEN
            RAISE_APPLICATION_ERROR(
                -20105,
                'Error: id_set_padre debe referenciar un SET (es_set = TRUE)'
            );
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20106,
            'Error: id_set_padre (' || :NEW.id_set_padre || ') no existe'
        );
END;
/

-- 1. SETS
INSERT INTO juguetes VALUES (1, 'Star Wars Millennium Falcon', '9-11', 'D', 1350, 'Set avanzado con detalles de la nave espacial', 'MillenniumFalcon_75192.pdf', 'S', NULL);

INSERT INTO juguetes VALUES (2, 'Harry Potter Hogwarts Castle', '12+', 'D', 6020, 'Castillo de Hogwarts con figuras detalladas', 'HogwartsCastle_71043.pdf', 'S', NULL);

INSERT INTO juguetes VALUES (3, 'Minecraft The Nether Fortress', '7-8', 'B', 675, 'Edificio y criaturas del Nether para Minecraft', 'NetherFortress_21132.pdf', 'S', NULL);

-- 2. PRODUCTOS HIJOS
INSERT INTO juguetes VALUES (4, 'X-Wing Fighter', '9-11', 'C', 727, 'Caza estelar de la Alianza Rebelde', 'XWing_75155.pdf', 'N', 1);

INSERT INTO juguetes VALUES (5, 'Dementor Figure', '12+', 'B', 3, 'Figuras de dementores para Hogwarts', 'Dementor_75969.pdf', 'N', 2);

INSERT INTO juguetes VALUES (6, 'Nether Zombie Pigman', '7-8', 'B', 5, 'Figura de zombie Pigman del Nether', 'ZombiePigman_21163.pdf', 'N', 3);

INSERT INTO juguetes VALUES (7, 'Micro-scale Creeper', '7-8', 'A', 14, 'Pequeña figura de Creeper explosivo', 'CreeperMicro_21141.pdf', 'N', 3);

-- 3. INDEPENDIENTE
INSERT INTO juguetes VALUES (8, 'LEGO City Police Patrol', '5-6', 'B', 245, 'Vehículo patrulla de policía con minifiguras', 'PolicePatrol_60239.pdf', 'N', NULL);
