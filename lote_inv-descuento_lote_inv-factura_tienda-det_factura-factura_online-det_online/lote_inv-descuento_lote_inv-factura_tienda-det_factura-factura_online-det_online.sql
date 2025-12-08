DROP TABLE lotes_inventarios CASCADE CONSTRAINTS;
DROP TABLE descuentos_lotes_inventarios CASCADE CONSTRAINTS;
DROP TABLE facturas_tiendas CASCADE CONSTRAINTS;
DROP TABLE dets_facturas CASCADE CONSTRAINTS;
DROP TABLE facturas_online CASCADE CONSTRAINTS;
DROP TABLE dets_online CASCADE CONSTRAINTS;

CREATE TABLE lotes_inventarios (
    id_tienda_lote      NUMBER(5)       NOT NULL,
    id_juguete_lote     NUMBER(5)       NOT NULL,
    nro_lote            NUMBER(6)       NOT NULL,
    cant_stock          NUMBER(7)       NOT NULL,
    CONSTRAINT pk_lote_inv PRIMARY KEY(id_tienda_lote, id_juguete_lote, nro_lote)
);

CREATE TABLE descuentos_lotes_inventarios (
    id_tienda_lote      NUMBER(5)       NOT NULL,
    id_juguete_lote     NUMBER(5)       NOT NULL,
    nro_lote            NUMBER(6)       NOT NULL,
    id_desc             NUMBER(6)       NOT NULL,
    fecha               DATE            NOT NULL,
    cantidad_desc       NUMBER(8,2)     NOT NULL,
    CONSTRAINT pk_desc_lote_inv PRIMARY KEY(id_tienda_lote, id_juguete_lote, nro_lote, id_desc)
);

CREATE TABLE facturas_tiendas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_factura         NUMBER(7)       NOT NULL,
    fecha_emision       DATE            NOT NULL,
    costo_total         NUMBER(8,2)     NOT NULL,
    id_cliente          NUMBER(7)       NOT NULL,
    CONSTRAINT pk_fact_tien PRIMARY KEY(id_tienda, nro_factura)
);

CREATE TABLE dets_facturas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_fact_tienda     NUMBER(7)       NOT NULL,
    id_renglon          NUMBER(3)       NOT NULL,
    tipo_cliente        CHAR(2)         NOT NULL CONSTRAINT check_tipo_clie CHECK(tipo_cliente IN ('Ma','Me')),
    cantidad            NUMBER(7)       NOT NULL,
    id_tienda_lote      NUMBER(5)       NOT NULL,
    id_juguete_lote     NUMBER(5)       NOT NULL,
    nro_lote            NUMBER(6)       NOT NULL,
    CONSTRAINT pk_det_fact PRIMARY KEY(id_tienda, nro_fact_tienda, id_renglon)
);

CREATE TABLE facturas_online (
    nro_factura         NUMBER(7)       NOT NULL CONSTRAINT pk_fact_on PRIMARY KEY,
    fecha_emision       DATE            NOT NULL,
    costo_total         NUMBER(8,2)     NOT NULL,
    puntos_leal         NUMBER(3)       NOT NULL,
    id_cliente          NUMBER(7)       NOT NULL,
    venta_gratis        BOOLEAN
);

CREATE TABLE dets_online (
    nro_fact_online     NUMBER(7)       NOT NULL,
    id_det_on           NUMBER(3)       NOT NULL,
    tipo_cliente        CHAR(2)         NOT NULL CONSTRAINT check_tipo_clie_on CHECK(tipo_cliente IN ('Ma','Me')),
    cantidad            NUMBER(7)       NOT NULL,
    id_pais_cat         NUMBER(3)       NOT NULL,
    id_juguete_cat      NUMBER(5)       NOT NULL,
    CONSTRAINT pk_det_fact_on PRIMARY KEY(nro_fact_online, id_det_on)
);


ALTER TABLE lotes_inventarios
  ADD(
  CONSTRAINT fk_tien_lote
  FOREIGN KEY (id_tienda_lote)
  REFERENCES tiendas_fisica (id_tienda),

  CONSTRAINT fk_jugue_lote
  FOREIGN KEY (id_juguete_lote)
  REFERENCES juguetes (id));
  
ALTER TABLE descuentos_lotes_inventarios
  ADD(
  CONSTRAINT fk_desc_lote
  FOREIGN KEY (id_tienda_lote, id_juguete_lote, nro_lote)
  REFERENCES lotes_inventarios (id_tienda_lote, id_juguete_lote, nro_lote));

ALTER TABLE facturas_tiendas
  ADD(
  CONSTRAINT fk_tien_fact
  FOREIGN KEY (id_tienda)
  REFERENCES tiendas_fisica (id_tienda),

  CONSTRAINT fk_clie_fact
  FOREIGN KEY (id_cliente)
  REFERENCES clientes (id_lego));
  
ALTER TABLE dets_facturas
  ADD(
  CONSTRAINT fk_detfact_tien
  FOREIGN KEY (id_tienda, nro_fact_tienda)
  REFERENCES facturas_tiendas (id_tienda, nro_factura),

  CONSTRAINT fk_detfact_lote
  FOREIGN KEY (id_tienda_lote, id_juguete_lote, nro_lote)
  REFERENCES lotes_inventarios (id_tienda_lote, id_juguete_lote, nro_lote));
  
ALTER TABLE facturas_online
  ADD(
  CONSTRAINT fk_clie_fact_on
  FOREIGN KEY (id_cliente)
  REFERENCES clientes (id_lego));
  
ALTER TABLE dets_online
  ADD(
  CONSTRAINT fk_detfact_on
  FOREIGN KEY (nro_fact_online)
  REFERENCES facturas_online (nro_factura),

  CONSTRAINT fk_detfact_on_cat
  FOREIGN KEY (id_pais_cat, id_juguete_cat)
  REFERENCES catalogos (id_pais, id_juguete));
