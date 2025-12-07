CREATE TABLE hist_precios (
    fecha_inicio DATE NOT NULL
        CONSTRAINT pk_hist_precios PRIMARY KEY,
    
    fecha_fin DATE,

    precio NUMBER NOT NULL,

    id_juguete NUMBER NOT NULL
        CONSTRAINT fk_hist_precios_id_juguete REFERENCES juguetes(id)
);