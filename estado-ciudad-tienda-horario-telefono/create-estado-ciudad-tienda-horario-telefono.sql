DROP TABLE telefonos;
DROP TABLE horarios;
DROP TABLE tiendas_fisicas;
DROP TABLE ciudades;
DROP TABLE estados;

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


SELECT * FROM paises;
SELECT * FROM tours;
SELECT * FROM clientes;
SELECT * FROM fans_menores;
COMMIT;

SELECT * FROM estados;
SELECT * FROM ciudades;
SELECT * FROM tiendas_fisicas;
SELECT * FROM horarios;
SELECT * FROM telefonos;
COMMIT;