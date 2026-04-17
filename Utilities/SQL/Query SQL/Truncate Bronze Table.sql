truncate table esercizio_spacex.bronze.bronze_rockets;
truncate table esercizio_spacex.bronze.bronze_launches;
truncate table esercizio_spacex.bronze.bronze_launchpads;
truncate table esercizio_spacex.bronze.bronze_payloads;
truncate table esercizio_spacex.bronze.bronze_ingestion_logs;


select distinct(raw_payload) from esercizio_spacex.bronze.bronze_launches;