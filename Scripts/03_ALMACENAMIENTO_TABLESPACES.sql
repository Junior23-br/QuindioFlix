SELECT file_name 
FROM dba_data_files;

/* ============================================================
   PROYECTO QUINDIOFLIX
   SCRIPT 02 - ESQUEMA DE ALMACENAMIENTO, TABLESPACES Y DATAFILES
   Autor: Grupo QuindioFlix


   IMPORTANTE:
   1. Ejecutar este script conectado como SYSTEM o un usuario DBA.
   2. Ejecutarlo ANTES del script de creación de tablas si se va a crear
      la base desde cero.
   3.  RUTA_DATAFILES almacena sus archivos .DBF.
      Para verla, ejecutar:
          SELECT file_name FROM dba_data_files;
   ============================================================ */

SET DEFINE ON;

-- Cambiar esta ruta según el entorno.


DEFINE RUTA_DATAFILES = 'C:\APP\DAVID\PRODUCT\21C\ORADATA\XE';

PROMPT ============================================================
PROMPT Creando tablespaces de QuindioFlix
PROMPT ============================================================

CREATE TABLESPACE TS_QF_USUARIOS
DATAFILE '&RUTA_DATAFILES\ts_qf_usuarios01.dbf'
SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 300M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_SUSCRIPCIONES
DATAFILE '&RUTA_DATAFILES\ts_qf_suscripciones01.dbf'
SIZE 40M
AUTOEXTEND ON NEXT 10M MAXSIZE 250M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_PAGOS
DATAFILE '&RUTA_DATAFILES\ts_qf_pagos01.dbf'
SIZE 60M
AUTOEXTEND ON NEXT 10M MAXSIZE 400M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_ORGANIZACION
DATAFILE '&RUTA_DATAFILES\ts_qf_organizacion01.dbf'
SIZE 30M
AUTOEXTEND ON NEXT 10M MAXSIZE 200M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_CATALOGO
DATAFILE '&RUTA_DATAFILES\ts_qf_catalogo01.dbf'
SIZE 80M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_INTERACCION
DATAFILE '&RUTA_DATAFILES\ts_qf_interaccion01.dbf'
SIZE 60M
AUTOEXTEND ON NEXT 10M MAXSIZE 400M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_REP_2024
DATAFILE '&RUTA_DATAFILES\ts_qf_rep_2024_01.dbf'
SIZE 80M
AUTOEXTEND ON NEXT 20M MAXSIZE 600M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_REP_2025
DATAFILE '&RUTA_DATAFILES\ts_qf_rep_2025_01.dbf'
SIZE 80M
AUTOEXTEND ON NEXT 20M MAXSIZE 600M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_REP_2026
DATAFILE '&RUTA_DATAFILES/ts_qf_rep_2026_01.dbf'
SIZE 80M
AUTOEXTEND ON NEXT 20M MAXSIZE 600M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_REP_FUTURO
DATAFILE '&RUTA_DATAFILES\ts_qf_rep_futuro_01.dbf'
SIZE 80M
AUTOEXTEND ON NEXT 20M MAXSIZE 600M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TS_QF_INDICES
DATAFILE '&RUTA_DATAFILES\ts_qf_indices01.dbf'
SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 300M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ============================================================
PROMPT Verificación de tablespaces creados
PROMPT ============================================================

SELECT
    tablespace_name,
    status,
    contents,
    extent_management,
    segment_space_management
FROM dba_tablespaces
WHERE tablespace_name LIKE 'TS_QF_%'
ORDER BY tablespace_name;

PROMPT ============================================================
PROMPT Verificación de datafiles creados
PROMPT ============================================================

SELECT
    tablespace_name,
    file_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb,
    autoextensible,
    ROUND(maxbytes / 1024 / 1024, 2) AS max_size_mb
FROM dba_data_files
WHERE tablespace_name LIKE 'TS_QF_%'
ORDER BY tablespace_name, file_name;

/* ============================================================
   NOTA PARA EL SCRIPT 01 - MODELO FÍSICO

   Después de crear estos tablespaces, en el script QUINDIOFLIX.sql
   se debe agregar TABLESPACE al final de cada CREATE TABLE.

   Ejemplo:
      CREATE TABLE CIUDADES (
          ...
      ) TABLESPACE TS_QF_USUARIOS;

   Para la tabla REPRODUCCIONES, no basta con TABLESPACE simple:
   se debe reemplazar por la versión particionada por rango de fechas.
   Ver el archivo: 02B_reproducciones_particionada.sql
   ============================================================ */

COMMIT;
