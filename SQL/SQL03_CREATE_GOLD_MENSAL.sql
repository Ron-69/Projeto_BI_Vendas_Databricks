-- SQL/03_CREATE_GOLD_MENSAL.sql

-- 1. Cria a tabela GOLD de Série Temporal, pronta para BI
CREATE OR REPLACE TABLE vendas_gold_mensal
USING DELTA
AS
SELECT
    -- Cria a coluna de Mês/Ano (início do mês), replicando o floor_date do R
    DATE_TRUNC('MONTH', order_date) AS mes_ano,
    
    -- Agrega as Vendas
    SUM(sales) AS vendas_totais,
    
    -- Conta o número de pedidos únicos no mês
    COUNT(DISTINCT order_id) AS total_pedidos
FROM
    vendas_silver
GROUP BY
    1 -- Agrupa pela primeira coluna selecionada (mes_ano)
ORDER BY
    mes_ano;

-- 2. Visualiza a tabela Gold de Série Temporal
SELECT * FROM vendas_gold_mensal ORDER BY mes_ano LIMIT 10;