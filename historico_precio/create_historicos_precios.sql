CREATE TABLE hist_precios (
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    precio NUMBER NOT NULL,
    id_juguete NUMBER NOT NULL,
    CONSTRAINT pk_hist_precios PRIMARY KEY (fecha_inicio, id_juguete)
);

ALTER TABLE hist_precios
ADD (
    CONSTRAINT fk_hist_precios_id_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES JUGUETES(id)
);

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

INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 299.99, 1);  -- Millennium Falcon
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 449.99, 2);  -- Hogwarts Castle  
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 89.99, 3);   -- Nether Fortress
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 129.99, 4);  -- X-Wing Fighter
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 19.99, 5);   -- Dementor Figure
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 9.99, 6);    -- Zombie Pigman
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 4.99, 7);    -- Micro Creeper
INSERT INTO hist_precios (fecha_inicio,  precio, id_juguete) VALUES (SYSDATE, 29.99, 8);   -- Police Patrol
