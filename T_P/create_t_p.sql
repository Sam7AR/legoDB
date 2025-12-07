CREATE TABLE T_J (
    id_tema     NUMBER NOT NULL,
    id_juguete NUMBER NOT NULL,

    CONSTRAINT pk_t_j
        PRIMARY KEY (id_tema, id_juguete),

    CONSTRAINT fk_tj_pais
        FOREIGN KEY (id_tema)
        REFERENCES temas(id),

    CONSTRAINT fk_tj_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES juguetes(id)
);
