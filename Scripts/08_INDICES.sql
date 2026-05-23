/* ============================================================
   QUINDIOFLIX
   SCRIPT 08 - INDICES Y OPTIMIZACION
   Oracle 19c/21c

   Objetivo:
   - Crear indices requeridos por el proyecto.
   - Comparar consultas antes y despues con EXPLAIN PLAN.
   - Justificar mejoras de rendimiento.
   ============================================================ */

SET SERVEROUTPUT ON;
SET DEFINE OFF;


/* ============================================================
   0. LIMPIEZA DE INDICES PERSONALIZADOS
   No se elimina el indice UNIQUE de USUARIOS.EMAIL porque
   fue creado por la restriccion UQ_USUARIOS_EMAIL.
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX IX_REP_PERFIL_FECHA';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX IX_CONT_CATEGORIA_ANIO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX IX_PAGOS_USUARIO_FECHA';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX IX_REP_CONT_DISP_FECHA';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/


/* ============================================================
   1. ACTUALIZAR ESTADISTICAS
   Esto ayuda al optimizador de Oracle a elegir mejores planes.
   ============================================================ */

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'REPRODUCCIONES');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'USUARIOS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'CONTENIDOS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PAGOS');
END;
/


/* ============================================================
   2. EXPLAIN PLAN ANTES DE CREAR INDICES
   Consulta pesada: historial de reproducciones por perfil
   en un rango de fechas.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT R.ID_REPRODUCCION,
       R.ID_PERFIL,
       R.ID_CONTENIDO,
       R.FECHA_HORA_INICIO,
       R.DISPOSITIVO,
       R.PORCENTAJE_AVANCE
FROM REPRODUCCIONES R
WHERE R.ID_PERFIL = 1
  AND R.FECHA_HORA_INICIO BETWEEN TIMESTAMP '2024-01-01 00:00:00'
                              AND TIMESTAMP '2026-12-31 23:59:59'
ORDER BY R.FECHA_HORA_INICIO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   3. EXPLAIN PLAN ANTES
   Consulta de busqueda de contenido por categoria y año.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT C.ID_CONTENIDO,
       C.TITULO,
       C.ANIO_LANZAMIENTO,
       C.ID_CATEGORIA
FROM CONTENIDOS C
WHERE C.ID_CATEGORIA = 1
  AND C.ANIO_LANZAMIENTO BETWEEN 2018 AND 2026
ORDER BY C.ANIO_LANZAMIENTO DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   4. EXPLAIN PLAN ANTES
   Consulta de pagos por usuario y fecha.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT P.ID_PAGO,
       P.ID_USUARIO,
       P.FECHA_PAGO,
       P.MONTO_PAGADO,
       P.ESTADO_PAGO
FROM PAGOS P
WHERE P.ID_USUARIO = 1
  AND P.FECHA_PAGO >= TIMESTAMP '2025-01-01 00:00:00'
ORDER BY P.FECHA_PAGO DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   5. CREACION DE INDICES REQUERIDOS
   ============================================================ */

/* 
   Indice 1:
   Historial de reproducciones por perfil y rango de fechas.
*/
CREATE INDEX IX_REP_PERFIL_FECHA
ON REPRODUCCIONES (ID_PERFIL, FECHA_HORA_INICIO);


/*
   Indice 2:
   El requisito pide indice en USUARIOS(EMAIL).
   En nuestro modelo ya existe por la restriccion UNIQUE:

   CONSTRAINT UQ_USUARIOS_EMAIL UNIQUE (EMAIL)

   Oracle crea automaticamente un indice unico para esa restriccion.
   Por eso no se crea otro indice duplicado sobre EMAIL, porque daria
   ORA-01408: such column list already indexed.

   Se deja evidencia con una consulta al diccionario mas abajo.
*/


/*
   Indice 3:
   Busqueda de contenidos por categoria y año.
*/
CREATE INDEX IX_CONT_CATEGORIA_ANIO
ON CONTENIDOS (ID_CATEGORIA, ANIO_LANZAMIENTO);


/*
   Indice 4:
   Indice adicional justificado.
   Optimiza historial de pagos, renovaciones e informes financieros
   por usuario y periodo.
*/
CREATE INDEX IX_PAGOS_USUARIO_FECHA
ON PAGOS (ID_USUARIO, FECHA_PAGO);


/*
   Indice adicional de apoyo:
   Optimiza reportes de reproducciones por contenido, dispositivo
   y fecha, utiles para analitica de consumo.
*/
CREATE INDEX IX_REP_CONT_DISP_FECHA
ON REPRODUCCIONES (ID_CONTENIDO, DISPOSITIVO, FECHA_HORA_INICIO);


/* ============================================================
   6. ACTUALIZAR ESTADISTICAS DESPUES DE CREAR INDICES
   ============================================================ */

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'REPRODUCCIONES');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'USUARIOS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'CONTENIDOS');
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PAGOS');
END;
/


/* ============================================================
   7. EXPLAIN PLAN DESPUES DE CREAR INDICES
   Misma consulta del historial por perfil.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT R.ID_REPRODUCCION,
       R.ID_PERFIL,
       R.ID_CONTENIDO,
       R.FECHA_HORA_INICIO,
       R.DISPOSITIVO,
       R.PORCENTAJE_AVANCE
FROM REPRODUCCIONES R
WHERE R.ID_PERFIL = 1
  AND R.FECHA_HORA_INICIO BETWEEN TIMESTAMP '2024-01-01 00:00:00'
                              AND TIMESTAMP '2026-12-31 23:59:59'
ORDER BY R.FECHA_HORA_INICIO;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   8. EXPLAIN PLAN DESPUES
   Busqueda de contenido por categoria y año.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT C.ID_CONTENIDO,
       C.TITULO,
       C.ANIO_LANZAMIENTO,
       C.ID_CATEGORIA
FROM CONTENIDOS C
WHERE C.ID_CATEGORIA = 1
  AND C.ANIO_LANZAMIENTO BETWEEN 2018 AND 2026
ORDER BY C.ANIO_LANZAMIENTO DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   9. EXPLAIN PLAN DESPUES
   Pagos por usuario y fecha.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT P.ID_PAGO,
       P.ID_USUARIO,
       P.FECHA_PAGO,
       P.MONTO_PAGADO,
       P.ESTADO_PAGO
FROM PAGOS P
WHERE P.ID_USUARIO = 1
  AND P.FECHA_PAGO >= TIMESTAMP '2025-01-01 00:00:00'
ORDER BY P.FECHA_PAGO DESC;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


/* ============================================================
   10. VERIFICACION DE INDICES CREADOS
   ============================================================ */

SELECT INDEX_NAME,
       TABLE_NAME,
       UNIQUENESS,
       STATUS
FROM USER_INDEXES
WHERE INDEX_NAME IN (
    'IX_REP_PERFIL_FECHA',
    'IX_CONT_CATEGORIA_ANIO',
    'IX_PAGOS_USUARIO_FECHA',
    'IX_REP_CONT_DISP_FECHA',
    'UQ_USUARIOS_EMAIL'
)
ORDER BY TABLE_NAME, INDEX_NAME;


/* Ver columnas de los indices */
SELECT INDEX_NAME,
       TABLE_NAME,
       COLUMN_NAME,
       COLUMN_POSITION
FROM USER_IND_COLUMNS
WHERE INDEX_NAME IN (
    'IX_REP_PERFIL_FECHA',
    'IX_CONT_CATEGORIA_ANIO',
    'IX_PAGOS_USUARIO_FECHA',
    'IX_REP_CONT_DISP_FECHA',
    'UQ_USUARIOS_EMAIL'
)
ORDER BY INDEX_NAME, COLUMN_POSITION;







/* ============================================================
   QUINDIOFLIX
   SCRIPT 08B - FRAGMENTACION / PARTICIONAMIENTO
   Tabla: REPRODUCCIONES_PART
   Oracle 19c/21c

   Objetivo:
   Crear una version particionada de REPRODUCCIONES por rango
   de FECHA_HORA_INICIO.
   ============================================================ */

SET SERVEROUTPUT ON;
SET DEFINE OFF;


/* ============================================================
   1. ELIMINAR TABLA PARTICIONADA SI YA EXISTE
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REPRODUCCIONES_PART CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/


/* ============================================================
   2. CREAR TABLA PARTICIONADA POR RANGO DE FECHAS

   Nota:
   Esta tabla se crea como demostracion tecnica.
   No reemplaza la tabla REPRODUCCIONES original.
   ============================================================ */

CREATE TABLE REPRODUCCIONES_PART (
    ID_REPRODUCCION     NUMBER(10) NOT NULL,
    ID_PERFIL           NUMBER(10) NOT NULL,
    ID_CONTENIDO        NUMBER(10) NOT NULL,
    ID_EPISODIO         NUMBER(10),
    ID_SESION           NUMBER(10),
    FECHA_HORA_INICIO   TIMESTAMP NOT NULL,
    FECHA_HORA_FIN      TIMESTAMP,
    DISPOSITIVO         VARCHAR2(20) NOT NULL,
    PORCENTAJE_AVANCE   NUMBER(5,2) DEFAULT 0 NOT NULL,

    CONSTRAINT PK_REPRODUCCIONES_PART
        PRIMARY KEY (ID_REPRODUCCION, FECHA_HORA_INICIO),

    CONSTRAINT CK_REP_PART_DISPOSITIVO CHECK (
        DISPOSITIVO IN ('CELULAR', 'TABLET', 'TV', 'COMPUTADOR')
    ),

    CONSTRAINT CK_REP_PART_AVANCE CHECK (
        PORCENTAJE_AVANCE BETWEEN 0 AND 100
    ),

    CONSTRAINT CK_REP_PART_FECHAS CHECK (
        FECHA_HORA_FIN IS NULL OR FECHA_HORA_FIN >= FECHA_HORA_INICIO
    )
)
PARTITION BY RANGE (FECHA_HORA_INICIO)
(
    PARTITION P_REP_2024 VALUES LESS THAN (TIMESTAMP '2025-01-01 00:00:00'),
    PARTITION P_REP_2025 VALUES LESS THAN (TIMESTAMP '2026-01-01 00:00:00'),
    PARTITION P_REP_2026 VALUES LESS THAN (TIMESTAMP '2027-01-01 00:00:00'),
    PARTITION P_REP_MAX  VALUES LESS THAN (MAXVALUE)
);


/* ============================================================
   3. COMENTARIOS
   ============================================================ */

COMMENT ON TABLE REPRODUCCIONES_PART IS
'Tabla particionada de demostracion para fragmentar reproducciones por rango de fechas.';

COMMENT ON COLUMN REPRODUCCIONES_PART.FECHA_HORA_INICIO IS
'Columna usada como clave de particionamiento por rango temporal.';


/* ============================================================
   4. COPIAR DATOS DESDE REPRODUCCIONES
   ============================================================ */

INSERT INTO REPRODUCCIONES_PART (
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
SELECT ID_REPRODUCCION,
       ID_PERFIL,
       ID_CONTENIDO,
       ID_EPISODIO,
       ID_SESION,
       FECHA_HORA_INICIO,
       FECHA_HORA_FIN,
       DISPOSITIVO,
       PORCENTAJE_AVANCE
FROM REPRODUCCIONES;

COMMIT;


/* ============================================================
   5. CREAR INDICE LOCAL SOBRE TABLA PARTICIONADA
   ============================================================ */

CREATE INDEX IX_REP_PART_PERFIL_FECHA
ON REPRODUCCIONES_PART (ID_PERFIL, FECHA_HORA_INICIO)
LOCAL;


/* ============================================================
   6. VERIFICAR PARTICIONES
   ============================================================ */

SELECT TABLE_NAME,
       PARTITION_NAME,
       HIGH_VALUE,
       NUM_ROWS
FROM USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'REPRODUCCIONES_PART'
ORDER BY PARTITION_POSITION;


/* ============================================================
   7. VERIFICAR DISTRIBUCION DE DATOS POR PARTICION
   ============================================================ */

SELECT 'P_REP_2024' AS PARTICION, COUNT(*) AS TOTAL
FROM REPRODUCCIONES_PART PARTITION (P_REP_2024)
UNION ALL
SELECT 'P_REP_2025', COUNT(*)
FROM REPRODUCCIONES_PART PARTITION (P_REP_2025)
UNION ALL
SELECT 'P_REP_2026', COUNT(*)
FROM REPRODUCCIONES_PART PARTITION (P_REP_2026)
UNION ALL
SELECT 'P_REP_MAX', COUNT(*)
FROM REPRODUCCIONES_PART PARTITION (P_REP_MAX)
ORDER BY 1;


/* ============================================================
   8. EXPLAIN PLAN SOBRE TABLA PARTICIONADA
   Oracle debe poder usar eliminacion de particiones
   cuando se filtra por FECHA_HORA_INICIO.
   ============================================================ */

EXPLAIN PLAN FOR
SELECT ID_REPRODUCCION,
       ID_PERFIL,
       ID_CONTENIDO,
       FECHA_HORA_INICIO,
       DISPOSITIVO
FROM REPRODUCCIONES_PART
WHERE FECHA_HORA_INICIO >= TIMESTAMP '2024-01-01 00:00:00'
  AND FECHA_HORA_INICIO <  TIMESTAMP '2025-01-01 00:00:00';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);










