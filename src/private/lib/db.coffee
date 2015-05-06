rdb = require 'rethinkdb'

dbConfig =
    host   : process.env.RDB_HOST || 'localhost'
    port   : parseInt(process.env.RDB_PORT) || 28015
    db     : process.env.RDB_DB || 'bigsalesWeb'
    tables :
        users: 'id'

###*
 * Connect to RethinkDB instance and perform basic database setup.
###
module.exports.setup = ->
    rdb.connect {host: dbConfig.host, port: dbConfig.port}, (err, conn) ->
        rdb.dbCreate(dbConfig.db).run conn, (err, result) ->
            if err
                console.log "[DB] RethinkDB database " + dbConfig.db + " already exists."
            else
                console.log "[DB] RethinkDB database " + dbConfig.db + " created."

            for table, key of dbConfig.tables
                rdb.db(dbConfig.db).tableCreate(table, {primaryKey: key}).run conn, (err, result) ->
                    if err
                        console.log "[DB] RethinkDB table " + table + " already exists."
                    else
                        console.log "[DB] RethinkDB table " + table + " created."

###*
 * Wrapper function for RethinkDB API `rdb.connect` method
 * to extend it (thinking about error handling) when necesary.
 * @param  {Function} cb Callback called with error and connection as parameters.
###
connectDb = (cb) ->
    rdb.connect {host: dbConfig.host, port: dbConfig.port}, (err, conn) ->
        cb err, conn