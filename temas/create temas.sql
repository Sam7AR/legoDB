CREATE TABLE TEMAS (
    id NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
        CONSTRAINT pk_temas PRIMARY KEY,
        
    nombre VARCHAR(50) NOT NULL
        CONSTRAINT chk_temas_nombre CHECK (LENGTH(nombre) >= 4)
        CONSTRAINT uq_temas_nombre UNIQUE,
        
    descripcion VARCHAR(450) NOT NULL,

    tipo VARCHAR(5) NOT NULL
        CONSTRAINT chk_temas_tipo CHECK (tipo IN ('tema', 'serie')), 
    
    id_serie_padre NUMBER
        CONSTRAINT fk_temas_serie_padre REFERENCES temas(id)
    );