{{ config(
    materialized = 'table',
    cluster_by = ['symbol']
) }}

SELECT
    symbol,
    price,
    tradeTime
FROM
    {{ ref('raw_coinbase_data') }}
WHERE
    tradeTime >= current_timestamp() - INTERVAL '25 HOURS'
