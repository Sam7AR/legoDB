CREATE TABLE prods_relacionados (
    id_jgt_base NUMBER NOT NULL,
    id_jgt_rela NUMBER NOT NULL,

    CONSTRAINT pk_prods_rela
        PRIMARY KEY (id_jgt_base, id_jgt_rela),

    CONSTRAINT fk_prods_relacionados_jgt_base
        FOREIGN KEY (id_jgt_base)
        REFERENCES juguetes(id),

    CONSTRAINT fk_prods_relacionados_jgt_rela
        FOREIGN KEY (id_jgt_rela)
        REFERENCES juguetes(id)
)