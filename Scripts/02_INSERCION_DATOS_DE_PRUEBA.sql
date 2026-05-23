/* ============================================================
   QUINDIOFLIX
   SCRIPT 02 - INSERCION DE DATOS DE PRUEBA ASIMETRICOS
   Oracle 19c/21c
   ============================================================ */

SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

/* ============================================================
   0. LIMPIEZA DE DATOS PREVIOS
   Se eliminan primero las tablas hijas para evitar errores de FK.
   ============================================================ */

BEGIN
    DELETE FROM REPRODUCCIONES;
    DELETE FROM SESIONES_STREAMING;
    DELETE FROM CALIFICACIONES;
    DELETE FROM FAVORITOS;
    DELETE FROM REPORTES_CONTENIDO;
    DELETE FROM BENEFICIOS_REFERIDO;
    DELETE FROM REFERIDOS;
    DELETE FROM USUARIOS_ROLES;
    DELETE FROM CAMBIOS_PLAN;
    DELETE FROM SUSCRIPCIONES;
    DELETE FROM PAGOS;

    DELETE FROM EPISODIOS;
    DELETE FROM TEMPORADAS;
    DELETE FROM RELACIONES_CONTENIDO;
    DELETE FROM CONTENIDOS_GENEROS;
    DELETE FROM CONTENIDOS;
    DELETE FROM TIPOS_RELACION_CONTENIDO;
    DELETE FROM GENEROS;
    DELETE FROM CATEGORIAS_CONTENIDO;

    UPDATE DEPARTAMENTOS
    SET ID_EMPLEADO_JEFE = NULL;

    UPDATE EMPLEADOS
    SET ID_SUPERVISOR = NULL;

    DELETE FROM EMPLEADOS;
    DELETE FROM DEPARTAMENTOS;

    DELETE FROM PERFILES;
    DELETE FROM USUARIOS;
    DELETE FROM PLANES_SUSCRIPCION;
    DELETE FROM CIUDADES;
    DELETE FROM ROLES_USUARIO;

    COMMIT;
END;
/

/* ============================================================
   1. DATOS BASE: CIUDADES, PLANES Y ROLES
   ============================================================ */

INSERT INTO CIUDADES (ID_CIUDAD, NOMBRE_CIUDAD, DEPARTAMENTO, PAIS, ESTADO)
VALUES (1, 'Armenia', 'Quindio', 'Colombia', 'ACTIVO');

INSERT INTO CIUDADES (ID_CIUDAD, NOMBRE_CIUDAD, DEPARTAMENTO, PAIS, ESTADO)
VALUES (2, 'Pereira', 'Risaralda', 'Colombia', 'ACTIVO');

INSERT INTO CIUDADES (ID_CIUDAD, NOMBRE_CIUDAD, DEPARTAMENTO, PAIS, ESTADO)
VALUES (3, 'Manizales', 'Caldas', 'Colombia', 'ACTIVO');

INSERT INTO CIUDADES (ID_CIUDAD, NOMBRE_CIUDAD, DEPARTAMENTO, PAIS, ESTADO)
VALUES (4, 'Bogota', 'Cundinamarca', 'Colombia', 'ACTIVO');

INSERT INTO CIUDADES (ID_CIUDAD, NOMBRE_CIUDAD, DEPARTAMENTO, PAIS, ESTADO)
VALUES (5, 'Medellin', 'Antioquia', 'Colombia', 'ACTIVO');


INSERT INTO PLANES_SUSCRIPCION
(ID_PLAN, NOMBRE_PLAN, PANTALLAS_SIMULTANEAS, MAX_PERFILES, CALIDAD_VIDEO, PRECIO_MENSUAL, ESTADO)
VALUES (1, 'BASICO', 1, 2, 'SD', 14900, 'ACTIVO');

INSERT INTO PLANES_SUSCRIPCION
(ID_PLAN, NOMBRE_PLAN, PANTALLAS_SIMULTANEAS, MAX_PERFILES, CALIDAD_VIDEO, PRECIO_MENSUAL, ESTADO)
VALUES (2, 'ESTANDAR', 2, 3, 'HD', 24900, 'ACTIVO');

INSERT INTO PLANES_SUSCRIPCION
(ID_PLAN, NOMBRE_PLAN, PANTALLAS_SIMULTANEAS, MAX_PERFILES, CALIDAD_VIDEO, PRECIO_MENSUAL, ESTADO)
VALUES (3, 'PREMIUM', 4, 5, '4K', 34900, 'ACTIVO');


INSERT INTO ROLES_USUARIO (ID_ROL_USUARIO, NOMBRE_ROL, DESCRIPCION)
VALUES (1, 'CLIENTE', 'Usuario cliente de la plataforma.');

INSERT INTO ROLES_USUARIO (ID_ROL_USUARIO, NOMBRE_ROL, DESCRIPCION)
VALUES (2, 'MODERADOR', 'Usuario con permisos para revisar reportes de contenido.');

INSERT INTO ROLES_USUARIO (ID_ROL_USUARIO, NOMBRE_ROL, DESCRIPCION)
VALUES (3, 'ADMIN', 'Usuario administrador de la plataforma.');


/* ============================================================
   2. DEPARTAMENTOS Y EMPLEADOS
   ============================================================ */

INSERT INTO DEPARTAMENTOS (ID_DEPARTAMENTO, NOMBRE_DEPARTAMENTO, DESCRIPCION, ESTADO)
VALUES (1, 'TECNOLOGIA', 'Departamento encargado de infraestructura y desarrollo.', 'ACTIVO');

INSERT INTO DEPARTAMENTOS (ID_DEPARTAMENTO, NOMBRE_DEPARTAMENTO, DESCRIPCION, ESTADO)
VALUES (2, 'CONTENIDO', 'Departamento encargado del catalogo multimedia.', 'ACTIVO');

INSERT INTO DEPARTAMENTOS (ID_DEPARTAMENTO, NOMBRE_DEPARTAMENTO, DESCRIPCION, ESTADO)
VALUES (3, 'MARKETING', 'Departamento encargado de campanias y crecimiento.', 'ACTIVO');

INSERT INTO DEPARTAMENTOS (ID_DEPARTAMENTO, NOMBRE_DEPARTAMENTO, DESCRIPCION, ESTADO)
VALUES (4, 'SOPORTE', 'Departamento encargado de atencion y reportes.', 'ACTIVO');

INSERT INTO DEPARTAMENTOS (ID_DEPARTAMENTO, NOMBRE_DEPARTAMENTO, DESCRIPCION, ESTADO)
VALUES (5, 'FINANZAS', 'Departamento encargado de pagos e ingresos.', 'ACTIVO');


INSERT INTO EMPLEADOS
(ID_EMPLEADO, ID_DEPARTAMENTO, ID_SUPERVISOR, NOMBRE, EMAIL, TELEFONO, CARGO, FECHA_INGRESO, ESTADO)
VALUES (1, 1, NULL, 'Carlos Rojas', 'carlos.rojas@quindioflix.com', '3001000001', 'Jefe de Tecnologia', DATE '2021-01-10', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (2, 1, 1, 'Natalia Gomez', 'natalia.gomez@quindioflix.com', '3001000002', 'Arquitecta de Datos', DATE '2022-03-14', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (3, 1, 1, 'Felipe Vargas', 'felipe.vargas@quindioflix.com', '3001000003', 'Administrador de BD', DATE '2023-02-20', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (4, 2, NULL, 'Paula Mejia', 'paula.mejia@quindioflix.com', '3001000004', 'Jefe de Contenido', DATE '2020-08-01', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (5, 2, 4, 'Juan Esteban Torres', 'juan.torres@quindioflix.com', '3001000005', 'Gestor de Catalogo', DATE '2022-05-18', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (6, 2, 4, 'Diana Salazar', 'diana.salazar@quindioflix.com', '3001000006', 'Editora de Contenido', DATE '2023-07-09', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (7, 3, NULL, 'Andres Cardenas', 'andres.cardenas@quindioflix.com', '3001000007', 'Jefe de Marketing', DATE '2021-11-11', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (8, 4, NULL, 'Marcela Ruiz', 'marcela.ruiz@quindioflix.com', '3001000008', 'Jefe de Soporte', DATE '2020-04-21', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (9, 4, 8, 'Santiago Lopez', 'santiago.lopez@quindioflix.com', '3001000009', 'Analista de Soporte', DATE '2022-10-03', 'ACTIVO');

INSERT INTO EMPLEADOS
VALUES (10, 5, NULL, 'Laura Restrepo', 'laura.restrepo@quindioflix.com', '3001000010', 'Jefe de Finanzas', DATE '2021-06-30', 'ACTIVO');


UPDATE DEPARTAMENTOS SET ID_EMPLEADO_JEFE = 1 WHERE ID_DEPARTAMENTO = 1;
UPDATE DEPARTAMENTOS SET ID_EMPLEADO_JEFE = 4 WHERE ID_DEPARTAMENTO = 2;
UPDATE DEPARTAMENTOS SET ID_EMPLEADO_JEFE = 7 WHERE ID_DEPARTAMENTO = 3;
UPDATE DEPARTAMENTOS SET ID_EMPLEADO_JEFE = 8 WHERE ID_DEPARTAMENTO = 4;
UPDATE DEPARTAMENTOS SET ID_EMPLEADO_JEFE = 10 WHERE ID_DEPARTAMENTO = 5;


/* ============================================================
   3. CATEGORIAS Y GENEROS
   ============================================================ */

INSERT INTO CATEGORIAS_CONTENIDO VALUES (1, 'PELICULA', 'Peliculas disponibles en catalogo.', 'ACTIVO');
INSERT INTO CATEGORIAS_CONTENIDO VALUES (2, 'SERIE', 'Series organizadas en temporadas y episodios.', 'ACTIVO');
INSERT INTO CATEGORIAS_CONTENIDO VALUES (3, 'DOCUMENTAL', 'Documentales disponibles en catalogo.', 'ACTIVO');
INSERT INTO CATEGORIAS_CONTENIDO VALUES (4, 'MUSICA', 'Contenido musical.', 'ACTIVO');
INSERT INTO CATEGORIAS_CONTENIDO VALUES (5, 'PODCAST', 'Podcasts organizados en temporadas y episodios.', 'ACTIVO');

INSERT INTO GENEROS VALUES (1, 'ACCION', 'Contenido de accion.', 'ACTIVO');
INSERT INTO GENEROS VALUES (2, 'COMEDIA', 'Contenido de comedia.', 'ACTIVO');
INSERT INTO GENEROS VALUES (3, 'DRAMA', 'Contenido dramatico.', 'ACTIVO');
INSERT INTO GENEROS VALUES (4, 'SUSPENSO', 'Contenido de suspenso.', 'ACTIVO');
INSERT INTO GENEROS VALUES (5, 'ROMANCE', 'Contenido romantico.', 'ACTIVO');
INSERT INTO GENEROS VALUES (6, 'CIENCIA FICCION', 'Contenido de ciencia ficcion.', 'ACTIVO');
INSERT INTO GENEROS VALUES (7, 'TERROR', 'Contenido de terror.', 'ACTIVO');
INSERT INTO GENEROS VALUES (8, 'INFANTIL', 'Contenido infantil.', 'ACTIVO');


/* ============================================================
   4. USUARIOS, ROLES Y SUSCRIPCIONES
   30 usuarios distribuidos por ciudades y planes.
   ============================================================ */

BEGIN
    FOR I IN 1..30 LOOP
        INSERT INTO USUARIOS (
            ID_USUARIO,
            ID_CIUDAD,
            NOMBRE,
            EMAIL,
            TELEFONO,
            FECHA_NACIMIENTO,
            FECHA_REGISTRO,
            ESTADO_CUENTA,
            FECHA_ULTIMO_PAGO
        )
        VALUES (
            I,
            CASE
                WHEN I BETWEEN 1 AND 12 THEN 1
                WHEN I BETWEEN 13 AND 21 THEN 2
                WHEN I BETWEEN 22 AND 27 THEN 3
                WHEN I BETWEEN 28 AND 29 THEN 4
                ELSE 5
            END,
            'Usuario Prueba ' || LPAD(I, 2, '0'),
            'usuario' || LPAD(I, 2, '0') || '@quindioflix.com',
            '310200' || LPAD(I, 4, '0'),
            ADD_MONTHS(DATE '1990-01-01', I * 7),
            DATE '2025-01-01' + I,
            CASE
                WHEN I IN (9, 18, 27) THEN 'INACTIVO'
                ELSE 'ACTIVO'
            END,
            DATE '2026-04-01' - MOD(I, 12)
        );

        INSERT INTO USUARIOS_ROLES
        (ID_USUARIO, ID_ROL_USUARIO, FECHA_ASIGNACION, ESTADO)
        VALUES (I, 1, DATE '2025-01-01' + I, 'ACTIVO');

        INSERT INTO SUSCRIPCIONES
        (ID_SUSCRIPCION, ID_USUARIO, ID_PLAN, FECHA_INICIO, FECHA_FIN, ESTADO_SUSCRIPCION)
        VALUES (
            I,
            I,
            CASE
                WHEN MOD(I, 3) = 1 THEN 1
                WHEN MOD(I, 3) = 2 THEN 2
                ELSE 3
            END,
            DATE '2025-01-01' + I,
            NULL,
            'ACTIVA'
        );
    END LOOP;

    INSERT INTO USUARIOS_ROLES VALUES (3, 2, DATE '2025-02-01', 'ACTIVO');
    INSERT INTO USUARIOS_ROLES VALUES (6, 2, DATE '2025-02-01', 'ACTIVO');
    INSERT INTO USUARIOS_ROLES VALUES (1, 3, DATE '2025-01-15', 'ACTIVO');
END;
/


/* ============================================================
   5. PERFILES
   50 perfiles: todos los usuarios tienen al menos uno.
   20 usuarios tienen un segundo perfil.
   ============================================================ */

BEGIN
    FOR I IN 1..30 LOOP
        INSERT INTO PERFILES
        (ID_PERFIL, ID_USUARIO, NOMBRE_PERFIL, AVATAR, TIPO_PERFIL, FECHA_CREACION, ESTADO)
        VALUES (
            I,
            I,
            'Principal ' || LPAD(I, 2, '0'),
            'avatar_principal_' || I || '.png',
            CASE WHEN MOD(I, 6) = 0 THEN 'INFANTIL' ELSE 'ADULTO' END,
            DATE '2025-01-10' + I,
            'ACTIVO'
        );
    END LOOP;

    FOR I IN 1..20 LOOP
        INSERT INTO PERFILES
        (ID_PERFIL, ID_USUARIO, NOMBRE_PERFIL, AVATAR, TIPO_PERFIL, FECHA_CREACION, ESTADO)
        VALUES (
            30 + I,
            I,
            'Familiar ' || LPAD(I, 2, '0'),
            'avatar_familiar_' || I || '.png',
            CASE WHEN MOD(I, 4) = 0 THEN 'INFANTIL' ELSE 'ADULTO' END,
            DATE '2025-02-01' + I,
            'ACTIVO'
        );
    END LOOP;
END;
/


/* ============================================================
   6. CONTENIDOS
   40 contenidos distribuidos entre categorias.
   Peliculas: 1-12
   Series: 13-20
   Documentales: 21-28
   Musica: 29-34
   Podcasts: 35-40
   ============================================================ */

BEGIN
    FOR I IN 1..40 LOOP
        INSERT INTO CONTENIDOS (
            ID_CONTENIDO,
            ID_CATEGORIA,
            ID_EMPLEADO_RESPONSABLE,
            TITULO,
            ANIO_LANZAMIENTO,
            DURACION_MINUTOS,
            SINOPSIS,
            CLASIFICACION_EDAD,
            FECHA_AGREGADO_CATALOGO,
            ES_ORIGINAL,
            ESTADO_CONTENIDO,
            POPULARIDAD
        )
        VALUES (
            I,
            CASE
                WHEN I BETWEEN 1 AND 12 THEN 1
                WHEN I BETWEEN 13 AND 20 THEN 2
                WHEN I BETWEEN 21 AND 28 THEN 3
                WHEN I BETWEEN 29 AND 34 THEN 4
                ELSE 5
            END,
            CASE
                WHEN MOD(I, 3) = 0 THEN 4
                WHEN MOD(I, 3) = 1 THEN 5
                ELSE 6
            END,
            CASE
                WHEN I BETWEEN 1 AND 12 THEN 'Pelicula Quindiana ' || I
                WHEN I BETWEEN 13 AND 20 THEN 'Serie Cafetera ' || (I - 12)
                WHEN I BETWEEN 21 AND 28 THEN 'Documental Regional ' || (I - 20)
                WHEN I BETWEEN 29 AND 34 THEN 'Concierto Local ' || (I - 28)
                ELSE 'Podcast Tecnologia ' || (I - 34)
            END,
            2010 + MOD(I, 15),
            CASE
                WHEN I BETWEEN 13 AND 20 THEN NULL
                WHEN I BETWEEN 35 AND 40 THEN NULL
                ELSE 80 + MOD(I * 7, 70)
            END,
            'Contenido de prueba generado para reportes asimetricos de QuindioFlix.',
            CASE
                WHEN MOD(I, 10) IN (0, 1) THEN '+18'
                WHEN MOD(I, 10) IN (2, 3) THEN '+16'
                WHEN MOD(I, 10) IN (4, 5) THEN '+13'
                WHEN MOD(I, 10) IN (6, 7) THEN '+7'
                ELSE 'TP'
            END,
            DATE '2024-01-01' + (I * 11),
            CASE WHEN MOD(I, 4) = 0 THEN 'S' ELSE 'N' END,
            CASE WHEN MOD(I, 17) = 0 THEN 'OCULTO' ELSE 'DISPONIBLE' END,
            0
        );
    END LOOP;
END;
/


/* Generos variados para cada contenido */
BEGIN
    FOR I IN 1..40 LOOP
        INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
        VALUES (I, MOD(I - 1, 8) + 1);

        IF MOD(I, 2) = 0 THEN
            INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
            VALUES (I, MOD(I + 2, 8) + 1);
        END IF;

        IF MOD(I, 5) = 0 THEN
            INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
            VALUES (I, 8);
        END IF;
    END LOOP;
END;
/


/* Relaciones recursivas entre contenidos */
INSERT INTO TIPOS_RELACION_CONTENIDO VALUES (1, 'SECUELA', 'Contenido que continua una historia anterior.');
INSERT INTO TIPOS_RELACION_CONTENIDO VALUES (2, 'PRECUELA', 'Contenido que ocurre antes de la historia original.');
INSERT INTO TIPOS_RELACION_CONTENIDO VALUES (3, 'SPIN_OFF', 'Contenido derivado de otro contenido.');
INSERT INTO TIPOS_RELACION_CONTENIDO VALUES (4, 'REMAKE', 'Nueva version de un contenido existente.');
INSERT INTO TIPOS_RELACION_CONTENIDO VALUES (5, 'VERSION_EXTENDIDA', 'Version extendida del contenido.');

INSERT INTO RELACIONES_CONTENIDO VALUES (1, 1, 2, 1, 'Continuacion directa de la historia.', DATE '2025-01-01');
INSERT INTO RELACIONES_CONTENIDO VALUES (2, 13, 21, 3, 'Documental derivado de la serie.', DATE '2025-01-03');
INSERT INTO RELACIONES_CONTENIDO VALUES (3, 4, 5, 2, 'Historia previa al contenido principal.', DATE '2025-01-05');
INSERT INTO RELACIONES_CONTENIDO VALUES (4, 16, 35, 3, 'Podcast complementario de la serie.', DATE '2025-01-07');
INSERT INTO RELACIONES_CONTENIDO VALUES (5, 7, 8, 5, 'Version extendida de la pelicula.', DATE '2025-01-09');


/* ============================================================
   7. TEMPORADAS Y EPISODIOS
   15 temporadas y 50 episodios.
   ============================================================ */

INSERT INTO TEMPORADAS VALUES (1, 13, 1, 'Temporada 1', 'Inicio de la serie cafetera 1.', DATE '2024-01-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (2, 14, 1, 'Temporada 1', 'Inicio de la serie cafetera 2.', DATE '2024-02-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (3, 15, 1, 'Temporada 1', 'Inicio de la serie cafetera 3.', DATE '2024-03-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (4, 16, 1, 'Temporada 1', 'Inicio de la serie cafetera 4.', DATE '2024-04-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (5, 17, 1, 'Temporada 1', 'Inicio de la serie cafetera 5.', DATE '2024-05-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (6, 18, 1, 'Temporada 1', 'Inicio de la serie cafetera 6.', DATE '2024-06-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (7, 19, 1, 'Temporada 1', 'Inicio de la serie cafetera 7.', DATE '2024-07-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (8, 20, 1, 'Temporada 1', 'Inicio de la serie cafetera 8.', DATE '2024-08-10', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (9, 13, 2, 'Temporada 2', 'Continuacion de la serie cafetera 1.', DATE '2025-01-10', 'DISPONIBLE');

INSERT INTO TEMPORADAS VALUES (10, 35, 1, 'Temporada 1', 'Inicio podcast tecnologia 1.', DATE '2024-01-15', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (11, 36, 1, 'Temporada 1', 'Inicio podcast tecnologia 2.', DATE '2024-02-15', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (12, 37, 1, 'Temporada 1', 'Inicio podcast tecnologia 3.', DATE '2024-03-15', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (13, 38, 1, 'Temporada 1', 'Inicio podcast tecnologia 4.', DATE '2024-04-15', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (14, 39, 1, 'Temporada 1', 'Inicio podcast tecnologia 5.', DATE '2024-05-15', 'DISPONIBLE');
INSERT INTO TEMPORADAS VALUES (15, 40, 1, 'Temporada 1', 'Inicio podcast tecnologia 6.', DATE '2024-06-15', 'DISPONIBLE');


BEGIN
    FOR I IN 1..50 LOOP
        INSERT INTO EPISODIOS (
            ID_EPISODIO,
            ID_TEMPORADA,
            NUMERO_EPISODIO,
            TITULO_EPISODIO,
            DURACION_MINUTOS,
            SINOPSIS,
            FECHA_LANZAMIENTO,
            ESTADO
        )
        VALUES (
            I,
            MOD(I - 1, 15) + 1,
            FLOOR((I - 1) / 15) + 1,
            'Episodio ' || I,
            25 + MOD(I * 4, 35),
            'Episodio de prueba para temporadas de series y podcasts.',
            DATE '2024-01-01' + (I * 5),
            'DISPONIBLE'
        );
    END LOOP;
END;
/


/* ============================================================
   8. REFERIDOS Y BENEFICIOS
   ============================================================ */

BEGIN
    FOR I IN 1..8 LOOP
        INSERT INTO REFERIDOS (
            ID_REFERIDO,
            ID_USUARIO_REFERIDOR,
            ID_USUARIO_REFERIDO,
            FECHA_REFERIDO,
            ESTADO_REFERIDO
        )
        VALUES (
            I,
            I,
            I + 20,
            DATE '2025-03-01' + I,
            CASE WHEN MOD(I, 3) = 0 THEN 'APLICADO' ELSE 'ACTIVO' END
        );

        INSERT INTO BENEFICIOS_REFERIDO (
            ID_BENEFICIO,
            ID_REFERIDO,
            ID_USUARIO_BENEFICIARIO,
            TIPO_BENEFICIO,
            VALOR_DESCUENTO,
            ESTADO_BENEFICIO,
            FECHA_GENERACION,
            FECHA_APLICACION,
            ID_PAGO_APLICADO
        )
        VALUES (
            (I * 2) - 1,
            I,
            I,
            'DESCUENTO',
            5000,
            CASE WHEN MOD(I, 3) = 0 THEN 'APLICADO' ELSE 'PENDIENTE' END,
            DATE '2025-03-05' + I,
            CASE WHEN MOD(I, 3) = 0 THEN DATE '2025-04-05' + I ELSE NULL END,
            NULL
        );

        INSERT INTO BENEFICIOS_REFERIDO (
            ID_BENEFICIO,
            ID_REFERIDO,
            ID_USUARIO_BENEFICIARIO,
            TIPO_BENEFICIO,
            VALOR_DESCUENTO,
            ESTADO_BENEFICIO,
            FECHA_GENERACION,
            FECHA_APLICACION,
            ID_PAGO_APLICADO
        )
        VALUES (
            I * 2,
            I,
            I + 20,
            'DESCUENTO',
            5000,
            CASE WHEN MOD(I, 3) = 0 THEN 'APLICADO' ELSE 'PENDIENTE' END,
            DATE '2025-03-05' + I,
            CASE WHEN MOD(I, 3) = 0 THEN DATE '2025-04-05' + I ELSE NULL END,
            NULL
        );
    END LOOP;
END;
/


/* ============================================================
   9. PAGOS
   80 pagos con estados variados.
   ============================================================ */

DECLARE
    V_USUARIO NUMBER;
    V_PLAN NUMBER;
    V_MONTO NUMBER(10,2);
    V_DESC NUMBER(10,2);
BEGIN
    FOR I IN 1..80 LOOP
        V_USUARIO := MOD(I - 1, 30) + 1;

        V_PLAN := CASE
            WHEN MOD(V_USUARIO, 3) = 1 THEN 1
            WHEN MOD(V_USUARIO, 3) = 2 THEN 2
            ELSE 3
        END;

        V_MONTO := CASE V_PLAN
            WHEN 1 THEN 14900
            WHEN 2 THEN 24900
            ELSE 34900
        END;

        V_DESC := CASE
            WHEN MOD(I, 13) = 0 THEN 5000
            WHEN MOD(I, 17) = 0 THEN 3000
            ELSE 0
        END;

        INSERT INTO PAGOS (
            ID_PAGO,
            ID_USUARIO,
            ID_PLAN,
            FECHA_PAGO,
            FECHA_VENCIMIENTO,
            MONTO_BRUTO,
            DESCUENTO_APLICADO,
            MONTO_PAGADO,
            METODO_PAGO,
            ESTADO_PAGO,
            REFERENCIA_PAGO
        )
        VALUES (
            I,
            V_USUARIO,
            V_PLAN,
            TIMESTAMP '2025-01-01 09:00:00' + NUMTODSINTERVAL(I * 11, 'DAY'),
            DATE '2025-01-30' + (I * 11),
            V_MONTO,
            V_DESC,
            V_MONTO - V_DESC,
            CASE MOD(I, 5)
                WHEN 0 THEN 'TARJETA_CREDITO'
                WHEN 1 THEN 'TARJETA_DEBITO'
                WHEN 2 THEN 'PSE'
                WHEN 3 THEN 'NEQUI'
                ELSE 'DAVIPLATA'
            END,
            CASE
                WHEN MOD(I, 11) = 0 THEN 'FALLIDO'
                WHEN MOD(I, 19) = 0 THEN 'PENDIENTE'
                WHEN MOD(I, 29) = 0 THEN 'REEMBOLSADO'
                ELSE 'EXITOSO'
            END,
            'QF-PAGO-' || LPAD(I, 5, '0')
        );
    END LOOP;
END;
/


/* ============================================================
   10. SESIONES DE STREAMING
   60 sesiones para soportar control futuro de pantallas.
   ============================================================ */

BEGIN
    FOR I IN 1..60 LOOP
        INSERT INTO SESIONES_STREAMING (
            ID_SESION,
            ID_PERFIL,
            FECHA_INICIO,
            FECHA_ULTIMA_ACTIVIDAD,
            FECHA_CIERRE,
            DISPOSITIVO,
            ESTADO_SESION
        )
        VALUES (
            I,
            MOD(I - 1, 50) + 1,
            TIMESTAMP '2026-01-01 08:00:00' + NUMTODSINTERVAL(I * 9, 'HOUR'),
            TIMESTAMP '2026-01-01 08:30:00' + NUMTODSINTERVAL(I * 9, 'HOUR'),
            CASE
                WHEN MOD(I, 7) = 0 THEN NULL
                ELSE TIMESTAMP '2026-01-01 10:00:00' + NUMTODSINTERVAL(I * 9, 'HOUR')
            END,
            CASE MOD(I, 4)
                WHEN 0 THEN 'CELULAR'
                WHEN 1 THEN 'TABLET'
                WHEN 2 THEN 'TV'
                ELSE 'COMPUTADOR'
            END,
            CASE
                WHEN MOD(I, 7) = 0 THEN 'ACTIVA'
                WHEN MOD(I, 9) = 0 THEN 'EXPIRADA'
                ELSE 'CERRADA'
            END
        );
    END LOOP;
END;
/


/* ============================================================
   11. FAVORITOS
   40 favoritos variados.
   ============================================================ */

BEGIN
    FOR I IN 1..40 LOOP
        INSERT INTO FAVORITOS (
            ID_PERFIL,
            ID_CONTENIDO,
            FECHA_AGREGADO
        )
        VALUES (
            MOD(I - 1, 50) + 1,
            I,
            DATE '2025-05-01' + MOD(I * 3, 80)
        );
    END LOOP;
END;
/


/* ============================================================
   12. CALIFICACIONES
   60 calificaciones variadas entre 1 y 5 estrellas.
   ============================================================ */

BEGIN
    FOR I IN 1..60 LOOP
        INSERT INTO CALIFICACIONES (
            ID_CALIFICACION,
            ID_PERFIL,
            ID_CONTENIDO,
            ESTRELLAS,
            RESENA,
            FECHA_CALIFICACION
        )
        VALUES (
            I,
            MOD(I - 1, 50) + 1,
            MOD(I * 7, 40) + 1,
            MOD(I, 5) + 1,
            CASE
                WHEN MOD(I, 4) = 0 THEN 'Buen contenido, recomendado para ver en familia.'
                WHEN MOD(I, 4) = 1 THEN 'Interesante, aunque podria mejorar el ritmo.'
                WHEN MOD(I, 4) = 2 THEN 'Excelente produccion y buena calidad.'
                ELSE NULL
            END,
            DATE '2025-06-01' + MOD(I * 2, 100)
        );
    END LOOP;
END;
/


/* ============================================================
   13. REPORTES DE CONTENIDO
   Reportes variados para medir moderadores y soporte.
   ============================================================ */

BEGIN
    FOR I IN 1..15 LOOP
        INSERT INTO REPORTES_CONTENIDO (
            ID_REPORTE,
            ID_PERFIL_REPORTA,
            ID_CONTENIDO,
            ID_USUARIO_MODERADOR,
            ID_EMPLEADO_SOPORTE,
            MOTIVO,
            DESCRIPCION,
            ESTADO_REPORTE,
            FECHA_REPORTE,
            FECHA_RESOLUCION,
            RESPUESTA_MODERADOR
        )
        VALUES (
            I,
            MOD(I - 1, 50) + 1,
            MOD(I * 5, 40) + 1,
            CASE WHEN MOD(I, 2) = 0 THEN 3 ELSE 6 END,
            CASE WHEN MOD(I, 3) = 0 THEN 9 ELSE 8 END,
            CASE MOD(I, 4)
                WHEN 0 THEN 'Clasificacion incorrecta'
                WHEN 1 THEN 'Contenido sensible'
                WHEN 2 THEN 'Descripcion inadecuada'
                ELSE 'Posible contenido duplicado'
            END,
            'Reporte de prueba para validar flujo de moderacion.',
            CASE
                WHEN MOD(I, 5) = 0 THEN 'PENDIENTE'
                WHEN MOD(I, 5) = 1 THEN 'EN_REVISION'
                WHEN MOD(I, 5) = 2 THEN 'RESUELTO'
                ELSE 'RECHAZADO'
            END,
            TIMESTAMP '2025-07-01 10:00:00' + NUMTODSINTERVAL(I * 17, 'HOUR'),
            CASE
                WHEN MOD(I, 5) IN (2, 3, 4)
                THEN TIMESTAMP '2025-07-03 12:00:00' + NUMTODSINTERVAL(I * 17, 'HOUR')
                ELSE NULL
            END,
            CASE
                WHEN MOD(I, 5) IN (2, 3, 4)
                THEN 'Reporte revisado por moderacion.'
                ELSE NULL
            END
        );
    END LOOP;
END;
/


/* ============================================================
   14. REPRODUCCIONES
   200 reproducciones asimetricas por perfil, contenido,
   dispositivo, fecha y avance.
   Para series/podcasts se asigna episodio.
   Para peliculas/documentales/musica ID_EPISODIO queda NULL.
   ============================================================ */

DECLARE
    V_CONTENIDO NUMBER;
    V_CATEGORIA NUMBER;
    V_EPISODIO NUMBER;
BEGIN
    FOR I IN 1..200 LOOP
        V_CONTENIDO := MOD(I * 7, 40) + 1;

        SELECT ID_CATEGORIA
        INTO V_CATEGORIA
        FROM CONTENIDOS
        WHERE ID_CONTENIDO = V_CONTENIDO;

        IF V_CATEGORIA IN (2, 5) THEN
            SELECT MIN(E.ID_EPISODIO)
            INTO V_EPISODIO
            FROM EPISODIOS E
            JOIN TEMPORADAS T
              ON T.ID_TEMPORADA = E.ID_TEMPORADA
            WHERE T.ID_CONTENIDO = V_CONTENIDO;
        ELSE
            V_EPISODIO := NULL;
        END IF;

        INSERT INTO REPRODUCCIONES (
            ID_REPRODUCCION,
            ID_PERFIL,
            ID_CONTENIDO,
            ID_EPISODIO,
            ID_SESION,
            FECHA_HORA_INICIO,
            FECHA_HORA_FIN,
            DISPOSITIVO,
            PORCENTAJE_AVANCE
        )
        VALUES (
            I,
            MOD(I - 1, 50) + 1,
            V_CONTENIDO,
            V_EPISODIO,
            MOD(I - 1, 60) + 1,
            TIMESTAMP '2024-01-01 06:00:00' + NUMTODSINTERVAL(I * 87, 'HOUR'),
            CASE
                WHEN MOD(I, 12) = 0 THEN NULL
                ELSE TIMESTAMP '2024-01-01 07:20:00' + NUMTODSINTERVAL(I * 87, 'HOUR')
            END,
            CASE MOD(I, 4)
                WHEN 0 THEN 'CELULAR'
                WHEN 1 THEN 'TABLET'
                WHEN 2 THEN 'TV'
                ELSE 'COMPUTADOR'
            END,
            CASE
                WHEN MOD(I, 10) = 0 THEN 100
                WHEN MOD(I, 10) IN (1, 2, 3) THEN 90
                WHEN MOD(I, 10) IN (4, 5) THEN 65
                WHEN MOD(I, 10) IN (6, 7) THEN 45
                ELSE 20
            END
        );
    END LOOP;
END;
/


/* ============================================================
   15. CAMBIOS DE PLAN
   Historial pequeño de cambios para pruebas de SP_CAMBIAR_PLAN.
   ============================================================ */

INSERT INTO CAMBIOS_PLAN VALUES (1, 5, 1, 2, TIMESTAMP '2025-08-01 09:00:00', 'Usuario aumento plan por mas pantallas.');
INSERT INTO CAMBIOS_PLAN VALUES (2, 8, 2, 3, TIMESTAMP '2025-08-05 10:00:00', 'Usuario cambio a plan premium.');
INSERT INTO CAMBIOS_PLAN VALUES (3, 14, 1, 3, TIMESTAMP '2025-08-11 11:00:00', 'Promocion especial aplicada.');
INSERT INTO CAMBIOS_PLAN VALUES (4, 22, 3, 2, TIMESTAMP '2025-09-01 15:00:00', 'Usuario redujo plan.');
INSERT INTO CAMBIOS_PLAN VALUES (5, 29, 2, 1, TIMESTAMP '2025-09-12 16:00:00', 'Ajuste por menor consumo.');


/* ============================================================
   16. ACTUALIZAR POPULARIDAD
   Popularidad = reproducciones completas con avance >= 90.
   ============================================================ */

UPDATE CONTENIDOS C
SET POPULARIDAD = (
    SELECT COUNT(*)
    FROM REPRODUCCIONES R
    WHERE R.ID_CONTENIDO = C.ID_CONTENIDO
      AND R.PORCENTAJE_AVANCE >= 90
);

COMMIT;


/* ============================================================
   17. CONSULTAS DE VERIFICACION
   ============================================================ */

PROMPT ===== VERIFICACION DE CONTEOS QUINDIOFLIX =====

SELECT 'PLANES_SUSCRIPCION' AS TABLA, COUNT(*) AS TOTAL FROM PLANES_SUSCRIPCION
UNION ALL SELECT 'USUARIOS', COUNT(*) FROM USUARIOS
UNION ALL SELECT 'PERFILES', COUNT(*) FROM PERFILES
UNION ALL SELECT 'CATEGORIAS_CONTENIDO', COUNT(*) FROM CATEGORIAS_CONTENIDO
UNION ALL SELECT 'GENEROS', COUNT(*) FROM GENEROS
UNION ALL SELECT 'CONTENIDOS', COUNT(*) FROM CONTENIDOS
UNION ALL SELECT 'TEMPORADAS', COUNT(*) FROM TEMPORADAS
UNION ALL SELECT 'EPISODIOS', COUNT(*) FROM EPISODIOS
UNION ALL SELECT 'REPRODUCCIONES', COUNT(*) FROM REPRODUCCIONES
UNION ALL SELECT 'CALIFICACIONES', COUNT(*) FROM CALIFICACIONES
UNION ALL SELECT 'PAGOS', COUNT(*) FROM PAGOS
UNION ALL SELECT 'FAVORITOS', COUNT(*) FROM FAVORITOS
UNION ALL SELECT 'SESIONES_STREAMING', COUNT(*) FROM SESIONES_STREAMING
ORDER BY TABLA;







/* ============================================================
   CORRECCION DE CONTENIDOS_GENEROS
   Elimina asociaciones anteriores y las recrea sin duplicados
   ============================================================ */

DELETE FROM CONTENIDOS_GENEROS;

COMMIT;

DECLARE
    V_GENERO_1 NUMBER;
    V_GENERO_2 NUMBER;
    V_GENERO_3 NUMBER;
BEGIN
    FOR I IN 1..40 LOOP

        V_GENERO_1 := MOD(I - 1, 8) + 1;
        V_GENERO_2 := MOD(I + 2, 8) + 1;
        V_GENERO_3 := 8;

        /* Genero principal */
        INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
        VALUES (I, V_GENERO_1);

        /* Segundo genero para contenidos pares, evitando duplicado */
        IF MOD(I, 2) = 0 AND V_GENERO_2 <> V_GENERO_1 THEN
            INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
            VALUES (I, V_GENERO_2);
        END IF;

        /* Genero infantil para algunos contenidos, evitando duplicado */
        IF MOD(I, 5) = 0
           AND V_GENERO_3 <> V_GENERO_1
           AND V_GENERO_3 <> V_GENERO_2 THEN

            INSERT INTO CONTENIDOS_GENEROS (ID_CONTENIDO, ID_GENERO)
            VALUES (I, V_GENERO_3);

        END IF;

    END LOOP;

    COMMIT;
END;
/




/* ============================================================
   VERIFICACION DE CONTEOS
   ============================================================ */

SELECT 'PLANES_SUSCRIPCION' AS NOMBRE_TABLA, COUNT(*) AS TOTAL FROM PLANES_SUSCRIPCION
UNION ALL SELECT 'USUARIOS', COUNT(*) FROM USUARIOS
UNION ALL SELECT 'PERFILES', COUNT(*) FROM PERFILES
UNION ALL SELECT 'CATEGORIAS_CONTENIDO', COUNT(*) FROM CATEGORIAS_CONTENIDO
UNION ALL SELECT 'GENEROS', COUNT(*) FROM GENEROS
UNION ALL SELECT 'CONTENIDOS', COUNT(*) FROM CONTENIDOS
UNION ALL SELECT 'CONTENIDOS_GENEROS', COUNT(*) FROM CONTENIDOS_GENEROS
UNION ALL SELECT 'TEMPORADAS', COUNT(*) FROM TEMPORADAS
UNION ALL SELECT 'EPISODIOS', COUNT(*) FROM EPISODIOS
UNION ALL SELECT 'REPRODUCCIONES', COUNT(*) FROM REPRODUCCIONES
UNION ALL SELECT 'CALIFICACIONES', COUNT(*) FROM CALIFICACIONES
UNION ALL SELECT 'PAGOS', COUNT(*) FROM PAGOS
UNION ALL SELECT 'FAVORITOS', COUNT(*) FROM FAVORITOS
UNION ALL SELECT 'SESIONES_STREAMING', COUNT(*) FROM SESIONES_STREAMING
ORDER BY 1;





SELECT 'BENEFICIOS_REFERIDO' AS NOMBRE_TABLA, COUNT(*) AS TOTAL FROM BENEFICIOS_REFERIDO
UNION ALL SELECT 'CALIFICACIONES', COUNT(*) FROM CALIFICACIONES
UNION ALL SELECT 'CAMBIOS_PLAN', COUNT(*) FROM CAMBIOS_PLAN
UNION ALL SELECT 'CATEGORIAS_CONTENIDO', COUNT(*) FROM CATEGORIAS_CONTENIDO
UNION ALL SELECT 'CIUDADES', COUNT(*) FROM CIUDADES
UNION ALL SELECT 'CONTENIDOS', COUNT(*) FROM CONTENIDOS
UNION ALL SELECT 'CONTENIDOS_GENEROS', COUNT(*) FROM CONTENIDOS_GENEROS
UNION ALL SELECT 'DEPARTAMENTOS', COUNT(*) FROM DEPARTAMENTOS
UNION ALL SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS
UNION ALL SELECT 'EPISODIOS', COUNT(*) FROM EPISODIOS
UNION ALL SELECT 'FAVORITOS', COUNT(*) FROM FAVORITOS
UNION ALL SELECT 'GENEROS', COUNT(*) FROM GENEROS
UNION ALL SELECT 'PAGOS', COUNT(*) FROM PAGOS
UNION ALL SELECT 'PERFILES', COUNT(*) FROM PERFILES
UNION ALL SELECT 'PLANES_SUSCRIPCION', COUNT(*) FROM PLANES_SUSCRIPCION
UNION ALL SELECT 'REFERIDOS', COUNT(*) FROM REFERIDOS
UNION ALL SELECT 'RELACIONES_CONTENIDO', COUNT(*) FROM RELACIONES_CONTENIDO
UNION ALL SELECT 'REPORTES_CONTENIDO', COUNT(*) FROM REPORTES_CONTENIDO
UNION ALL SELECT 'REPRODUCCIONES', COUNT(*) FROM REPRODUCCIONES
UNION ALL SELECT 'ROLES_USUARIO', COUNT(*) FROM ROLES_USUARIO
UNION ALL SELECT 'SESIONES_STREAMING', COUNT(*) FROM SESIONES_STREAMING
UNION ALL SELECT 'SUSCRIPCIONES', COUNT(*) FROM SUSCRIPCIONES
UNION ALL SELECT 'TEMPORADAS', COUNT(*) FROM TEMPORADAS
UNION ALL SELECT 'TIPOS_RELACION_CONTENIDO', COUNT(*) FROM TIPOS_RELACION_CONTENIDO
UNION ALL SELECT 'USUARIOS', COUNT(*) FROM USUARIOS
UNION ALL SELECT 'USUARIOS_ROLES', COUNT(*) FROM USUARIOS_ROLES
ORDER BY 1;








































/* ============================================================
   QUINDIOFLIX
   SCRIPT DE REFUERZO DE DATOS DE PRUEBA
   Objetivo:
   - Mantener cumplimiento del PDF.
   - Reforzar tablas con menos de 25 registros.
   - Reforzar tablas intermedias hasta mínimo 40 registros.
   Oracle 19c/21c
   ============================================================ */

SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

/* ============================================================
   1. REFORZAR CIUDADES HASTA 25 REGISTROS
   ============================================================ */

BEGIN
    FOR I IN 6..25 LOOP
        BEGIN
            INSERT INTO CIUDADES (
                ID_CIUDAD,
                NOMBRE_CIUDAD,
                DEPARTAMENTO,
                PAIS,
                ESTADO
            )
            VALUES (
                I,
                'Ciudad Prueba ' || I,
                CASE
                    WHEN MOD(I, 5) = 0 THEN 'Valle del Cauca'
                    WHEN MOD(I, 5) = 1 THEN 'Antioquia'
                    WHEN MOD(I, 5) = 2 THEN 'Cundinamarca'
                    WHEN MOD(I, 5) = 3 THEN 'Santander'
                    ELSE 'Quindio'
                END,
                'Colombia',
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   2. REFORZAR GENEROS HASTA 25 REGISTROS
   ============================================================ */

BEGIN
    FOR I IN 9..25 LOOP
        BEGIN
            INSERT INTO GENEROS (
                ID_GENERO,
                NOMBRE_GENERO,
                DESCRIPCION,
                ESTADO
            )
            VALUES (
                I,
                CASE I
                    WHEN 9 THEN 'AVENTURA'
                    WHEN 10 THEN 'FANTASIA'
                    WHEN 11 THEN 'ANIMACION'
                    WHEN 12 THEN 'BIOGRAFICO'
                    WHEN 13 THEN 'HISTORICO'
                    WHEN 14 THEN 'CRIMEN'
                    WHEN 15 THEN 'MISTERIO'
                    WHEN 16 THEN 'DEPORTIVO'
                    WHEN 17 THEN 'EDUCATIVO'
                    WHEN 18 THEN 'TECNOLOGIA'
                    WHEN 19 THEN 'CIENCIA'
                    WHEN 20 THEN 'CULTURAL'
                    WHEN 21 THEN 'REALITY'
                    WHEN 22 THEN 'FAMILIAR'
                    WHEN 23 THEN 'MUSICAL DOCUMENTAL'
                    WHEN 24 THEN 'POLITICO'
                    ELSE 'SOCIAL'
                END,
                'Genero adicional de prueba para ampliar variedad analitica.',
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   3. REFORZAR TIPOS DE RELACION DE CONTENIDO HASTA 25
   ============================================================ */

BEGIN
    FOR I IN 6..25 LOOP
        BEGIN
            INSERT INTO TIPOS_RELACION_CONTENIDO (
                ID_TIPO_RELACION,
                NOMBRE_TIPO_RELACION,
                DESCRIPCION
            )
            VALUES (
                I,
                CASE I
                    WHEN 6 THEN 'ADAPTACION'
                    WHEN 7 THEN 'REBOOT'
                    WHEN 8 THEN 'UNIVERSO_COMPARTIDO'
                    WHEN 9 THEN 'CROSSOVER'
                    WHEN 10 THEN 'ESPECIAL'
                    WHEN 11 THEN 'CAPITULO_EXTRA'
                    WHEN 12 THEN 'CONTINUACION_TEMATICA'
                    WHEN 13 THEN 'INSPIRADO_EN'
                    WHEN 14 THEN 'VERSION_CORTA'
                    WHEN 15 THEN 'VERSION_DIRECTOR'
                    WHEN 16 THEN 'RELATO_ALTERNATIVO'
                    WHEN 17 THEN 'SAGA'
                    WHEN 18 THEN 'ANTOLOGIA'
                    WHEN 19 THEN 'EDICION_ESPECIAL'
                    WHEN 20 THEN 'REINTERPRETACION'
                    WHEN 21 THEN 'EXPANSION'
                    WHEN 22 THEN 'PROLOGO'
                    WHEN 23 THEN 'EPILOGO'
                    WHEN 24 THEN 'CONTENIDO_COMPLEMENTARIO'
                    ELSE 'RELACION_TEMATICA'
                END,
                'Tipo adicional de relacion entre contenidos.'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   4. REFORZAR DEPARTAMENTOS HASTA 25
   ============================================================ */

BEGIN
    FOR I IN 6..25 LOOP
        BEGIN
            INSERT INTO DEPARTAMENTOS (
                ID_DEPARTAMENTO,
                NOMBRE_DEPARTAMENTO,
                DESCRIPCION,
                ID_EMPLEADO_JEFE,
                ESTADO
            )
            VALUES (
                I,
                'AREA_PRUEBA_' || I,
                'Area adicional usada para poblar el modelo organizacional.',
                NULL,
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   5. REFORZAR EMPLEADOS HASTA 30
   ============================================================ */

BEGIN
    FOR I IN 11..30 LOOP
        BEGIN
            INSERT INTO EMPLEADOS (
                ID_EMPLEADO,
                ID_DEPARTAMENTO,
                ID_SUPERVISOR,
                NOMBRE,
                EMAIL,
                TELEFONO,
                CARGO,
                FECHA_INGRESO,
                ESTADO
            )
            VALUES (
                I,
                CASE
                    WHEN I BETWEEN 11 AND 30 THEN I - 5
                    ELSE 1
                END,
                CASE
                    WHEN MOD(I, 3) = 0 THEN 1
                    WHEN MOD(I, 3) = 1 THEN 4
                    ELSE 8
                END,
                'Empleado Prueba ' || I,
                'empleado.prueba' || I || '@quindioflix.com',
                '300900' || LPAD(I, 4, '0'),
                CASE
                    WHEN MOD(I, 4) = 0 THEN 'Analista'
                    WHEN MOD(I, 4) = 1 THEN 'Coordinador'
                    WHEN MOD(I, 4) = 2 THEN 'Auxiliar'
                    ELSE 'Especialista'
                END,
                DATE '2024-01-01' + I,
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* Asignar jefe a los departamentos adicionales */
BEGIN
    FOR I IN 6..25 LOOP
        UPDATE DEPARTAMENTOS
        SET ID_EMPLEADO_JEFE = I + 5
        WHERE ID_DEPARTAMENTO = I
          AND ID_EMPLEADO_JEFE IS NULL;
    END LOOP;
END;
/

/* ============================================================
   6. REFORZAR ROLES_USUARIO HASTA 25
   Son roles funcionales de aplicacion, no roles Oracle.
   ============================================================ */

BEGIN
    FOR I IN 4..25 LOOP
        BEGIN
            INSERT INTO ROLES_USUARIO (
                ID_ROL_USUARIO,
                NOMBRE_ROL,
                DESCRIPCION
            )
            VALUES (
                I,
                CASE I
                    WHEN 4 THEN 'ANALISTA'
                    WHEN 5 THEN 'SOPORTE'
                    WHEN 6 THEN 'CONTENIDO'
                    WHEN 7 THEN 'GESTOR_CATALOGO'
                    WHEN 8 THEN 'SUPERVISOR_SOPORTE'
                    WHEN 9 THEN 'AUDITOR'
                    WHEN 10 THEN 'FINANZAS'
                    WHEN 11 THEN 'MARKETING'
                    WHEN 12 THEN 'OPERADOR'
                    WHEN 13 THEN 'LECTOR_REPORTES'
                    WHEN 14 THEN 'EDITOR_CONTENIDO'
                    WHEN 15 THEN 'REVISOR_CALIDAD'
                    WHEN 16 THEN 'COORDINADOR_CONTENIDO'
                    WHEN 17 THEN 'COORDINADOR_TECNICO'
                    WHEN 18 THEN 'GESTOR_PAGOS'
                    WHEN 19 THEN 'GESTOR_USUARIOS'
                    WHEN 20 THEN 'MONITOR_CONSUMO'
                    WHEN 21 THEN 'SUPERVISOR_CATALOGO'
                    WHEN 22 THEN 'CONSULTOR'
                    WHEN 23 THEN 'OPERADOR_TECNICO'
                    WHEN 24 THEN 'GESTOR_REPORTES'
                    ELSE 'INVITADO_CONTROLADO'
                END,
                'Rol funcional adicional para poblar pruebas del sistema.'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   7. AGREGAR 20 USUARIOS ADICIONALES
   Esto permite reforzar referidos y relaciones usuario-rol.
   Usuarios 31 a 50.
   ============================================================ */

BEGIN
    FOR I IN 31..50 LOOP
        BEGIN
            INSERT INTO USUARIOS (
                ID_USUARIO,
                ID_CIUDAD,
                NOMBRE,
                EMAIL,
                TELEFONO,
                FECHA_NACIMIENTO,
                FECHA_REGISTRO,
                ESTADO_CUENTA,
                FECHA_ULTIMO_PAGO
            )
            VALUES (
                I,
                MOD(I - 1, 25) + 1,
                'Usuario Refuerzo ' || I,
                'usuario.refuerzo' || I || '@quindioflix.com',
                '311500' || LPAD(I, 4, '0'),
                ADD_MONTHS(DATE '1988-01-01', I * 5),
                DATE '2025-04-01' + I,
                CASE
                    WHEN MOD(I, 9) = 0 THEN 'INACTIVO'
                    ELSE 'ACTIVO'
                END,
                DATE '2026-04-01' - MOD(I, 10)
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   8. SUSCRIPCIONES PARA LOS USUARIOS NUEVOS
   ============================================================ */

BEGIN
    FOR I IN 31..50 LOOP
        BEGIN
            INSERT INTO SUSCRIPCIONES (
                ID_SUSCRIPCION,
                ID_USUARIO,
                ID_PLAN,
                FECHA_INICIO,
                FECHA_FIN,
                ESTADO_SUSCRIPCION
            )
            VALUES (
                I,
                I,
                CASE
                    WHEN MOD(I, 3) = 1 THEN 1
                    WHEN MOD(I, 3) = 2 THEN 2
                    ELSE 3
                END,
                DATE '2025-04-01' + I,
                NULL,
                'ACTIVA'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   9. PERFILES PARA LOS USUARIOS NUEVOS
   Perfiles 51 a 70.
   ============================================================ */

BEGIN
    FOR I IN 31..50 LOOP
        BEGIN
            INSERT INTO PERFILES (
                ID_PERFIL,
                ID_USUARIO,
                NOMBRE_PERFIL,
                AVATAR,
                TIPO_PERFIL,
                FECHA_CREACION,
                ESTADO
            )
            VALUES (
                I + 20,
                I,
                'Perfil Refuerzo ' || I,
                'avatar_refuerzo_' || I || '.png',
                CASE
                    WHEN MOD(I, 5) = 0 THEN 'INFANTIL'
                    ELSE 'ADULTO'
                END,
                DATE '2025-05-01' + I,
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   10. REFORZAR USUARIOS_ROLES
   Tabla intermedia: debe superar 40 registros.
   ============================================================ */

BEGIN
    FOR I IN 31..50 LOOP
        BEGIN
            INSERT INTO USUARIOS_ROLES (
                ID_USUARIO,
                ID_ROL_USUARIO,
                FECHA_ASIGNACION,
                ESTADO
            )
            VALUES (
                I,
                1,
                DATE '2025-06-01',
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;

    FOR I IN 31..40 LOOP
        BEGIN
            INSERT INTO USUARIOS_ROLES (
                ID_USUARIO,
                ID_ROL_USUARIO,
                FECHA_ASIGNACION,
                ESTADO
            )
            VALUES (
                I,
                MOD(I, 22) + 4,
                DATE '2025-06-10',
                'ACTIVO'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   11. REFORZAR TEMPORADAS HASTA 25
   Solo se agregan a contenidos SERIE o PODCAST.
   ============================================================ */

BEGIN
    FOR I IN 16..25 LOOP
        BEGIN
            INSERT INTO TEMPORADAS (
                ID_TEMPORADA,
                ID_CONTENIDO,
                NUMERO_TEMPORADA,
                TITULO_TEMPORADA,
                SINOPSIS,
                FECHA_LANZAMIENTO,
                ESTADO
            )
            VALUES (
                I,
                CASE I
                    WHEN 16 THEN 14
                    WHEN 17 THEN 15
                    WHEN 18 THEN 16
                    WHEN 19 THEN 17
                    WHEN 20 THEN 18
                    WHEN 21 THEN 19
                    WHEN 22 THEN 20
                    WHEN 23 THEN 35
                    WHEN 24 THEN 36
                    ELSE 37
                END,
                2,
                'Temporada Refuerzo ' || I,
                'Temporada adicional para completar datos de prueba.',
                DATE '2025-01-01' + I,
                'DISPONIBLE'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   12. REFORZAR REFERIDOS HASTA 40
   Tabla recursiva de usuarios.
   Se agregan usuarios nuevos como referidos.
   ============================================================ */

BEGIN
    /* Referidos 9 a 28: usuarios 31 a 50 como referidos */
    FOR I IN 9..28 LOOP
        BEGIN
            INSERT INTO REFERIDOS (
                ID_REFERIDO,
                ID_USUARIO_REFERIDOR,
                ID_USUARIO_REFERIDO,
                FECHA_REFERIDO,
                ESTADO_REFERIDO
            )
            VALUES (
                I,
                I - 8,
                I + 22,
                DATE '2025-07-01' + I,
                CASE
                    WHEN MOD(I, 4) = 0 THEN 'APLICADO'
                    ELSE 'ACTIVO'
                END
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;

    /* Referidos 29 a 40: usuarios 9 a 20 como referidos */
    FOR I IN 29..40 LOOP
        BEGIN
            INSERT INTO REFERIDOS (
                ID_REFERIDO,
                ID_USUARIO_REFERIDOR,
                ID_USUARIO_REFERIDO,
                FECHA_REFERIDO,
                ESTADO_REFERIDO
            )
            VALUES (
                I,
                I + 1,
                I - 20,
                DATE '2025-08-01' + I,
                CASE
                    WHEN MOD(I, 5) = 0 THEN 'APLICADO'
                    ELSE 'ACTIVO'
                END
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   13. REFORZAR BENEFICIOS_REFERIDO
   Dos beneficios por referido: referidor y referido.
   ============================================================ */

BEGIN
    FOR I IN 1..40 LOOP
        BEGIN
            INSERT INTO BENEFICIOS_REFERIDO (
                ID_BENEFICIO,
                ID_REFERIDO,
                ID_USUARIO_BENEFICIARIO,
                TIPO_BENEFICIO,
                VALOR_DESCUENTO,
                ESTADO_BENEFICIO,
                FECHA_GENERACION,
                FECHA_APLICACION,
                ID_PAGO_APLICADO
            )
            SELECT
                (I * 2) - 1,
                R.ID_REFERIDO,
                R.ID_USUARIO_REFERIDOR,
                'DESCUENTO',
                5000,
                CASE
                    WHEN R.ESTADO_REFERIDO = 'APLICADO' THEN 'APLICADO'
                    ELSE 'PENDIENTE'
                END,
                R.FECHA_REFERIDO + 1,
                CASE
                    WHEN R.ESTADO_REFERIDO = 'APLICADO' THEN R.FECHA_REFERIDO + 30
                    ELSE NULL
                END,
                NULL
            FROM REFERIDOS R
            WHERE R.ID_REFERIDO = I;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;

        BEGIN
            INSERT INTO BENEFICIOS_REFERIDO (
                ID_BENEFICIO,
                ID_REFERIDO,
                ID_USUARIO_BENEFICIARIO,
                TIPO_BENEFICIO,
                VALOR_DESCUENTO,
                ESTADO_BENEFICIO,
                FECHA_GENERACION,
                FECHA_APLICACION,
                ID_PAGO_APLICADO
            )
            SELECT
                I * 2,
                R.ID_REFERIDO,
                R.ID_USUARIO_REFERIDO,
                'DESCUENTO',
                5000,
                CASE
                    WHEN R.ESTADO_REFERIDO = 'APLICADO' THEN 'APLICADO'
                    ELSE 'PENDIENTE'
                END,
                R.FECHA_REFERIDO + 1,
                CASE
                    WHEN R.ESTADO_REFERIDO = 'APLICADO' THEN R.FECHA_REFERIDO + 30
                    ELSE NULL
                END,
                NULL
            FROM REFERIDOS R
            WHERE R.ID_REFERIDO = I;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   14. REFORZAR CAMBIOS_PLAN HASTA 25
   ============================================================ */

BEGIN
    FOR I IN 6..25 LOOP
        BEGIN
            INSERT INTO CAMBIOS_PLAN (
                ID_CAMBIO_PLAN,
                ID_USUARIO,
                ID_PLAN_ANTERIOR,
                ID_PLAN_NUEVO,
                FECHA_CAMBIO,
                MOTIVO
            )
            VALUES (
                I,
                MOD(I - 1, 50) + 1,
                MOD(I, 3) + 1,
                MOD(I + 1, 3) + 1,
                TIMESTAMP '2025-09-01 08:00:00' + NUMTODSINTERVAL(I, 'DAY'),
                'Cambio de plan de prueba para trazabilidad historica.'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   15. REFORZAR REPORTES_CONTENIDO HASTA 25
   ============================================================ */

BEGIN
    FOR I IN 16..25 LOOP
        BEGIN
            INSERT INTO REPORTES_CONTENIDO (
                ID_REPORTE,
                ID_PERFIL_REPORTA,
                ID_CONTENIDO,
                ID_USUARIO_MODERADOR,
                ID_EMPLEADO_SOPORTE,
                MOTIVO,
                DESCRIPCION,
                ESTADO_REPORTE,
                FECHA_REPORTE,
                FECHA_RESOLUCION,
                RESPUESTA_MODERADOR
            )
            VALUES (
                I,
                MOD(I - 1, 70) + 1,
                MOD(I * 3, 40) + 1,
                CASE
                    WHEN MOD(I, 2) = 0 THEN 3
                    ELSE 6
                END,
                CASE
                    WHEN MOD(I, 3) = 0 THEN 9
                    ELSE 8
                END,
                CASE MOD(I, 4)
                    WHEN 0 THEN 'Contenido sensible'
                    WHEN 1 THEN 'Clasificacion incorrecta'
                    WHEN 2 THEN 'Descripcion confusa'
                    ELSE 'Reporte duplicado'
                END,
                'Reporte adicional para completar minimo de registros por tabla.',
                CASE
                    WHEN MOD(I, 5) = 0 THEN 'PENDIENTE'
                    WHEN MOD(I, 5) = 1 THEN 'EN_REVISION'
                    WHEN MOD(I, 5) = 2 THEN 'RESUELTO'
                    ELSE 'RECHAZADO'
                END,
                TIMESTAMP '2025-10-01 09:00:00' + NUMTODSINTERVAL(I, 'DAY'),
                CASE
                    WHEN MOD(I, 5) IN (2, 3, 4)
                    THEN TIMESTAMP '2025-10-03 09:00:00' + NUMTODSINTERVAL(I, 'DAY')
                    ELSE NULL
                END,
                CASE
                    WHEN MOD(I, 5) IN (2, 3, 4)
                    THEN 'Reporte revisado en etapa de prueba.'
                    ELSE NULL
                END
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
    END LOOP;
END;
/

/* ============================================================
   16. REFORZAR RELACIONES_CONTENIDO HASTA 40
   Tabla recursiva/intermedia entre contenidos.
   ============================================================ */

DECLARE
    V_TOTAL      NUMBER;
    V_ID         NUMBER;
    V_ORIGEN     NUMBER;
    V_DESTINO    NUMBER;
    V_TIPO       NUMBER;
    V_INTENTOS   NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO V_TOTAL
    FROM RELACIONES_CONTENIDO;

    SELECT NVL(MAX(ID_RELACION_CONTENIDO), 0) + 1
    INTO V_ID
    FROM RELACIONES_CONTENIDO;

    WHILE V_TOTAL < 40 AND V_INTENTOS < 500 LOOP
        V_INTENTOS := V_INTENTOS + 1;

        V_ORIGEN := MOD(V_INTENTOS - 1, 40) + 1;
        V_DESTINO := MOD(V_INTENTOS * 3, 40) + 1;
        V_TIPO := MOD(V_INTENTOS - 1, 25) + 1;

        IF V_ORIGEN <> V_DESTINO THEN
            BEGIN
                INSERT INTO RELACIONES_CONTENIDO (
                    ID_RELACION_CONTENIDO,
                    ID_CONTENIDO_ORIGEN,
                    ID_CONTENIDO_DESTINO,
                    ID_TIPO_RELACION,
                    DESCRIPCION,
                    FECHA_REGISTRO
                )
                VALUES (
                    V_ID,
                    V_ORIGEN,
                    V_DESTINO,
                    V_TIPO,
                    'Relacion adicional de prueba entre contenidos.',
                    DATE '2025-11-01' + V_INTENTOS
                );

                V_ID := V_ID + 1;
                V_TOTAL := V_TOTAL + 1;

            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
        END IF;
    END LOOP;
END;
/

/* ============================================================
   17. ACTUALIZAR POPULARIDAD DESPUES DEL REFUERZO
   ============================================================ */

UPDATE CONTENIDOS C
SET POPULARIDAD = (
    SELECT COUNT(*)
    FROM REPRODUCCIONES R
    WHERE R.ID_CONTENIDO = C.ID_CONTENIDO
      AND R.PORCENTAJE_AVANCE >= 90
);

COMMIT;

/* ============================================================
   18. VERIFICACION FINAL DE LAS 26 TABLAS
   ============================================================ */

SELECT 'BENEFICIOS_REFERIDO' AS NOMBRE_TABLA, COUNT(*) AS TOTAL FROM BENEFICIOS_REFERIDO
UNION ALL SELECT 'CALIFICACIONES', COUNT(*) FROM CALIFICACIONES
UNION ALL SELECT 'CAMBIOS_PLAN', COUNT(*) FROM CAMBIOS_PLAN
UNION ALL SELECT 'CATEGORIAS_CONTENIDO', COUNT(*) FROM CATEGORIAS_CONTENIDO
UNION ALL SELECT 'CIUDADES', COUNT(*) FROM CIUDADES
UNION ALL SELECT 'CONTENIDOS', COUNT(*) FROM CONTENIDOS
UNION ALL SELECT 'CONTENIDOS_GENEROS', COUNT(*) FROM CONTENIDOS_GENEROS
UNION ALL SELECT 'DEPARTAMENTOS', COUNT(*) FROM DEPARTAMENTOS
UNION ALL SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS
UNION ALL SELECT 'EPISODIOS', COUNT(*) FROM EPISODIOS
UNION ALL SELECT 'FAVORITOS', COUNT(*) FROM FAVORITOS
UNION ALL SELECT 'GENEROS', COUNT(*) FROM GENEROS
UNION ALL SELECT 'PAGOS', COUNT(*) FROM PAGOS
UNION ALL SELECT 'PERFILES', COUNT(*) FROM PERFILES
UNION ALL SELECT 'PLANES_SUSCRIPCION', COUNT(*) FROM PLANES_SUSCRIPCION
UNION ALL SELECT 'REFERIDOS', COUNT(*) FROM REFERIDOS
UNION ALL SELECT 'RELACIONES_CONTENIDO', COUNT(*) FROM RELACIONES_CONTENIDO
UNION ALL SELECT 'REPORTES_CONTENIDO', COUNT(*) FROM REPORTES_CONTENIDO
UNION ALL SELECT 'REPRODUCCIONES', COUNT(*) FROM REPRODUCCIONES
UNION ALL SELECT 'ROLES_USUARIO', COUNT(*) FROM ROLES_USUARIO
UNION ALL SELECT 'SESIONES_STREAMING', COUNT(*) FROM SESIONES_STREAMING
UNION ALL SELECT 'SUSCRIPCIONES', COUNT(*) FROM SUSCRIPCIONES
UNION ALL SELECT 'TEMPORADAS', COUNT(*) FROM TEMPORADAS
UNION ALL SELECT 'TIPOS_RELACION_CONTENIDO', COUNT(*) FROM TIPOS_RELACION_CONTENIDO
UNION ALL SELECT 'USUARIOS', COUNT(*) FROM USUARIOS
UNION ALL SELECT 'USUARIOS_ROLES', COUNT(*) FROM USUARIOS_ROLES
ORDER BY 1;