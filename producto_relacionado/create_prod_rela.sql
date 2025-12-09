CREATE TABLE prods_relacionados (
    id_jgt_base NUMBER(7) NOT NULL,
    id_jgt_rela NUMBER(7) NOT NULL,

    CONSTRAINT pk_prods_rela
        PRIMARY KEY (id_jgt_base, id_jgt_rela)
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

-- Star Wars: Millennium Falcon ↔ X-Wing (mismo universo)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (1, 4);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (4, 1);

-- Harry Potter: Hogwarts Castle ↔ Dementor Figure (mismo castillo)
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (2, 5);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (5, 2);

-- Minecraft Nether: Fortress ↔ Zombie Pigman ↔ Micro Creeper
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (3, 6);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (6, 3);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (3, 7);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (7, 3);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (6, 7);
INSERT INTO prods_relacionados (id_jgt_base, id_jgt_rela) VALUES (7, 6);