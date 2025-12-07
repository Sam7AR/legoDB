CREATE TABLE CATALOGOS (
    lim_compra_ol NUMBER NOT NULL
        CONSTRAINT chk_catalogos_lim_compra_ol CHECK (lim_compra_ol > 0),
        
    id_pais NUMBER NOT NULL
        CONSTRAINT fk_catalogos_id_pais REFERENCES paises(id),
    
    id_juguete NUMBER NOT NULL
        CONSTRAINT fk_catalogos_id_pais REFERENCES juguetes(id)
    );