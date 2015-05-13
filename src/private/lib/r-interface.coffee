path = require('path')
rio = require('rio')

module.exports.getHoltWintersPrediction = (xlsx, cb) ->
    cfg =
        entryPoint: 'getPrediction'
        data:
            xlsxPath: xlsx
        callback: (err, res) ->
            console.log "err: ", err
            console.log "res: ", res

            if not err
                data = JSON.parse res
            else
                data = "Rserve Holt Winters prediction failed."

            cb data

    scriptPath = path.join "private", "models", "holt-winters.R"
    rio.sourceAndEval scriptPath, cfg
