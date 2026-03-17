{{ config(materialized='view') }}

SELECT
    symbol,
    COUNT(*) as total
FROM
    {{ ref('raw_coinbase_data') }}
WHERE
    tradeTime >= current_timestamp() - INTERVAL 1 HOUR
GROUP BY
    symbol
