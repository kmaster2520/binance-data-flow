{{ config(materialized='table') }}


SELECT
    date_trunc('minute', tradeTime) as tradeMinute,
    AVG(price) as avgPrice,
    SUM(quantity) as totalQuantity,
    COUNT(CASE WHEN side = 'BUY' THEN 1 END) as numBuys,
    COUNT(CASE WHEN side = 'SELL' THEN 1 END) as numSells
FROM
    {{ ref('eth_timeseries') }}
WHERE
    tradeTime >= current_timestamp() - INTERVAL 7 DAY
GROUP BY
    tradeMinute
