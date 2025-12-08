CREATE TABLE T_J (
    id_tema    NUMBER(7) NOT NULL,
    id_juguete NUMBER(7) NOT NULL,

    CONSTRAINT pk_t_j
        PRIMARY KEY (id_tema, id_juguete)
);

ALTER TABLE T_J
ADD (
    CONSTRAINT fk_tj_tema
        FOREIGN KEY (id_tema)
        REFERENCES TEMAS(id),
    CONSTRAINT fk_tj_juguete
        FOREIGN KEY (id_juguete)
        REFERENCES JUGUETES(id)
);

-- Star Wars (tema 1) + sus series (5,6,7)
INSERT INTO T_J (id_tema, id_juguete) VALUES (1, 1);  -- Star Wars → Millennium Falcon
INSERT INTO T_J (id_tema, id_juguete) VALUES (5, 1);  -- Episodio I → Millennium Falcon  
INSERT INTO T_J (id_tema, id_juguete) VALUES (5, 4);  -- Episodio I → X-Wing Fighter
INSERT INTO T_J (id_tema, id_juguete) VALUES (6, 4);  -- Episodio II → X-Wing Fighter

-- Harry Potter (tema 2) + serie (8)
INSERT INTO T_J (id_tema, id_juguete) VALUES (2, 2);  -- Harry Potter → Hogwarts Castle
INSERT INTO T_J (id_tema, id_juguete) VALUES (8, 2);  -- Piedra Filosofal → Hogwarts Castle
INSERT INTO T_J (id_tema, id_juguete) VALUES (8, 5);  -- Piedra Filosofal → Dementor Figure

-- Minecraft (tema 3) + series (10,11)
INSERT INTO T_J (id_tema, id_juguete) VALUES (3, 3);  -- Minecraft → Nether Fortress
INSERT INTO T_J (id_tema, id_juguete) VALUES (10, 3); -- Village y Pillage → Nether Fortress
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 3); -- Nether Update → Nether Fortress
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 6); -- Nether Update → Zombie Pigman
INSERT INTO T_J (id_tema, id_juguete) VALUES (11, 7); -- Nether Update → Micro Creeper

-- City (tema 12)
INSERT INTO T_J (id_tema, id_juguete) VALUES (12, 8); -- City → Police Patrol
