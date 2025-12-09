CREATE TABLE TEMAS (
    id NUMBER(7) CONSTRAINT pk_temas PRIMARY KEY,
    
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT chk_temas_nombre CHECK (LENGTH(nombre) >= 4)
        CONSTRAINT uq_temas_nombre UNIQUE,
        
    descripcion VARCHAR2(450) NOT NULL,

    tipo VARCHAR2(5) NOT NULL
        CONSTRAINT chk_temas_tipo CHECK (tipo IN ('tema', 'serie')), 
    
    id_tema_padre NUMBER(7)  
);

ALTER TABLE TEMAS
ADD (
    CONSTRAINT fk_temas_serie_padre
    FOREIGN KEY (id_tema_padre)
    REFERENCES TEMAS (id)
);

CREATE OR REPLACE TRIGGER trg_temas_validar_padre_serie
BEFORE INSERT OR UPDATE OF tipo, id_tema_padre
ON TEMAS
FOR EACH ROW
DECLARE
    v_tipo_padre TEMAS.tipo%TYPE;
BEGIN
    
    IF :NEW.tipo = 'tema' AND :NEW.id_tema_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 
            'Los TEMAS no pueden tener id_tema_padre. Solo las SERIES.');
    END IF;

    
    IF :NEW.tipo = 'serie' THEN
        
        SELECT tipo INTO v_tipo_padre
        FROM TEMAS
        WHERE id = :NEW.id_tema_padre;

        IF v_tipo_padre <> 'tema' THEN
            RAISE_APPLICATION_ERROR(-20102, 
                'El id_tema_padre debe referenciar una fila con tipo = ''tema''.');
        END IF;
    END IF;
END;
/

-- 1. TEMAS PRINCIPALES (sin padre)
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(1, 'Star Wars', 'Saga de ciencia ficción épica de George Lucas', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(2, 'Harry Potter', 'Universo mágico creado por J.K. Rowling', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(3, 'Minecraft', 'Universo cúbico de construcción y aventura', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(4, 'LEGO Friends', 'Amistad, aventuras y vida cotidiana', 'tema', NULL);

-- 2. SERIES HIJAS de Star Wars (padre = tema 1)
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(5, 'Episodio I', 'La Amenaza Fantasma - Precuela', 'serie', 1);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(6, 'Episodio II', 'El Ataque de los Clones', 'serie', 1);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(7, 'Episodio III', 'La Venganza de los Sith', 'serie', 1);

-- 3. SERIES HIJAS de Harry Potter (padre = tema 2)
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(8, 'La Piedra Filosofal', 'Primer año en Hogwarts', 'serie', 2);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(9, 'La Cámara Secreta', 'Segundo año - Basilisco', 'serie', 2);

-- 4. SERIES HIJAS de Minecraft (padre = tema 3)
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(10, 'Village y Pillage', 'Aldeanos y bandidos', 'serie', 3);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(11, 'The Nether Update', 'Dimension infernal expandida', 'serie', 3);

-- 5. MÁS TEMAS para diversidad
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(12, 'City', 'Vida urbana moderna y vehículos', 'tema', NULL);