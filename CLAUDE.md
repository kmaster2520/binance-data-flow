# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

End-to-end crypto trade data pipeline:
1. **EC2** runs `instance/websocket_script_coinbase_v2.py`, which connects to the Coinbase Advanced Trade WebSocket and pushes raw trade records into **Kinesis** (`raw-trade-data` stream).
2. **Kinesis Firehose** (`KDS-S3-trade-data`) invokes `lambda/lambda_function.py` to transform each record before delivering JSON to **S3** (`s3://greatestbucketever/coinbase/raw/`).
3. **dbt** (Databricks) reads from S3 and builds medallion-layer tables.

## AWS Infrastructure

Infrastructure is managed in two ways — legacy CloudFormation scripts and new CDK:

- `iam/` — IAM role for the EC2 instance (Kinesis PutRecord + S3 GetObject)
- `instance/websocket_instance_cft.yaml` — CloudFormation for the EC2 instance (t4g.nano, private subnet)
- `endpoints/btc-websocket-endpoints.yaml` — VPC endpoints / security groups
- `cdk/` — CDK (Python) for the Firehose transform Lambda

### CDK deploy
```bash
cd cdk
pip install -r requirements.txt
cdk bootstrap aws://391262527903/us-east-1   # first time only
cdk diff
cdk deploy
```

## dbt (Databricks)

Profile: `coinbase_data_flow` (configured in `~/.dbt/profiles.yml`, targets Databricks).

```bash
cd coinbase_data_flow
dbt run                        # run all models
dbt run --select <model_name>  # run a single model
dbt test                       # run schema tests
dbt test --select <model_name> # test a single model
```

### Medallion layers

| Layer  | Materialization    | Description |
|--------|--------------------|-------------|
| Bronze | `streaming_table` (Delta, liquid-clustered on `tradeTime`+`symbol`) | Streams JSON from S3, retains 90 days, deduplicated at query time |
| Silver | `incremental` (merge on `tradeId` or insert_overwrite) | Deduplicates trades; `trades_timeseries` is the canonical deduplicated table; `recent_coinbase_data_1d` covers the last 25 hours |
| Gold   | `table` | Per-minute OHLCV-style aggregates per symbol (BTC, ETH), last 7 days |

Silver `trades_timeseries` has a hardcoded start date filter (`tradeTime >= '2026-03-17'`) — update this when backfilling or extending the window.

## Lambda

`lambda/lambda_function.py` is a **Kinesis Firehose data transform**. It receives base64-encoded records, decodes them, filters for `channel == "market_trades"`, reshapes the fields, and re-encodes. It has no external dependencies (stdlib only). Test it locally by running `python lambda/lambda_function.py` — the `__main__` block uses the bundled `EXAMPLE_EVENT`.

## Python environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

`requirements.txt` is pinned and includes dbt-databricks, aws-cdk-lib, boto3, and websockets.
