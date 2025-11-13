-- SQL/02_CREATE_SILVER_TABLE.sql

-- Cria a tabela SILVER (Limpa e Padronizada) usando o formato DELTA
CREATE OR REPLACE TABLE vendas_silver
USING DELTA
AS
SELECT
    -- Chaves e Identificadores
    `Row ID` AS row_id,
    `Order ID` AS order_id,
    `Customer ID` AS customer_id,
    `Product ID` AS product_id,

    -- Conversão e Padronização de Datas
    -- Assume que as datas estão no formato MM/DD/YYYY ou YYYY-MM-DD. 
    -- Se precisar de dmy como no R, use to_date(..., 'dd/MM/yyyy')
    TO_DATE(`Order Date`) AS order_date,
    TO_DATE(`Ship Date`) AS ship_date,

    -- Detalhes de Envio e Cliente
    `Ship Mode` AS ship_mode,
    `Customer Name` AS customer_name,
    `Segment` AS segment,
    `Country` AS country,
    `City` AS city,
    `State` AS state,
    `Region` AS region,
    
    -- Detalhes do Produto
    `Category` AS category,
    `Sub-Category` AS sub_category,
    `Product Name` AS product_name,

    -- Métricas (Números)
    `Sales` AS sales,
    -- Opcional: Se a coluna Profit for encontrada (como 'Profit' ou 'P'), inclua aqui:
    -- 'Profit' AS profit 
    CAST(REPLACE(`Postal Code`, ',', '') AS INT) AS postal_code -- Trata o código postal como inteiro, limpando vírgulas se houver
FROM
    vendas_raw
WHERE
    `Sales` IS NOT NULL -- Remove linhas onde a métrica principal está faltando
    AND `Order Date` IS NOT NULL; -- Garante que apenas pedidos válidos sejam considerados

-- 3. Visualiza a nova tabela Silver
SELECT * FROM vendas_silver LIMIT 10;