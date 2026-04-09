-- Bronze launches senza location
CREATE TABLE IF NOT EXISTS esercizio_spacex.bronze.bronze_launches (
    ingestion_timestamp TIMESTAMP,
    raw_payload STRING
)
USING DELTA;

-- Bronze rockets
CREATE TABLE IF NOT EXISTS esercizio_spacex.bronze.bronze_rockets (
    ingestion_timestamp TIMESTAMP,
    raw_payload STRING
)
USING DELTA;

-- Bronze launchpads
CREATE TABLE IF NOT EXISTS esercizio_spacex.bronze.bronze_launchpads (
    ingestion_timestamp TIMESTAMP,
    raw_payload STRING
)
USING DELTA;

-- Bronze payloads
CREATE TABLE IF NOT EXISTS esercizio_spacex.bronze.bronze_payloads (
    ingestion_timestamp TIMESTAMP,
    raw_payload STRING
)
USING DELTA;

-- Bronze ingestion_logs
CREATE OR REPLACE TABLE esercizio_spacex.bronze.bronze_ingestion_logs (
    Data_Caricamento DATE,
    File_Json INT,
    Esito STRING
)
USING DELTA;