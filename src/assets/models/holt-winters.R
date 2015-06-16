# BigSales - Holt Winters Prediction Model
# May 2015
library(xlsx)
library(forecast)
library(RJSONIO)

getPrediction <- function(jsonObj) {
    o = fromJSON(jsonObj)
    xlsxPath = o["xlsxPath"]
    demands = read.xlsx(xlsxPath, 1)
    # TO DO: flexibilizar frecuencia.
    demandsTimeSeries = ts(demands, frequency = 12)
    demandsHoltWinters = HoltWinters(demandsTimeSeries)
    # TO DO: flexibilizar intervalos de predicción.
    demandsForecast = forecast.HoltWinters(demandsHoltWinters, h = 48)
    results = c(demandsForecast, demandsHoltWinters)
    return(toJSON(results))
}
