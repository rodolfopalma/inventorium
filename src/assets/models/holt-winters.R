# BigSales - Holt Winters Prediction Model
# May 2015
library(xlsx)
library(forecast)
library(RJSONIO)

getPrediction <- function(jsonObj) {
    o = fromJSON(jsonObj)

    xlsxPath = o$xlsxPath
    demands = read.xlsx(xlsxPath)
    # TO DO: flexibilizar frecuencia.
    demandsTimeSeries = ts(demands, frequency = 12)
    demandsHoltWinters = HoltWinters(demandsTimeSeries)
    # TO DO: flexibilizar intervalos de predicción.
    demandsForecast = forecast.HoltWinters(demandsHoltWinters, h = 48)
    
    return(toJSON(demandsForecast))
}

### Ventas de shampoo
#shampoo = read.xlsx("/home/rodolfo/drive/dev/bigsales/model/shampoo.xlsx",1)
#shampoots = ts(shampoo, frequency = 12)
#shampootsfc = HoltWinters(shampoots)
##shampootsfc1 = HoltWinters(shampoots, gamma = FALSE)
##shampootsfc2 = HoltWinters(shampoots,beta = FALSE, gamma = FALSE)
#shampootsfc$SSE
##shampootsfc1$SSE
##shampootsfc2$SSE

#plot(shampootsfc)
##plot(shampootsfc1)
##plot(shampootsfc2)

#forecasting = forecast.HoltWinters(shampootsfc, h = 12)
#forecasting
#plot.forecast(forecasting)

##Sales of shampoo over a three year period
##Source: Time Series Data Library (citing: Makridakis, Wheelwright and Hyndman (1998))
