--DROPS
DROP TABLE entradas CASCADE CONSTRAINTS;
DROP TABLE inscritos CASCADE CONSTRAINTS;
DROP TABLE recibos_inscripcion CASCADE CONSTRAINTS;
DROP TABLE fans_menores CASCADE CONSTRAINTS;
DROP TABLE clientes CASCADE CONSTRAINTS;
DROP TABLE tours CASCADE CONSTRAINTS;
DROP TABLE paises CASCADE CONSTRAINTS;
DROP TABLE telefonos;
DROP TABLE horarios;
DROP TABLE tiendas_fisicas;
DROP TABLE ciudades;
DROP TABLE estados;
DROP TABLE temas CASCADE CONSTRAINTS;
DROP TABLE juguetes CASCADE CONSTRAINTS;
--CREATES
CREATE TABLE paises (
    id_pais              NUMBER(3)     NOT NULL CONSTRAINT pk_pais PRIMARY KEY,
    nombre               VARCHAR2(50)  NOT NULL,
    continente           CHAR(2)       NOT NULL CONSTRAINT check_cont CHECK(continente IN ('AM','AF','AS','EU','OC')),
    nacionalidad         VARCHAR2(50)  NOT NULL,
    pertenece_ue         BOOLEAN       NOT NULL
);

CREATE TABLE tours (
    fec_inic             DATE CONSTRAINT pk_tour PRIMARY KEY,
    cupos_tot            NUMBER(4) NOT NULL,
    precio_ent           NUMBER(6,2) NOT NULL
);

CREATE TABLE clientes (
    id_lego              NUMBER(7) NOT NULL CONSTRAINT pk_cliente PRIMARY KEY,
    p_nombre             VARCHAR2(20) NOT NULL,
    p_apellido           VARCHAR2(20) NOT NULL,
    s_apellido           VARCHAR2(20) NOT NULL,
    fec_naci             DATE NOT NULL,
    doc_iden             VARCHAR2(20) NOT NULL,
    id_pais_nacio        NUMBER(3) NOT NULL,
    id_pais_resi         NUMBER(3) NOT NULL,
    s_nombre             VARCHAR2(20),
    pasaporte            VARCHAR2(9),
    fec_ven_pas          DATE
);

CREATE TABLE fans_menores (
    id_fan               NUMBER(7) NOT NULL CONSTRAINT pk_fan_menor PRIMARY KEY,
    p_nombre             VARCHAR2(20) NOT NULL,
    p_apellido           VARCHAR2(20) NOT NULL,
    s_apellido           VARCHAR2(20) NOT NULL,
    fec_naci             DATE NOT NULL,
    doc_iden             VARCHAR2(20) NOT NULL,
    id_pais_nacio        NUMBER(3) NOT NULL,
    id_representante     NUMBER(7),
    s_nombre             VARCHAR2(20),
    pasaporte            VARCHAR2(9),
    fec_ven_pas          DATE
);

CREATE TABLE recibos_inscripcion (
    id_tour              DATE NOT NULL,
    nro_reci             NUMBER(4) NOT NULL,
    costo_tot            NUMBER(8,2) NOT NULL,
    estatus              VARCHAR2(9) NOT NULL CONSTRAINT check_recibo_estatus CHECK (estatus IN ('pendiente','pagado')),
    fec_emi              DATE,
    CONSTRAINT pk_recibo_ins PRIMARY KEY(id_tour,nro_reci)
);

CREATE TABLE inscritos (
    id_tour              DATE NOT NULL,
    nro_reci             NUMBER(4) NOT NULL,
    id_ins               NUMBER(2) NOT NULL,
    id_clien             NUMBER(7),
    id_fan_men           NUMBER(7),
    CONSTRAINT pk_inscritos PRIMARY KEY(id_tour,nro_reci,id_ins),
    CONSTRAINT clien_fan_exclu CHECK(
                                    (id_clien IS NOT NULL AND id_fan_men IS NULL) OR
                                    (id_clien IS NULL AND id_fan_men IS NOT NULL))
);

CREATE TABLE entradas (
    id_tour              DATE NOT NULL,
    nro_reci             NUMBER(4) NOT NULL,
    nro_ent              NUMBER(4) NOT NULL,
    tipo_asis            VARCHAR2(6) NOT NULL CONSTRAINT check_tipo_asis CHECK (tipo_asis IN ('adulto','menor')),
    CONSTRAINT pk_entradas PRIMARY KEY(id_tour,nro_reci,nro_ent)
);

CREATE TABLE estados (
    id_pais              NUMBER(3)     NOT NULL,
    id_estado            NUMBER(3)     NOT NULL,
    nombre               VARCHAR2(50)  NOT NULL,
    CONSTRAINT pk_estado PRIMARY KEY (id_pais, id_estado)
);

CREATE TABLE ciudades (
    id_pais              NUMBER(3)     NOT NULL,
    id_estado            NUMBER(3)     NOT NULL,
    id_ciudad            NUMBER(5)     NOT NULL,
    nombre               VARCHAR2(50)  NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_pais, id_estado, id_ciudad)
);

CREATE TABLE tiendas_fisicas (
    id_tienda            NUMBER(5)     NOT NULL CONSTRAINT pk_tienda PRIMARY KEY,
    nombre               VARCHAR2(100) NOT NULL,
    direccion            VARCHAR2(200) NOT NULL,
    id_pais              NUMBER(3)     NOT NULL,
    id_estado            NUMBER(3)     NOT NULL,
    id_ciudad            NUMBER(5)     NOT NULL
);

CREATE TABLE horarios (
    id_tienda            NUMBER(5)     NOT NULL,
    dia                  VARCHAR2(10)  NOT NULL CONSTRAINT check_horario_dia CHECK (dia IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO')),
    hora_apertura        VARCHAR2(5)   NOT NULL,
    hora_cierre          VARCHAR2(5)   NOT NULL,
    CONSTRAINT pk_horario PRIMARY KEY (id_tienda, dia)
);

CREATE TABLE telefonos (
    id_tienda            NUMBER(5)     NOT NULL,
    codigo_pais          VARCHAR2(5)   NOT NULL,
    codigo_area          VARCHAR2(5)   NOT NULL,
    numero               VARCHAR2(15)  NOT NULL,
    CONSTRAINT pk_telefono PRIMARY KEY (id_tienda, codigo_pais, codigo_area, numero)
);

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

CREATE TABLE juguetes (
    id NUMBER(7)
        CONSTRAINT pk_juguetes PRIMARY KEY,
    
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT chk_juguetes_nombre CHECK (LENGTH(nombre) >= 8)
        CONSTRAINT uq_juguetes_nombre UNIQUE,
    
    rgo_edad VARCHAR2(7) NOT NULL
        CONSTRAINT chk_juguetes_rgo_edad CHECK (rgo_edad IN ('0-2', '3-4', '5-6', '7-8', '9-11', '12+', 'adultos')),
    
    rgo_precio VARCHAR2(1) NOT NULL
        CONSTRAINT chk_juguetes_rgo_precio CHECK (rgo_precio IN ('A', 'B', 'C', 'D')),
    
    cant_pzas NUMBER
        CONSTRAINT chk_juguetes_cant_pzas CHECK (cant_pzas > 0),
    
    descripcion VARCHAR2(450) NOT NULL,
    
    instrucciones VARCHAR2(260),
    
    es_set VARCHAR2(1) NOT NULL
        CONSTRAINT chk_juguetes_es_set CHECK (es_set IN ('S', 'N')),
    
    id_set_padre NUMBER
);

--ALTERS
ALTER TABLE clientes
  ADD(
  CONSTRAINT fk_clien_nacio
  FOREIGN KEY (id_pais_nacio)
  REFERENCES paises (id_pais),

  CONSTRAINT fk_clien_resi
  FOREIGN KEY (id_pais_resi)
  REFERENCES paises (id_pais));

ALTER TABLE fans_menores
  ADD(
  CONSTRAINT fk_fan_represen
  FOREIGN KEY (id_representante)
  REFERENCES clientes (id_lego),

  CONSTRAINT fk_fan_nacio
  FOREIGN KEY (id_pais_nacio)
  REFERENCES paises (id_pais));

ALTER TABLE recibos_inscripcion
  ADD CONSTRAINT fk_recibo_tour
  FOREIGN KEY (id_tour)
  REFERENCES tours (fec_inic);

ALTER TABLE inscritos
  ADD(
  CONSTRAINT fk_inscritos_recibo
  FOREIGN KEY (id_tour, nro_reci)
  REFERENCES recibos_inscripcion (id_tour, nro_reci),

  CONSTRAINT fk_inscritos_cliente
  FOREIGN KEY (id_clien)
  REFERENCES clientes (id_lego),

  CONSTRAINT fk_inscritos_fan
  FOREIGN KEY (id_fan_men)
  REFERENCES fans_menores (id_fan));

ALTER TABLE entradas
  ADD CONSTRAINT fk_entradas_recibo
  FOREIGN KEY (id_tour, nro_reci)
  REFERENCES recibos_inscripcion (id_tour, nro_reci);

ALTER TABLE estados
  ADD CONSTRAINT fk_estado_pais
  FOREIGN KEY (id_pais)
  REFERENCES paises (id_pais);

ALTER TABLE ciudades
  ADD CONSTRAINT fk_ciudad_estado
  FOREIGN KEY (id_pais, id_estado)
  REFERENCES estados (id_pais, id_estado);

ALTER TABLE tiendas_fisicas
  ADD CONSTRAINT fk_tienda_ciudad
  FOREIGN KEY (id_pais, id_estado, id_ciudad)
  REFERENCES ciudades (id_pais, id_estado, id_ciudad);

ALTER TABLE horarios
  ADD CONSTRAINT fk_horario_tienda
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisicas (id_tienda);
  
ALTER TABLE horarios
    ADD CONSTRAINT check_horario_valido
    CHECK (hora_apertura < hora_cierre);

ALTER TABLE telefonos
  ADD CONSTRAINT fk_telefono_tienda
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisicas (id_tienda);
  
ALTER TABLE telefonos
    ADD CONSTRAINT check_telefono_min_len
    CHECK (LENGTH(numero) >= 7);

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
--FUNCIONES
CREATE OR REPLACE FUNCTION edad(fec_naci DATE) RETURN NUMBER IS
    BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci) / 12);
    END edad;
/

--TRIGGERS
CREATE OR REPLACE TRIGGER validar_clien
BEFORE INSERT OR UPDATE OF fec_naci, id_pais_nacio ON clientes
FOR EACH ROW
DECLARE
    v_edad           NUMBER;
    v_pertenece_ue BOOLEAN;
BEGIN
    v_edad := edad(:NEW.fec_naci);

    IF v_edad < 21 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'El cliente debe tener al menos 21 años.'
        );
    END IF;

    SELECT pertenece_ue
      INTO v_pertenece_ue
      FROM paises
     WHERE id_pais = :NEW.id_pais_nacio;

    IF NOT v_pertenece_ue THEN
        IF :NEW.pasaporte IS NULL OR :NEW.fec_ven_pas IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'Clientes no nacidos en la UE deben especificar pasaporte con su fecha de vencimiento.'
            );
        END IF;

        IF :NEW.fec_ven_pas <= SYSDATE THEN
            RAISE_APPLICATION_ERROR(
                -20006,
                'La fecha de vencimiento del pasaporte debe ser posterior a la fecha actual.'
            );
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20007,
            'Pais de nacimiento no encontrado'
        );
END;
/


CREATE OR REPLACE TRIGGER validar_fan_menor
BEFORE INSERT OR UPDATE OF fec_naci,id_representante,id_pais_nacio ON fans_menores
FOR EACH ROW
DECLARE
    v_edad           NUMBER;
    v_pertenece_ue BOOLEAN;
BEGIN
    v_edad := edad(:NEW.fec_naci);

    IF v_edad < 12 THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'El fan debe tener al menos 12 años.'
        );
    END IF;

    IF v_edad >= 21 THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'El fan debe ser menor de 21 años.'
        );
    END IF;

    IF v_edad < 18 AND :NEW.id_representante IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Los fans menores de 18 años deben tener representante.'
        );
    END IF;

    SELECT pertenece_ue
      INTO v_pertenece_ue
      FROM paises
     WHERE id_pais = :NEW.id_pais_nacio;

    IF NOT v_pertenece_ue THEN
        IF :NEW.pasaporte IS NULL OR :NEW.fec_ven_pas IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'Fans no nacidos en la UE deben especificar pasaporte y fecha de vencimiento.'
            );
        END IF;

        IF :NEW.fec_ven_pas <= SYSDATE THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'La fecha de vencimiento del pasaporte debe ser posterior a la fecha actual.'
            );
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'País no encontrado.'
        );
END;
/

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

CREATE OR REPLACE TRIGGER trg_relacion_set_juguetes
BEFORE INSERT OR UPDATE OF es_set, id_set_padre
ON JUGUETES
FOR EACH ROW
DECLARE
    v_es_set_padre JUGUETES.es_set%TYPE;
BEGIN
    
    IF :NEW.es_set = 'S' AND :NEW.id_set_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(
            -20104,
            'Error: Un SET no puede tener id_set_padre (debe ser NULL)'
        );
    END IF;

    
    IF :NEW.es_set = 'N' AND :NEW.id_set_padre IS NOT NULL THEN
        
        SELECT es_set 
        INTO v_es_set_padre 
        FROM JUGUETES 
        WHERE id = :NEW.id_set_padre;

        
        IF v_es_set_padre != 'S' THEN
            RAISE_APPLICATION_ERROR(
                -20105,
                'Error: id_set_padre debe referenciar un SET (es_set = ''S'')'
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
--INSERTS

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (1, 'España', 'EU', 'Española', TRUE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (2, 'Venezuela', 'AM', 'Venezolana', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (3, 'Colombia', 'AM', 'Colombiana', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (4, 'Alemania', 'EU', 'Alemana', TRUE);

COMMIT;

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-10-01', 3, 2500.00);

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-11-29', 5000, 2854.20 );

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-12-10', 4000, 3000.57);

COMMIT;


INSERT INTO clientes VALUES (
101, 'Carlos', 'Gomez', 'Perez', DATE '1990-05-12', 'V1234567',
1, 1, 'Andres', NULL, NULL
);

INSERT INTO clientes VALUES (
102, 'Maria', 'Lopez', 'Hernandez', DATE '1988-11-03', 'E8765432',
4, 4, NULL, NULL, NULL
);

INSERT INTO clientes VALUES (
103, 'Jose', 'Martinez', 'Castro', DATE '1984-07-20', 'V1928374',
2, 2, NULL, 'P9988776', DATE '2031-10-10'
);

INSERT INTO clientes VALUES (
104, 'Lucia', 'Fernandez', 'Lopez', DATE '1992-08-29', 'E6629103',
1, 3, 'Beatriz', NULL, NULL
);

INSERT INTO clientes VALUES (
105, 'Miguel', 'Silva', 'Torres', DATE '1980-07-14', 'V4455667',
3, 3, NULL, 'X1234567', DATE '2032-05-05'
);

INSERT INTO clientes VALUES (
106, 'Ana', 'Ramirez', 'Soto', DATE '1995-09-10', 'E2233445',
4, 4, 'Patricia', NULL, NULL
);

INSERT INTO clientes VALUES (
107, 'Rafael', 'Vargas', 'Lopez', DATE '1982-03-25', 'V5566778',
3, 1, NULL, 'C1122334', DATE '2030-12-31'
);

INSERT INTO clientes VALUES (
108, 'Carmen', 'Diaz', 'Mendoza', DATE '1979-01-19', 'E3344556',
1, 1, NULL, NULL, NULL
);

INSERT INTO clientes VALUES (
109, 'Luis', 'Suarez', 'Pena', DATE '1994-06-04', 'V9988776',
2, 2, 'Alejandro', 'M1234500', DATE '2035-01-01'
);

INSERT INTO clientes VALUES (
110, 'Patricia', 'Moreno', 'Guzman', DATE '1987-12-30', 'E1122554',
4, 4, NULL, NULL, NULL
);

COMMIT;

INSERT INTO fans_menores VALUES (
201, 'Luis', 'Gomez', 'Perez', DATE '2007-05-12', 'FM1234',
1, 101, 'Andres', NULL, NULL
);

INSERT INTO fans_menores VALUES (
202, 'Carla', 'Lopez', 'Soto', DATE '2006-11-03', 'FM2233',
4, NULL, NULL, NULL, NULL
);

INSERT INTO fans_menores VALUES (
203, 'Mateo', 'Ramirez', 'Diaz', DATE '2008-02-20', 'FM9988',
2, 105, NULL, 'P1234567', DATE '2032-01-15'
);

INSERT INTO fans_menores VALUES (
204, 'Sofia', 'Fernandez', 'Lopez', DATE '2005-09-15', 'FM5566',
3, NULL, 'Beatriz', 'X112233', DATE '2030-12-31'
);

INSERT INTO fans_menores VALUES (
205, 'Adriana', 'Suarez', 'Pena', DATE '2008-12-25', 'FM8899',
3, 105, 'Maria', 'Q555888', DATE '2031-07-07'
);

COMMIT;

INSERT INTO estados (id_pais, id_estado, nombre) VALUES (1, 10, 'Comunidad de Madrid');
INSERT INTO estados (id_pais, id_estado, nombre) VALUES (2, 20, 'Zulia');
INSERT INTO estados (id_pais, id_estado, nombre) VALUES (3, 30, 'Cundinamarca');
INSERT INTO estados (id_pais, id_estado, nombre) VALUES (4, 40, 'Baviera');
COMMIT;

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre) VALUES (1, 10, 100, 'Madrid');
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre) VALUES (2, 20, 200, 'Maracaibo');
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre) VALUES (3, 30, 300, 'Bogotá');
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre) VALUES (4, 40, 400, 'Múnich');
COMMIT;

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (1, 'Flagship Madrid - Serrano', 'Calle Serrano 5, 28001', 1, 10, 100);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (2, 'Tienda Maracaibo - 5 de Julio', 'Av. 5 de Julio, C.C. Las Delicias', 2, 20, 200);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (3, 'Tienda Bogotá - Zona Rosa', 'Carrera 13 #85-20', 3, 30, 300);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (4, 'Tienda Múnich - Karlsplatz', 'Karlsplatz 25, 80335', 4, 40, 400);
COMMIT;

INSERT INTO telefonos (id_tienda, codigo_pais, codigo_area, numero) VALUES (1, '+34', '91', '1234567');
INSERT INTO telefonos (id_tienda, codigo_pais, codigo_area, numero) VALUES (1, '+34', '91', '1234568');
INSERT INTO telefonos (id_tienda, codigo_pais, codigo_area, numero) VALUES (2, '+58', '261', '5551234');
INSERT INTO telefonos (id_tienda, codigo_pais, codigo_area, numero) VALUES (3, '+57', '1', '8765432');
INSERT INTO telefonos (id_tienda, codigo_pais, codigo_area, numero) VALUES (4, '+49', '89', '4455667');
COMMIT;

INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (1, 'LUNES', '09:00', '19:00');
INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (1, 'MARTES', '09:00', '19:00');
INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (1, 'SABADO', '10:00', '15:00');

INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (2, 'LUNES', '08:00', '18:00');
INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (2, 'MARTES', '08:00', '18:00');

INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (3, 'LUNES', '10:00', '20:00');
INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (3, 'VIERNES', '10:00', '20:00');

INSERT INTO horarios (id_tienda, dia, hora_apertura, hora_cierre) VALUES (4, 'LUNES', '09:30', '18:30');
COMMIT;


INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(1, 'Star Wars', 'Saga de ciencia ficción épica de George Lucas', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(2, 'Harry Potter', 'Universo mágico creado por J.K. Rowling', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(3, 'Minecraft', 'Universo cúbico de construcción y aventura', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(4, 'LEGO Friends', 'Amistad, aventuras y vida cotidiana', 'tema', NULL);


INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(5, 'Episodio I', 'La Amenaza Fantasma - Precuela', 'serie', 1);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(6, 'Episodio II', 'El Ataque de los Clones', 'serie', 1);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(7, 'Episodio III', 'La Venganza de los Sith', 'serie', 1);


INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(8, 'La Piedra Filosofal', 'Primer año en Hogwarts', 'serie', 2);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(9, 'La Cámara Secreta', 'Segundo año - Basilisco', 'serie', 2);


INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(10, 'Village y Pillage', 'Aldeanos y bandidos', 'serie', 3);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(11, 'The Nether Update', 'Dimension infernal expandida', 'serie', 3);


INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(12, 'City', 'Vida urbana moderna y vehículos', 'tema', NULL);

INSERT INTO TEMAS (id, nombre, descripcion, tipo, id_tema_padre) VALUES 
(13, 'Technic', 'Mecanismos complejos e ingeniería', 'tema', NULL);

-- 1. SETS
INSERT INTO juguetes VALUES (1, 'Star Wars Millennium Falcon', '9-11', 'D', 1350, 'Set avanzado con detalles de la nave espacial', 'MillenniumFalcon_75192.pdf', 'S', NULL);

INSERT INTO juguetes VALUES (2, 'Harry Potter Hogwarts Castle', '12+', 'D', 6020, 'Castillo de Hogwarts con figuras detalladas', 'HogwartsCastle_71043.pdf', 'S', NULL);

INSERT INTO juguetes VALUES (3, 'Minecraft The Nether Fortress', '7-8', 'B', 675, 'Edificio y criaturas del Nether para Minecraft', 'NetherFortress_21132.pdf', 'S', NULL);

-- 2. JUGUETES HIJOS
INSERT INTO juguetes VALUES (4, 'X-Wing Fighter', '9-11', 'C', 727, 'Caza estelar de la Alianza Rebelde', 'XWing_75155.pdf', 'N', 1);

INSERT INTO juguetes VALUES (5, 'Dementor Figure', '12+', 'B', 3, 'Figuras de dementores para Hogwarts', 'Dementor_75969.pdf', 'N', 2);

INSERT INTO juguetes VALUES (6, 'Nether Zombie Pigman', '7-8', 'B', 5, 'Figura de zombie Pigman del Nether', 'ZombiePigman_21163.pdf', 'N', 3);

INSERT INTO juguetes VALUES (7, 'Micro-scale Creeper', '7-8', 'A', 14, 'Pequeña figura de Creeper explosivo', 'CreeperMicro_21141.pdf', 'N', 3);

-- 3. JUGUETE INDEPENDIENTE
INSERT INTO juguetes VALUES (8, 'LEGO City Police Patrol', '5-6', 'B', 245, 'Vehículo patrulla de policía con minifiguras', 'PolicePatrol_60239.pdf', 'N', NULL);