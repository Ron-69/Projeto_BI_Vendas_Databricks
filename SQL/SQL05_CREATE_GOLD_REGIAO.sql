-- SQL/05_CREATE_GOLD_REGIAO.sql

-- 1. Cria a tabela GOLD agregada apenas por Região
CREATE OR REPLACE TABLE vendas_gold_regiao
USING DELTA
AS
SELECT
    region,
    -- Soma as vendas já calculadas na tabela anterior para obter o total da Região
    SUM(vendas_totais_categoria) AS vendas_totais_regiao,
    SUM(total_pedidos_categoria) AS total_pedidos_regiao
FROM
    vendas_gold_categorias
GROUP BY
    region
ORDER BY
    vendas_totais_regiao DESC;

-- 2. Visualiza a tabela Gold de Região
SELECT * FROM vendas_gold_regiao;