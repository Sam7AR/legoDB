DROP TABLE telefonos;
DROP TABLE horarios;
DROP TABLE tiendas_fisicas;
DROP TABLE ciudades;
DROP TABLE estados;
DROP TABLE paises;

CREATE TABLE paises (
    id_pais              NUMBER(3) NOT NULL CONSTRAINT pk_pais PRIMARY KEY,
    nombre               VARCHAR2(50)  NOT NULL,
    continente           CHAR(2)       NOT NULL CONSTRAINT check_cont CHECK(continente IN ('AM','AF','AS','EU','OC')),
    nacionalidad         VARCHAR2(50)  NOT NULL,
    pertenece_ue         BOOLEAN       NOT NULL
);

CREATE TABLE estados (
    id_pais    NUMBER(3) NOT NULL,
    id_estado  NUMBER(3) NOT NULL,
    nombre     VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_estado PRIMARY KEY (id_pais, id_estado)
);

CREATE TABLE ciudades (
    id_pais    NUMBER(3) NOT NULL,
    id_estado  NUMBER(3) NOT NULL,
    id_ciudad  NUMBER(3) NOT NULL,
    nombre     VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_pais, id_estado, id_ciudad)
);

CREATE TABLE tiendas_fisicas (
    id_tienda  NUMBER(5)     NOT NULL CONSTRAINT pk_tienda PRIMARY KEY,
    nombre     VARCHAR2(50)  NOT NULL,
    direccion  VARCHAR2(200) NOT NULL,
    id_pais    NUMBER(3)     NOT NULL,
    id_estado  NUMBER(3)     NOT NULL,
    id_ciudad  NUMBER(3)     NOT NULL
);

CREATE TABLE horarios (
    id_tienda  NUMBER(5) NOT NULL,
    dia        NUMBER(1) NOT NULL
               CONSTRAINT check_horario_dia CHECK (dia IN (1,2,3,4,5,6,7)),
    hora_aper  DATE      NOT NULL,
    hora_cier  DATE      NOT NULL,
    CONSTRAINT pk_horario PRIMARY KEY (id_tienda, dia),
    CONSTRAINT check_horario CHECK (hora_aper < hora_cier)
);

CREATE TABLE telefonos (
    id_tienda  NUMBER(5)  NOT NULL,
    cod_pais   VARCHAR2(5)  NOT NULL,
    cod_area   VARCHAR2(5)  NOT NULL,
    numero     VARCHAR2(15) NOT NULL,
    CONSTRAINT pk_telefono PRIMARY KEY (id_tienda, cod_pais, cod_area, numero)
);

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
  
ALTER TABLE telefonos
  ADD CONSTRAINT fk_telefono_tienda
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisicas (id_tienda);
  
INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (1, 'España', 'EU', 'Española', TRUE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (2, 'Venezuela', 'AM', 'Venezolana', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (3, 'Colombia', 'AM', 'Colombiana', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (4, 'Alemania', 'EU', 'Alemana', TRUE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (5, 'Reino Unido', 'EU', 'Británica', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (6, 'Rumanía', 'EU', 'Rumana', FALSE);

INSERT INTO paises (id_pais, nombre, continente, nacionalidad, pertenece_ue)
VALUES (7, 'Canadá', 'AM', 'Canadiense', FALSE);

COMMIT;

-- España
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (1, 1, 'País Vasco');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (1, 2, 'Comunidad de Madrid');

-- Reino Unido
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (5, 1, 'Escocia');

-- Rumanía
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (6, 1, 'Brașov');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (6, 2, 'Cluj');

-- Canadá
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (7, 1, 'Quebec');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (7, 2, 'Ontario');

-- Reino Unido (Escocia)
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (5, 1, 1, 'Edimburgo');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (5, 1, 2, 'Glasgow');

-- Rumanía
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (6, 1, 1, 'Brașov');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (6, 2, 1, 'Cluj-Napoca');

-- Canadá
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (7, 1, 1, 'Pointe-Claire');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (7, 2, 1, 'Ottawa');

-- España
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (1, 1, 1, 'Bilbao');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (1, 2, 1, 'Leganés');

COMMIT;

-- 1) Reino Unido
INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (1, 'LEGO® Store Edinburgh', 'St James Quarter, Edinburgh', 5, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (2, 'LEGO® Store Glasgow', 'Buchanan Galleries, Glasgow', 5, 1, 2);

-- 2) Rumanía
INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (3, 'LEGO® Store Coresi Shopping Centre', 'Coresi Shopping Resort, Brașov', 6, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (4, 'LEGO® Store VIVO! Mall', 'VIVO! Cluj-Napoca', 6, 2, 1);

-- 3) Canadá
INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (5, 'LEGO® Store Montreal - Pointe-Claire', 'Fairview Pointe-Claire, QC', 7, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (6, 'LEGO® Store Ottawa', 'Rideau Centre, Ottawa, ON', 7, 2, 1);

-- 4) España
INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (7, 'LEGO® Store Bilbao', 'Centro Comercial Zubiarte, Bilbao', 1, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (8, 'LEGO® Store Parquesur', 'Centro Comercial Parquesur, Leganés', 1, 2, 1);

COMMIT;

-- Tienda 1 a 8, lunes a sábado
INSERT INTO horarios VALUES (1,1,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,2,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,3,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,4,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,5,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,6,TO_DATE('10:00','HH24:MI'),TO_DATE('21:00','HH24:MI'));
INSERT INTO horarios VALUES (1,7,TO_DATE('11:00','HH24:MI'),TO_DATE('19:00','HH24:MI'));

INSERT INTO horarios SELECT 2, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 3, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 4, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 5, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 6, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 7, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;
INSERT INTO horarios SELECT 8, dia, hora_aper, hora_cier FROM horarios WHERE id_tienda = 1;

COMMIT;

-- Reino Unido (44)
INSERT INTO telefonos VALUES (1, '44', '131', '5551234');
INSERT INTO telefonos VALUES (2, '44', '141', '5552345');

-- Rumanía (40)
INSERT INTO telefonos VALUES (3, '40', '268', '5553456');
INSERT INTO telefonos VALUES (4, '40', '264', '5554567');

-- Canadá (1)
INSERT INTO telefonos VALUES (5, '1', '514', '5555678');
INSERT INTO telefonos VALUES (6, '1', '613', '5556789');

-- España (34)
INSERT INTO telefonos VALUES (7, '34', '944', '5557890');
INSERT INTO telefonos VALUES (8, '34', '91',  '5558901');

COMMIT;

