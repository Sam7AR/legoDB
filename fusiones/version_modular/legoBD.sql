-------------------------------------------------------------------------------
-- EJEMPLO DE CREACIÓN DEL USUARIO PARA EL PROYECTO LEGO 
-------------------------------------------------------------------------------

-- CREATE USER lego IDENTIFIED BY lego123

-------------------------------------------------------------------------------
-- PRIVILEGIOS BÁSICOS PARA PERMITIR CREAR TABLAS, TIPOS, TRIGGERS, PROCEDURES
-------------------------------------------------------------------------------

-- GRANT CREATE SESSION TO lego;
-- GRANT CREATE TABLE TO lego;
-- GRANT CREATE VIEW TO lego;
-- GRANT CREATE SEQUENCE TO lego;
-- GRANT CREATE TRIGGER TO lego;
-- GRANT CREATE PROCEDURE TO lego;
-- GRANT CREATE TYPE TO lego;



--RUTINA PARA ELIMINAR TODOS LOS OBJETOS EN EL ESQUEMA
BEGIN

   FOR rec IN (SELECT view_name FROM user_views) LOOP
      EXECUTE IMMEDIATE 'DROP VIEW ' || rec.view_name || ' CASCADE CONSTRAINTS';
   END LOOP;

   FOR rec IN (SELECT table_name FROM user_tables ORDER BY table_name) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;

   FOR rec IN (SELECT sequence_name FROM user_sequences WHERE sequence_name NOT LIKE 'ISEQ$$%') LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
   END LOOP;

   FOR rec IN (SELECT type_name FROM user_types) LOOP
       EXECUTE IMMEDIATE 'DROP TYPE ' || rec.type_name || ' FORCE';
   END LOOP;
END;
/

--TIPOS DECLARADOS

    CREATE OR REPLACE TYPE id_tab AS TABLE OF NUMBER;
    /

  -- parametros de detalle de factura
    CREATE OR REPLACE TYPE det_fac_params AS OBJECT (
        id_juguete  NUMBER(5),
        cantidad    NUMBER(7),
        tipo_clien  CHAR(2)       -- 'MA' o 'ME'
    );
    /

    -- Tabla de detalles de factura 
    CREATE OR REPLACE TYPE det_fac_tab AS TABLE OF det_fac_params;
    /

 --SECUENCIAS
CREATE SEQUENCE id_fact_online INCREMENT BY 1 START WITH 1; 


--CREATES DE LAS TABLAS
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
    id_tienda  NUMBER(5)    NOT NULL,
    cod_pais   VARCHAR2(5)  NOT NULL,
    cod_area   VARCHAR2(5)  NOT NULL,
    numero     VARCHAR2(15) NOT NULL,
    CONSTRAINT pk_telefono PRIMARY KEY (id_tienda, cod_pais, cod_area, numero)
);

CREATE TABLE temas (
    id           NUMBER(7)     NOT NULL CONSTRAINT pk_temas PRIMARY KEY,
    nombre       VARCHAR2(50)  NOT NULL
                 CONSTRAINT chk_temas_nombre CHECK (LENGTH(nombre) >= 4)
                 CONSTRAINT uq_temas_nombre UNIQUE,
    descripcion  VARCHAR2(450) NOT NULL,
    tipo         VARCHAR2(5)   NOT NULL
                 CONSTRAINT chk_temas_tipo CHECK (tipo IN ('tema', 'serie')), 
    id_tema_padre NUMBER(7)  
);

CREATE TABLE juguetes (
    id            NUMBER(7) NOT NULL CONSTRAINT pk_juguetes PRIMARY KEY, 
    nombre        VARCHAR2(50) NOT NULL
                  CONSTRAINT chk_juguetes_nombre CHECK (LENGTH(nombre) >= 3)
                  CONSTRAINT uq_juguetes_nombre UNIQUE,
    rgo_edad      VARCHAR2(7) NOT NULL
                  CONSTRAINT chk_juguetes_rgo_edad CHECK (rgo_edad IN ('0-2', '3-4', '5-6', '7-8', '9-11', '12+', 'adultos')),
    rgo_precio    CHAR(1) NOT NULL
                  CONSTRAINT chk_juguetes_rgo_precio CHECK (rgo_precio IN ('A', 'B', 'C', 'D')),
    descripcion   VARCHAR2(450) NOT NULL,
    es_set        BOOLEAN NOT NULL,
    cant_pzas     NUMBER(5) CONSTRAINT chk_juguetes_cant_pzas CHECK (cant_pzas > 0),
    id_set_padre  NUMBER,
    instrucciones VARCHAR2(260)    
);

CREATE TABLE T_J (
    id_tema    NUMBER(7) NOT NULL,
    id_juguete NUMBER(7) NOT NULL,

    CONSTRAINT pk_t_j
        PRIMARY KEY (id_tema, id_juguete)
);

CREATE TABLE catalogos (
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
    precio NUMBER NOT NULL,
    id_juguete NUMBER NOT NULL,
    fecha_fin DATE,
    CONSTRAINT pk_hist_precios PRIMARY KEY (fecha_inicio, id_juguete)
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
    fec_ven_pas          DATE,
    CONSTRAINT uq_clien_doc_pais UNIQUE(id_pais_nacio,doc_iden)
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
    fec_ven_pas          DATE,
    CONSTRAINT uq_fan_doc_pais UNIQUE(id_pais_nacio,doc_iden)
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
    CONSTRAINT uq_visitante_tour UNIQUE(id_tour,id_clien, id_fan_men),
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

CREATE TABLE lotes_inventarios (
    id_tienda           NUMBER(5)       NOT NULL,
    id_juguete          NUMBER(6)       NOT NULL,
    nro_lote            NUMBER(5)       NOT NULL,
    cant_stock          NUMBER(6)       NOT NULL CONSTRAINT check_cant_stock CHECK(cant_stock >= 0),
    CONSTRAINT pk_lote_inv PRIMARY KEY(id_tienda, id_juguete, nro_lote)
);

CREATE TABLE descuentos_lotes_inventarios (
    id_tienda           NUMBER(5)       NOT NULL,
    id_juguete          NUMBER(6)       NOT NULL,
    nro_lote            NUMBER(5)       NOT NULL,
    id_desc             NUMBER(5)       NOT NULL,
    fecha               DATE            NOT NULL,
    cant_desc           NUMBER(6)       NOT NULL,
    CONSTRAINT pk_desc_lote_inv PRIMARY KEY(id_tienda, id_juguete, nro_lote, id_desc)
);

CREATE TABLE facturas_tiendas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_fact            NUMBER(7)       NOT NULL,
    fec_emi             DATE            NOT NULL,
    id_cliente          NUMBER(7)       NOT NULL,
    costo_tot           NUMBER(8,2),
    CONSTRAINT pk_fact_tien PRIMARY KEY(id_tienda, nro_fact)
);

CREATE TABLE dets_facturas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_fact            NUMBER(7)       NOT NULL,
    id_renglon          NUMBER(3)       NOT NULL,
    tipo_clien          CHAR(2)         NOT NULL CONSTRAINT check_tipo_clien CHECK(tipo_clien IN ('MA','ME')),
    cantidad            NUMBER(7)       NOT NULL CONSTRAINT check_cant_det CHECK(cantidad > 0),
    id_juguete          NUMBER(6)       NOT NULL,
    nro_lote            NUMBER(5)       NOT NULL,
    CONSTRAINT pk_det_fact PRIMARY KEY(id_tienda, nro_fact, id_renglon)
);

CREATE TABLE facturas_online (
    nro_fact            NUMBER(8)       NOT NULL CONSTRAINT pk_fact_on PRIMARY KEY,
    fec_emi             DATE            NOT NULL,
    id_cliente          NUMBER(7)       NOT NULL,
    costo_tot           NUMBER(8,2),
    puntos_leal         NUMBER(3),
    venta_gratis        BOOLEAN
);



CREATE TABLE dets_online (
    nro_fact            NUMBER(8)       NOT NULL,
    id_renglon          NUMBER(3)       NOT NULL,
    tipo_clien          CHAR(2)         NOT NULL CONSTRAINT check_tipo_clien_on CHECK(tipo_clien IN ('MA','ME')),
    cantidad            NUMBER(7)       NOT NULL CONSTRAINT check_cant_det_on CHECK(cantidad > 0),
    id_pais_cat         NUMBER(3)       NOT NULL,
    id_juguete_cat      NUMBER(5)       NOT NULL,
    CONSTRAINT pk_det_fact_on PRIMARY KEY(nro_fact, id_renglon)
);

--ALTERS PARA AGREGAR LAS FK
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
  REFERENCES recibos_inscripcion (id_tour, nro_reci)
  ON DELETE CASCADE,

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
  
ALTER TABLE lotes_inventarios
  ADD(
  CONSTRAINT fk_tien_lote
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisicas (id_tienda),

  CONSTRAINT fk_jugue_lote
  FOREIGN KEY (id_juguete)
  REFERENCES juguetes (id));
  
ALTER TABLE descuentos_lotes_inventarios
  ADD(
  CONSTRAINT fk_desc_lote
  FOREIGN KEY (id_tienda, id_juguete, nro_lote)
  REFERENCES lotes_inventarios (id_tienda, id_juguete, nro_lote));

ALTER TABLE facturas_tiendas
  ADD(
  CONSTRAINT fk_tien_fact
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisicas (id_tienda),

  CONSTRAINT fk_clie_fact
  FOREIGN KEY (id_cliente)
  REFERENCES clientes (id_lego));
  
ALTER TABLE dets_facturas
  ADD(
  CONSTRAINT fk_detfact_tien
  FOREIGN KEY (id_tienda, nro_fact)
  REFERENCES facturas_tiendas (id_tienda, nro_fact),

  CONSTRAINT fk_detfact_lote
  FOREIGN KEY (id_tienda, id_juguete, nro_lote)
  REFERENCES lotes_inventarios (id_tienda, id_juguete, nro_lote));
  
ALTER TABLE facturas_online
  ADD(
  CONSTRAINT fk_clie_fact_on
  FOREIGN KEY (id_cliente)
  REFERENCES clientes (id_lego));
  
ALTER TABLE dets_online
  ADD(
  CONSTRAINT fk_detfact_on
  FOREIGN KEY (nro_fact)
  REFERENCES facturas_online (nro_fact),

  CONSTRAINT fk_detfact_on_cat
  FOREIGN KEY (id_pais_cat, id_juguete_cat)
  REFERENCES catalogos (id_pais, id_juguete));
  
--FUNCIONES:
CREATE OR REPLACE FUNCTION edad(fec_naci DATE) RETURN NUMBER IS
    BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, fec_naci) / 12);
    END edad;
/

CREATE OR REPLACE FUNCTION calc_puntos_lealtad (
    p_monto IN NUMBER
) RETURN NUMBER IS
    v_puntos NUMBER := 0;
BEGIN
    IF p_monto IS NULL OR p_monto <= 0 THEN
        RETURN 0;
        
    -- A: menos de 10 €
    ELSIF p_monto < 10 THEN
        v_puntos := 5;
        
    -- B: 10 € a menos de 70 €
    ELSIF p_monto <= 70 THEN
        v_puntos := 20;
        
    -- C: 70 € a 200 € 
    ELSIF p_monto <= 200 THEN
        v_puntos := 50;
        
    -- D: más de 200 €
    ELSE
        v_puntos := 200;
    END IF;

    RETURN v_puntos;
END calc_puntos_lealtad;
/

CREATE OR REPLACE FUNCTION venta_es_gratis (
    p_id_cliente IN clientes.id_lego%TYPE
) RETURN BOOLEAN IS
    v_fec_ult_gratis  DATE;
    v_suma_puntos     NUMBER := 0;
BEGIN

    SELECT MAX(fo.fec_emi)
      INTO v_fec_ult_gratis
      FROM facturas_online fo
     WHERE fo.id_cliente = p_id_cliente
       AND fo.venta_gratis = TRUE;  

    IF v_fec_ult_gratis IS NOT NULL THEN
        SELECT NVL(SUM(fo.puntos_leal),0)
          INTO v_suma_puntos
          FROM facturas_online fo
         WHERE fo.id_cliente = p_id_cliente
           AND fo.fec_emi > v_fec_ult_gratis;
    ELSE
        -- No tiene compras gratis previas → sumar todas
        SELECT NVL(SUM(fo.puntos_leal),0)
          INTO v_suma_puntos
          FROM facturas_online fo
         WHERE fo.id_cliente = p_id_cliente;
    END IF;

    IF v_suma_puntos >= 500 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END venta_es_gratis;
/ 
  
--TRIGGERS:
CREATE OR REPLACE TRIGGER trg_temas_validar_padre_serie
BEFORE INSERT OR UPDATE OF tipo, id_tema_padre
ON TEMAS
FOR EACH ROW
DECLARE
    v_tipo_padre TEMAS.tipo%TYPE;
BEGIN
    
    IF :NEW.tipo = 'tema' AND :NEW.id_tema_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Los TEMAS no pueden tener id_tema_padre. Solo las SERIES.');
    END IF;

    
    IF :NEW.tipo = 'serie' THEN
        
        SELECT tipo INTO v_tipo_padre
        FROM TEMAS
        WHERE id = :NEW.id_tema_padre;

        IF v_tipo_padre <> 'tema' THEN
            RAISE_APPLICATION_ERROR(-20002, 
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
    
    IF :NEW.es_set = TRUE AND :NEW.id_set_padre IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(
            -20003,
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
                -20004,
                'Error: id_set_padre debe referenciar un SET (es_set = TRUE)'
            );
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20005,
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
            -20006,
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
            -20007,
            'Error: La relación (' || :NEW.id_jgt_base || ',' || :NEW.id_jgt_rela || 
            ') ya existe.'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_valida_lote_catalogo
BEFORE INSERT OR UPDATE ON lotes_inventarios
FOR EACH ROW
DECLARE
    v_id_pais   tiendas_fisicas.id_pais%TYPE;
    v_existe     NUMBER;
BEGIN
    BEGIN
        SELECT t.id_pais
          INTO v_id_pais
          FROM tiendas_fisicas t
         WHERE t.id_tienda = :NEW.id_tienda;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'La tienda con id = ' || :NEW.id_tienda || ' no existe.'
            );
    END;

    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM catalogos c
         WHERE c.id_pais    = v_id_pais
           AND c.id_juguete = :NEW.id_juguete;
    IF v_existe = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20009,
                'El juguete id = ' || :NEW.id_juguete ||
                ' no está en el catálogo del país de la tienda (id_pais = ' || v_id_pais || ').'
            );
    END IF;
    END;
END trg_valida_lote_catalogo;
/



CREATE OR REPLACE TRIGGER validar_clien
BEFORE INSERT OR UPDATE OF fec_naci ON clientes
FOR EACH ROW
DECLARE
    v_edad           NUMBER;
BEGIN
    v_edad := edad(:NEW.fec_naci);

    IF v_edad < 21 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'El cliente debe tener al menos 21 años.'
        );
    END IF;
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
            -20011,
            'El fan debe tener al menos 12 años.'
        );
    END IF;

    IF v_edad >= 21 THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'El fan debe ser menor de 21 años.'
        );
    END IF;

    IF v_edad < 18 AND :NEW.id_representante IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20013,
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
                -20014,
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
            -20015,
            'País no encontrado.'
        );
END;
/

--PROCEDIMIENTOS:

CREATE OR REPLACE PROCEDURE registrar_precio_juguete (
    p_precio   NUMBER,
    p_id_juguete NUMBER
)
IS
BEGIN
    -- Inserta nuevo precio con SYSDATE automáticamente
    INSERT INTO hist_precios (fecha_inicio, precio, id_juguete) VALUES (SYSDATE, p_precio, p_id_juguete);
END;
/

CREATE OR REPLACE PROCEDURE registrar_inscripcion_tour (
    p_fec_tour  IN tours.fec_inic%TYPE,
    p_clientes  IN id_tab,
    p_fans      IN id_tab
) IS
    v_cupos_tot         tours.cupos_tot%TYPE;
    v_precio_ent        tours.precio_ent%TYPE;
    v_inscritos_actuales  NUMBER;
    v_nuevos              NUMBER;
    v_nro_reci          recibos_inscripcion.nro_reci%TYPE;
    v_costo_total       recibos_inscripcion.costo_tot%TYPE;
    v_pasaporte         VARCHAR2(20);
    v_fec_ven           DATE;
    v_pertenece_ue      BOOLEAN;
    v_id_rep            fans_menores.id_representante%TYPE;
    v_edad_fan          NUMBER;
    v_id_ins            inscritos.id_ins%TYPE := 0;
    v_rep_en_lista      BOOLEAN;
    
    v_nombre_asistente  VARCHAR2(100);
    v_tipo_asistente    VARCHAR2(20);
    
    v_existe_inscripcion NUMBER;
BEGIN
    BEGIN
        SELECT t.cupos_tot, t.precio_ent INTO v_cupos_tot, v_precio_ent
          FROM tours t WHERE t.fec_inic = p_fec_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20016, 'El tour indicado no existe.');
    END;

    IF TRUNC(SYSDATE) >= TRUNC(p_fec_tour) THEN
        RAISE_APPLICATION_ERROR(-20017, 'No se puede inscribir: la fecha actual es igual o posterior a la fecha del tour.');
    END IF;

    SELECT COUNT(*) INTO v_inscritos_actuales FROM inscritos WHERE id_tour = p_fec_tour;

    v_nuevos := CASE WHEN p_clientes IS NOT NULL THEN p_clientes.COUNT ELSE 0 END +
                CASE WHEN p_fans IS NOT NULL THEN p_fans.COUNT ELSE 0 END;

    IF v_inscritos_actuales + v_nuevos > v_cupos_tot THEN
        RAISE_APPLICATION_ERROR(-20018, 'No hay cupos suficientes para este tour.');
    END IF;

    v_costo_total := v_nuevos * v_precio_ent;

    SELECT NVL(MAX(r.nro_reci), 0) + 1 INTO v_nro_reci FROM recibos_inscripcion r WHERE r.id_tour = p_fec_tour;

    INSERT INTO recibos_inscripcion (id_tour, nro_reci, costo_tot, estatus, fec_emi) 
    VALUES (p_fec_tour, v_nro_reci, v_costo_total, 'pendiente', NULL);

    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('              CONSTANCIA DE INSCRIPCIÓN (PENDIENTE)        ');
    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('Fecha Tour  : ' || TO_CHAR(p_fec_tour, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Nro Recibo  : ' || v_nro_reci);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('ID   | ASISTENTE                      | TIPO    | COSTO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');

    IF p_clientes IS NOT NULL THEN
        FOR i IN 1 .. p_clientes.COUNT LOOP
            SELECT COUNT(*) INTO v_existe_inscripcion 
              FROM inscritos 
             WHERE id_tour = p_fec_tour AND id_clien = p_clientes(i);
            
            IF v_existe_inscripcion > 0 THEN
                RAISE_APPLICATION_ERROR(-20037, 'El cliente ID ' || p_clientes(i) || ' ya se encuentra inscrito en este tour.');
            END IF;

            BEGIN
                SELECT c.pasaporte, c.fec_ven_pas, p.pertenece_ue, c.p_nombre || ' ' || c.p_apellido
                  INTO v_pasaporte, v_fec_ven, v_pertenece_ue, v_nombre_asistente
                  FROM paises p, clientes c
                 WHERE c.id_lego = p_clientes(i) AND p.id_pais = c.id_pais_nacio;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20019, 'Cliente con id = ' || p_clientes(i) || ' no existe.');
            END;

            IF NOT v_pertenece_ue THEN
                IF v_pasaporte IS NULL THEN RAISE_APPLICATION_ERROR(-20020, 'Cliente ID ' || p_clientes(i) || ' sin pasaporte.'); END IF;
                IF v_fec_ven IS NULL THEN RAISE_APPLICATION_ERROR(-20021, 'Cliente ID ' || p_clientes(i) || ' sin fecha vencimiento pasaporte.'); END IF;
                IF TRUNC(v_fec_ven) < TRUNC(SYSDATE) THEN RAISE_APPLICATION_ERROR(-20022, 'Pasaporte vencido Cliente ID ' || p_clientes(i)); END IF;
            END IF;

            v_id_ins := v_id_ins + 1;
            INSERT INTO inscritos (id_tour, nro_reci, id_ins, id_clien, id_fan_men) VALUES (p_fec_tour, v_nro_reci, v_id_ins, p_clientes(i), NULL);
            
            DBMS_OUTPUT.PUT_LINE(RPAD(p_clientes(i), 5) || '| ' || RPAD(SUBSTR(v_nombre_asistente,1,30), 31) || '| ADULTO  | ' || v_precio_ent);
        END LOOP;
    END IF;

    IF p_fans IS NOT NULL THEN
        FOR j IN 1 .. p_fans.COUNT LOOP
            SELECT COUNT(*) INTO v_existe_inscripcion 
              FROM inscritos 
             WHERE id_tour = p_fec_tour AND id_fan_men = p_fans(j);
            
            IF v_existe_inscripcion > 0 THEN
                RAISE_APPLICATION_ERROR(-20038, 'El fan menor ID ' || p_fans(j) || ' ya se encuentra inscrito en este tour.');
            END IF;

            BEGIN
                SELECT f.id_representante, edad(f.fec_naci), f.fec_ven_pas, p.pertenece_ue, f.p_nombre || ' ' || f.p_apellido
                  INTO v_id_rep, v_edad_fan, v_fec_ven, v_pertenece_ue, v_nombre_asistente
                  FROM paises p, fans_menores f
                 WHERE f.id_fan = p_fans(j) AND p.id_pais = f.id_pais_nacio;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20023, 'Fan menor id=' || p_fans(j) || ' no existe.');
            END;
            
            IF NOT v_pertenece_ue AND TRUNC(v_fec_ven) < TRUNC(SYSDATE) THEN RAISE_APPLICATION_ERROR(-20024, 'Pasaporte vencido Fan ID ' || p_fans(j)); END IF;

            IF v_edad_fan < 18 THEN
                v_rep_en_lista := FALSE;
                IF p_clientes IS NOT NULL THEN
                    FOR k IN 1 .. p_clientes.COUNT LOOP
                        IF p_clientes(k) = v_id_rep THEN v_rep_en_lista := TRUE; EXIT; END IF;
                    END LOOP;
                END IF;
                IF NOT v_rep_en_lista THEN RAISE_APPLICATION_ERROR(-20025, 'El representante (ID ' || v_id_rep || ') del fan (ID ' || p_fans(j) || ') no está en la lista de adultos.'); END IF;
            END IF;

            v_id_ins := v_id_ins + 1;
            INSERT INTO inscritos (id_tour, nro_reci, id_ins, id_clien, id_fan_men) VALUES (p_fec_tour, v_nro_reci, v_id_ins, NULL, p_fans(j));
            
            DBMS_OUTPUT.PUT_LINE(RPAD(p_fans(j), 5) || '| ' || RPAD(SUBSTR(v_nombre_asistente,1,30), 31) || '| MENOR   | ' || v_precio_ent);
        END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TOTAL A PAGAR: ' || v_costo_total);
    DBMS_OUTPUT.PUT_LINE('Estado: PENDIENTE DE PAGO');
    DBMS_OUTPUT.PUT_LINE('===========================================================');

END registrar_inscripcion_tour;
/

CREATE OR REPLACE PROCEDURE confirmar_pago (
    p_id_tour  IN recibos_inscripcion.id_tour%TYPE,
    p_nro_reci IN recibos_inscripcion.nro_reci%TYPE
) IS
    v_estatus        recibos_inscripcion.estatus%TYPE;
    v_max_nro_ent    entradas.nro_ent%TYPE;
    v_tipo_asis      entradas.tipo_asis%TYPE;
BEGIN

    BEGIN
        SELECT estatus
          INTO v_estatus
          FROM recibos_inscripcion
         WHERE id_tour = p_id_tour AND nro_reci = p_nro_reci;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20026,
                'El recibo de inscripción no existe para ese tour.'
            );
    END;

    IF v_estatus = 'pagado' THEN
        RAISE_APPLICATION_ERROR(
            -20027,
            'La inscripcion ya fue confirmada anteriormente.'
        );
    END IF;
    
    UPDATE recibos_inscripcion
       SET estatus = 'pagado', fec_emi = SYSDATE
     WHERE id_tour = p_id_tour AND nro_reci = p_nro_reci;

    SELECT NVL(MAX(nro_ent), 0)
      INTO v_max_nro_ent
      FROM entradas
     WHERE id_tour = p_id_tour;

    FOR i IN (
        SELECT id_clien, id_fan_men
          FROM inscritos
         WHERE id_tour = p_id_tour
           AND nro_reci = p_nro_reci
         ORDER BY id_ins
    ) LOOP
        v_max_nro_ent := v_max_nro_ent + 1;

        IF i.id_clien IS NOT NULL THEN
            v_tipo_asis := 'adulto';
        ELSE
            v_tipo_asis := 'menor';
        END IF;

        INSERT INTO entradas (
            id_tour,
            nro_reci,
            nro_ent,
            tipo_asis
        ) VALUES (
            p_id_tour,
            p_nro_reci,
            v_max_nro_ent,
            v_tipo_asis
        );
    END LOOP;
END confirmar_pago;
/


CREATE OR REPLACE PROCEDURE registrar_factura_online (
    p_id_cliente IN facturas_online.id_cliente%TYPE,
    p_detalles   IN det_fac_tab
) IS
    v_id_pais_resi    clientes.id_pais_resi%TYPE;
    v_pertenece_ue    paises.pertenece_ue%TYPE;
    v_recargo_env     NUMBER(2,2);
    v_nro_fact        facturas_online.nro_fact%TYPE;
    v_costo_tot       facturas_online.costo_tot%TYPE := 0;
    
    v_venta_gratis    facturas_online.venta_gratis%TYPE;
    v_puntos_leal     facturas_online.puntos_leal%TYPE;
    
    v_puntos_antes_compra NUMBER; 
    v_puntos_total_cli    NUMBER; 

    v_precio_unit     hist_precios.precio%TYPE;
    v_lim_comp_on     catalogos.lim_compra_ol%TYPE;

    v_id_pais_cat     catalogos.id_pais%TYPE;
    v_id_juguete_cat  catalogos.id_juguete%TYPE;

    v_renglon         dets_online.id_renglon%TYPE := 0;
    v_nombre_juguete  juguetes.nombre%TYPE;
    v_nombre_cliente  VARCHAR2(100);
    
    v_fec_ultimo_reset DATE;
BEGIN
    BEGIN
        SELECT c.id_pais_resi, p.pertenece_ue, c.p_nombre || ' ' || c.p_apellido
          INTO v_id_pais_resi, v_pertenece_ue, v_nombre_cliente
          FROM paises p, clientes c
         WHERE id_lego = p_id_cliente AND p.id_pais = c.id_pais_resi;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-21001, 'El cliente con id = ' || p_id_cliente || ' no existe.');
    END;

    IF p_detalles IS NULL OR p_detalles.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20028, 'La factura online debe contener al menos un item.');
    END IF;
    
    IF v_pertenece_ue THEN v_recargo_env := 0.05; ELSE v_recargo_env := 0.15; END IF;
    
    BEGIN
        SELECT MAX(fec_emi) INTO v_fec_ultimo_reset
          FROM facturas_online
         WHERE id_cliente = p_id_cliente 
           AND venta_gratis = TRUE;
    EXCEPTION 
        WHEN OTHERS THEN v_fec_ultimo_reset := NULL;
    END;

    IF v_fec_ultimo_reset IS NOT NULL THEN
        SELECT NVL(SUM(puntos_leal), 0) INTO v_puntos_antes_compra
          FROM facturas_online
         WHERE id_cliente = p_id_cliente 
           AND fec_emi >= v_fec_ultimo_reset;
    ELSE
        SELECT NVL(SUM(puntos_leal), 0) INTO v_puntos_antes_compra
          FROM facturas_online
         WHERE id_cliente = p_id_cliente;
    END IF;

    v_venta_gratis := (v_puntos_antes_compra >= 500);
    
    v_nro_fact := id_fact_online.nextval;
      
    INSERT INTO facturas_online (nro_fact, fec_emi, costo_tot, puntos_leal, id_cliente, venta_gratis) 
    VALUES (v_nro_fact, SYSDATE, NULL, NULL, p_id_cliente, NULL);

    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('              COMPROBANTE DE VENTA ONLINE                  ');
    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('Factura Nro: ' || v_nro_fact);
    DBMS_OUTPUT.PUT_LINE('Cliente    : ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('ITEM | PRODUCTO                  | CANT | P.UNIT  | SUBTOTAL');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');

    FOR i IN 1 .. p_detalles.COUNT LOOP
        BEGIN
            SELECT c.lim_compra_ol INTO v_lim_comp_on FROM catalogos c
             WHERE c.id_juguete = p_detalles(i).id_juguete AND c.id_pais = v_id_pais_resi;
            v_id_pais_cat := v_id_pais_resi; 
            v_id_juguete_cat := p_detalles(i).id_juguete;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20029, 'El juguete id=' || p_detalles(i).id_juguete || ' no está en el catálogo local.');
        END;
        
        BEGIN
            SELECT h.precio, j.nombre INTO v_precio_unit, v_nombre_juguete 
              FROM hist_precios h JOIN juguetes j ON h.id_juguete = j.id
             WHERE h.id_juguete = p_detalles(i).id_juguete AND h.fecha_fin IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20030, 'El juguete id=' || p_detalles(i).id_juguete || ' no tiene precio activo.');
        END;

        IF p_detalles(i).cantidad > v_lim_comp_on THEN
            RAISE_APPLICATION_ERROR(-20031, 'Cantidad ('||p_detalles(i).cantidad||') excede el límite permitido (' || v_lim_comp_on || ').');
        END IF;

        v_costo_tot := v_costo_tot + (p_detalles(i).cantidad * v_precio_unit);
        v_renglon := v_renglon + 1;

        INSERT INTO dets_online (nro_fact, id_renglon, tipo_clien, cantidad, id_pais_cat, id_juguete_cat) 
        VALUES (v_nro_fact, v_renglon, p_detalles(i).tipo_clien, p_detalles(i).cantidad, v_id_pais_cat, v_id_juguete_cat);
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_renglon, 5) || '| ' || 
            RPAD(SUBSTR(v_nombre_juguete,1,25), 26) || '| ' || 
            RPAD(p_detalles(i).cantidad, 5) || '| ' || 
            RPAD(v_precio_unit, 8) || '| ' || 
            (p_detalles(i).cantidad * v_precio_unit)
        );
    END LOOP;

    IF v_venta_gratis THEN 
        v_puntos_leal := 0;
        v_costo_tot := v_costo_tot * (v_recargo_env);
        v_puntos_total_cli := v_puntos_antes_compra - 500;
    ELSE
        v_puntos_leal := calc_puntos_lealtad(v_costo_tot);
        v_costo_tot := v_costo_tot * (1 + v_recargo_env);
        v_puntos_total_cli := v_puntos_antes_compra + v_puntos_leal;
    END IF;
    
    UPDATE facturas_online 
       SET venta_gratis = v_venta_gratis, 
           costo_tot = v_costo_tot, 
           puntos_leal = v_puntos_leal
     WHERE nro_fact = v_nro_fact;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    IF v_venta_gratis THEN
        DBMS_OUTPUT.PUT_LINE('** ¡VENTA GRATIS APLICADA! **');
        DBMS_OUTPUT.PUT_LINE('(Solo se cobra recargo de envío)');
    END IF;
    DBMS_OUTPUT.PUT_LINE('TOTAL A PAGAR (Inc. Envío): ' || ROUND(v_costo_tot, 2));
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('PUNTOS GANADOS   : ' || v_puntos_leal);
    DBMS_OUTPUT.PUT_LINE('PUNTOS ACUMULADOS: ' || v_puntos_total_cli);
    DBMS_OUTPUT.PUT_LINE('===========================================================');

END registrar_factura_online;
/


CREATE OR REPLACE PROCEDURE registrar_factura_tienda (
    p_id_tienda  IN facturas_tiendas.id_tienda%TYPE,
    p_id_cliente IN facturas_tiendas.id_cliente%TYPE,
    p_detalles   IN det_fac_tab
) IS
    v_fec_emi         facturas_tiendas.fec_emi%TYPE := SYSDATE;
    v_nro_fact        facturas_tiendas.nro_fact%TYPE;
    v_costo_tot       facturas_tiendas.costo_tot%TYPE := 0;
    v_id_pais_tienda  tiendas_fisicas.id_pais%TYPE;
    v_stock_total     NUMBER;
    v_cant_pend       NUMBER;
    v_nro_lote        lotes_inventarios.nro_lote%TYPE;
    v_stock_lote      lotes_inventarios.cant_stock%TYPE;
    v_cant_desc       descuentos_lotes_inventarios.cant_desc%TYPE;
    v_id_desc         descuentos_lotes_inventarios.id_desc%TYPE;
    v_precio_unit     NUMBER(8,2);
    v_renglon         dets_facturas.id_renglon%TYPE := 0;
    
    v_nombre_juguete  juguetes.nombre%TYPE;
    v_nombre_tienda   tiendas_fisicas.nombre%TYPE;
    v_nombre_cliente  VARCHAR2(100);
BEGIN
    BEGIN
        SELECT id_pais, nombre INTO v_id_pais_tienda, v_nombre_tienda 
          FROM tiendas_fisicas WHERE id_tienda = p_id_tienda;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20032, 'La tienda con id = ' || p_id_tienda || ' no existe.');
    END;

    BEGIN
        SELECT p_nombre || ' ' || p_apellido INTO v_nombre_cliente 
          FROM clientes WHERE id_lego = p_id_cliente;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20033, 'El cliente con id = ' || p_id_cliente || ' no existe.');
    END;

    IF p_detalles IS NULL OR p_detalles.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20034, 'La factura física debe contener al menos un ítem.');
    END IF;

    SELECT NVL(MAX(nro_fact), 0) + 1 INTO v_nro_fact FROM facturas_tiendas WHERE id_tienda = p_id_tienda;

    INSERT INTO facturas_tiendas (id_tienda, nro_fact, fec_emi, id_cliente, costo_tot) 
    VALUES (p_id_tienda, v_nro_fact, v_fec_emi, p_id_cliente, NULL);

    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('                  COMPROBANTE DE VENTA                  ');
    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('Tienda     : ' || v_nombre_tienda);
    DBMS_OUTPUT.PUT_LINE('Cliente    : ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('Factura Nro: ' || v_nro_fact);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('ITEM | PRODUCTO                  | CANT | P.UNIT  | SUBTOTAL');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');

    FOR i IN 1 .. p_detalles.COUNT LOOP
        SELECT NVL(SUM(cant_stock), 0) INTO v_stock_total 
          FROM lotes_inventarios 
         WHERE id_tienda = p_id_tienda AND id_juguete = p_detalles(i).id_juguete;

        IF v_stock_total < p_detalles(i).cantidad THEN
            RAISE_APPLICATION_ERROR(-20035, 'Stock insuficiente (ID: '||p_detalles(i).id_juguete||'). Disponible: '||v_stock_total);
        END IF;

        BEGIN
            SELECT h.precio, j.nombre INTO v_precio_unit, v_nombre_juguete
              FROM hist_precios h JOIN juguetes j ON h.id_juguete = j.id
             WHERE h.id_juguete = p_detalles(i).id_juguete AND h.fecha_fin IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20036, 'Juguete sin precio activo.');
        END;

        v_cant_pend := p_detalles(i).cantidad;

        WHILE v_cant_pend > 0 LOOP
            SELECT nro_lote, cant_stock INTO v_nro_lote, v_stock_lote
              FROM lotes_inventarios
             WHERE id_tienda = p_id_tienda AND id_juguete = p_detalles(i).id_juguete AND cant_stock > 0
             ORDER BY nro_lote FETCH FIRST 1 ROWS ONLY;

            v_cant_desc := LEAST(v_cant_pend, v_stock_lote);

            UPDATE lotes_inventarios SET cant_stock = cant_stock - v_cant_desc
             WHERE id_tienda = p_id_tienda AND id_juguete = p_detalles(i).id_juguete AND nro_lote = v_nro_lote;

            SELECT NVL(MAX(id_desc), 0) + 1 INTO v_id_desc FROM descuentos_lotes_inventarios
             WHERE id_tienda = p_id_tienda AND id_juguete = p_detalles(i).id_juguete AND nro_lote = v_nro_lote;

            INSERT INTO descuentos_lotes_inventarios (id_tienda, id_juguete, nro_lote, id_desc, fecha, cant_desc) 
            VALUES (p_id_tienda, p_detalles(i).id_juguete, v_nro_lote, v_id_desc, v_fec_emi, v_cant_desc);
            
            v_renglon := v_renglon + 1;

            INSERT INTO dets_facturas (id_tienda, nro_fact, id_renglon, tipo_clien, cantidad, id_juguete, nro_lote) 
            VALUES (p_id_tienda, v_nro_fact, v_renglon, p_detalles(i).tipo_clien, v_cant_desc, p_detalles(i).id_juguete, v_nro_lote);

            v_costo_tot := v_costo_tot + (v_cant_desc * v_precio_unit);
            v_cant_pend := v_cant_pend - v_cant_desc;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(i, 5) || '| ' || 
            RPAD(SUBSTR(v_nombre_juguete,1,25), 26) || '| ' || 
            RPAD(p_detalles(i).cantidad, 5) || '| ' || 
            RPAD(v_precio_unit, 8) || '| ' || 
            (p_detalles(i).cantidad * v_precio_unit)
        );
        
    END LOOP;

    UPDATE facturas_tiendas SET costo_tot = v_costo_tot WHERE id_tienda = p_id_tienda AND nro_fact = v_nro_fact;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TOTAL PAGADO: ' || ROUND(v_costo_tot, 2));
    DBMS_OUTPUT.PUT_LINE('===========================================================');

END registrar_factura_tienda;
/

--INSERTS DE DATOS DE ENTRADA

--Paises
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


-- Estados
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (1, 1, 'País Vasco');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (1, 2, 'Comunidad de Madrid');

INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (5, 1, 'Escocia');

INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (6, 1, 'Brașov');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (6, 2, 'Cluj');

INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (7, 1, 'Quebec');
INSERT INTO estados (id_pais, id_estado, nombre)
VALUES (7, 2, 'Ontario');

--Ciudades:
INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (5, 1, 1, 'Edimburgo');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (5, 1, 2, 'Glasgow');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (6, 1, 1, 'Brașov');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (6, 2, 1, 'Cluj-Napoca');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (7, 1, 1, 'Pointe-Claire');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (7, 2, 1, 'Ottawa');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (1, 1, 1, 'Bilbao');

INSERT INTO ciudades (id_pais, id_estado, id_ciudad, nombre)
VALUES (1, 2, 1, 'Leganés');

--TIENDAS
INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (1, 'LEGO® Store Edinburgh', 'St James Quarter, Edinburgh', 5, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (2, 'LEGO® Store Glasgow', 'Buchanan Galleries, Glasgow', 5, 1, 2);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (3, 'LEGO® Store Coresi Shopping Centre', 'Coresi Shopping Resort, Brașov', 6, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (4, 'LEGO® Store VIVO! Mall', 'VIVO! Cluj-Napoca', 6, 2, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (5, 'LEGO® Store Montreal - Pointe-Claire', 'Fairview Pointe-Claire, QC', 7, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (6, 'LEGO® Store Ottawa', 'Rideau Centre, Ottawa, ON', 7, 2, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (7, 'LEGO® Store Bilbao', 'Centro Comercial Zubiarte, Bilbao', 1, 1, 1);

INSERT INTO tiendas_fisicas (id_tienda, nombre, direccion, id_pais, id_estado, id_ciudad)
VALUES (8, 'LEGO® Store Parquesur', 'Centro Comercial Parquesur, Leganés', 1, 2, 1);

--Horarios 
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

--Telefonos
INSERT INTO telefonos VALUES (1, '44', '131', '5551234');
INSERT INTO telefonos VALUES (2, '44', '141', '5552345');

INSERT INTO telefonos VALUES (3, '40', '268', '5553456');
INSERT INTO telefonos VALUES (4, '40', '264', '5554567');

INSERT INTO telefonos VALUES (5, '1', '514', '5555678');
INSERT INTO telefonos VALUES (6, '1', '613', '5556789');

INSERT INTO telefonos VALUES (7, '34', '944', '5557890');
INSERT INTO telefonos VALUES (8, '34', '91',  '5558901');

--TEMAS SIN PADRE

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

--CATALOGOS
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

--PRODUCTOS RELACIONADOS
-- 1. TECHNIC - Autos relacionados con el Pack Super Autos
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (17, 4);  -- Pack Super Autos → Ferrari FXX K


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

--TOURS

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2025-10-01', 36, 2081.00);


INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-10-01', 3, 2081.00);

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-11-29', 5000, 2081.00 );

INSERT INTO tours (fec_inic, cupos_tot, precio_ent)
VALUES (DATE '2026-12-10', 4000, 2081.00);

--CLIENTES

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

--FANS MENORES

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

--LOTE INVENTARIO

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (7, 1, 1, 5);     -- lote 1, 5 unidades

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (7, 1, 2, 3);     -- lote 2, 3 unidades

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (7, 5, 1, 4);     -- lote 1, 4 unidades

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (7, 5, 2, 6);     -- lote 2, 6 unidades

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (7, 14, 1, 10);   -- lote 1, 10 unidades

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (8, 1, 1, 2);     -- menos stock, útil para casos borde

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (8, 7, 1, 3);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (8, 7, 2, 5);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (8, 15, 1, 8);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (5, 12, 1, 6);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (5, 12, 2, 4);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (3, 27, 1, 12);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (3, 13, 1, 15);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (1, 21, 1, 5);

INSERT INTO lotes_inventarios (id_tienda, id_juguete, nro_lote, cant_stock)
VALUES (1, 6, 1, 7);

COMMIT;

--VIEWS

CREATE OR REPLACE VIEW v_precios_por_pais AS
SELECT 
    p.id_pais,
    p.nombre     AS pais,
    j.nombre     AS juguete,
    h.fecha_inicio,
    h.fecha_fin,
    
    CASE 
        WHEN h.fecha_fin IS NULL THEN 'ACTIVO'
        ELSE 'FINALIZADO'
    END AS estado,
    
    CASE 
        WHEN p.pertenece_ue THEN 'EUR'
        ELSE 'USD' 
    END AS moneda,
   
    CASE 
        WHEN p.pertenece_ue THEN h.precio            -- Precio original
        ELSE ROUND(h.precio * 1.05, 2)               -- Conversión a Dólar (1.05)
    END AS precio_final
FROM hist_precios h
JOIN juguetes j ON h.id_juguete = j.id
CROSS JOIN paises p;

CREATE OR REPLACE VIEW v_horarios_tiendas AS
SELECT
    t.id_tienda,
    t.nombre AS nombre_tienda,
    num_a_dia(h.dia) AS dia_semana,
    TO_CHAR(h.hora_aper, 'HH24:MI') AS hora_apertura,
    TO_CHAR(h.hora_cier, 'HH24:MI') AS hora_cierre
FROM
    tiendas_fisicas t
JOIN
    horarios h ON t.id_tienda = h.id_tienda
ORDER BY
    t.id_tienda, h.dia;
/

SELECT *
FROM v_horarios_tiendas
WHERE id_tienda = 7;

CREATE OR REPLACE VIEW v_recibos_detallados AS
SELECT 
    
    id_tour AS "Fecha del Tour",
    
    
    nro_reci AS "Nro. Recibo",
    
    
    TO_CHAR(costo_tot, 'L99G999D99', 'NLS_CURRENCY=''€''') AS "Importe Total",
    
    
    CASE estatus
        WHEN 'pagado'    THEN 'PAGADO'
        WHEN 'pendiente' THEN 'PENDIENTE'
        ELSE UPPER(estatus)
    END AS "Estado del Pago",
    
    
    CASE 
        WHEN fec_emi IS NULL THEN '---'
        ELSE TO_CHAR(fec_emi, 'DD/MM/YYYY HH24:MI') 
    END AS "Fecha de Emisión"

FROM recibos_inscripcion
ORDER BY id_tour DESC, nro_reci ASC;
/

@menu_LEGO.sql
