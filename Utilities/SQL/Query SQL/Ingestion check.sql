select
  x.Data_Caricamento,
  count(x.raw_payload) as File_Json,
  CASE
    WHEN count(x.raw_payload) == 4 THEN 'OK'
    ELSE 'KO'
  END as Esito
from
  (
    select
      to_date(ingestion_timestamp) as Data_Caricamento,
      raw_payload
    from
      esercizio_spacex.bronze.bronze_launches
    union all
    select
      to_date(ingestion_timestamp) as Data_Caricamento,
      raw_payload
    from
      esercizio_spacex.bronze.bronze_launchpads
    union all
    select
      to_date(ingestion_timestamp) as Data_Caricamento,
      raw_payload
    from
      esercizio_spacex.bronze.bronze_payloads
    union all
    select
      to_date(ingestion_timestamp) as Data_Caricamento,
      raw_payload
    from
      esercizio_spacex.bronze.bronze_rockets
  ) x
where
  x.data_caricamento not in (
    select
      data_caricamento
    from
      esercizio_spacex.bronze.bronze_ingestion_logs
  )
group by
  x.Data_Caricamento
order by
  x.Data_Caricamento desc;