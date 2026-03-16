{{ config(materialized='view') }}

SELECT
    timestamp,
    CAST(price AS DECIMAL(18, 8)),
    lambdaRequestId
FROM
    {{ ref('raw_binance_data') }}
WHERE
    timestamp >= current_timestamp() - INTERVAL 1 HOUR
