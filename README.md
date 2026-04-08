# Progetto Data Engineering – SpaceX

Documentazione del progetto di Data Engineering per la raccolta, trasformazione e analisi dei dati SpaceX.

---

## 1️⃣ Data Ingestion (Raw Layer)

**Obiettivo:** Recuperare dati dagli endpoint API SpaceX e salvarli in JSON in storage strutturato.

### Endpoint API

| Dataset    | Endpoint API                                                                         |
| ---------- | ------------------------------------------------------------------------------------ |
| Launches   | [https://api.spacexdata.com/v4/launches](https://api.spacexdata.com/v4/launches)     |
| Rockets    | [https://api.spacexdata.com/v4/rockets](https://api.spacexdata.com/v4/rockets)       |
| Launchpads | [https://api.spacexdata.com/v4/launchpads](https://api.spacexdata.com/v4/launchpads) |
| Payloads   | [https://api.spacexdata.com/v4/payloads](https://api.spacexdata.com/v4/payloads)     |

### Storage Raw (Data Lake)

```
/data_lake/spacex/raw/
├── launches/2026-04-08/launches.json
├── rockets/2026-04-08/rockets.json
├── launchpads/2026-04-08/launchpads.json
└── payloads/2026-04-08/payloads.json
```

### Regole

* Salvare con timestamp di ingestion.
* Gestione `null`/empty: salvare così come arrivano dall’API.
* Conservare struttura JSON originale.

---

## 2️⃣ Bronze Layer (Raw Tables)

**Obiettivo:** Creare tabelle Delta con JSON raw, aggiungendo timestamp di ingestione.

### Tabelle Bronze

| Tabella           | Colonne                          |
| ----------------- | -------------------------------- |
| bronze_launches   | ingestion_timestamp, raw_payload |
| bronze_rockets    | ingestion_timestamp, raw_payload |
| bronze_launchpads | ingestion_timestamp, raw_payload |
| bronze_payloads   | ingestion_timestamp, raw_payload |

### Regole

* Nessuna trasformazione.
* Conservare JSON originale.
* Aggiungere timestamp di ingestion.

---

## 3️⃣ Silver Layer (Data Cleaning & Structuring)

**Obiettivo:** Pulizia e strutturazione dati per analisi.

### Regole Generali

* `null`/empty → NULL.
* Timestamp → convertire in tipo `timestamp` Spark.
* Rimuovere duplicati → `dropDuplicates()`.
* Flatten JSON annidati.

### Tabelle Silver

| Tabella           | Colonne principali                                         |
| ----------------- | ---------------------------------------------------------- |
| silver_launches   | launch_id, rocket_id, launchpad_id, launch_date, success   |
| silver_rockets    | rocket_id, rocket_name, rocket_type, first_flight, country |
| silver_launchpads | launchpad_id, launchpad_name, region, latitude, longitude  |
| silver_payloads   | payload_id, payload_type, orbit, mass_kg                   |

---

## 4️⃣ Gold Layer (Aggregazioni Analitiche)

**Obiettivo:** Creare aggregazioni per analisi e dashboard.

### Tabelle Gold

| Analisi               | Colonne principali                                      | Note                              |
| --------------------- | ------------------------------------------------------- | --------------------------------- |
| Mission Success Rate  | year, total_launches, successful_launches, success_rate | NULL nei campi chiave → escludere |
| Launches by Rocket    | rocket_name, total_launches                             | —                                 |
| Launchpad Utilization | launchpad_name, total_launches                          | —                                 |
| Payload Analysis      | orbit, total_payloads, avg_mass_kg                      | Media esclude valori null         |

---

## 5️⃣ Pipeline Orchestration su Databricks

**Workflow consigliato:**

1. **Job 1 – API Ingestion:** Python notebook → salva JSON in `/raw`.
2. **Job 2 – Bronze ingestion:** PySpark notebook → salva Delta Bronze.
3. **Job 3 – Silver transformations:** PySpark notebook → salva Delta Silver.
4. **Job 4 – Gold aggregations:** PySpark notebook → salva Delta Gold.
5. **Scheduler:** Databricks Jobs → schedulabile giornalmente.
6. **Monitoring:** log ingestion, conteggio record, alert su fallimenti.

---

## 6️⃣ Diagramma Flusso Dati (ASCII Avanzato)

```
       +---------------------+
       |     Raw JSON        |
       |  (API SpaceX)       |
       +----------+----------+
                  |
                  ▼
       +---------------------+
       |   Bronze Layer      |
       |  (Delta Tables)     |
       +----------+----------+
                  |
                  ▼
       +---------------------+
       |   Silver Layer      |
       | (Clean & Flatten)   |
       +----------+----------+
                  |
                  ▼
       +---------------------+
       |    Gold Layer       |
       |  (Aggregazioni)     |
       +----------+----------+
                  |
                  ▼
       +---------------------+
       |  Dashboard / Analisi|
       +---------------------+

Legenda:
- Raw: dati JSON originali dall'API
- Bronze: tabelle Delta con JSON raw + timestamp
- Silver: dati puliti e flattenati
- Gold: aggregazioni analitiche pronte per dashboard
```

---

## 7️⃣ Dashboard PowerBI

| Dashboard          | Metriche principali                    | Grafici suggeriti            |
| ------------------ | -------------------------------------- | ---------------------------- |
| Launch Success     | success rate per anno, numero di lanci | line chart, KPI cards        |
| Rocket Utilization | numero di missioni per razzo           | bar chart, ranking table     |
| Launchpad Analysis | basi più utilizzate, mappa geografica  | map visualization, bar chart |
| Payload Analysis   | numero payload per orbita, massa media | bar chart, KPI cards         |

