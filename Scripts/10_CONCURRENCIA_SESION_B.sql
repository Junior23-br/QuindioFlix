/* ============================================================
   CONCURRENCIA - SESION 2
   Esta sesion intenta bloquear la misma suscripcion del usuario 2.
   Debe quedar esperando hasta que la Sesion 1 haga COMMIT o ROLLBACK.
   ============================================================ */

SET SERVEROUTPUT ON;

DECLARE
    V_ID_SUSCRIPCION SUSCRIPCIONES.ID_SUSCRIPCION%TYPE;
    V_ID_PLAN        SUSCRIPCIONES.ID_PLAN%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('SESION 2: intentando bloquear la misma fila...');

    SELECT ID_SUSCRIPCION,
           ID_PLAN
    INTO V_ID_SUSCRIPCION,
         V_ID_PLAN
    FROM SUSCRIPCIONES
    WHERE ID_USUARIO = 2
      AND ESTADO_SUSCRIPCION = 'ACTIVA'
    FOR UPDATE;

    DBMS_OUTPUT.PUT_LINE('SESION 2: bloqueo obtenido despues de liberacion de Sesion 1.');
    DBMS_OUTPUT.PUT_LINE('ID_SUSCRIPCION: ' || V_ID_SUSCRIPCION);
    DBMS_OUTPUT.PUT_LINE('PLAN ACTUAL: ' || V_ID_PLAN);
END;
/