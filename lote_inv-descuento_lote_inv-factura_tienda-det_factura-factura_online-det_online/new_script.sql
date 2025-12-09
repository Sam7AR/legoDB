DROP TABLE lotes_inventarios;
DROP TABLE descuentos_lotes_inventarios;
DROP TABLE facturas_tiendas;
DROP TABLE dets_facturas;
DROP TABLE facturas_online;
DROP TABLE dets_online;

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

CREATE SEQUENCE id_fact_online INCREMENT BY 1 START WITH 1; 


CREATE TABLE dets_online (
    nro_fact            NUMBER(8)       NOT NULL,
    id_renglon          NUMBER(3)       NOT NULL,
    tipo_clien          CHAR(2)         NOT NULL CONSTRAINT check_tipo_clien_on CHECK(tipo_clien IN ('MA','ME')),
    cantidad            NUMBER(7)       NOT NULL CONSTRAINT check_cant_det_on CHECK(cantidad > 0),
    id_pais_cat         NUMBER(3)       NOT NULL,
    id_juguete_cat      NUMBER(5)       NOT NULL,
    CONSTRAINT pk_det_fact_on PRIMARY KEY(nro_fact, id_renglon)
);


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


CREATE OR REPLACE PROCEDURE registrar_factura_online (
    p_id_cliente IN facturas_online.id_cliente%TYPE,
    p_detalles   IN det_fac_tab
) IS
    v_id_pais_resi   clientes.id_pais_resi%TYPE;
    v_pertenece_ue   paises.pertenece_ue%TYPE;
    v_recargo_env    NUMBER(2,2);
    v_nro_fact       facturas_online.nro_fact%TYPE;
    v_costo_tot      facturas_online.costo_tot%TYPE := 0;
    
    v_venta_gratis   facturas_online.venta_gratis%TYPE;
    v_puntos_leal   facturas_online.puntos_leal%TYPE;


    v_precio_unit    historico_precios.precio%TYPE;
    v_lim_comp_on    catalogos.lim_comp_on%TYPE;

    v_id_pais_cat    catalogos.id_pais%TYPE;
    v_id_juguete_cat catalogos.id_juguete%TYPE;

    v_renglon        dets_online.id_renglon%TYPE := 0;
BEGIN

    BEGIN
        SELECT c.id_pais_resi, p.pertenece_ue
          INTO v_id_pais_resi, v_pertenece_ue
          FROM paises p, clientes c
         WHERE id_lego = p_id_cliente AND p.id_pais = c.id_pais_resi;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -21001,
                'El cliente con id = ' || p_id_cliente || ' no existe.'
            );
    END;


    IF p_detalles IS NULL OR p_detalles.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -21002,
            'La factura online debe contener al menos un item.'
        );
    END IF;
    
    IF v_pertenece_ue THEN
        v_recargo_env := 0.05;
    ELSE
        v_recargo_env := 0.15;
    END IF;
    
    v_venta_gratis := venta_es_gratis(p_id_cliente);

    v_nro_fact := id_fact_online.nextval;

     
    INSERT INTO facturas_online (
        nro_fact,
        fec_emi,
        costo_tot,
        puntos_leal,
        id_cliente,
        venta_gratis
    ) VALUES (
        v_nro_fact,
        SYSDATE,
        NULL,
        NULL,         
        p_id_cliente,
        NULL           
    );


    FOR i IN 1 .. p_detalles.COUNT LOOP

        BEGIN
            SELECT c.id_pais,
                   c.id_juguete,
                   h.precio_unit,
                   c.lim_comp_on
              INTO v_id_pais_cat,
                   v_id_juguete_cat,
                   v_precio_unit,
                   v_lim_comp_on
              FROM catalogos c, juguetes j, historico_precios h
             WHERE c.id_juguete = p_detalles(i).id_juguete
               AND c.id_pais    = v_id_pais_resi
               AND j.id_jgt     = h.id_jgt
               AND h.fec_fin IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -21004,
                    'El juguete con id = ' || p_detalles(i).id_juguete ||
                    ' no está en el catálogo del país de residencia del cliente.'
                );
        END;

        -- Validar límite de compra online
        IF p_detalles(i).cantidad > v_lim_comp_on THEN
            RAISE_APPLICATION_ERROR(
                -21005,
                'La cantidad solicitada (' || p_detalles(i).cantidad ||
                ') excede el límite de compra online (' || v_lim_comp_on ||
                ') para el juguete id = ' || p_detalles(i).id_juguete || '.'
            );
        END IF;

        -- Acumular total
        v_costo_tot := v_costo_tot + (p_detalles(i).cantidad * v_precio_unit);
        
        v_renglon := v_renglon + 1;

        INSERT INTO dets_online (
            nro_fact,
            id_renglon,
            tipo_clien,
            cantidad,
            id_pais_cat,
            id_juguete_cat
        ) VALUES (
            v_nro_fact,
            v_renglon,
            p_detalles(i).tipo_clien,
            p_detalles(i).cantidad,
            v_id_pais_cat,
            v_id_juguete_cat
        );
        
    END LOOP;
    IF v_venta_gratis THEN 
        v_puntos_leal := 0;
        v_costo_tot := v_costo_tot *(v_recargo_env);
    ELSE
        v_puntos_leal := calc_puntos_lealtad(v_costo_tot);
        v_costo_tot := v_costo_tot *(1+ v_recargo_env);
    END IF;
    UPDATE facturas_online
    SET    venta_gratis = v_venta_gratis,
           costo_tot = v_costo_tot,
           puntos_leal = v_puntos_leal
    WHERE  nro_fact = v_nro_fact;
END registrar_factura_online;
/
