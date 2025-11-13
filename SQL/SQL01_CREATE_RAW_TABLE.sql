-- SQL/01_CREATE_RAW_TABLE.sql

-- 1. Cria a tabela RAW (Bruta) no Databricks/Delta Lake
CREATE TABLE IF NOT EXISTS vendas_raw
USING CSV
OPTIONS (
    'header' 'true',
    'inferSchema' 'true',
    'delimiter' ','
)
LOCATION '/FileStore/tables/train.csv'; 

-- 2. Visualiza as primeiras 100 linhas da tabela bruta
SELECT * FROM vendas_raw LIMIT 100;