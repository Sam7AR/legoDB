CREATE TABLE paises (
    id                       NUMBER(3)     NOT NULL CONSTRAINT pk_pais PRIMARY KEY,
    nombre                   VARCHAR2(50)  NOT NULL,
    continente               CHAR(2)       NOT NULL CONSTRAINT check_cont CHECK(continente IN ('AM','AF','AS','EU','OC')),
    nacionalidad             VARCHAR2(50)  NOT NULL,
    pertenece_ue             BOOLEAN       NOT NULL
);

CREATE TABLE tours (
    fec_inic    DATE CONSTRAINT pk_tour PRIMARY KEY,
    cupos_tot   NUMBER(4) NOT NULL,
    precio_ent  NUMBER(6,2) NOT NULL
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
    id_tour           DATE NOT NULL,
    nro_reci          NUMBER(4) NOT NULL,
    costo_tot         NUMBER(8,2) NOT NULL,
    estatus           VARCHAR2(9) NOT NULL CONSTRAINT check_recibo_estatus CHECK (estatus IN ('pendiente','pagado')),
    fec_emi           DATE, 
    CONSTRAINT pk_recibo_ins PRIMARY KEY(id_tour,nro_reci)
);

CREATE TABLE inscritos (
    id_tour           DATE NOT NULL,
    nro_reci          NUMBER(4) NOT NULL,
    id_ins            NUMBER(2) NOT NULL,
    id_clien          NUMBER(7),
    id_fan_men        NUMBER(7),
    CONSTRAINT pk_inscritos PRIMARY KEY(id_tour,nro_reci,id_ins),
    CONSTRAINT clien_fan_exclu CHECK( 
                                    (id_clien IS NOT NULL AND id_fan_men IS NULL) OR
                                    (id_clien IS NULL AND id_fan_men IS NOT NULL))  
);

CREATE TABLE entradas (
    id_tour           DATE NOT NULL,
    nro_reci          NUMBER(4) NOT NULL,
    nro_ent           NUMBER(4) NOT NULL,
    tipo_asis         VARCHAR2(6) NOT NULL CONSTRAINT check_tipo_asis CHECK (tipo_asis IN ('adulto','menor')),
    CONSTRAINT pk_entradas PRIMARY KEY(id_tour,nro_reci,nro_ent)
);

ALTER TABLE clientes
  ADD(
  CONSTRAINT fk_clien_nacio
  FOREIGN KEY (id_pais_nacio)
  REFERENCES paises (id),
  
  CONSTRAINT fk_clien_resi
  FOREIGN KEY (id_pais_resi)
  REFERENCES paises (id));
  
ALTER TABLE fans_menores
  ADD(
  CONSTRAINT fk_fan_represen
  FOREIGN KEY (id_representante)
  REFERENCES clientes (id_lego),
  
  CONSTRAINT fk_fan_nacio
  FOREIGN KEY (id_pais_nacio)
  REFERENCES paises (id));
  
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
    v_edad         NUMBER;
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
     WHERE id = :NEW.id_pais_nacio;

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
    v_edad         NUMBER;
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
     WHERE id = :NEW.id_pais_nacio;

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

INSERT INTO paises (id, nombre, continente, nacionalidad, pertenece_ue)
VALUES (1, 'España', 'EU', 'Española', TRUE);

INSERT INTO paises (id, nombre, continente, nacionalidad, pertenece_ue)
VALUES (2, 'Venezuela', 'AM', 'Venezolana', FALSE);

INSERT INTO paises (id, nombre, continente, nacionalidad, pertenece_ue)
VALUES (3, 'Colombia', 'AM', 'Colombiana', FALSE);

INSERT INTO paises (id, nombre, continente, nacionalidad, pertenece_ue)
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