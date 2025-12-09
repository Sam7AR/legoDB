CREATE TABLE CATALOGOS (
    lim_compra_ol NUMBER(2) NOT NULL
        CONSTRAINT chk_catalogos_lim_compra_ol CHECK (lim_compra_ol > 0),
        
    id_pais NUMBER(3) NOT NULL,
    id_juguete NUMBER(7) NOT NULL,
    
    CONSTRAINT pk_catalogos 
        PRIMARY KEY (id_pais, id_juguete)
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