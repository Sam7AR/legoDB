CREATE TABLE juguetes (
    id NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
        CONSTRAINT pk_juguetes PRIMARY KEY,
        
    nombre VARCHAR(50) NOT NULL
        CONSTRAINT chk_juguetes_nombre CHECK (LENGTH(nombre) >= 8)
        CONSTRAINT uq_juguetes_nombre UNIQUE,
    
    rgo_edad VARCHAR(7) NOT NULL
        CONSTRAINT chk_juguetes_rgo_edad CHECK (rgo_edad IN ('0-2', '3-4', '5-6', '7-8', '9-11', '12+', 'adultos')),

    rgo_precio VARCHAR(1) NOT NULL
        CONSTRAINT chk_juguetes_rgo_precio CHECK (rgo_precio IN ('A', 'B', 'C', 'D')),
    
    cant_pzas NUMBER
        CONSTRAINT chk_juguetes_cant_pzas CHECK (cant_pzas > 0),
    
    descripcion VARCHAR(450) NOT NULL,

    instrucciones VARCHAR(260),

    es_set VARCHAR(1) NOT NULL
        CONSTRAINT chk_juguetes_es_set CHECK (es_set IN ('S', 'N')),

    id_set_padre NUMBER
        CONSTRAINT fk_juguetes_set_padre REFERENCES juguetes(id)
    );