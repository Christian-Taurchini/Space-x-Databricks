WITH parsed AS (
SELECT
    explode(
        from_json(
            raw_payload,
            'ARRAY<STRUCT<
                auto_update: BOOLEAN,
                capsules: ARRAY<STRING>,
                cores: ARRAY<STRUCT<
                    core: STRING,
                    flight: BIGINT,
                    gridfins: BOOLEAN,
                    landing_attempt: BOOLEAN,
                    landing_success: BOOLEAN,
                    landing_type: STRING,
                    landpad: STRING,
                    legs: BOOLEAN,
                    reused: BOOLEAN
                >>,
                crew: ARRAY<STRING>,
                date_local: STRING,
                date_precision: STRING,
                date_unix: BIGINT,
                date_utc: STRING,
                details: STRING,
                failures: ARRAY<STRUCT<
                    altitude: BIGINT,
                    reason: STRING,
                    time: BIGINT
                >>,
                fairings: STRUCT<
                    recovered: BOOLEAN,
                    recovery_attempt: BOOLEAN,
                    reused: BOOLEAN,
                    ships: ARRAY<STRING>
                >,
                flight_number: BIGINT,
                id: STRING,
                launch_library_id: STRING,
                launchpad: STRING,
                links: STRUCT<
                    article: STRING,
                    flickr: STRUCT<
                        original: ARRAY<STRING>,
                        small: ARRAY<STRING>
                    >,
                    patch: STRUCT<
                        large: STRING,
                        small: STRING
                    >,
                    presskit: STRING,
                    reddit: STRUCT<
                        campaign: STRING,
                        launch: STRING,
                        media: STRING,
                        recovery: STRING
                    >,
                    webcast: STRING,
                    wikipedia: STRING,
                    youtube_id: STRING
                >,
                name: STRING,
                net: BOOLEAN,
                payloads: ARRAY<STRING>,
                rocket: STRING,
                ships: ARRAY<STRING>,
                static_fire_date_unix: BIGINT,
                static_fire_date_utc: STRING,
                success: BOOLEAN,
                tbd: BOOLEAN,
                upcoming: BOOLEAN,
                window: BIGINT
            >>'
        )
    ) AS launch
FROM esercizio_spacex.bronze.bronze_launches
)
SELECT DISTINCT
    launch.id,
    launch.flight_number,
    launch.name,
    launch.date_utc,
    launch.success,
    launch.rocket,
    launch.details,
    launch.launchpad,
    -- fairings
    launch.fairings.reused        AS fairings_reused,
    launch.fairings.recovered     AS fairings_recovered,
    -- links
    launch.links.patch.small      AS patch_small,
    launch.links.patch.large      AS patch_large,
    launch.links.webcast          AS webcast,
    launch.links.article          AS article,
    launch.links.wikipedia        AS wikipedia,
    -- cores
    core.core                     AS core_id,
    core.flight                   AS core_flight,
    core.reused                   AS core_reused,
    core.landing_attempt          AS landing_attempt,
    core.landing_success          AS landing_success,
    -- failures
    failure.reason                AS failure_reason,
    failure.time                  AS failure_time,
    failure.altitude              AS failure_altitude,
    -- payload
    payload
FROM parsed
LATERAL VIEW OUTER explode(launch.cores) c AS core
LATERAL VIEW OUTER explode(launch.failures) f AS failure
LATERAL VIEW OUTER explode(launch.payloads) p AS payload;