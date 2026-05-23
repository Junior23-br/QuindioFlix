/* ============================================================
   QUINDIOFLIX
   SCRIPT 06 - PL/SQL
   HITO 3: COMPONENTES DE LOGICA DE NEGOCIO
   Oracle 19c/21c

   Incluye:
   1. Funciones
      - FN_CALCULAR_MONTO
      - FN_CONTENIDO_RECOMENDADO

   2. Procedimientos con cursores
      - PRC_REPORTE_USUARIOS_VENCIDOS
      - PRC_ACTUALIZAR_POPULARIDAD

   3. Procedimientos almacenados principales
      - SP_REGISTRAR_USUARIO
      - SP_CAMBIAR_PLAN
      - SP_REPORTE_CONSUMO

   4. Excepciones personalizadas mediante RAISE_APPLICATION_ERROR
   ============================================================ */

SET SERVEROUTPUT ON;
SET DEFINE OFF;


/* ============================================================
   0. ELIMINAR OBJETOS SI YA EXISTEN
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION FN_CALCULAR_MONTO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION FN_CONTENIDO_RECOMENDADO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE PRC_REPORTE_USUARIOS_VENCIDOS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE PRC_ACTUALIZAR_POPULARIDAD';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE SP_REGISTRAR_USUARIO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE SP_CAMBIAR_PLAN';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE SP_REPORTE_CONSUMO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/


/* ============================================================
   1. FUNCION FN_CALCULAR_MONTO

   Regla:
   Recibe un ID de usuario y retorna el monto a cobrar en el
   próximo mes, tomando el plan activo y aplicando descuentos
   por antigüedad:
   - Mas de 24 meses: 15%
   - Mas de 12 meses: 10%
   - Menor o igual a 12 meses: sin descuento

   Excepciones:
   -20060: Usuario sin suscripción activa.
   ============================================================ */

CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO (
    P_ID_USUARIO IN USUARIOS.ID_USUARIO%TYPE
)
RETURN NUMBER
IS
    V_PRECIO_BASE      PLANES_SUSCRIPCION.PRECIO_MENSUAL%TYPE;
    V_FECHA_REGISTRO   USUARIOS.FECHA_REGISTRO%TYPE;
    V_MESES_ANTIGUEDAD NUMBER;
    V_DESCUENTO        NUMBER := 0;
    V_MONTO_FINAL      NUMBER(10,2);
BEGIN
    SELECT P.PRECIO_MENSUAL,
           U.FECHA_REGISTRO
    INTO V_PRECIO_BASE,
         V_FECHA_REGISTRO
    FROM USUARIOS U
    JOIN SUSCRIPCIONES S
      ON S.ID_USUARIO = U.ID_USUARIO
    JOIN PLANES_SUSCRIPCION P
      ON P.ID_PLAN = S.ID_PLAN
    WHERE U.ID_USUARIO = P_ID_USUARIO
      AND S.ESTADO_SUSCRIPCION = 'ACTIVA';

    V_MESES_ANTIGUEDAD := MONTHS_BETWEEN(SYSDATE, V_FECHA_REGISTRO);

    IF V_MESES_ANTIGUEDAD > 24 THEN
        V_DESCUENTO := 0.15;
    ELSIF V_MESES_ANTIGUEDAD > 12 THEN
        V_DESCUENTO := 0.10;
    ELSE
        V_DESCUENTO := 0;
    END IF;

    V_MONTO_FINAL := ROUND(V_PRECIO_BASE * (1 - V_DESCUENTO), 2);

    RETURN V_MONTO_FINAL;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20060,
            'No se puede calcular el monto: el usuario no existe o no tiene suscripcion activa.'
        );
END;
/

SHOW ERRORS FUNCTION FN_CALCULAR_MONTO;


/* ============================================================
   2. FUNCION FN_CONTENIDO_RECOMENDADO

   Regla:
   Recibe un ID de perfil y retorna el título del contenido más
   recomendado, basándose en el género que más ha reproducido
   el perfil.

   Estrategia:
   1. Identificar el género más consumido por el perfil.
   2. Buscar un contenido de ese género que el perfil no haya
      reproducido todavía.
   3. Si ya reprodujo todo, retorna el contenido más popular
      del género.
   4. Si no hay historial, retorna el contenido más popular general.

   Excepciones:
   -20061: Perfil inexistente.
   ============================================================ */

CREATE OR REPLACE FUNCTION FN_CONTENIDO_RECOMENDADO (
    P_ID_PERFIL IN PERFILES.ID_PERFIL%TYPE
)
RETURN VARCHAR2
IS
    V_EXISTE_PERFIL   NUMBER;
    V_ID_GENERO       GENEROS.ID_GENERO%TYPE;
    V_TITULO          CONTENIDOS.TITULO%TYPE;
BEGIN
    SELECT COUNT(*)
    INTO V_EXISTE_PERFIL
    FROM PERFILES
    WHERE ID_PERFIL = P_ID_PERFIL;

    IF V_EXISTE_PERFIL = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20061,
            'No se puede recomendar contenido: el perfil no existe.'
        );
    END IF;

    BEGIN
        SELECT ID_GENERO
        INTO V_ID_GENERO
        FROM (
            SELECT CG.ID_GENERO,
                   COUNT(*) AS TOTAL_REPRODUCCIONES
            FROM REPRODUCCIONES R
            JOIN CONTENIDOS_GENEROS CG
              ON CG.ID_CONTENIDO = R.ID_CONTENIDO
            WHERE R.ID_PERFIL = P_ID_PERFIL
            GROUP BY CG.ID_GENERO
            ORDER BY COUNT(*) DESC
        )
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_ID_GENERO := NULL;
    END;

    IF V_ID_GENERO IS NOT NULL THEN
        BEGIN
            SELECT TITULO
            INTO V_TITULO
            FROM (
                SELECT C.TITULO,
                       C.POPULARIDAD
                FROM CONTENIDOS C
                JOIN CONTENIDOS_GENEROS CG
                  ON CG.ID_CONTENIDO = C.ID_CONTENIDO
                WHERE CG.ID_GENERO = V_ID_GENERO
                  AND C.ESTADO_CONTENIDO = 'DISPONIBLE'
                  AND NOT EXISTS (
                      SELECT 1
                      FROM REPRODUCCIONES R
                      WHERE R.ID_PERFIL = P_ID_PERFIL
                        AND R.ID_CONTENIDO = C.ID_CONTENIDO
                  )
                ORDER BY C.POPULARIDAD DESC, C.TITULO
            )
            WHERE ROWNUM = 1;

            RETURN V_TITULO;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT TITULO
                INTO V_TITULO
                FROM (
                    SELECT C.TITULO,
                           C.POPULARIDAD
                    FROM CONTENIDOS C
                    JOIN CONTENIDOS_GENEROS CG
                      ON CG.ID_CONTENIDO = C.ID_CONTENIDO
                    WHERE CG.ID_GENERO = V_ID_GENERO
                      AND C.ESTADO_CONTENIDO = 'DISPONIBLE'
                    ORDER BY C.POPULARIDAD DESC, C.TITULO
                )
                WHERE ROWNUM = 1;

                RETURN V_TITULO;
        END;
    ELSE
        SELECT TITULO
        INTO V_TITULO
        FROM (
            SELECT TITULO,
                   POPULARIDAD
            FROM CONTENIDOS
            WHERE ESTADO_CONTENIDO = 'DISPONIBLE'
            ORDER BY POPULARIDAD DESC, TITULO
        )
        WHERE ROWNUM = 1;

        RETURN V_TITULO;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No hay contenido disponible para recomendar.';
END;
/

SHOW ERRORS FUNCTION FN_CONTENIDO_RECOMENDADO;


/* ============================================================
   3. PROCEDIMIENTO CON CURSOR:
      PRC_REPORTE_USUARIOS_VENCIDOS

   Regla:
   Recorre usuarios cuya fecha de último pago supera los 30 días
   de mora. Muestra nombre, email, plan, días de mora y monto
   adeudado.

   Este procedimiento cumple el cursor requerido:
   "Cursor que recorra todos los usuarios cuya suscripción está
   vencida".
   ============================================================ */

CREATE OR REPLACE PROCEDURE PRC_REPORTE_USUARIOS_VENCIDOS
IS
    CURSOR C_USUARIOS_VENCIDOS IS
        SELECT U.ID_USUARIO,
               U.NOMBRE,
               U.EMAIL,
               P.NOMBRE_PLAN,
               TRUNC(SYSDATE - NVL(U.FECHA_ULTIMO_PAGO, U.FECHA_REGISTRO)) AS DIAS_SIN_PAGO,
               P.PRECIO_MENSUAL
        FROM USUARIOS U
        JOIN SUSCRIPCIONES S
          ON S.ID_USUARIO = U.ID_USUARIO
        JOIN PLANES_SUSCRIPCION P
          ON P.ID_PLAN = S.ID_PLAN
        WHERE S.ESTADO_SUSCRIPCION = 'ACTIVA'
          AND TRUNC(SYSDATE - NVL(U.FECHA_ULTIMO_PAGO, U.FECHA_REGISTRO)) > 30
        ORDER BY DIAS_SIN_PAGO DESC;

    V_MONTO_ADEUDADO NUMBER(10,2);
BEGIN
    DBMS_OUTPUT.PUT_LINE('REPORTE DE USUARIOS CON SUSCRIPCION VENCIDA');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

    FOR REG IN C_USUARIOS_VENCIDOS LOOP
        V_MONTO_ADEUDADO := FN_CALCULAR_MONTO(REG.ID_USUARIO);

        DBMS_OUTPUT.PUT_LINE(
            'Usuario: ' || REG.NOMBRE ||
            ' | Email: ' || REG.EMAIL ||
            ' | Plan: ' || REG.NOMBRE_PLAN ||
            ' | Dias de mora: ' || REG.DIAS_SIN_PAGO ||
            ' | Monto adeudado: $' || TO_CHAR(V_MONTO_ADEUDADO, '999G999G990D00')
        );
    END LOOP;
END;
/

SHOW ERRORS PROCEDURE PRC_REPORTE_USUARIOS_VENCIDOS;


/* ============================================================
   4. PROCEDIMIENTO CON CURSOR:
      PRC_ACTUALIZAR_POPULARIDAD

   Regla:
   Recorre el catálogo y para cada contenido calcula cuántas
   reproducciones completas ha tenido.
   Se considera reproducción completa si PORCENTAJE_AVANCE >= 90.

   Actualiza CONTENIDOS.POPULARIDAD.
   ============================================================ */

CREATE OR REPLACE PROCEDURE PRC_ACTUALIZAR_POPULARIDAD
IS
    CURSOR C_CONTENIDOS IS
        SELECT C.ID_CONTENIDO,
               C.TITULO
        FROM CONTENIDOS C
        ORDER BY C.ID_CONTENIDO;

    V_REPRODUCCIONES_COMPLETAS NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('ACTUALIZACION DE POPULARIDAD DE CONTENIDOS');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');

    FOR REG IN C_CONTENIDOS LOOP
        SELECT COUNT(*)
        INTO V_REPRODUCCIONES_COMPLETAS
        FROM REPRODUCCIONES R
        WHERE R.ID_CONTENIDO = REG.ID_CONTENIDO
          AND R.PORCENTAJE_AVANCE >= 90;

        UPDATE CONTENIDOS
        SET POPULARIDAD = V_REPRODUCCIONES_COMPLETAS
        WHERE ID_CONTENIDO = REG.ID_CONTENIDO;

        DBMS_OUTPUT.PUT_LINE(
            'Contenido: ' || REG.TITULO ||
            ' | Reproducciones completas: ' || V_REPRODUCCIONES_COMPLETAS
        );
    END LOOP;

    COMMIT;
END;
/

SHOW ERRORS PROCEDURE PRC_ACTUALIZAR_POPULARIDAD;


/* ============================================================
   5. PROCEDIMIENTO SP_REGISTRAR_USUARIO

   Regla:
   Recibe datos del usuario y plan elegido.
   Valida que el email no exista.
   Crea usuario.
   Crea suscripción.
   Crea perfil predeterminado.
   Registra primer pago.

   Excepciones:
   -20070: Email ya existe.
   -20071: Plan inválido.
   -20072: Ciudad inválida.
   ============================================================ */

CREATE OR REPLACE PROCEDURE SP_REGISTRAR_USUARIO (
    P_NOMBRE              IN USUARIOS.NOMBRE%TYPE,
    P_EMAIL               IN USUARIOS.EMAIL%TYPE,
    P_TELEFONO            IN USUARIOS.TELEFONO%TYPE,
    P_FECHA_NACIMIENTO    IN USUARIOS.FECHA_NACIMIENTO%TYPE,
    P_ID_CIUDAD           IN USUARIOS.ID_CIUDAD%TYPE,
    P_ID_PLAN             IN PLANES_SUSCRIPCION.ID_PLAN%TYPE,
    P_METODO_PAGO         IN PAGOS.METODO_PAGO%TYPE,
    P_ID_USUARIO_CREADO   OUT USUARIOS.ID_USUARIO%TYPE
)
IS
    V_EXISTE_EMAIL      NUMBER;
    V_EXISTE_CIUDAD     NUMBER;
    V_PRECIO_PLAN       PLANES_SUSCRIPCION.PRECIO_MENSUAL%TYPE;
    V_ID_USUARIO        NUMBER;
    V_ID_SUSCRIPCION    NUMBER;
    V_ID_PERFIL         NUMBER;
    V_ID_PAGO           NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_EXISTE_EMAIL
    FROM USUARIOS
    WHERE LOWER(EMAIL) = LOWER(P_EMAIL);

    IF V_EXISTE_EMAIL > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20070,
            'No se puede registrar el usuario: el email ya existe.'
        );
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE_CIUDAD
    FROM CIUDADES
    WHERE ID_CIUDAD = P_ID_CIUDAD
      AND ESTADO = 'ACTIVO';

    IF V_EXISTE_CIUDAD = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20072,
            'No se puede registrar el usuario: la ciudad no existe o esta inactiva.'
        );
    END IF;

    BEGIN
        SELECT PRECIO_MENSUAL
        INTO V_PRECIO_PLAN
        FROM PLANES_SUSCRIPCION
        WHERE ID_PLAN = P_ID_PLAN
          AND ESTADO = 'ACTIVO';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20071,
                'No se puede registrar el usuario: el plan seleccionado no es valido.'
            );
    END;

    SELECT NVL(MAX(ID_USUARIO), 0) + 1
    INTO V_ID_USUARIO
    FROM USUARIOS;

    SELECT NVL(MAX(ID_SUSCRIPCION), 0) + 1
    INTO V_ID_SUSCRIPCION
    FROM SUSCRIPCIONES;

    SELECT NVL(MAX(ID_PERFIL), 0) + 1
    INTO V_ID_PERFIL
    FROM PERFILES;

    SELECT NVL(MAX(ID_PAGO), 0) + 1
    INTO V_ID_PAGO
    FROM PAGOS;

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
        V_ID_USUARIO,
        P_ID_CIUDAD,
        P_NOMBRE,
        LOWER(P_EMAIL),
        P_TELEFONO,
        P_FECHA_NACIMIENTO,
        SYSDATE,
        'ACTIVO',
        SYSDATE
    );

    INSERT INTO SUSCRIPCIONES (
        ID_SUSCRIPCION,
        ID_USUARIO,
        ID_PLAN,
        FECHA_INICIO,
        FECHA_FIN,
        ESTADO_SUSCRIPCION
    )
    VALUES (
        V_ID_SUSCRIPCION,
        V_ID_USUARIO,
        P_ID_PLAN,
        SYSDATE,
        NULL,
        'ACTIVA'
    );

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
        V_ID_PERFIL,
        V_ID_USUARIO,
        'Principal',
        'avatar_default.png',
        'ADULTO',
        SYSDATE,
        'ACTIVO'
    );

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
        V_ID_PAGO,
        V_ID_USUARIO,
        P_ID_PLAN,
        SYSTIMESTAMP,
        SYSDATE + 30,
        V_PRECIO_PLAN,
        0,
        V_PRECIO_PLAN,
        P_METODO_PAGO,
        'EXITOSO',
        'QF-REG-' || V_ID_USUARIO || '-' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
    );

    P_ID_USUARIO_CREADO := V_ID_USUARIO;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Usuario registrado correctamente. ID_USUARIO = ' || V_ID_USUARIO);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

SHOW ERRORS PROCEDURE SP_REGISTRAR_USUARIO;


/* ============================================================
   6. PROCEDIMIENTO SP_CAMBIAR_PLAN

   Regla:
   Recibe el ID de usuario y el nuevo plan.
   Valida que el usuario exista y tenga suscripción activa.
   Valida que el nuevo plan exista.
   Valida que el usuario no tenga más perfiles activos que los
   permitidos por el nuevo plan.
   Finaliza la suscripción anterior.
   Crea una nueva suscripción activa.
   Registra el cambio en CAMBIOS_PLAN.

   Excepciones:
   -20080: Usuario sin suscripción activa.
   -20081: Nuevo plan inválido.
   -20082: El usuario tiene más perfiles que los permitidos.
   -20083: El usuario ya tiene ese plan.
   ============================================================ */

CREATE OR REPLACE PROCEDURE SP_CAMBIAR_PLAN (
    P_ID_USUARIO    IN USUARIOS.ID_USUARIO%TYPE,
    P_ID_PLAN_NUEVO IN PLANES_SUSCRIPCION.ID_PLAN%TYPE,
    P_MOTIVO        IN CAMBIOS_PLAN.MOTIVO%TYPE DEFAULT 'Cambio de plan solicitado por el usuario.'
)
IS
    V_ID_PLAN_ACTUAL       PLANES_SUSCRIPCION.ID_PLAN%TYPE;
    V_ID_SUSCRIPCION_ACT   SUSCRIPCIONES.ID_SUSCRIPCION%TYPE;
    V_MAX_PERFILES_NUEVO   PLANES_SUSCRIPCION.MAX_PERFILES%TYPE;
    V_TOTAL_PERFILES       NUMBER;
    V_ID_SUSCRIPCION_NVA   NUMBER;
    V_ID_CAMBIO_PLAN       NUMBER;
BEGIN
    BEGIN
        SELECT S.ID_SUSCRIPCION,
               S.ID_PLAN
        INTO V_ID_SUSCRIPCION_ACT,
             V_ID_PLAN_ACTUAL
        FROM SUSCRIPCIONES S
        WHERE S.ID_USUARIO = P_ID_USUARIO
          AND S.ESTADO_SUSCRIPCION = 'ACTIVA';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20080,
                'No se puede cambiar el plan: el usuario no tiene una suscripcion activa.'
            );
    END;

    IF V_ID_PLAN_ACTUAL = P_ID_PLAN_NUEVO THEN
        RAISE_APPLICATION_ERROR(
            -20083,
            'No se puede cambiar el plan: el usuario ya tiene asignado ese plan.'
        );
    END IF;

    BEGIN
        SELECT MAX_PERFILES
        INTO V_MAX_PERFILES_NUEVO
        FROM PLANES_SUSCRIPCION
        WHERE ID_PLAN = P_ID_PLAN_NUEVO
          AND ESTADO = 'ACTIVO';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20081,
                'No se puede cambiar el plan: el nuevo plan no existe o esta inactivo.'
            );
    END;

    SELECT COUNT(*)
    INTO V_TOTAL_PERFILES
    FROM PERFILES
    WHERE ID_USUARIO = P_ID_USUARIO
      AND ESTADO = 'ACTIVO';

    IF V_TOTAL_PERFILES > V_MAX_PERFILES_NUEVO THEN
        RAISE_APPLICATION_ERROR(
            -20082,
            'No se puede cambiar el plan: el usuario tiene mas perfiles activos que los permitidos por el nuevo plan.'
        );
    END IF;

    SELECT NVL(MAX(ID_SUSCRIPCION), 0) + 1
    INTO V_ID_SUSCRIPCION_NVA
    FROM SUSCRIPCIONES;

    SELECT NVL(MAX(ID_CAMBIO_PLAN), 0) + 1
    INTO V_ID_CAMBIO_PLAN
    FROM CAMBIOS_PLAN;

    UPDATE SUSCRIPCIONES
    SET ESTADO_SUSCRIPCION = 'FINALIZADA',
        FECHA_FIN = SYSDATE
    WHERE ID_SUSCRIPCION = V_ID_SUSCRIPCION_ACT;

    INSERT INTO SUSCRIPCIONES (
        ID_SUSCRIPCION,
        ID_USUARIO,
        ID_PLAN,
        FECHA_INICIO,
        FECHA_FIN,
        ESTADO_SUSCRIPCION
    )
    VALUES (
        V_ID_SUSCRIPCION_NVA,
        P_ID_USUARIO,
        P_ID_PLAN_NUEVO,
        SYSDATE,
        NULL,
        'ACTIVA'
    );

    INSERT INTO CAMBIOS_PLAN (
        ID_CAMBIO_PLAN,
        ID_USUARIO,
        ID_PLAN_ANTERIOR,
        ID_PLAN_NUEVO,
        FECHA_CAMBIO,
        MOTIVO
    )
    VALUES (
        V_ID_CAMBIO_PLAN,
        P_ID_USUARIO,
        V_ID_PLAN_ACTUAL,
        P_ID_PLAN_NUEVO,
        SYSTIMESTAMP,
        P_MOTIVO
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Plan cambiado correctamente. Usuario: ' || P_ID_USUARIO ||
        ' | Plan anterior: ' || V_ID_PLAN_ACTUAL ||
        ' | Plan nuevo: ' || P_ID_PLAN_NUEVO
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

SHOW ERRORS PROCEDURE SP_CAMBIAR_PLAN;


/* ============================================================
   7. PROCEDIMIENTO SP_REPORTE_CONSUMO

   Regla:
   Recibe ID de usuario y rango de fechas.
   Genera un reporte detallado de reproducciones de cada perfil,
   agrupadas por categoria, con total de reproducciones y tiempo
   consumido en minutos.

   Salida:
   DBMS_OUTPUT.
   ============================================================ */

CREATE OR REPLACE PROCEDURE SP_REPORTE_CONSUMO (
    P_ID_USUARIO   IN USUARIOS.ID_USUARIO%TYPE,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN    IN DATE
)
IS
    CURSOR C_REPORTE IS
        SELECT P.NOMBRE_PERFIL,
               CC.NOMBRE_CATEGORIA,
               COUNT(R.ID_REPRODUCCION) AS TOTAL_REPRODUCCIONES,
               ROUND(
                   SUM(
                       CASE
                           WHEN R.FECHA_HORA_FIN IS NOT NULL THEN
                               (CAST(R.FECHA_HORA_FIN AS DATE) - CAST(R.FECHA_HORA_INICIO AS DATE)) * 24 * 60
                           ELSE
                               0
                       END
                   ),
                   2
               ) AS MINUTOS_CONSUMIDOS
        FROM PERFILES P
        JOIN REPRODUCCIONES R
          ON R.ID_PERFIL = P.ID_PERFIL
        JOIN CONTENIDOS C
          ON C.ID_CONTENIDO = R.ID_CONTENIDO
        JOIN CATEGORIAS_CONTENIDO CC
          ON CC.ID_CATEGORIA = C.ID_CATEGORIA
        WHERE P.ID_USUARIO = P_ID_USUARIO
          AND CAST(R.FECHA_HORA_INICIO AS DATE) BETWEEN P_FECHA_INICIO AND P_FECHA_FIN
        GROUP BY P.NOMBRE_PERFIL,
                 CC.NOMBRE_CATEGORIA
        ORDER BY P.NOMBRE_PERFIL,
                 CC.NOMBRE_CATEGORIA;

    V_EXISTE_USUARIO NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_EXISTE_USUARIO
    FROM USUARIOS
    WHERE ID_USUARIO = P_ID_USUARIO;

    IF V_EXISTE_USUARIO = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20090,
            'No se puede generar el reporte: el usuario no existe.'
        );
    END IF;

    IF P_FECHA_FIN < P_FECHA_INICIO THEN
        RAISE_APPLICATION_ERROR(
            -20091,
            'No se puede generar el reporte: la fecha final no puede ser menor que la fecha inicial.'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('REPORTE DE CONSUMO DEL USUARIO ' || P_ID_USUARIO);
    DBMS_OUTPUT.PUT_LINE('Rango: ' || TO_CHAR(P_FECHA_INICIO, 'YYYY-MM-DD') ||
                         ' a ' || TO_CHAR(P_FECHA_FIN, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');

    FOR REG IN C_REPORTE LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Perfil: ' || REG.NOMBRE_PERFIL ||
            ' | Categoria: ' || REG.NOMBRE_CATEGORIA ||
            ' | Reproducciones: ' || REG.TOTAL_REPRODUCCIONES ||
            ' | Minutos consumidos: ' || REG.MINUTOS_CONSUMIDOS
        );
    END LOOP;
END;
/

SHOW ERRORS PROCEDURE SP_REPORTE_CONSUMO;


/* ============================================================
   8. VERIFICACION DE OBJETOS CREADOS
   ============================================================ */

SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME IN (
    'FN_CALCULAR_MONTO',
    'FN_CONTENIDO_RECOMENDADO',
    'PRC_REPORTE_USUARIOS_VENCIDOS',
    'PRC_ACTUALIZAR_POPULARIDAD',
    'SP_REGISTRAR_USUARIO',
    'SP_CAMBIAR_PLAN',
    'SP_REPORTE_CONSUMO'
)
ORDER BY OBJECT_TYPE, OBJECT_NAME;

--PRUEBAS 

/*1. Prueba de función FN_CALCULAR_MONTO
Debe retornar un valor numérico*/

SELECT FN_CALCULAR_MONTO(1) AS MONTO_PROXIMO_PAGO
FROM DUAL;

/*2. Prueba de función FN_CONTENIDO_RECOMENDADO
Debe retornar el título de un contenido recomendado*/

SELECT FN_CONTENIDO_RECOMENDADO(1) AS CONTENIDO_RECOMENDADO
FROM DUAL;

/*3. Prueba de cursor de usuarios vencidos
Debe mostrar por consola usuarios con mora mayor a 30 días*/

SET SERVEROUTPUT ON;

BEGIN
    PRC_REPORTE_USUARIOS_VENCIDOS;
END;
/

/*4. Prueba de cursor de popularidad*/

BEGIN
    PRC_ACTUALIZAR_POPULARIDAD;
END;
/

--Verifica

SELECT ID_CONTENIDO, TITULO, POPULARIDAD
FROM CONTENIDOS
ORDER BY POPULARIDAD DESC, ID_CONTENIDO
FETCH FIRST 10 ROWS ONLY;


/*5. Prueba de reporte de consumo
Debe mostrar consumo agrupado por perfil y categoría*/

BEGIN
    SP_REPORTE_CONSUMO(
        P_ID_USUARIO   => 1,
        P_FECHA_INICIO => DATE '2024-01-01',
        P_FECHA_FIN    => DATE '2026-12-31'
    );
END;
/


/*6. Prueba de excepción: email duplicado
Debe salir:
ORA-20070: No se puede registrar el usuario: el email ya existe*/

DECLARE
    V_ID_USUARIO NUMBER;
BEGIN
    SP_REGISTRAR_USUARIO(
        P_NOMBRE            => 'Usuario Duplicado',
        P_EMAIL             => 'usuario01@quindioflix.com',
        P_TELEFONO          => '3109999999',
        P_FECHA_NACIMIENTO  => DATE '1995-05-10',
        P_ID_CIUDAD         => 1,
        P_ID_PLAN           => 1,
        P_METODO_PAGO       => 'PSE',
        P_ID_USUARIO_CREADO => V_ID_USUARIO
    );
END;
/

/*7. Prueba de registro correcto
Debe crear:
-Usuario
-Suscripción
-Perfil principal
-Pago exitoso*/

DECLARE
    V_ID_USUARIO NUMBER;
BEGIN
    SP_REGISTRAR_USUARIO(
        P_NOMBRE            => 'Nuevo Usuario Hito 3',
        P_EMAIL             => 'nuevo.hito3@quindioflix.com',
        P_TELEFONO          => '3128888888',
        P_FECHA_NACIMIENTO  => DATE '1998-08-20',
        P_ID_CIUDAD         => 1,
        P_ID_PLAN           => 2,
        P_METODO_PAGO       => 'NEQUI',
        P_ID_USUARIO_CREADO => V_ID_USUARIO
    );

    DBMS_OUTPUT.PUT_LINE('ID creado: ' || V_ID_USUARIO);
END;
/

/*8. Prueba de excepción: plan inválido
Debe salir:
ORA-20081: No se puede cambiar el plan: el nuevo plan no existe o esta inactivo*/

BEGIN
    SP_CAMBIAR_PLAN(
        P_ID_USUARIO    => 1,
        P_ID_PLAN_NUEVO => 99,
        P_MOTIVO        => 'Prueba de plan invalido'
    );
END;
/


/* ============================================================
   QUINDIOFLIX
   SCRIPT 06 - PL/SQL
   HITO 2: TRIGGERS / DISPARADORES
   Oracle 19c/21c

   Objetivo:
   Implementar reglas de negocio que no pueden controlarse
   únicamente con PK, FK, UNIQUE o CHECK.

   Triggers incluidos:
   1. TRG_PAGOS_ACTUALIZAR_USUARIO
   2. CTRG_PERFILES_MAX_PLAN
   3. TRG_CALIFICACIONES_MIN_AVANCE
   4. TRG_REP_VALIDACIONES_CONTENIDO
   ============================================================ */

SET SERVEROUTPUT ON;
SET DEFINE OFF;


/* ============================================================
   0. ELIMINAR TRIGGERS SI YA EXISTEN
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TRG_PAGOS_ACTUALIZAR_USUARIO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER CTRG_PERFILES_MAX_PLAN';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TRG_CALIFICACIONES_MIN_AVANCE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TRG_REP_VALIDACIONES_CONTENIDO';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN
            RAISE;
        END IF;
END;
/


/* ============================================================
   1. TRIGGER SOBRE PAGOS
   Regla:
   Después de insertar o actualizar un pago exitoso, la cuenta
   del usuario debe quedar ACTIVO y se debe actualizar
   FECHA_ULTIMO_PAGO.

   Nota técnica:
   Se usa COMPOUND TRIGGER para separar la captura de filas
   y la actualización posterior a nivel de sentencia.
   ============================================================ */

CREATE OR REPLACE TRIGGER TRG_PAGOS_ACTUALIZAR_USUARIO
FOR INSERT OR UPDATE OF ESTADO_PAGO, FECHA_PAGO
ON PAGOS
COMPOUND TRIGGER

    TYPE T_ID_USUARIO IS TABLE OF PAGOS.ID_USUARIO%TYPE INDEX BY PLS_INTEGER;
    TYPE T_FECHA_PAGO IS TABLE OF DATE INDEX BY PLS_INTEGER;

    G_USUARIOS T_ID_USUARIO;
    G_FECHAS   T_FECHA_PAGO;
    G_TOTAL    PLS_INTEGER := 0;

AFTER EACH ROW IS
BEGIN
    IF :NEW.ESTADO_PAGO = 'EXITOSO' THEN
        G_TOTAL := G_TOTAL + 1;
        G_USUARIOS(G_TOTAL) := :NEW.ID_USUARIO;
        G_FECHAS(G_TOTAL) := CAST(:NEW.FECHA_PAGO AS DATE);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
    FOR I IN 1 .. G_TOTAL LOOP
        UPDATE USUARIOS
        SET ESTADO_CUENTA = 'ACTIVO',
            FECHA_ULTIMO_PAGO = G_FECHAS(I)
        WHERE ID_USUARIO = G_USUARIOS(I);
    END LOOP;
END AFTER STATEMENT;

END TRG_PAGOS_ACTUALIZAR_USUARIO;
/

SHOW ERRORS TRIGGER TRG_PAGOS_ACTUALIZAR_USUARIO;


/* ============================================================
   2. TRIGGER SOBRE PERFILES
   Regla:
   Un usuario no puede tener más perfiles activos que los
   permitidos por su plan activo.

   Planes esperados:
   BASICO    -> 2 perfiles
   ESTANDAR  -> 3 perfiles
   PREMIUM   -> 5 perfiles

   Nota técnica:
   Se usa COMPOUND TRIGGER para evitar error de tabla mutante
   sobre PERFILES.
   ============================================================ */

CREATE OR REPLACE TRIGGER CTRG_PERFILES_MAX_PLAN
FOR INSERT OR UPDATE OF ID_USUARIO, ESTADO
ON PERFILES
COMPOUND TRIGGER

    TYPE T_ID_USUARIO IS TABLE OF PERFILES.ID_USUARIO%TYPE INDEX BY PLS_INTEGER;

    G_USUARIOS T_ID_USUARIO;
    G_TOTAL    PLS_INTEGER := 0;

AFTER EACH ROW IS
BEGIN
    IF :NEW.ESTADO = 'ACTIVO' THEN
        G_TOTAL := G_TOTAL + 1;
        G_USUARIOS(G_TOTAL) := :NEW.ID_USUARIO;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    V_MAX_PERFILES     PLANES_SUSCRIPCION.MAX_PERFILES%TYPE;
    V_TOTAL_PERFILES   NUMBER;
BEGIN
    FOR I IN 1 .. G_TOTAL LOOP

        SELECT P.MAX_PERFILES
        INTO V_MAX_PERFILES
        FROM SUSCRIPCIONES S
        JOIN PLANES_SUSCRIPCION P
          ON P.ID_PLAN = S.ID_PLAN
        WHERE S.ID_USUARIO = G_USUARIOS(I)
          AND S.ESTADO_SUSCRIPCION = 'ACTIVA';

        SELECT COUNT(*)
        INTO V_TOTAL_PERFILES
        FROM PERFILES
        WHERE ID_USUARIO = G_USUARIOS(I)
          AND ESTADO = 'ACTIVO';

        IF V_TOTAL_PERFILES > V_MAX_PERFILES THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'No se puede crear el perfil: el usuario supera el maximo de perfiles permitidos por su plan.'
            );
        END IF;

    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'No se puede validar el perfil: el usuario no tiene una suscripcion activa.'
        );
END AFTER STATEMENT;

END CTRG_PERFILES_MAX_PLAN;
/

SHOW ERRORS TRIGGER CTRG_PERFILES_MAX_PLAN;


/* ============================================================
   3. TRIGGER SOBRE CALIFICACIONES
   Regla:
   Un perfil solo puede calificar un contenido si ya lo reprodujo
   al menos al 50%.

   Evento:
   BEFORE INSERT OR UPDATE sobre CALIFICACIONES.
   ============================================================ */

CREATE OR REPLACE TRIGGER TRG_CALIFICACIONES_MIN_AVANCE
BEFORE INSERT OR UPDATE OF ID_PERFIL, ID_CONTENIDO, ESTRELLAS
ON CALIFICACIONES
FOR EACH ROW
DECLARE
    V_TOTAL_REPRODUCCIONES NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_TOTAL_REPRODUCCIONES
    FROM REPRODUCCIONES
    WHERE ID_PERFIL = :NEW.ID_PERFIL
      AND ID_CONTENIDO = :NEW.ID_CONTENIDO
      AND PORCENTAJE_AVANCE >= 50;

    IF V_TOTAL_REPRODUCCIONES = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20020,
            'No se puede calificar el contenido: el perfil debe haber reproducido al menos el 50%.'
        );
    END IF;
END;
/

SHOW ERRORS TRIGGER TRG_CALIFICACIONES_MIN_AVANCE;


/* ============================================================
   4. TRIGGER SOBRE REPRODUCCIONES
   Reglas:
   1. La cuenta del usuario debe estar ACTIVA.
   2. Un perfil infantil solo puede reproducir TP, +7 o +13.
   3. Si el contenido es SERIE o PODCAST, debe tener ID_EPISODIO.
   4. Si el contenido es PELICULA, DOCUMENTAL o MUSICA,
      ID_EPISODIO debe ser NULL.
   5. Si ID_EPISODIO no es NULL, el episodio debe pertenecer
      al mismo contenido padre indicado en ID_CONTENIDO.

   Evento:
   BEFORE INSERT OR UPDATE sobre REPRODUCCIONES.
   ============================================================ */

CREATE OR REPLACE TRIGGER TRG_REP_VALIDACIONES_CONTENIDO
BEFORE INSERT OR UPDATE OF ID_PERFIL, ID_CONTENIDO, ID_EPISODIO, PORCENTAJE_AVANCE
ON REPRODUCCIONES
FOR EACH ROW
DECLARE
    V_ESTADO_CUENTA     USUARIOS.ESTADO_CUENTA%TYPE;
    V_TIPO_PERFIL       PERFILES.TIPO_PERFIL%TYPE;
    V_CATEGORIA         CATEGORIAS_CONTENIDO.NOMBRE_CATEGORIA%TYPE;
    V_CLASIFICACION     CONTENIDOS.CLASIFICACION_EDAD%TYPE;
    V_CONTENIDO_PADRE   CONTENIDOS.ID_CONTENIDO%TYPE;
BEGIN
    /* Validar estado de cuenta y tipo de perfil */
    SELECT U.ESTADO_CUENTA,
           P.TIPO_PERFIL
    INTO V_ESTADO_CUENTA,
         V_TIPO_PERFIL
    FROM PERFILES P
    JOIN USUARIOS U
      ON U.ID_USUARIO = P.ID_USUARIO
    WHERE P.ID_PERFIL = :NEW.ID_PERFIL;

    IF V_ESTADO_CUENTA <> 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(
            -20030,
            'No se puede registrar la reproduccion: la cuenta del usuario no esta activa.'
        );
    END IF;

    /* Obtener categoria y clasificacion del contenido */
    SELECT UPPER(CC.NOMBRE_CATEGORIA),
           C.CLASIFICACION_EDAD
    INTO V_CATEGORIA,
         V_CLASIFICACION
    FROM CONTENIDOS C
    JOIN CATEGORIAS_CONTENIDO CC
      ON CC.ID_CATEGORIA = C.ID_CATEGORIA
    WHERE C.ID_CONTENIDO = :NEW.ID_CONTENIDO;

    /* Validar restriccion de perfil infantil */
    IF V_TIPO_PERFIL = 'INFANTIL'
       AND V_CLASIFICACION NOT IN ('TP', '+7', '+13') THEN
        RAISE_APPLICATION_ERROR(
            -20031,
            'Un perfil infantil solo puede reproducir contenido clasificado como TP, +7 o +13.'
        );
    END IF;

    /* Validaciones para series y podcasts */
    IF V_CATEGORIA IN ('SERIE', 'PODCAST') THEN

        IF :NEW.ID_EPISODIO IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20032,
                'Las series y podcasts deben registrar el episodio reproducido.'
            );
        END IF;

        SELECT T.ID_CONTENIDO
        INTO V_CONTENIDO_PADRE
        FROM EPISODIOS E
        JOIN TEMPORADAS T
          ON T.ID_TEMPORADA = E.ID_TEMPORADA
        WHERE E.ID_EPISODIO = :NEW.ID_EPISODIO;

        IF V_CONTENIDO_PADRE <> :NEW.ID_CONTENIDO THEN
            RAISE_APPLICATION_ERROR(
                -20033,
                'El episodio indicado no pertenece al contenido registrado en la reproduccion.'
            );
        END IF;

    ELSE
        /* Peliculas, documentales y musica no deben tener episodio */
        IF :NEW.ID_EPISODIO IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(
                -20034,
                'Las peliculas, documentales y musica no deben registrar ID_EPISODIO.'
            );
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20035,
            'Datos invalidos: perfil, contenido o episodio inexistente en la reproduccion.'
        );
END;
/

SHOW ERRORS TRIGGER TRG_REP_VALIDACIONES_CONTENIDO;


/* ============================================================
   5. VERIFICAR TRIGGERS CREADOS
   ============================================================ */

SELECT TRIGGER_NAME, TABLE_NAME, STATUS
FROM USER_TRIGGERS
WHERE TRIGGER_NAME IN (
    'TRG_PAGOS_ACTUALIZAR_USUARIO',
    'CTRG_PERFILES_MAX_PLAN',
    'TRG_CALIFICACIONES_MIN_AVANCE',
    'TRG_REP_VALIDACIONES_CONTENIDO'
)
ORDER BY TRIGGER_NAME;



--PRUEBAS

/*Prueba 1 — Trigger de pagos exitosos
Esta prueba valida que un pago exitoso actualiza la cuenta del usuario.*/

/* Ver estado antes */
SELECT ID_USUARIO, ESTADO_CUENTA, FECHA_ULTIMO_PAGO
FROM USUARIOS
WHERE ID_USUARIO = 9;

/* Insertar pago exitoso */
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
    9001,
    9,
    1,
    SYSTIMESTAMP,
    SYSDATE + 30,
    14900,
    0,
    14900,
    'PSE',
    'EXITOSO',
    'QF-TEST-PAGO-9001'
);

/* Ver estado después */
SELECT ID_USUARIO, ESTADO_CUENTA, FECHA_ULTIMO_PAGO
FROM USUARIOS
WHERE ID_USUARIO = 9;

/* Para dejar la base como estaba durante la prueba */
ROLLBACK;


/*Prueba 2 — Trigger de máximo de perfiles por plan
El usuario 1 tiene plan Básico y ya tiene varios perfiles. Esta inserción debe fallar*/

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
    9001,
    1,
    'Perfil Extra No Permitido',
    'avatar_error.png',
    'ADULTO',
    SYSDATE,
    'ACTIVO'
);

ROLLBACK;

/*Prueba 3 — Trigger de calificación mínima
Esta prueba intenta calificar un contenido que el perfil no ha reproducido al menos al 50%*/

DECLARE
    V_ID_PERFIL     NUMBER;
    V_ID_CONTENIDO  NUMBER;
    V_ID_CALIF      NUMBER;
BEGIN
    SELECT NVL(MAX(ID_CALIFICACION), 0) + 1
    INTO V_ID_CALIF
    FROM CALIFICACIONES;

    SELECT P.ID_PERFIL, C.ID_CONTENIDO
    INTO V_ID_PERFIL, V_ID_CONTENIDO
    FROM PERFILES P
    CROSS JOIN CONTENIDOS C
    WHERE NOT EXISTS (
        SELECT 1
        FROM REPRODUCCIONES R
        WHERE R.ID_PERFIL = P.ID_PERFIL
          AND R.ID_CONTENIDO = C.ID_CONTENIDO
          AND R.PORCENTAJE_AVANCE >= 50
    )
    AND NOT EXISTS (
        SELECT 1
        FROM CALIFICACIONES CA
        WHERE CA.ID_PERFIL = P.ID_PERFIL
          AND CA.ID_CONTENIDO = C.ID_CONTENIDO
    )
    AND ROWNUM = 1;

    INSERT INTO CALIFICACIONES (
        ID_CALIFICACION,
        ID_PERFIL,
        ID_CONTENIDO,
        ESTRELLAS,
        RESENA,
        FECHA_CALIFICACION
    )
    VALUES (
        V_ID_CALIF,
        V_ID_PERFIL,
        V_ID_CONTENIDO,
        5,
        'Prueba de calificacion no permitida.',
        SYSDATE
    );
END;
/

/*Prueba 4 — Trigger de reproducciones: película con episodio
Esta prueba intenta registrar una película con ID_EPISODIO, lo cual debe fallar*/

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
    9001,
    1,
    1,
    1,
    NULL,
    SYSTIMESTAMP,
    SYSTIMESTAMP + INTERVAL '60' MINUTE,
    'TV',
    80
);

ROLLBACK;









/* ============================================================
   5. BLOQUES DE PRUEBA
   ============================================================ */

-- Pruebas exitosas
-- Pruebas con errores controlados