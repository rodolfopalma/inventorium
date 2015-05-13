path = require('path')
rio = require('rio')
xlsBuilder = require('msexcel-builder')

module.exports.getHoltWintersPrediction = (id, xlsx, cb) ->
    cfg =
        entryPoint: 'getPrediction'
        data:
            xlsxPath: xlsx
        callback: (err, res) ->
            if not err
                data = JSON.parse res
            else
                data = "Rserve Holt Winters prediction failed."
            
            resultsPath = path.join "results", id + ".xlsx" 
            workbook = xlsBuilder.createWorkbook("results", id + ".xlsx")
            sheet = workbook.createSheet('Resultados', 100, 2000)

            rowIndex = 1
            colIndex = 1

            # Encabezado
            sheet.set(colIndex, rowIndex, "BIGSALES - PREDICTIVE MODEL FOR STOCK MANAGEMENT")
            rowIndex += 1
            sheet.set(colIndex, rowIndex, "Demandas Originales v/s Ajustadas mensuales")
            rowIndex += 1
            sheet.set(colIndex, rowIndex, "Demandas Originales")
            colIndex += 1
            sheet.set(colIndex, rowIndex, "Demandas Ajustadas")
            
            colIndex = 1 
            rowIndex += 1
            # Setear valores iniciales y ajuste de modelo
            for field, val of data.x
                sheet.set(colIndex, rowIndex, val["Ventas"])
                rowIndex += 1
            
            rowIndexInitial = rowIndex
            colIndex += 1
            rowIndex = 4
            for field, val of data.model.fitted
                sheet.set(colIndex, rowIndex, val["level"])
                rowIndex += 1
            
            # Indicar valores con 95% de confianza
            colIndex = 1
            rowIndex = rowIndexInitial + 2
            sheet.set(colIndex, rowIndex, "PREDICCIÓN CON 95% DE CONFIANZA PARA 48 MESES")
            rowIndex += 1
            sheet.set(colIndex, rowIndex, "Demanda Mínima")
            colIndex += 1
            sheet.set(colIndex, rowIndex, "Demanda Media")
            colIndex += 1
            sheet.set(colIndex, rowIndex, "Demanda Máxima")
            rowIndex += 1
            colIndex = 1

            rowIndexPrediction = rowIndex

            for field, val of data.lower
                sheet.set(colIndex, rowIndex, val["95%"])
                rowIndex += 1

            rowIndex = rowIndexPrediction
            colIndex += 1

            for field, val of data.mean
                sheet.set(colIndex, rowIndex, val)
                rowIndex += 1

            rowIndex = rowIndexPrediction
            colIndex += 1
            
            for field, val of data.upper
                sheet.set(colIndex, rowIndex, val["95%"])
                rowIndex += 1

            workbook.save (ok) ->
                data["resultsPath"] = resultsPath
                cb id, data

    scriptPath = path.join "private", "models", "holt-winters.R"
    rio.sourceAndEval scriptPath, cfg
