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
    cant_stock          NUMBER(6)       NOT NULL CONSTRAINT check_cant_stock CHECK(cant_stock >= 0),
    CONSTRAINT pk_lote_inv PRIMARY KEY(id_tienda_lote, id_juguete_lote, nro_lote)
);

CREATE TABLE descuentos_lotes_inventarios (
    id_tienda_lote      NUMBER(5)       NOT NULL,
    id_juguete_lote     NUMBER(5)       NOT NULL,
    nro_lote            NUMBER(6)       NOT NULL,
    id_desc             NUMBER(6)       NOT NULL,
    fecha               DATE            NOT NULL,
    cantidad_desc       NUMBER(6)     NOT NULL,
    CONSTRAINT pk_desc_lote_inv PRIMARY KEY(id_tienda_lote, id_juguete_lote, nro_lote, id_desc)
);

CREATE TABLE facturas_tiendas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_factura         NUMBER(7)       NOT NULL,
    fecha_emision       DATE            NOT NULL,
    costo_total         NUMBER(8,2),
    id_cliente          NUMBER(7)       NOT NULL,
    CONSTRAINT pk_fact_tien PRIMARY KEY(id_tienda, nro_factura)
);

CREATE TABLE dets_facturas (
    id_tienda           NUMBER(5)       NOT NULL,
    nro_fact_tienda     NUMBER(7)       NOT NULL,
    id_renglon          NUMBER(3)       NOT NULL,
    tipo_cliente        CHAR(2)         NOT NULL CONSTRAINT check_tipo_clie CHECK(tipo_cliente IN ('Ma','Me')),
    cantidad            NUMBER(7)       NOT NULL CONSTRAINT check_cant_det CHECK(cantidad > 0),
    id_tienda_lote      NUMBER(5)       NOT NULL,
    id_juguete_lote     NUMBER(5)       NOT NULL,
    nro_lote            NUMBER(6)       NOT NULL,
    CONSTRAINT pk_det_fact PRIMARY KEY(id_tienda, nro_fact_tienda, id_renglon)
);

CREATE TABLE facturas_online (
    nro_factura         NUMBER(7)       NOT NULL CONSTRAINT pk_fact_on PRIMARY KEY,
    fecha_emision       DATE            NOT NULL,
    costo_total         NUMBER(8,2),
    puntos_leal         NUMBER(3),
    id_cliente          NUMBER(7)       NOT NULL,
    venta_gratis        BOOLEAN
);

CREATE TABLE dets_online (
    nro_fact_online     NUMBER(7)       NOT NULL,
    id_det_on           NUMBER(3)       NOT NULL,
    tipo_cliente        CHAR(2)         NOT NULL CONSTRAINT check_tipo_clie_on CHECK(tipo_cliente IN ('Ma','Me')),
    cantidad            NUMBER(7)       NOT NULL CONSTRAINT check_cant_det_on CHECK(cantidad > 0),
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
  
  
  -- Funciones
-- Este procedimiento calcula el costo total para las facturas de ventas físicas
CREATE OR REPLACE PROCEDURE actualizar_costo_total_fact_tienda (
    p_id_tienda IN facturas_tiendas.id_tienda%TYPE,
    p_nro_factura IN facturas_tiendas.nro_factura%TYPE
)
IS
    v_costo_calculado NUMBER(8, 2) := 0;
BEGIN
    -- Calcular el Costo Total
    SELECT SUM(df.cantidad * hp.precio)
    INTO v_costo_calculado
    FROM dets_facturas df
    
    JOIN lotes_inventarios li ON 
        df.id_tienda_lote = li.id_tienda_lote AND
        df.id_juguete_lote = li.id_juguete_lote AND
        df.nro_lote = li.nro_lote

    JOIN hist_precios hp ON 
        li.id_juguete_lote = hp.id_juguete

    WHERE df.id_tienda = p_id_tienda
      AND df.nro_fact_tienda = p_nro_factura
      AND hp.fecha_fin IS NULL;
      
    IF v_costo_calculado IS NULL THEN
        v_costo_calculado := 0;
    END IF;

    -- Actualizar la tabla facturas_tiendas
    UPDATE facturas_tiendas
    SET costo_total = v_costo_calculado
    WHERE id_tienda = p_id_tienda
      AND nro_factura = p_nro_factura;
      
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error al actualizar costo total de la factura: ' || SQLERRM);
END;
/
-- Se usa el siguiente comando para ejecutar el procedimiento luego de insertar una fila de facturas_clientes (costo_total como NULL) y sus filas de dets_facturas necesarios
-- EXEC actualizar_costo_total_fact_tienda(id_tienda, nro_factura);
  
  
-- Este procedimiento calcula el costo total y los puntos de lealtad para las facturas de ventas online
CREATE OR REPLACE PROCEDURE actualizar_factura_online (
    p_nro_factura IN NUMBER
)
IS
    v_costo_base          NUMBER := 0;
    v_recargo_porcentaje  NUMBER := 0;
    v_recargo_monto       NUMBER := 0;
    v_costo_final         NUMBER := 0;
    
    v_id_cliente          NUMBER(7);
    v_puntos_acumulados_ant NUMBER := 0; -- Suma de puntos de facturas anteriores
    v_puntos_ganados_esta_factura NUMBER := 0;
    
    v_es_gratis_compra    BOOLEAN := FALSE; 
    
    v_pertenece_ue        BOOLEAN;
    
    e_no_data_factura EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_no_data_factura, -20001);
    
BEGIN
    SELECT fo.id_cliente, 
           SUM(do.cantidad * hp.precio),
           p.pertenece_ue
    INTO v_id_cliente, v_costo_base, v_pertenece_ue
    FROM facturas_online fo
    JOIN dets_online do ON fo.nro_factura = do.nro_factura
    JOIN catalogos c ON do.id_catalogo = c.id_catalogo
    JOIN juguetes j ON c.id_juguete = j.id_juguete
    JOIN hist_precios hp ON j.id_juguete = hp.id_juguete
    JOIN clientes cl ON fo.id_cliente = cl.id_lego
    JOIN paises p ON cl.id_pais_resi = p.id_pais
    WHERE fo.nro_factura = p_nro_factura
    AND hp.fec_vigencia_fin IS NULL 
    GROUP BY fo.id_cliente, p.pertenece_ue;

    IF v_costo_base IS NULL THEN
       v_costo_base := 0;
    END IF;

    -- Determinar Recargo
    IF v_pertenece_ue = TRUE THEN
        v_recargo_porcentaje := 0.05; -- UE: 5%
    ELSE
        v_recargo_porcentaje := 0.15; -- No UE: 15%
    END IF;
    
    v_recargo_monto := v_costo_base * v_recargo_porcentaje;

    -- Calcular Puntos de Lealtad Acumulados ANTERIORES
    -- Suma los puntos_leal de TODAS las facturas anteriores del cliente que NO fueron gratuitas.
    SELECT NVL(SUM(puntos_leal), 0)
    INTO v_puntos_acumulados_ant
    FROM facturas_online
    WHERE id_cliente = v_id_cliente
    AND nro_factura != p_nro_factura -- Excluye la factura actual si ya existe
    AND venta_gratis = FALSE; -- Solo considera facturas pagadas para acumulación
    
    -- Determinar si la compra actual es gratuita 
    -- Consulta si ya existe una factura gratuita posterior a la que hizo que el cliente llegara a 500
    IF v_puntos_acumulados_ant >= 500 THEN
        v_es_gratis_compra := TRUE;
        v_costo_final := v_recargo_monto; -- Solo paga el recargo
    ELSE
        v_es_gratis_compra := FALSE;
        v_costo_final := v_costo_base * (1 + v_recargo_porcentaje);
    END IF;
    
    -- Lógica de puntos ganados en esta factura
    
    IF v_es_gratis_compra = TRUE THEN
        -- Si fue la compra gratuita, no acumula puntos en esta transacción.
        v_puntos_ganados_esta_factura := 0; 
    ELSE
        -- Si fue una compra normal, acumula puntos según el costo base (sin recargo).
        IF v_costo_base < 10 THEN
            v_puntos_ganados_esta_factura := 5;
        ELSIF v_costo_base >= 10 AND v_costo_base < 70 THEN
            v_puntos_ganados_esta_factura := 20;
        ELSIF v_costo_base >= 70 AND v_costo_base < 200 THEN
            v_puntos_ganados_esta_factura := 50;
        ELSIF v_costo_base >= 200 THEN
            v_puntos_ganados_esta_factura := 200;
        ELSE
            v_puntos_ganados_esta_factura := 0;
        END IF;
    END IF;

    -- Actualización de la Factura
    -- Esta factura registra el costo final, si fue gratuita, y cuántos puntos se ganaron.
    UPDATE facturas_online
    SET 
        costo_total = v_costo_final,
        puntos_leal = v_puntos_ganados_esta_factura, -- Los puntos ganados en esta transacción
        venta_gratis = v_es_gratis_compra
    WHERE nro_factura = p_nro_factura;
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error: Factura Online ' || p_nro_factura || ' no existe, no tiene detalles o faltan datos de cliente/país.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Error inesperado al procesar la factura: ' || SQLERRM);
END PR_CALCULAR_FACTURA_ONLINE;
/
-- Se usa el siguiente comando para ejecutar el procedimiento luego de insertar una fila de facturas_online (costo_total como NULL) y sus filas de dets_online necesarios
-- ejemplo de id_factura_online(1001)
-- EXEC actualizar_factura_online(1001);

  
  --TRIGGERS
-- Este trigger valida que la cantidad de juguetes compradas en un renglón de factura no puede exceder 
-- el límite máximo de compras online definido para el país en la tabla catalogos.
CREATE OR REPLACE TRIGGER validar_cant_limite_online
BEFORE INSERT OR UPDATE OF cantidad ON dets_online
FOR EACH ROW
DECLARE
    v_limite_compra catalogos.lim_compra_ol%TYPE;
BEGIN
    SELECT lim_compra_ol
    INTO v_limite_compra
    FROM catalogos
    WHERE id_pais = :NEW.id_pais_cat
      AND id_juguete = :NEW.id_juguete_cat;

    IF :NEW.cantidad > v_limite_compra THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'La cantidad comprada online (' || :NEW.cantidad || ') excede el límite permitido por el catálogo (' || v_limite_compra || ').'
        );
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20006,
            'Error de integridad: No se encontró la referencia del catálogo para este producto.'
        );
END;
/

-- Este trigger verifica que la cantidad vendida en una línea de factura sea positiva (> 0)
-- y que no exceda el stock físico disponible del lote.
CREATE OR REPLACE TRIGGER validar_stock_venta_tienda
BEFORE INSERT OR UPDATE OF cantidad ON dets_facturas
FOR EACH ROW
DECLARE
    v_stock_actual lotes_inventarios.cant_stock%TYPE;
BEGIN
    IF :NEW.cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20007,
            'La cantidad vendida debe ser un valor positivo (mayor que cero).'
        );
    END IF;

    SELECT cant_stock
    INTO v_stock_actual
    FROM lotes_inventarios
    WHERE id_tienda_lote = :NEW.id_tienda_lote
      AND id_juguete_lote = :NEW.id_juguete_lote
      AND nro_lote = :NEW.nro_lote;

    IF :NEW.cantidad > v_stock_actual THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'La cantidad vendida (' || :NEW.cantidad || ') excede el stock disponible (' || v_stock_actual || ') para el lote de la tienda.'
        );
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'Error de integridad: No se encontró el lote de inventario asociado a la venta.'
        );
END;
/
