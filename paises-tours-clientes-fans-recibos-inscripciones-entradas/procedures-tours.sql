CREATE OR REPLACE TYPE id_tab AS TABLE OF NUMBER;
/

CREATE OR REPLACE PROCEDURE registrar_inscripcion_tour (
    p_fec_tour  IN tours.fec_inic%TYPE,
    p_clientes  IN id_tab,
    p_fans      IN id_tab
) IS
    v_cupos_tot        tours.cupos_tot%TYPE;
    v_precio_ent       tours.precio_ent%TYPE;

    v_inscritos_actuales  NUMBER;
    v_nuevos              NUMBER;

    v_nro_reci        recibos_inscripcion.nro_reci%TYPE;
    v_costo_total     recibos_inscripcion.costo_tot%TYPE;

    v_pasaporte       VARCHAR2(20);
    v_fec_ven         DATE;
    v_pertenece_ue    BOOLEAN;

    v_id_rep          fans_menores.id_representante%TYPE;
    v_edad_fan        NUMBER;

    v_id_ins          inscritos.id_ins%TYPE := 0;

    v_rep_en_lista  BOOLEAN;
BEGIN

    BEGIN
        SELECT t.cupos_tot, t.precio_ent
          INTO v_cupos_tot, v_precio_ent
          FROM tours t
         WHERE t.fec_inic = p_fec_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20021,
                'El tour indicado no existe.'
            );
    END;

    IF TRUNC(SYSDATE) >= TRUNC(p_fec_tour) THEN
        RAISE_APPLICATION_ERROR(
            -20022,
            'No se puede inscribir: la fecha actual es igual o posterior a la fecha del tour.'
        );
    END IF;

    SELECT COUNT(*)
      INTO v_inscritos_actuales
      FROM inscritos
     WHERE id_tour = p_fec_tour;

    v_nuevos :=
        NVL(p_clientes.COUNT, 0) +
        NVL(p_fans.COUNT, 0);

    IF v_inscritos_actuales + v_nuevos > v_cupos_tot THEN
        RAISE_APPLICATION_ERROR(
            -20023,
            'No hay cupos suficientes para este tour.'
        );
    END IF;

    v_costo_total    := v_nuevos * v_precio_ent;

    SELECT NVL(MAX(r.nro_reci), 0) + 1
      INTO v_nro_reci
      FROM recibos_inscripcion r
     WHERE r.id_tour = p_fec_tour;


    INSERT INTO recibos_inscripcion (
        id_tour,
        nro_reci,
        costo_tot,
        estatus,
        fec_emi
    ) VALUES (
        p_fec_tour,
        v_nro_reci,
        v_costo_total,
        'pendiente',
        NULL
    );

    IF p_clientes IS NOT NULL THEN
        FOR i IN 1 .. p_clientes.COUNT LOOP
            BEGIN
                SELECT c.pasaporte,
                       c.fec_ven_pas,
                       p.pertenece_ue
                  INTO v_pasaporte,
                       v_fec_ven,
                       v_pertenece_ue
                  FROM paises p, clientes c
                 WHERE c.id_lego = p_clientes(i) AND p.id_pais = c.id_pais_nacio;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(
                        -20024,
                        'Cliente con id = ' || p_clientes(i) || ' no existe.'
                    );
            END;

            IF NOT v_pertenece_ue THEN
                IF v_pasaporte IS NULL  THEN
                    RAISE_APPLICATION_ERROR(
                        -20025,
                        'Cliente con id =' || p_clientes(i) ||
                        '  no tiene pasaporte registrado.'
                    );
                ELSIF  v_fec_ven IS NULL THEN
                    RAISE_APPLICATION_ERROR(
                        -20026,
                        'Cliente con id =' || p_clientes(i) ||
                        ' no tiene fecha de vencimiento del pasaporte registrada.'
                    );
                ELSIF TRUNC(v_fec_ven) < TRUNC(SYSDATE) THEN
                    RAISE_APPLICATION_ERROR(
                        -20027,
                        'El pasaporte del cliente con id=' || p_clientes(i) ||
                        ' está vencido.'
                    );
                END IF;
            END IF;

            v_id_ins := v_id_ins + 1;

            INSERT INTO inscritos (
                id_tour,
                nro_reci,
                id_ins,
                id_clien,
                id_fan_men
            ) VALUES (
                p_fec_tour,
                v_nro_reci,
                v_id_ins,
                p_clientes(i),
                NULL
            );
        END LOOP;
    END IF;

    IF p_fans IS NOT NULL THEN
        FOR j IN 1 .. p_fans.COUNT LOOP
            BEGIN
                SELECT f.id_representante,
                       edad(f.fec_naci),
                       f.fec_ven_pas,
                       p.pertenece_ue
                  INTO v_id_rep,
                       v_edad_fan,
                       v_fec_ven,
                       v_pertenece_ue
                  FROM paises p, fans_menores f
                 WHERE f.id_fan = p_fans(j) AND p.id_pais = f.id_pais_nacio;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(
                        -20028,
                        'Fan menor con id =' || p_fans(j) || ' no existe.'
                    );
            END;
            
            IF NOT v_pertenece_ue AND TRUNC(v_fec_ven) < TRUNC(SYSDATE) THEN
                    RAISE_APPLICATION_ERROR(
                        -20029,
                        'El pasaporte del fan con id =' || p_fans(j) ||
                        ' está vencido.'
                    );
            END IF;

            IF v_edad_fan < 18 THEN
                v_rep_en_lista := FALSE;

                IF p_clientes IS NOT NULL THEN
                    FOR k IN 1 .. p_clientes.COUNT LOOP
                        IF p_clientes(k) = v_id_rep THEN
                            v_rep_en_lista := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;

                IF NOT v_rep_en_lista THEN
                    RAISE_APPLICATION_ERROR(
                        -20030,
                        'El representante (id =' || v_id_rep ||
                        ') del fan id =' || p_fans(j) ||
                        ' no está incluido en la lista de visitantes de esta inscripción.'
                    );
                END IF;
            END IF;

            v_id_ins := v_id_ins + 1;

            INSERT INTO inscritos (
                id_tour,
                nro_reci,
                id_ins,
                id_clien,
                id_fan_men
            ) VALUES (
                p_fec_tour,
                v_nro_reci,
                v_id_ins,
                NULL,
                p_fans(j)
            );
        END LOOP;
    END IF;

END registrar_inscripcion_tour;
/

CREATE OR REPLACE PROCEDURE confirmar_pago (
    p_id_tour  IN recibos_inscripcion.id_tour%TYPE,
    p_nro_reci IN recibos_inscripcion.nro_reci%TYPE
) IS
    v_estatus        recibos_inscripcion.estatus%TYPE;
    v_max_nro_ent    entradas.nro_ent%TYPE;
    v_tipo_asis      entradas.tipo_asis%TYPE;
BEGIN

    BEGIN
        SELECT estatus
          INTO v_estatus
          FROM recibos_inscripcion
         WHERE id_tour = p_id_tour AND nro_reci = p_nro_reci;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20101,
                'El recibo de inscripción no existe para ese tour.'
            );
    END;

    IF v_estatus = 'pagado' THEN
        RAISE_APPLICATION_ERROR(
            -20102,
            'La inscripcion ya fue confirmada anteriormente.'
        );
    END IF;
    
    UPDATE recibos_inscripcion
       SET estatus = 'pagado', fec_emi = SYSDATE
     WHERE id_tour = p_id_tour AND nro_reci = p_nro_reci;

    SELECT NVL(MAX(nro_ent), 0)
      INTO v_max_nro_ent
      FROM entradas
     WHERE id_tour = p_id_tour;

    FOR i IN (
        SELECT id_clien, id_fan_men
          FROM inscritos
         WHERE id_tour = p_id_tour
           AND nro_reci = p_nro_reci
         ORDER BY id_ins
    ) LOOP
        v_max_nro_ent := v_max_nro_ent + 1;

        IF i.id_clien IS NOT NULL THEN
            v_tipo_asis := 'adulto';
        ELSE
            v_tipo_asis := 'menor';
        END IF;

        INSERT INTO entradas (
            id_tour,
            nro_reci,
            nro_ent,
            tipo_asis
        ) VALUES (
            p_id_tour,
            p_nro_reci,
            v_max_nro_ent,
            v_tipo_asis
        );
    END LOOP;
END confirmar_pago;
/