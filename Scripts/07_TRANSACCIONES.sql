/* ============================================================
   QUINDIOFLIX
   SCRIPT 07 - TRANSACCIONES Y CONCURRENCIA
   Oracle 19c/21c

   Incluye:
   1. Transaccion de registro completo.
   2. Transaccion de renovacion mensual con SAVEPOINT.
   3. Transaccion de eliminacion de cuenta.
   4. Escenario de concurrencia con SELECT FOR UPDATE.

   Nota:
   Ejecutar con el usuario propietario de las tablas.
   ============================================================ */

SET SERVEROUTPUT ON;
SET DEFINE OFF;


/* ============================================================
   TRANSACCION 1
   REGISTRO COMPLETO DE USUARIO

   Regla:
   Crear usuario + suscripcion + perfil predeterminado + primer pago.
   Si falla cualquier paso, se deshace todo con ROLLBACK.

   Tablas involucradas:
   - USUARIOS
   - SUSCRIPCIONES
   - PERFILES
   - PAGOS

   Estado transaccional:
   - Activa: inicia el bloque.
   - Parcialmente confirmada: todos los INSERT finalizan.
   - Confirmada: COMMIT.
   - Fallida: cualquier error.
   - Abortada: ROLLBACK.
   ============================================================ */

DECLARE
    V_ID_USUARIO        USUARIOS.ID_USUARIO%TYPE;
    V_ID_SUSCRIPCION    SUSCRIPCIONES.ID_SUSCRIPCION%TYPE;
    V_ID_PERFIL         PERFILES.ID_PERFIL%TYPE;
    V_ID_PAGO           PAGOS.ID_PAGO%TYPE;
    V_PRECIO_PLAN       PLANES_SUSCRIPCION.PRECIO_MENSUAL%TYPE;
    V_EMAIL             USUARIOS.EMAIL%TYPE := 'transaccion.registro@quindioflix.com';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transaccion de registro completo...');

    /* Validar que el correo no exista */
    DECLARE
        V_EXISTE NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO V_EXISTE
        FROM USUARIOS
        WHERE LOWER(EMAIL) = LOWER(V_EMAIL);

        IF V_EXISTE > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20100,
                'El correo ya existe. No se puede ejecutar la transaccion de registro.'
            );
        END IF;
    END;

    /* Obtener precio del plan elegido */
    SELECT PRECIO_MENSUAL
    INTO V_PRECIO_PLAN
    FROM PLANES_SUSCRIPCION
    WHERE ID_PLAN = 2
      AND ESTADO = 'ACTIVO';

    /* Generar IDs manuales para mantener consistencia con los datos de prueba */
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

    /* Paso 1: crear usuario */
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
        1,
        'Usuario Transaccion Registro',
        V_EMAIL,
        '3130000000',
        DATE '1997-04-15',
        SYSDATE,
        'ACTIVO',
        SYSDATE
    );

    /* Paso 2: crear suscripcion */
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
        2,
        SYSDATE,
        NULL,
        'ACTIVA'
    );

    /* Paso 3: crear perfil predeterminado */
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
        'avatar_transaccion.png',
        'ADULTO',
        SYSDATE,
        'ACTIVO'
    );

    /* Paso 4: registrar primer pago */
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
        2,
        SYSTIMESTAMP,
        SYSDATE + 30,
        V_PRECIO_PLAN,
        0,
        V_PRECIO_PLAN,
        'PSE',
        'EXITOSO',
        'QF-TX-REG-' || V_ID_USUARIO
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Transaccion confirmada correctamente.');
    DBMS_OUTPUT.PUT_LINE('Usuario creado: ' || V_ID_USUARIO);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaccion fallida. Se ejecuta ROLLBACK.');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


/* Verificacion de la transaccion 1 */
SELECT U.ID_USUARIO,
       U.NOMBRE,
       U.EMAIL,
       S.ID_PLAN,
       P.NOMBRE_PERFIL,
       PA.ESTADO_PAGO
FROM USUARIOS U
JOIN SUSCRIPCIONES S
  ON S.ID_USUARIO = U.ID_USUARIO
JOIN PERFILES P
  ON P.ID_USUARIO = U.ID_USUARIO
JOIN PAGOS PA
  ON PA.ID_USUARIO = U.ID_USUARIO
WHERE U.EMAIL = 'transaccion.registro@quindioflix.com';


/* ============================================================
   TRANSACCION 2
   RENOVACION MENSUAL CON SAVEPOINT

   Regla:
   Para cada usuario con suscripcion activa:
   - Calcular monto con FN_CALCULAR_MONTO.
   - Registrar pago mensual.
   - Si falla un usuario, hacer ROLLBACK TO SAVEPOINT.
   - Continuar con los demas usuarios.

   Tablas involucradas:
   - USUARIOS
   - SUSCRIPCIONES
   - PLANES_SUSCRIPCION
   - PAGOS

   Nota:
   Se procesan algunos usuarios para evitar generar demasiados pagos
   durante la prueba.
   ============================================================ */

DECLARE
    CURSOR C_USUARIOS_ACTIVOS IS
        SELECT U.ID_USUARIO,
               S.ID_PLAN,
               U.EMAIL
        FROM USUARIOS U
        JOIN SUSCRIPCIONES S
          ON S.ID_USUARIO = U.ID_USUARIO
        WHERE U.ESTADO_CUENTA = 'ACTIVO'
          AND S.ESTADO_SUSCRIPCION = 'ACTIVA'
          AND U.ID_USUARIO BETWEEN 1 AND 10
        ORDER BY U.ID_USUARIO;

    V_ID_PAGO      PAGOS.ID_PAGO%TYPE;
    V_MONTO        NUMBER(10,2);
    V_REFERENCIA   PAGOS.REFERENCIA_PAGO%TYPE;
    V_PROCESADOS   NUMBER := 0;
    V_FALLIDOS     NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transaccion de renovacion mensual...');

    FOR REG IN C_USUARIOS_ACTIVOS LOOP

        SAVEPOINT SP_USUARIO;

        BEGIN
            V_MONTO := FN_CALCULAR_MONTO(REG.ID_USUARIO);

            SELECT NVL(MAX(ID_PAGO), 0) + 1
            INTO V_ID_PAGO
            FROM PAGOS;

            V_REFERENCIA := 'QF-REN-' ||
                            REG.ID_USUARIO || '-' ||
                            TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '-' ||
                            V_ID_PAGO;

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
                REG.ID_USUARIO,
                REG.ID_PLAN,
                SYSTIMESTAMP,
                SYSDATE + 30,
                V_MONTO,
                0,
                V_MONTO,
                'PSE',
                'EXITOSO',
                V_REFERENCIA
            );

            V_PROCESADOS := V_PROCESADOS + 1;

            DBMS_OUTPUT.PUT_LINE(
                'Pago registrado para usuario ' || REG.ID_USUARIO ||
                ' por valor de $' || V_MONTO
            );

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO SP_USUARIO;
                V_FALLIDOS := V_FALLIDOS + 1;

                DBMS_OUTPUT.PUT_LINE(
                    'Fallo renovacion usuario ' || REG.ID_USUARIO ||
                    '. Se revierte solo este usuario. Error: ' || SQLERRM
                );
        END;

    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Renovacion mensual finalizada.');
    DBMS_OUTPUT.PUT_LINE('Usuarios procesados: ' || V_PROCESADOS);
    DBMS_OUTPUT.PUT_LINE('Usuarios fallidos: ' || V_FALLIDOS);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error general. Se revierte toda la renovacion.');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


/* Verificacion de la transaccion 2 */
SELECT ID_USUARIO,
       COUNT(*) AS TOTAL_PAGOS,
       MAX(FECHA_PAGO) AS ULTIMO_PAGO
FROM PAGOS
WHERE ID_USUARIO BETWEEN 1 AND 10
GROUP BY ID_USUARIO
ORDER BY ID_USUARIO;


/* ============================================================
   TRANSACCION 3
   ELIMINACION DE CUENTA

   Regla:
   Eliminar completamente una cuenta y sus dependencias.
   Debe ser todo o nada.

   Orden de eliminacion:
   1. Reportes hechos por perfiles del usuario.
   2. Calificaciones.
   3. Favoritos.
   4. Reproducciones.
   5. Sesiones de streaming.
   6. Perfiles.
   7. Beneficios de referidos.
   8. Referidos donde participa el usuario.
   9. Cambios de plan.
   10. Roles de usuario.
   11. Suscripciones.
   12. Pagos.
   13. Usuario.

   Nota:
   Se usa el usuario creado en la Transaccion 1 para no afectar datos base.
   ============================================================ */

DECLARE
    V_ID_USUARIO USUARIOS.ID_USUARIO%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transaccion de eliminacion de cuenta...');

    SELECT ID_USUARIO
    INTO V_ID_USUARIO
    FROM USUARIOS
    WHERE EMAIL = 'transaccion.registro@quindioflix.com';

    /* Reportes generados por perfiles del usuario */
    DELETE FROM REPORTES_CONTENIDO
    WHERE ID_PERFIL_REPORTA IN (
        SELECT ID_PERFIL
        FROM PERFILES
        WHERE ID_USUARIO = V_ID_USUARIO
    );

    /* Si el usuario aparece como moderador, se desvincula */
    UPDATE REPORTES_CONTENIDO
    SET ID_USUARIO_MODERADOR = NULL
    WHERE ID_USUARIO_MODERADOR = V_ID_USUARIO;

    DELETE FROM CALIFICACIONES
    WHERE ID_PERFIL IN (
        SELECT ID_PERFIL
        FROM PERFILES
        WHERE ID_USUARIO = V_ID_USUARIO
    );

    DELETE FROM FAVORITOS
    WHERE ID_PERFIL IN (
        SELECT ID_PERFIL
        FROM PERFILES
        WHERE ID_USUARIO = V_ID_USUARIO
    );

    DELETE FROM REPRODUCCIONES
    WHERE ID_PERFIL IN (
        SELECT ID_PERFIL
        FROM PERFILES
        WHERE ID_USUARIO = V_ID_USUARIO
    );

    DELETE FROM SESIONES_STREAMING
    WHERE ID_PERFIL IN (
        SELECT ID_PERFIL
        FROM PERFILES
        WHERE ID_USUARIO = V_ID_USUARIO
    );

    DELETE FROM PERFILES
    WHERE ID_USUARIO = V_ID_USUARIO;

    DELETE FROM BENEFICIOS_REFERIDO
    WHERE ID_USUARIO_BENEFICIARIO = V_ID_USUARIO
       OR ID_REFERIDO IN (
            SELECT ID_REFERIDO
            FROM REFERIDOS
            WHERE ID_USUARIO_REFERIDOR = V_ID_USUARIO
               OR ID_USUARIO_REFERIDO = V_ID_USUARIO
       );

    DELETE FROM REFERIDOS
    WHERE ID_USUARIO_REFERIDOR = V_ID_USUARIO
       OR ID_USUARIO_REFERIDO = V_ID_USUARIO;

    DELETE FROM CAMBIOS_PLAN
    WHERE ID_USUARIO = V_ID_USUARIO;

    DELETE FROM USUARIOS_ROLES
    WHERE ID_USUARIO = V_ID_USUARIO;

    DELETE FROM SUSCRIPCIONES
    WHERE ID_USUARIO = V_ID_USUARIO;

    DELETE FROM PAGOS
    WHERE ID_USUARIO = V_ID_USUARIO;

    DELETE FROM USUARIOS
    WHERE ID_USUARIO = V_ID_USUARIO;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cuenta eliminada correctamente. Usuario: ' || V_ID_USUARIO);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('No se encontro el usuario de prueba para eliminar.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en eliminacion. Se ejecuta ROLLBACK.');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


/* Verificacion de la transaccion 3 */
SELECT COUNT(*) AS USUARIO_RESTANTE
FROM USUARIOS
WHERE EMAIL = 'transaccion.registro@quindioflix.com';


/* ============================================================
   ESCENARIO DE CONCURRENCIA
   SELECT FOR UPDATE

   Objetivo:
   Simular dos sesiones que intentan cambiar el plan del mismo
   usuario al mismo tiempo.

   IMPORTANTE:
   Esta parte NO se ejecuta toda en una sola ventana.
   Debes abrir dos conexiones diferentes en SQL Developer:

   - Sesion 1: ejecutar bloque de Sesion 1.
   - Sesion 2: ejecutar bloque de Sesion 2 mientras Sesion 1
     sigue abierta y sin COMMIT.

   Usuario sugerido para la prueba: ID_USUARIO = 2.
   ============================================================ */