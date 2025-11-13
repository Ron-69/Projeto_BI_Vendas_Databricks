# 📈 Projeto de Business Intelligence: Pipeline de Vendas com Databricks e R

## 1. Visão Geral do Projeto

Este projeto demonstra um pipeline de **Business Intelligence (BI)** ponta a ponta, começando com dados brutos (`.csv`) e terminando em visualizações prontas para decisão (`ggplot2` no R). O objetivo principal foi migrar a fase de **Transformação e Agregação de Dados** de um ambiente de *scripting* local (R) para uma arquitetura escalável na nuvem, utilizando **Databricks SQL (Delta Lake)**.

### 🛠️ Tecnologias Utilizadas

| Categoria | Ferramenta | Uso |
| :--- | :--- | :--- |
| **Data Lakehouse** | **Databricks (Spark SQL)** | ETL, Modelagem (Raw, Silver, Gold), Armazenamento Delta Lake. |
| **Análise/Visualização** | **RStudio (Tidyverse, ggplot2)** | Conexão ODBC, Análise Estatística, Geração de Gráficos de BI. |
| **Versionamento** | **Git / GitHub** | Controle de Versão e Exposição do Portfólio. |
| **Conexão** | **ODBC** | Ponte de comunicação entre RStudio e Databricks SQL Warehouse. |

## 2. Arquitetura do Pipeline de Dados (Medalhões)

A modelagem de dados no Databricks seguiu a arquitetura de **Medalhões (Medallion Architecture)**, garantindo a qualidade e governança dos dados antes da análise. 

---

### 🟢 Camada RAW (Bruta) - `vendas_raw`

* **Fonte:** Ingestão direta do arquivo `train.csv`.
* **Formato:** String (CSV).
* **Objetivo:** Preservar a imutabilidade dos dados originais.

### ⚪ Camada SILVER (Limpa e Padronizada) - `vendas_silver`

* **Processo:** Aplicação de limpeza básica e padronização.
* **Ações:**
    * Conversão de datas (ex: `Order Date` -> `order_date`, formato YYYY-MM-DD).
    * Padronização de nomes de colunas para `snake_case`.
    * Remoção de valores nulos críticos (`Sales` IS NOT NULL).

### 🟡 Camada GOLD (Agregada para BI)

Esta camada contém as tabelas agregadas e otimizadas para consumo direto por ferramentas de BI (RStudio). O RStudio se conecta a estas três tabelas para gerar os gráficos finais:

1.  **`vendas_gold_mensal`**: Agregação de `Sales` por Mês/Ano (Série Temporal).
2.  **`vendas_gold_categorias`**: Agregação de `Sales` por Categoria e Sub-Categoria.
3.  **`vendas_gold_regiao`**: Agregação de `Sales` por Região.

---

## 3. 🎯 Conclusões e Insights de Negócio

A análise final dos dados agregados na camada GOLD (`vendas_gold_...`) resultou nos seguintes *insights* estratégicos:

### A. Performance de Vendas por Categoria

A categoria **Tecnologia** é a principal geradora de receita, enquanto a categoria Material de Escritório tem a menor contribuição total.

| Categoria | Vendas Totais (R$) | Rank |
| :--- | :--- | :--- |
| **Technology (Tecnologia)** | **827.455,87** | 1º |
| Furniture (Móveis) | 728.658,58 | 2º |
| Office Supplies (Material de Escritório) | 705.422,33 | 3º |

### B. Desempenho Geográfico por Região

As regiões Costa Oeste (West) e Leste (East) dominam o mercado em volume de vendas. A região **South** (Sul) é a área de menor performance.

| Região | Vendas Totais (R$) | Pedidos Totais |
| :--- | :--- | :--- |
| **West (Oeste)** | **710.219,68** | 2.879 |
| East (Leste) | 669.518,73 | 2.551 |
| Central | 492.646,91 | 2.096 |
| South (Sul) | 389.151,46 | 1.460 |

**Recomendação de Negócio:** A Região Sul representa o maior potencial inexplorado ou uma área que requer otimização imediata de recursos e campanhas de vendas.

---

## 4. 🔗 Como Rodar o Projeto

### Pré-requisitos

1.  Um ambiente **Databricks** (Community Edition ou superior) com um SQL Warehouse ativo.
2.  **RStudio** instalado.
3.  **Driver ODBC Databricks/Simba Spark** instalado na máquina.
4.  Um **Personal Access Token (PAT)** válido do Databricks.

### Execução

1.  **Databricks:** Execute os scripts SQL (`SQL/01_RAW.sql` a `SQL/05_GOLD.sql`) para criar e popular as tabelas na arquitetura Medalhão.
2.  **RStudio:**
    * Abra o projeto.
    * Edite o arquivo `R/analise_dashboard.R` e substitua as variáveis de conexão (`DB_HOST`, `DB_PATH`, `DB_TOKEN`) por variáveis de ambiente ou *placeholders* seguros.
    * Execute o script R. Ele se conectará ao Databricks, puxará os dados agregados das tabelas GOLD e gerará os gráficos `ggplot2` no RStudio.