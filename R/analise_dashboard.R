# R/analise_dashboard.R

# Instala os packages DBI e odbc
install.packages("odbc")
#install.packages("DBI")

# Carrega os pacotes necessários
library(DBI)
library(odbc)
library(tidyverse)
library(lubridate)
library(scales) 

# --- CONFIGURAÇÃO DA CONEXÃO DATABRICKS (SQL WAREHOUSE) ---
DB_HOST <- "dbc-76a36605-9c31.cloud.databricks.com"
DB_PATH <- "/sql/1.0/warehouses/46c28e6da8fd5c94"
DB_TOKEN <- Sys.getenv("DATABRICKS_PAT") 

# O nome do driver ODBC deve ser exato
DB_DRIVER <- "Simba Spark ODBC Driver" 

# --- 1. CONSTRUINDO A STRING DE CONEXÃO OTIMIZADA ---
# Simplificamos a string, retirando o Schema
connection_string <- glue::glue(
  "Driver={{{DB_DRIVER}}};",
  "Host={DB_HOST};",
  "Port=443;",
  "UID=token;",
  "PWD={DB_TOKEN};",
  "ThriftTransport=1;", 
  "SSL=1;",
  "AuthMech=3;",
  "Protocol=6;",
  "SparkServerType=3;",
  "HttpPath={DB_PATH}",
  .sep = ""
)

# --- 2. TENTANDO CONECTAR COM A STRING ---
con <- tryCatch({
  # Usamos o .connection_string para passar todos os parâmetros de uma vez
  dbConnect(
    odbc::odbc(),
    .connection_string = connection_string
  )
}, error = function(e) {
  # MENSAGEM DE ERRO DETALHADA: Esta mensagem deve aparecer AGORA se falhar
  message("\n=========================================================================")
  message("ERRO CRÍTICO DE CONEXÃO. CAUSA: Token inválido ou SQL Warehouse PARADO.")
  message(paste("Mensagem de erro completa do ODBC:", e$message))
  message("=========================================================================")
  stop(e)
})

# --- 3. QUERY DA CAMADA GOLD (Série Temporal) ---
# A query consulta a tabela final que você criou no Databricks
sql_query_mensal <- "SELECT mes_ano, vendas_totais FROM vendas_gold_mensal ORDER BY mes_ano;"

df_mensal <- dbGetQuery(con, sql_query_mensal) %>%
  # Converte o timestamp retornado do Databricks para o tipo Date do R
  mutate(mes_ano = as.Date(mes_ano))

# --- 4. FECHAR A CONEXÃO ---
dbDisconnect(con)

cat("\nDados carregados com sucesso do Databricks:\n")
print(head(df_mensal))


# --- 5. QUERY DA CAMADA GOLD (Categorias e Região) ---

# Carrega a agregação por Categoria/Sub-Categoria/Região
sql_query_categorias <- "SELECT category, sub_category, vendas_totais_categoria FROM vendas_gold_categorias ORDER BY vendas_totais_categoria DESC;"

df_categorias <- dbGetQuery(con, sql_query_categorias) %>%
  # Garantimos que a coluna de vendas é numérica
  mutate(vendas_totais_categoria = as.numeric(vendas_totais_categoria))

# Carrega a agregação por Região
sql_query_regiao <- "SELECT region, vendas_totais_regiao FROM vendas_gold_regiao ORDER BY vendas_totais_regiao DESC;"

df_regiao <- dbGetQuery(con, sql_query_regiao) %>%
  mutate(vendas_totais_regiao = as.numeric(vendas_totais_regiao))


# --- 6. FECHAR A CONEXÃO ---
dbDisconnect(con)

cat("\nTodos os dados Gold carregados com sucesso!\n")
print(head(df_categorias))
print(head(df_regiao))

# --- 7. VISUALIZAÇÃO COM GGPLOT2 ---

# 7.1. Gráfico de Série Temporal (Vendas Mensais) - Já planejado
plot_vendas_mensal <- df_mensal %>%
  ggplot(aes(x = mes_ano, y = vendas_totais)) +
  # ... (Seu código ggplot2 para o gráfico de linha)
  labs(title = "Vendas Totais por Mês/Ano")
print(plot_vendas_mensal)

# 7.2. Gráfico de Vendas por Categoria Principal
plot_vendas_categoria <- df_categorias %>%
  group_by(category) %>%
  summarise(Vendas_Totais = sum(vendas_totais_categoria)) %>%
  ggplot(aes(x = reorder(category, Vendas_Totais), y = Vendas_Totais)) +
  geom_col(fill = "darkred") +
  coord_flip() + # Facilita a leitura
  labs(title = "Vendas Totais por Categoria", x = "Categoria", y = "Vendas")
print(plot_vendas_categoria)

# 7.3. Gráfico de Vendas por Região
plot_vendas_regiao <- df_regiao %>%
  ggplot(aes(x = reorder(region, vendas_totais_regiao), y = vendas_totais_regiao)) +
  geom_col(fill = "darkgreen") +
  labs(title = "Vendas Totais por Região", x = "Região", y = "Vendas")
print(plot_vendas_regiao)