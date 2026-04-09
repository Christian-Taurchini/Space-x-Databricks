---
Documentazione Progetto Data Engineering -- SpaceX
---

1️⃣ Data Ingestion (Raw Layer)

Obiettivo: recuperare dati dagli endpoint API SpaceX e salvarli in JSON
in storage strutturato.

Endpoint API:

\- Launches: https://api.spacexdata.com/v4/launches

\- Rockets: https://api.spacexdata.com/v4/rockets

\- Launchpads: https://api.spacexdata.com/v4/launchpads

\- Payloads: https://api.spacexdata.com/v4/payloads

Storage Raw (Data Lake):

/data_lake/spacex/raw/

├── launches/2026-04-08/launches.json

├── rockets/2026-04-08/rockets.json

├── launchpads/2026-04-08/launchpads.json

└── payloads/2026-04-08/payloads.json

Regole:

\- Salvare con timestamp di ingestion

\- Gestione null/empty: salvare così come arrivano dall'API

\- Conservare struttura JSON originale

2️⃣ Bronze Layer (Raw Tables)

Tabelle Bronze:

bronze_launches: ingestion_timestamp (timestamp), raw_payload (string)

bronze_rockets: ingestion_timestamp (timestamp), raw_payload (string)

bronze_launchpads: ingestion_timestamp (timestamp), raw_payload (string)

bronze_payloads: ingestion_timestamp (timestamp), raw_payload (string)

Regole: Nessuna trasformazione, conservare JSON originale, aggiungere
timestamp

3️⃣ Silver Layer (Data Cleaning & Structuring)

Regole Generali:

\- Null/empty → NULL

\- Timestamp → convertire in timestamp Spark

\- Duplicate → dropDuplicates()

\- Flatten JSON nested

Silver Launches: launch_id, rocket_id, launchpad_id, launch_date,
success

Silver Rockets: rocket_id, rocket_name, rocket_type, first_flight,
country

Silver Launchpads: launchpad_id, launchpad_name, region, latitude,
longitude

Silver Payloads: payload_id, payload_type, orbit, mass_kg

4️⃣ Gold Layer (Aggregazioni Analitiche)

Gold 1 -- Mission Success Rate: year, total_launches,
successful_launches, success_rate

Gold 2 -- Launches by Rocket: rocket_name, total_launches

Gold 3 -- Launchpad Utilization: launchpad_name, total_launches

Gold 4 -- Payload Analysis: orbit, total_payloads, avg_mass_kg

Regole Gold:

\- NULL nei campi chiave → escludere dall'aggregazione

\- Calcoli media → escludere valori null

5️⃣ Pipeline Orchestration su Databricks

Workflow consigliato:

1\. Job 1 -- API ingestion: Python notebook → salva JSON in /raw

2\. Job 2 -- Bronze ingestion: PySpark notebook → salva Delta Bronze

3\. Job 3 -- Silver transformations: PySpark notebook → salva Delta
Silver

4\. Job 4 -- Gold aggregations: PySpark notebook → salva Delta Gold

5\. Scheduler: Databricks Jobs → schedulabile (giornaliero)

6\. Monitoring: log ingestion, conteggio record, alert su fallimenti

6️⃣ Dashboard PowerBI

Dashboard \| Metriche \| Grafici suggeriti

Launch Success \| success rate per anno, numero di lanci annuali \| line
chart, KPI cards

Rocket Utilization \| numero di missioni per razzo \| bar chart, ranking
table

Launchpad Analysis \| basi più utilizzate, mappa geografica \| map
visualization, bar chart

Payload Analysis \| numero payload per orbita, massa media \| bar chart,
KPI cards

Esempi codice PySpark: Ingestione JSON, Trasformazioni Silver,
Aggregazioni Gold
