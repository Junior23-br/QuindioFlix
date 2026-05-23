/* ============================================================
   CONCURRENCIA - SESION 1
   Esta sesion bloquea la suscripcion activa del usuario 2.
   No hacer COMMIT inmediatamente.
   ============================================================ */

SET SERVEROUTPUT ON;

DECLARE
    V_ID_SUSCRIPCION SUSCRIPCIONES.ID_SUSCRIPCION%TYPE;
    V_ID_PLAN        SUSCRIPCIONES.ID_PLAN%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('SESION 1: intentando bloquear la suscripcion del usuario 2...');

    SELECT ID_SUSCRIPCION,
           ID_PLAN
    INTO V_ID_SUSCRIPCION,
         V_ID_PLAN
    FROM SUSCRIPCIONES
    WHERE ID_USUARIO = 2
      AND ESTADO_SUSCRIPCION = 'ACTIVA'
    FOR UPDATE;

    DBMS_OUTPUT.PUT_LINE('SESION 1: fila bloqueada.');
    DBMS_OUTPUT.PUT_LINE('ID_SUSCRIPCION: ' || V_ID_SUSCRIPCION);
    DBMS_OUTPUT.PUT_LINE('PLAN ACTUAL: ' || V_ID_PLAN);
    DBMS_OUTPUT.PUT_LINE('Mantener esta sesion sin COMMIT para probar bloqueo.');
END;
/


--Luego de ejecutar la sesión 2

COMMIT;