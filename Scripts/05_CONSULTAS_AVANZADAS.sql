/* ============================================================
   QUINDIOFLIX
   SCRIPT 05 - CONSULTAS AVANZADAS Y CAPA DE REPORTES
   Oracle 19c/21c

   Incluye:
   1. Consultas parametrizadas
   2. PIVOT
   3. UNPIVOT
   4. ROLLUP
   5. CUBE
   6. GROUPING()
   7. GROUPING SETS
   8. Vistas materializadas
   ============================================================ */

SET DEFINE ON;
SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';


/* ============================================================
   0. LIMPIEZA OPCIONAL DE VISTAS MATERIALIZADAS
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_POPULARIDAD_CONTENIDO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-12003, -942) THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_INGRESOS_MENSUALES';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-12003, -942) THEN
            RAISE;
        END IF;
END;
/


/* ============================================================
   1. CONSULTAS PARAMETRIZADAS
   ============================================================ */


/* ============================================================
   1.1 TOP 10 DE CONTENIDO MAS REPRODUCIDO POR CIUDAD

   Parametro:
   - Ciudad

   Ejemplo:
   Cuando SQL Developer pida el valor, escribir:
   Armenia
   ============================================================ */

PROMPT ============================================================
PROMPT CONSULTA PARAMETRIZADA 1 - TOP 10 POR CIUDAD
PROMPT ============================================================

SELECT *
FROM (
    SELECT CI.NOMBRE_CIUDAD,
           C.ID_CONTENIDO,
           C.TITULO,
           CAT.NOMBRE_CATEGORIA,
           COUNT(R.ID_REPRODUCCION) AS TOTAL_REPRODUCCIONES
    FROM CIUDADES CI
    JOIN USUARIOS U
      ON U.ID_CIUDAD = CI.ID_CIUDAD
    JOIN PERFILES P
      ON P.ID_USUARIO = U.ID_USUARIO
    JOIN REPRODUCCIONES R
      ON R.ID_PERFIL = P.ID_PERFIL
    JOIN CONTENIDOS C
      ON C.ID_CONTENIDO = R.ID_CONTENIDO
    JOIN CATEGORIAS_CONTENIDO CAT
      ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
    WHERE UPPER(CI.NOMBRE_CIUDAD) = UPPER('&P_CIUDAD')
    GROUP BY CI.NOMBRE_CIUDAD,
             C.ID_CONTENIDO,
             C.TITULO,
             CAT.NOMBRE_CATEGORIA
    ORDER BY TOTAL_REPRODUCCIONES DESC
)
WHERE ROWNUM <= 10;


/* ============================================================
   1.2 INGRESOS POR PLAN EN MES Y ANIO

   Parametros:
   - Mes numerico: 1 a 12
   - Anio: ejemplo 2025 o 2026

   Solo se cuentan pagos EXITOSOS.
   ============================================================ */

PROMPT ============================================================
PROMPT CONSULTA PARAMETRIZADA 2 - INGRESOS POR PLAN Y PERIODO
PROMPT ============================================================

SELECT PL.NOMBRE_PLAN,
       EXTRACT(MONTH FROM PA.FECHA_PAGO) AS MES,
       EXTRACT(YEAR FROM PA.FECHA_PAGO) AS ANIO,
       COUNT(PA.ID_PAGO) AS TOTAL_PAGOS,
       SUM(PA.MONTO_PAGADO) AS INGRESOS_TOTALES
FROM PAGOS PA
JOIN PLANES_SUSCRIPCION PL
  ON PL.ID_PLAN = PA.ID_PLAN
WHERE PA.ESTADO_PAGO = 'EXITOSO'
  AND EXTRACT(MONTH FROM PA.FECHA_PAGO) = &P_MES
  AND EXTRACT(YEAR FROM PA.FECHA_PAGO) = &P_ANIO
GROUP BY PL.NOMBRE_PLAN,
         EXTRACT(MONTH FROM PA.FECHA_PAGO),
         EXTRACT(YEAR FROM PA.FECHA_PAGO)
ORDER BY PL.NOMBRE_PLAN;


/* ============================================================
   1.3 CALIFICACION PROMEDIO POR CATEGORIA PARA UN GENERO

   Parametro:
   - Genero

   Ejemplo:
   ACCION
   DRAMA
   INFANTIL
   ============================================================ */

PROMPT ============================================================
PROMPT CONSULTA PARAMETRIZADA 3 - CALIFICACION PROMEDIO POR GENERO
PROMPT ============================================================

SELECT G.NOMBRE_GENERO,
       CAT.NOMBRE_CATEGORIA,
       COUNT(CA.ID_CALIFICACION) AS TOTAL_CALIFICACIONES,
       ROUND(AVG(CA.ESTRELLAS), 2) AS CALIFICACION_PROMEDIO
FROM GENEROS G
JOIN CONTENIDOS_GENEROS CG
  ON CG.ID_GENERO = G.ID_GENERO
JOIN CONTENIDOS C
  ON C.ID_CONTENIDO = CG.ID_CONTENIDO
JOIN CATEGORIAS_CONTENIDO CAT
  ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
LEFT JOIN CALIFICACIONES CA
  ON CA.ID_CONTENIDO = C.ID_CONTENIDO
WHERE UPPER(G.NOMBRE_GENERO) = UPPER('&P_GENERO')
GROUP BY G.NOMBRE_GENERO,
         CAT.NOMBRE_CATEGORIA
ORDER BY CAT.NOMBRE_CATEGORIA;


/* ============================================================
   2. REPORTES CON PIVOT
   ============================================================ */


/* ============================================================
   2.1 PIVOT - USUARIOS ACTIVOS POR CIUDAD Y PLAN

   Filas: ciudades
   Columnas: planes
   Valor: cantidad de usuarios activos
   ============================================================ */

PROMPT ============================================================
PROMPT PIVOT 1 - USUARIOS ACTIVOS POR CIUDAD Y PLAN
PROMPT ============================================================

SELECT NOMBRE_CIUDAD,
       NVL(BASICO, 0) AS BASICO,
       NVL(ESTANDAR, 0) AS ESTANDAR,
       NVL(PREMIUM, 0) AS PREMIUM
FROM (
    SELECT CI.NOMBRE_CIUDAD,
           PL.NOMBRE_PLAN,
           U.ID_USUARIO
    FROM USUARIOS U
    JOIN CIUDADES CI
      ON CI.ID_CIUDAD = U.ID_CIUDAD
    JOIN SUSCRIPCIONES S
      ON S.ID_USUARIO = U.ID_USUARIO
    JOIN PLANES_SUSCRIPCION PL
      ON PL.ID_PLAN = S.ID_PLAN
    WHERE U.ESTADO_CUENTA = 'ACTIVO'
      AND S.ESTADO_SUSCRIPCION = 'ACTIVA'
)
PIVOT (
    COUNT(ID_USUARIO)
    FOR NOMBRE_PLAN IN (
        'BASICO' AS BASICO,
        'ESTANDAR' AS ESTANDAR,
        'PREMIUM' AS PREMIUM
    )
)
ORDER BY NOMBRE_CIUDAD;


/* ============================================================
   2.2 PIVOT - REPRODUCCIONES POR CATEGORIA Y DISPOSITIVO

   Filas: categorias
   Columnas: dispositivos
   Valor: total de reproducciones
   ============================================================ */

PROMPT ============================================================
PROMPT PIVOT 2 - REPRODUCCIONES POR CATEGORIA Y DISPOSITIVO
PROMPT ============================================================

SELECT NOMBRE_CATEGORIA,
       NVL(CELULAR, 0) AS CELULAR,
       NVL(TABLET, 0) AS TABLET,
       NVL(TV, 0) AS TV,
       NVL(COMPUTADOR, 0) AS COMPUTADOR
FROM (
    SELECT CAT.NOMBRE_CATEGORIA,
           R.DISPOSITIVO,
           R.ID_REPRODUCCION
    FROM REPRODUCCIONES R
    JOIN CONTENIDOS C
      ON C.ID_CONTENIDO = R.ID_CONTENIDO
    JOIN CATEGORIAS_CONTENIDO CAT
      ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
)
PIVOT (
    COUNT(ID_REPRODUCCION)
    FOR DISPOSITIVO IN (
        'CELULAR' AS CELULAR,
        'TABLET' AS TABLET,
        'TV' AS TV,
        'COMPUTADOR' AS COMPUTADOR
    )
)
ORDER BY NOMBRE_CATEGORIA;


/* ============================================================
   3. REPORTES CON UNPIVOT
   ============================================================ */


/* ============================================================
   3.1 UNPIVOT - CONVERTIR PIVOT DE PLANES EN FILAS

   Toma un reporte pivoteado de usuarios por ciudad y plan,
   y lo convierte nuevamente a filas.
   ============================================================ */

PROMPT ============================================================
PROMPT UNPIVOT 1 - PLANES POR CIUDAD EN FILAS
PROMPT ============================================================

SELECT NOMBRE_CIUDAD,
       PLAN,
       CANTIDAD_USUARIOS
FROM (
    SELECT NOMBRE_CIUDAD,
           NVL(BASICO, 0) AS BASICO,
           NVL(ESTANDAR, 0) AS ESTANDAR,
           NVL(PREMIUM, 0) AS PREMIUM
    FROM (
        SELECT CI.NOMBRE_CIUDAD,
               PL.NOMBRE_PLAN,
               U.ID_USUARIO
        FROM USUARIOS U
        JOIN CIUDADES CI
          ON CI.ID_CIUDAD = U.ID_CIUDAD
        JOIN SUSCRIPCIONES S
          ON S.ID_USUARIO = U.ID_USUARIO
        JOIN PLANES_SUSCRIPCION PL
          ON PL.ID_PLAN = S.ID_PLAN
        WHERE U.ESTADO_CUENTA = 'ACTIVO'
          AND S.ESTADO_SUSCRIPCION = 'ACTIVA'
    )
    PIVOT (
        COUNT(ID_USUARIO)
        FOR NOMBRE_PLAN IN (
            'BASICO' AS BASICO,
            'ESTANDAR' AS ESTANDAR,
            'PREMIUM' AS PREMIUM
        )
    )
)
UNPIVOT (
    CANTIDAD_USUARIOS
    FOR PLAN IN (
        BASICO AS 'BASICO',
        ESTANDAR AS 'ESTANDAR',
        PREMIUM AS 'PREMIUM'
    )
)
ORDER BY NOMBRE_CIUDAD, PLAN;


/* ============================================================
   3.2 UNPIVOT - CONVERTIR COLUMNAS DE MESES EN FILAS

   Primero se construye un resumen con columnas ENERO, FEBRERO,
   MARZO y ABRIL; luego se convierte a filas.
   ============================================================ */

PROMPT ============================================================
PROMPT UNPIVOT 2 - INGRESOS MENSUALES EN FILAS
PROMPT ============================================================

WITH RESUMEN_MESES AS (
    SELECT PL.NOMBRE_PLAN,
           SUM(CASE WHEN EXTRACT(MONTH FROM PA.FECHA_PAGO) = 1 THEN PA.MONTO_PAGADO ELSE 0 END) AS ENERO,
           SUM(CASE WHEN EXTRACT(MONTH FROM PA.FECHA_PAGO) = 2 THEN PA.MONTO_PAGADO ELSE 0 END) AS FEBRERO,
           SUM(CASE WHEN EXTRACT(MONTH FROM PA.FECHA_PAGO) = 3 THEN PA.MONTO_PAGADO ELSE 0 END) AS MARZO,
           SUM(CASE WHEN EXTRACT(MONTH FROM PA.FECHA_PAGO) = 4 THEN PA.MONTO_PAGADO ELSE 0 END) AS ABRIL
    FROM PAGOS PA
    JOIN PLANES_SUSCRIPCION PL
      ON PL.ID_PLAN = PA.ID_PLAN
    WHERE PA.ESTADO_PAGO = 'EXITOSO'
    GROUP BY PL.NOMBRE_PLAN
)
SELECT NOMBRE_PLAN,
       MES,
       INGRESOS
FROM RESUMEN_MESES
UNPIVOT (
    INGRESOS
    FOR MES IN (
        ENERO AS 'ENERO',
        FEBRERO AS 'FEBRERO',
        MARZO AS 'MARZO',
        ABRIL AS 'ABRIL'
    )
)
ORDER BY NOMBRE_PLAN, MES;


/* ============================================================
   4. FUNCIONES AVANZADAS DE GROUP BY
   ============================================================ */


/* ============================================================
   4.1 ROLLUP - INGRESOS POR CIUDAD Y PLAN

   Genera:
   - Detalle por ciudad y plan
   - Subtotal por ciudad
   - Gran total
   ============================================================ */

PROMPT ============================================================
PROMPT ROLLUP - INGRESOS POR CIUDAD Y PLAN
PROMPT ============================================================

SELECT CASE
           WHEN GROUPING(CI.NOMBRE_CIUDAD) = 1 THEN 'TOTAL GENERAL'
           ELSE CI.NOMBRE_CIUDAD
       END AS CIUDAD,
       CASE
           WHEN GROUPING(PL.NOMBRE_PLAN) = 1 THEN 'TOTAL CIUDAD'
           ELSE PL.NOMBRE_PLAN
       END AS PLAN,
       COUNT(PA.ID_PAGO) AS TOTAL_PAGOS,
       SUM(PA.MONTO_PAGADO) AS INGRESOS
FROM PAGOS PA
JOIN USUARIOS U
  ON U.ID_USUARIO = PA.ID_USUARIO
JOIN CIUDADES CI
  ON CI.ID_CIUDAD = U.ID_CIUDAD
JOIN PLANES_SUSCRIPCION PL
  ON PL.ID_PLAN = PA.ID_PLAN
WHERE PA.ESTADO_PAGO = 'EXITOSO'
GROUP BY ROLLUP(CI.NOMBRE_CIUDAD, PL.NOMBRE_PLAN)
ORDER BY CI.NOMBRE_CIUDAD NULLS LAST,
         PL.NOMBRE_PLAN NULLS LAST;


/* ============================================================
   4.2 CUBE - REPRODUCCIONES POR CATEGORIA Y DISPOSITIVO

   Genera todas las combinaciones:
   - Categoria + dispositivo
   - Total por categoria
   - Total por dispositivo
   - Total general
   ============================================================ */

PROMPT ============================================================
PROMPT CUBE - REPRODUCCIONES POR CATEGORIA Y DISPOSITIVO
PROMPT ============================================================

SELECT CASE
           WHEN GROUPING(CAT.NOMBRE_CATEGORIA) = 1 THEN 'TODAS LAS CATEGORIAS'
           ELSE CAT.NOMBRE_CATEGORIA
       END AS CATEGORIA,
       CASE
           WHEN GROUPING(R.DISPOSITIVO) = 1 THEN 'TODOS LOS DISPOSITIVOS'
           ELSE R.DISPOSITIVO
       END AS DISPOSITIVO,
       COUNT(R.ID_REPRODUCCION) AS TOTAL_REPRODUCCIONES
FROM REPRODUCCIONES R
JOIN CONTENIDOS C
  ON C.ID_CONTENIDO = R.ID_CONTENIDO
JOIN CATEGORIAS_CONTENIDO CAT
  ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
GROUP BY CUBE(CAT.NOMBRE_CATEGORIA, R.DISPOSITIVO)
ORDER BY CATEGORIA, DISPOSITIVO;


/* ============================================================
   4.3 GROUPING() - ETIQUETAS LEGIBLES EN ROLLUP

   Se usa GROUPING() para reemplazar los NULL generados por
   ROLLUP con etiquetas comprensibles.
   ============================================================ */

PROMPT ============================================================
PROMPT GROUPING - ETIQUETAS EN SUBTOTALES
PROMPT ============================================================

SELECT CASE
           WHEN GROUPING(CI.NOMBRE_CIUDAD) = 1 THEN 'TOTAL GENERAL'
           ELSE CI.NOMBRE_CIUDAD
       END AS CIUDAD,
       CASE
           WHEN GROUPING(PL.NOMBRE_PLAN) = 1 THEN 'TOTAL POR CIUDAD'
           ELSE PL.NOMBRE_PLAN
       END AS PLAN,
       GROUPING(CI.NOMBRE_CIUDAD) AS ES_TOTAL_GENERAL,
       GROUPING(PL.NOMBRE_PLAN) AS ES_TOTAL_PLAN,
       SUM(PA.MONTO_PAGADO) AS INGRESOS
FROM PAGOS PA
JOIN USUARIOS U
  ON U.ID_USUARIO = PA.ID_USUARIO
JOIN CIUDADES CI
  ON CI.ID_CIUDAD = U.ID_CIUDAD
JOIN PLANES_SUSCRIPCION PL
  ON PL.ID_PLAN = PA.ID_PLAN
WHERE PA.ESTADO_PAGO = 'EXITOSO'
GROUP BY ROLLUP(CI.NOMBRE_CIUDAD, PL.NOMBRE_PLAN)
ORDER BY CI.NOMBRE_CIUDAD NULLS LAST,
         PL.NOMBRE_PLAN NULLS LAST;


/* ============================================================
   4.4 GROUPING SETS - TOTALES POR CATEGORIA Y POR CIUDAD

   Muestra solamente:
   - Totales por categoria
   - Totales por ciudad

   No muestra el detalle cruzado categoria-ciudad.
   ============================================================ */

PROMPT ============================================================
PROMPT GROUPING SETS - TOTALES POR CATEGORIA Y POR CIUDAD
PROMPT ============================================================

SELECT CASE
           WHEN GROUPING(CAT.NOMBRE_CATEGORIA) = 0 THEN CAT.NOMBRE_CATEGORIA
           ELSE 'NO APLICA'
       END AS CATEGORIA,
       CASE
           WHEN GROUPING(CI.NOMBRE_CIUDAD) = 0 THEN CI.NOMBRE_CIUDAD
           ELSE 'NO APLICA'
       END AS CIUDAD,
       COUNT(R.ID_REPRODUCCION) AS TOTAL_REPRODUCCIONES
FROM REPRODUCCIONES R
JOIN PERFILES P
  ON P.ID_PERFIL = R.ID_PERFIL
JOIN USUARIOS U
  ON U.ID_USUARIO = P.ID_USUARIO
JOIN CIUDADES CI
  ON CI.ID_CIUDAD = U.ID_CIUDAD
JOIN CONTENIDOS C
  ON C.ID_CONTENIDO = R.ID_CONTENIDO
JOIN CATEGORIAS_CONTENIDO CAT
  ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
GROUP BY GROUPING SETS (
    (CAT.NOMBRE_CATEGORIA),
    (CI.NOMBRE_CIUDAD)
)
ORDER BY CATEGORIA, CIUDAD;


/* ============================================================
   5. VISTAS MATERIALIZADAS
   ============================================================ */


/* ============================================================
   5.1 MV_POPULARIDAD_CONTENIDO

   Precalcula:
   - Total de reproducciones
   - Reproducciones completas
   - Calificación promedio
   - Total de favoritos

   Uso:
   Reporte de contenido mas popular.
   ============================================================ */

CREATE MATERIALIZED VIEW MV_POPULARIDAD_CONTENIDO
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT C.ID_CONTENIDO,
       C.TITULO,
       CAT.NOMBRE_CATEGORIA,
       C.CLASIFICACION_EDAD,
       C.ES_ORIGINAL,
       COUNT(DISTINCT R.ID_REPRODUCCION) AS TOTAL_REPRODUCCIONES,
       SUM(CASE
               WHEN R.PORCENTAJE_AVANCE >= 90 THEN 1
               ELSE 0
           END) AS REPRODUCCIONES_COMPLETAS,
       ROUND(AVG(CA.ESTRELLAS), 2) AS CALIFICACION_PROMEDIO,
       COUNT(DISTINCT F.ID_PERFIL) AS TOTAL_FAVORITOS
FROM CONTENIDOS C
JOIN CATEGORIAS_CONTENIDO CAT
  ON CAT.ID_CATEGORIA = C.ID_CATEGORIA
LEFT JOIN REPRODUCCIONES R
  ON R.ID_CONTENIDO = C.ID_CONTENIDO
LEFT JOIN CALIFICACIONES CA
  ON CA.ID_CONTENIDO = C.ID_CONTENIDO
LEFT JOIN FAVORITOS F
  ON F.ID_CONTENIDO = C.ID_CONTENIDO
GROUP BY C.ID_CONTENIDO,
         C.TITULO,
         CAT.NOMBRE_CATEGORIA,
         C.CLASIFICACION_EDAD,
         C.ES_ORIGINAL;


/* Consultar vista materializada de popularidad */
PROMPT ============================================================
PROMPT VISTA MATERIALIZADA - POPULARIDAD DE CONTENIDO
PROMPT ============================================================

SELECT *
FROM MV_POPULARIDAD_CONTENIDO
ORDER BY TOTAL_REPRODUCCIONES DESC, CALIFICACION_PROMEDIO DESC NULLS LAST
FETCH FIRST 10 ROWS ONLY;


/* ============================================================
   5.2 MV_INGRESOS_MENSUALES

   Precalcula:
   - Ingresos mensuales por ciudad y plan
   - Cantidad de pagos exitosos
   - Ingreso promedio

   Uso:
   Reporte financiero mensual.
   ============================================================ */

CREATE MATERIALIZED VIEW MV_INGRESOS_MENSUALES
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT EXTRACT(YEAR FROM PA.FECHA_PAGO) AS ANIO,
       EXTRACT(MONTH FROM PA.FECHA_PAGO) AS MES,
       CI.NOMBRE_CIUDAD,
       PL.NOMBRE_PLAN,
       COUNT(PA.ID_PAGO) AS TOTAL_PAGOS_EXITOSOS,
       SUM(PA.MONTO_PAGADO) AS INGRESOS_TOTALES,
       ROUND(AVG(PA.MONTO_PAGADO), 2) AS INGRESO_PROMEDIO
FROM PAGOS PA
JOIN USUARIOS U
  ON U.ID_USUARIO = PA.ID_USUARIO
JOIN CIUDADES CI
  ON CI.ID_CIUDAD = U.ID_CIUDAD
JOIN PLANES_SUSCRIPCION PL
  ON PL.ID_PLAN = PA.ID_PLAN
WHERE PA.ESTADO_PAGO = 'EXITOSO'
GROUP BY EXTRACT(YEAR FROM PA.FECHA_PAGO),
         EXTRACT(MONTH FROM PA.FECHA_PAGO),
         CI.NOMBRE_CIUDAD,
         PL.NOMBRE_PLAN;


/* Consultar vista materializada de ingresos */
PROMPT ============================================================
PROMPT VISTA MATERIALIZADA - INGRESOS MENSUALES
PROMPT ============================================================

SELECT *
FROM MV_INGRESOS_MENSUALES
ORDER BY ANIO, MES, NOMBRE_CIUDAD, NOMBRE_PLAN;


/* ============================================================
   5.3 REFRESCO MANUAL DE VISTAS MATERIALIZADAS

   Política usada:
   REFRESH COMPLETE ON DEMAND.

   Esto significa que las vistas no se actualizan en cada cambio
   transaccional, sino cuando se solicita explícitamente.
   ============================================================ */

BEGIN
    DBMS_MVIEW.REFRESH('MV_POPULARIDAD_CONTENIDO', 'C');
    DBMS_MVIEW.REFRESH('MV_INGRESOS_MENSUALES', 'C');
END;
/


/* ============================================================
   5.4 VERIFICAR VISTAS MATERIALIZADAS
   ============================================================ */

SELECT MVIEW_NAME,
       REFRESH_MODE,
       REFRESH_METHOD,
       BUILD_MODE,
       STALENESS
FROM USER_MVIEWS
WHERE MVIEW_NAME IN (
    'MV_POPULARIDAD_CONTENIDO',
    'MV_INGRESOS_MENSUALES'
)
ORDER BY MVIEW_NAME;


/* ============================================================
   6. VERIFICACION GENERAL DE OBJETOS ANALITICOS
   ============================================================ */

SELECT 'MV_POPULARIDAD_CONTENIDO' AS OBJETO,
       COUNT(*) AS TOTAL_REGISTROS
FROM MV_POPULARIDAD_CONTENIDO
UNION ALL
SELECT 'MV_INGRESOS_MENSUALES',
       COUNT(*)
FROM MV_INGRESOS_MENSUALES
ORDER BY 1;