### CONEXÃO ###
library(DBI)
con <- dbConnect(odbc::odbc(), "ODBC_BI", timeout = 99)
query <- dbGetQuery(con, "xxxxxx")

### ANÁLISE ATRIBUTO CNPJ_NUM_FUNCIONAIOS ###
numFunc = query$PJ_NUM_FUNCIONARIOS
summary(query$PJ_NUM_FUNCIONARIOS)

# Configurando plot
par(mfrow=c(2,2))
  #>>StripChart
  stripchart(query$PJ_NUM_FUNCIONARIOS, main="STRIPCHART PJ_NUM_FUNCIONARIOS", method="stack")
  #>>BoxPlot
  boxplot(query$PJ_NUM_FUNCIONARIOS, main="BOXPLOT PJ_NUM_FUNCIONARIOS", ylab="N° Funcionarios", col=("green")) 
  #>>Plot Dispersão
  plot(query$CNPJ, query$PJ_NUM_FUNCIONARIOS, pch=1, lwd=2, main="DISPERSÃO PJ_NUM_FUNCIONARIOS",xlab="PJs", ylab="N° Funcionarios") 
  #>>BoxPlot (Horizontal- Validação)
  boxplot(query$PJ_NUM_FUNCIONARIOS, horizontal=TRUE, main="H-BOXPLOT PJ_NUM_FUNCIONARIOS", ylab="N° Funcionarios", col=("green")) 

############################################################################################################
#>Para cada atributo são realizadas as validações acima, basta trocar a referência
############################################################################################################