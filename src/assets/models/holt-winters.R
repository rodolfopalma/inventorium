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

### Ventas de shampoo
#shampoo = read.xlsx("/home/rodolfo/drive/dev/bigsales/model/shampoo.xlsx",1)
#shampoots = ts(shampoo, frequency = 12)
#shampootsfc = holtwinters(shampoots)
##shampootsfc1 = holtwinters(shampoots, gamma = false)
##shampootsfc2 = holtwinters(shampoots,beta = false, gamma = false)
#shampootsfc$sse
##shampootsfc1$sse
##shampootsfc2$sse

#plot(shampootsfc)
##plot(shampootsfc1)
##plot(shampootsfc2)

#forecasting = forecast.holtwinters(shampootsfc, h = 12)
#forecasting
#plot.forecast(forecasting)

##Sales of shampoo over a three year period
##Source: Time Series Data Library (citing: Makridakis, Wheelwright and Hyndman (1998))
