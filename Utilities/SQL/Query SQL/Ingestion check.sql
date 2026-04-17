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

-------------------------------------------------------------------
WITH base AS (
  SELECT
    to_date(ingestion_timestamp) AS data,
    'Launches' AS File_Caricato
  FROM
    esercizio_spacex.bronze.bronze_launches
  UNION ALL
  SELECT
    to_date(ingestion_timestamp),
    'Launchpads'
  FROM
    esercizio_spacex.bronze.bronze_launchpads
  UNION ALL
  SELECT
    to_date(ingestion_timestamp),
    'Payloads'
  FROM
    esercizio_spacex.bronze.bronze_payloads
  UNION ALL
  SELECT
    to_date(ingestion_timestamp),
    'Rockets'
  FROM
    esercizio_spacex.bronze.bronze_rockets
),
z AS (
  SELECT
    x.Data_Caricamento,
    COUNT(x.raw_payload) AS File_Json,
    CASE
      WHEN COUNT(x.raw_payload) >= 4 THEN 'OK'
      ELSE 'KO'
    END AS Esito
  FROM
    (
      SELECT
        to_date(ingestion_timestamp) AS Data_Caricamento,
        raw_payload
      FROM
        esercizio_spacex.bronze.bronze_launches
      UNION ALL
      SELECT
        to_date(ingestion_timestamp),
        raw_payload
      FROM
        esercizio_spacex.bronze.bronze_launchpads
      UNION ALL
      SELECT
        to_date(ingestion_timestamp),
        raw_payload
      FROM
        esercizio_spacex.bronze.bronze_payloads
      UNION ALL
      SELECT
        to_date(ingestion_timestamp),
        raw_payload
      FROM
        esercizio_spacex.bronze.bronze_rockets
    ) x
  GROUP BY
    x.Data_Caricamento
)
SELECT
  z.Data_Caricamento,
  z.File_Json,
  z.Esito,
  concat_ws(',', sort_array(collect_set(y.File_Caricato))) AS concatenati
FROM
  z
    INNER JOIN base y
      ON y.data = z.Data_Caricamento
GROUP BY
  z.Data_Caricamento,
  z.File_Json,
  z.Esito
ORDER BY
  z.Data_Caricamento;