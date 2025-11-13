-- SQL/04_CREATE_GOLD_CATEGORIAS.sql

-- 1. Cria a tabela GOLD agregada por Categoria e Região
CREATE OR REPLACE TABLE vendas_gold_categorias
USING DELTA
AS
SELECT
    -- Agrupadores
    category,
    `sub_category`,
    region,

    -- Métricas Agregadas
    SUM(sales) AS vendas_totais_categoria,
    COUNT(DISTINCT order_id) AS total_pedidos_categoria
FROM
    vendas_silver
GROUP BY
    category,
    `sub_category`,
    region;

-- 2. Visualiza as vendas totais agrupadas por Categoria (para validação)
SELECT 
    category,
    SUM(vendas_totais_categoria) AS vendas_por_categoria
FROM 
    vendas_gold_categorias
GROUP BY 
    category
ORDER BY 
    vendas_por_categoria DESC;