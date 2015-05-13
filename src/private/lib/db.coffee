rdb         = require 'rethinkdb'
rdbStoreLib = require 'express-session-rethinkdb'

dbConfig =
    host   : process.env.RDB_HOST || 'localhost'
    port   : parseInt(process.env.RDB_PORT) || 28015
    db     : process.env.RDB_DB || 'bigsalesWeb'
    tables :
        users: 'id'
        predictions: 'id'
        sessions: 'id'

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
                        console.log "[DB] " + err.msg
                    else
                        console.log "[DB] " + result.config_changes[0].new_val.name + " table created."

module.exports.getSessionStore = (session) ->
    rdbStore = rdbStoreLib session

    return new rdbStore {
        connectOptions:
            db: dbConfig.db
            host: dbConfig.host
            port: dbConfig.port
        table: 'sessions'
    }

module.exports.saveUser = (user, cb) ->
    connectDb (err, conn) ->
        rdb.db(dbConfig.db).table('users').insert(user).run conn, (err, result) ->
            if err
                console.log "[DB] Couldn't save user."
                cb err
            else
                console.log "[DB] New user inserted succesfully."
                cb null, result.inserted == 1, result.generated_keys[0]

module.exports.findUserByEmail = (email, cb) ->
    connectDb (err, conn) ->
        findUserByFilter conn, email: email, cb

module.exports.findUserById = (id, cb) ->
    connectDb (err, conn) ->
        findUserByFilter conn, id: id, cb
        
findUserByFilter = (conn, filterObject, cb) ->
    findElemByFilter(conn, 'users', filterObject, cb)


module.exports.savePrediction = (prediction, cb) ->
    connectDb (err, conn) ->
        rdb.db(dbConfig.db).table('predictions').insert(prediction).run conn, (err, result) ->
            if err
                console.log "[DB] Couldn't save prediction."
                cb err
            else
                console.log "[DB] New prediction inserted succesfully."
                cb null, result.inserted == 1, result.generated_keys[0]

module.exports.getPredictionsByUserId = (userId, cb) ->
    connectDb (err, conn) ->
        rdb.db(dbConfig.db).table('predictions').filter(ownerId: userId).run conn, (err, cursor) ->
            if err
                cb err
            else
                cursor.toArray (err, results) ->
                    if err
                        cb err
                    else
                        cb null, results

module.exports.updatePredictionStatus = (id, values) ->
    connectDb (err, conn) ->
        rdb.db(dbConfig.db).table('predictions').filter(id: id).update(status: "done", results: values).run conn, (err, result) ->
            if err
                console.log "[DB] Prediction " + id + " couldn't be updated."
            else
                console.log "[DB] Prediction " + id + " updated succesfully."
                
module.exports.getPredictionById = (id, cb) ->
    connectDb (err, conn) ->
        findElemByFilter(conn, 'predictions', id: id, cb)
    
###*
 * Wrapper function for RethinkDB API `rdb.connect` method
 * to extend it (thinking about error handling) when necessary.
 * @param  {Function} cb Callback called with error and connection as parameters.
###
connectDb = (cb) ->
    rdb.connect {host: dbConfig.host, port: dbConfig.port}, (err, conn) ->
        cb err, conn

findElemByFilter = (conn, table, filterObject, cb) ->
    rdb.db(dbConfig.db).table(table).filter(filterObject).limit(1).run conn, (err, cursor) ->
        # Database runtime error
        if err
            cb err
        else
            cursor.next (err, row) ->
                # No user matched
                if err
                    cb null
                # Success
                else
                    cb null, row
