--DROPS
DROP TABLE temas CASCADE CONSTRAINTS;
DROP TABLE juguetes CASCADE CONSTRAINTS;
DROP TABLE T_J CASCADE CONSTRAINTS;
DROP TABLE catalogos CASCADE CONSTRAINTS;
DROP TABLE prods_relacionados CASCADE CONSTRAINTS;
DROP TABLE hist_precios CASCADE CONSTRAINTS;
--CREATES
CREATE TABLE temas (
    id NUMBER(7) CONSTRAINT pk_temas PRIMARY KEY,
    
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT chk_temas_nombre CHECK (LENGTH(nombre) >= 4)
        CONSTRAINT uq_temas_nombre UNIQUE,
        
    descripcion VARCHAR2(450) NOT NULL,

    tipo VARCHAR2(5) NOT NULL
        CONSTRAINT chk_temas_tipo CHECK (tipo IN ('tema', 'serie')), 
    
    id_tema_padre NUMBER(7)  
);

CREATE TABLE juguetes (
    id NUMBER(7)
        CONSTRAINT pk_juguetes PRIMARY KEY,
    
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT chk_juguetes_nombre CHECK (LENGTH(nombre) >= 3)
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

CREATE TABLE T_J (
    id_tema    NUMBER(7) NOT NULL,
    id_juguete NUMBER(7) NOT NULL,

    CONSTRAINT pk_t_j
        PRIMARY KEY (id_tema, id_juguete)
);

CREATE TABLE CATALOGOS (
    lim_compra_ol NUMBER(2) NOT NULL
        CONSTRAINT chk_catalogos_lim_compra_ol CHECK (lim_compra_ol > 0),
        
    id_pais NUMBER(3) NOT NULL,
    id_juguete NUMBER(7) NOT NULL,
    
    CONSTRAINT pk_catalogos 
        PRIMARY KEY (id_pais, id_juguete)
);

CREATE TABLE prods_relacionados (
    id_jgt_base NUMBER(7) NOT NULL,
    id_jgt_rela NUMBER(7) NOT NULL,

    CONSTRAINT pk_prods_rela
        PRIMARY KEY (id_jgt_base, id_jgt_rela)
);

CREATE TABLE hist_precios (
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    precio NUMBER NOT NULL,
    id_juguete NUMBER NOT NULL,
    CONSTRAINT pk_hist_precios PRIMARY KEY (fecha_inicio, id_juguete)
);
--ALTERS
ALTER TABLE TEMAS
ADD (
    CONSTRAINT fk_temas_serie_padre
    FOREIGN KEY (id_tema_padre)
    REFERENCES TEMAS (id)
);

ALTER TABLE juguetes
  ADD (
    CONSTRAINT fk_juguetes_set_padre
    FOREIGN KEY (id_set_padre)
    REFERENCES juguetes (id)
  );

ALTER TABLE T_J
ADD (
    CONSTRAINT fk_tj_tema
        FOREIGN KEY (id_tema)
        REFERENCES TEMAS(id),
    CONSTRAINT fk_tj_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES JUGUETES(id)
);

ALTER TABLE CATALOGOS
ADD (
    CONSTRAINT fk_catalogos_pais
        FOREIGN KEY (id_pais)
        REFERENCES PAISES(id_pais),
        
    CONSTRAINT fk_catalogos_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES JUGUETES(id)
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

ALTER TABLE hist_precios
ADD (
    CONSTRAINT fk_hist_precios_id_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES JUGUETES(id)
);
-- PROCEDURES
CREATE OR REPLACE PROCEDURE registrar_precio_juguete (
    p_precio   NUMBER,
    p_id_juguete NUMBER
)
IS
BEGIN
    -- Inserta nuevo precio con SYSDATE automáticamente
    INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, p_precio, p_id_juguete);
    
    COMMIT; 
END;
/

--TRIGGERS
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
--JUGUETES
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

CREATE OR REPLACE TRIGGER trg_hist_precios_automatico
BEFORE INSERT ON hist_precios
FOR EACH ROW
DECLARE
    v_ultimo_activo DATE;
BEGIN
    
    UPDATE hist_precios 
    SET fecha_fin = SYSDATE
    WHERE id_juguete = :NEW.id_juguete AND fecha_fin IS NULL;
    
    
    CASE
        WHEN :NEW.precio < 10 THEN
            UPDATE JUGUETES 
            SET rgo_precio = 'A'
            WHERE id = :NEW.id_juguete;
            
        WHEN :NEW.precio BETWEEN 10 AND 70 THEN
            UPDATE JUGUETES 
            SET rgo_precio = 'B'
            WHERE id = :NEW.id_juguete;
            
        WHEN :NEW.precio > 70 AND :NEW.precio <= 200 THEN
            UPDATE JUGUETES 
            SET rgo_precio = 'C'
            WHERE id = :NEW.id_juguete;
            
        WHEN :NEW.precio > 200 THEN
            UPDATE JUGUETES 
            SET rgo_precio = 'D'
            WHERE id = :NEW.id_juguete;
            
        ELSE
            NULL;  
    END CASE;
    
    
END;
/

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

--INSERTS
-- 1. TEMAS PRINCIPALES (sin padre)
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(1, 'Technic', 'Ingeniería mecánica avanzada con piezas funcionales', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(2, 'Architecture', 'Réplicas detalladas de monumentos y ciudades', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(3, 'LEGO FORTNITE', 'Universo de supervivencia y construcción estilo battle royale', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(4, 'LEGO DISNEY', 'Personajes icónicos y mundos mágicos de Disney', 'tema', NULL);

-- 2. SERIES (sub-temas) de Technic
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(5, 'Super Cars', 'Autos deportivos con motores funcionales', 'serie', 1);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(6, 'Maquinaria Pesada', 'Excavadoras y grúas realistas', 'serie', 1);

-- 3. SERIES de Architecture
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(7, 'Skyline Series', 'Horizontes urbanos icónicos', 'serie', 2);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(8, 'World Wonders', 'Maravillas arquitectónicas mundiales', 'serie', 2);

-- 4. SERIES de LEGO FORTNITE
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(9, 'Survival Builds', 'Bases y estructuras de supervivencia', 'serie', 3);


-- 5. SERIES de LEGO DISNEY
INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(11, 'Princess Castles', 'Castillos de princesas Disney', 'serie', 4);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(12, 'Pixar Adventures', 'Escenas de películas Pixar', 'serie', 4);

--Juguetes

-- 1. JUGUETES TECHNIC

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(17, 'Pack Super Autos Technic', 'adultos', 'D', 5431, 'McLaren P1 + BMW M 1000 RR + Ford GT', 'Pack_SuperAutos_Technic.pdf', TRUE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(1, 'McLaren P1', 'adultos', 'D', 3874, 'McLaren P1 hiperdeportivo con suspensión activa', 'McLaren_P1_42172.pdf', FALSE, 17);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(2, 'BMW M 1000 RR', '12+', 'C', 1927, 'Moto BMW con motor giratorio y detalles realistas', 'BMW_M1000RR_42130.pdf', FALSE, 17);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(3, 'Ford GT 2022', 'adultos', 'D', 1476, 'Ford GT con puertas de mariposa y cockpit detallado', 'Ford_GT_42154.pdf', FALSE, 17);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(4, 'Ferrari FXX K', 'adultos', 'D', 1635, 'Ferrari de pista con aerodinámica activa', 'Ferrari_FXXK_42212.pdf', FALSE, NULL);

-- 2. JUGUETES ARCHITECTURE

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(21, 'Ciudades Europeas', 'adultos', 'C', 2700, 'París + Londres skylines', 'Ciudades_Europeas.pdf', TRUE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(5, 'Cielo París', 'adultos', 'C', 1493, 'Réplica de París con Torre Eiffel y Notre Dame', 'Paris_21044.pdf', FALSE, 21);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(6, 'Cielo Londres', 'adultos', 'C', 1217, 'Londres con Big Ben, London Eye y Tower Bridge', 'London_21034.pdf', FALSE, 21);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(7, 'Castillo Neuschwanstein', 'adultos', 'C', 1493, 'Castillo bávaro de cuento de hadas alemán', 'Neuschwanstein_21063.pdf', FALSE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(8, 'Pirámide de Guiza', 'adultos', 'B', 1476, 'Pirámide de Keops con Esfinge detallada', 'Guiza_21058.pdf', FALSE, NULL);

-- 3. JUGUETES LEGO FORTNITE

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(24, 'Criaturas Fortnite', '9-11', 'C', 1226, 'Klombo + Llama de Suministro', 'Criaturas_Fortnite.pdf', TRUE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(9, 'Klombo', '9-11', 'B', 686, 'Criatura gigante del universo Fortnite', 'Klombo_77077.pdf', FALSE, 24);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(10, 'Llama de Suministro', '9-11', 'B', 540, 'Llama de suministros explosiva', 'Llama_Suministro_77071.pdf', FALSE, 24);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(11, 'Hamburguesa Durrr', '7-8', 'B', 301, 'Restaurante icónico de Fortnite', 'Durrr_Burger_77070.pdf', FALSE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(12, 'Autobús de Batalla', '9-11', 'C', 912, 'Autobús de batalla con alas y propulsores', 'Battle_Bus_77073.pdf', FALSE, NULL);

-- 4. JUGUETES LEGO DISNEY

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(27, 'Colección Disney', '5-6', 'B', 438, 'Ángel + Heihei + Dumbo', 'Coleccion_Disney.pdf', TRUE, NULL);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(13, 'Ángel', '5-6', 'A', 144, 'Figurita coleccionable de Stitch como ángel', 'Angel_43257.pdf', FALSE, 27);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(14, 'Heihei', '5-6', 'A', 152, 'Gallo cómico de Moana', 'Heihei_43272.pdf', FALSE, 27);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(15, 'Dumbo', '3-4', 'A', 123, 'Elefantito volador de Disney clásico', 'Dumbo_40792.pdf', FALSE, 27);

INSERT INTO JUGUETES (id, nombre, rgo_edad, rgo_precio, cant_pzas, descripcion, instrucciones, es_set, id_set_padre) VALUES 
(16, 'Igor', '5-6', 'A', 142, 'Burro triste de Winnie the Pooh', 'Eeyore_40797.pdf', FALSE, NULL);

--T_J

-- 1. TECHNIC (tema=1, serie Super Cars=5)
INSERT INTO T_J (id_tema, id_juguete) VALUES (1, 17);  -- Pack Super Autos Technic → tema Technic
INSERT INTO T_J (id_tema, id_juguete) VALUES (5, 1);   -- McLaren P1 → serie Super Cars
INSERT INTO T_J (id_tema, id_juguete) VALUES (5, 2);   -- BMW M 1000 RR → serie Super Cars
INSERT INTO T_J (id_tema, id_juguete) VALUES (5, 3);   -- Ford GT 2022 → serie Super Cars
INSERT INTO T_J (id_tema, id_juguete) VALUES (1, 4);   -- Ferrari FXX K → tema Technic (individual)

-- 2. ARCHITECTURE (tema=2, serie Skyline Series=7)
INSERT INTO T_J (id_tema, id_juguete) VALUES (2, 21);  -- Ciudades Europeas → tema Architecture
INSERT INTO T_J (id_tema, id_juguete) VALUES (7, 5);   -- Cielo París → serie Skyline Series
INSERT INTO T_J (id_tema, id_juguete) VALUES (7, 6);   -- Cielo Londres → serie Skyline Series
INSERT INTO T_J (id_tema, id_juguete) VALUES (2, 7);   -- Castillo Neuschwanstein → tema Architecture
INSERT INTO T_J (id_tema, id_juguete) VALUES (8, 8);   -- Pirámide de Guiza → serie World Wonders

-- 3. LEGO FORTNITE (tema=3, serie Survival Builds=9)
INSERT INTO T_J (id_tema, id_juguete) VALUES (3, 24);  -- Criaturas Fortnite → tema LEGO FORTNITE
INSERT INTO T_J (id_tema, id_juguete) VALUES (9, 9);   -- Klombo → serie Survival Builds
INSERT INTO T_J (id_tema, id_juguete) VALUES (9, 10);  -- Llama de Suministro → serie Survival Builds
INSERT INTO T_J (id_tema, id_juguete) VALUES (3, 11);  -- Hamburguesa Durrr → tema LEGO FORTNITE
INSERT INTO T_J (id_tema, id_juguete) VALUES (3, 12);  -- Autobús de Batalla → tema LEGO FORTNITE

-- 4. LEGO DISNEY (tema=4, serie Princess Castles=11)
INSERT INTO T_J (id_tema, id_juguete) VALUES (4, 27);  -- Colección Disney → tema LEGO DISNEY
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 13); -- Ángel → serie Princess Castles
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 14); -- Heihei → serie Princess Castles
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 15); -- Dumbo → serie Princess Castles
INSERT INTO T_J (id_tema, id_juguete) VALUES (4, 16);  -- Igor → tema LEGO DISNEY

/*--CATALOGOS
-- 1. TECHNIC - España (1), Alemania (4) - Límites bajos (productos premium)
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (2, 1, 17);  -- Pack Super Autos → España
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (1, 1, 1);   -- McLaren P1 → España
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (1, 1, 2);   -- BMW → España
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (2, 4, 17);  -- Pack Super Autos → Alemania
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (1, 4, 3);   -- Ford GT → Alemania

-- 2. ARCHITECTURE - Reino Unido (5), España (1) - Límites medios
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (3, 5, 21);  -- Ciudades Europeas → UK
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (5, 5, 6);   -- Cielo Londres → UK
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (4, 1, 5);   -- Cielo París → España
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (3, 1, 7);   -- Neuschwanstein → España

-- 3. FORTNITE - Colombia (3), Venezuela (2), Canadá (7) - Límites altos (popular)
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (8, 3, 24);  -- Criaturas Fortnite → Colombia
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (10, 3, 9);  -- Klombo → Colombia
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (7, 2, 10);  -- Llama → Venezuela
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (6, 7, 12);  -- Battle Bus → Canadá

-- 4. DISNEY - Rumanía (6), España (1) - Límites altos (niños)
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (12, 6, 27); -- Colección Disney → Rumanía
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (15, 6, 13); -- Ángel → Rumanía
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (10, 1, 14); -- Heihei → España
INSERT INTO CATALOGOS (lim_compra_ol, id_pais, id_juguete) VALUES (12, 1, 15); -- Dumbo → España
*/
--PRODUCTOS RELACIONADOS
-- 1. TECHNIC - Autos relacionados con el Pack Super Autos
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (17, 4);  -- Pack Super Autos → Ferrari FXX K
INSERT INTO prods_relacionados (id_jgt_base, 1, 2);   -- McLaren P1 → BMW M 1000 RR
INSERT INTO prods_relacionados (id_jgt_base, 2, 3);   -- BMW → Ford GT 2022

-- 2. ARCHITECTURE - Ciudades y monumentos relacionados
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (21, 7);  -- Ciudades Europeas → Castillo Neuschwanstein
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (5, 6);    -- Cielo París → Cielo Londres
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (7, 8);    -- Neuschwanstein → Pirámide Guiza

-- 3. FORTNITE - Criaturas y vehículos relacionados
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (24, 11);  -- Criaturas Fortnite → Hamburguesa Durrr
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (9, 12);   -- Klombo → Autobús de Batalla
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (11, 10);  -- Hamburguesa Durrr → Llama Suministro

-- 4. DISNEY - Colección y figuras individuales
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (27, 16);  -- Colección Disney → Igor
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (13, 14);  -- Ángel → Heihei
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (14, 15);  -- Heihei → Dumbo

-- 5. CROSS-TEMA (relaciones entre temas diferentes)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (1, 5);    -- McLaren P1 → Cielo París (velocidad vs arquitectura)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (12, 9);   -- Autobús Batalla → Klombo (Fortnite completo)

--HISTÓRICO DE PRECIOS
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 599.99, 17);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 399.99, 1);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 249.99, 2);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 349.99, 3);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 429.99, 4);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 199.99, 21);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 129.99, 5);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 109.99, 6);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 139.99, 7);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 89.99, 8);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 79.99, 24);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 49.99, 9);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 39.99, 10);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 29.99, 11);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 59.99, 12);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 39.99, 27);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 19.99, 13);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 19.99, 14);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 14.99, 15);
INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, 16.99, 16);
