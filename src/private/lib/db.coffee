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

module.exports.saveUser = (user, cb) ->
    connectDb (err, conn) ->
        rdb.db(dbConfig.db).table('users').insert(user).run conn, (err, result) ->
            if err
                console.log "[DB] Couldn't save user."
                cb err
            else
                console.log "[DB] New user inserted succesfully."
                cb null, result.inserted == 1

            do conn.close

module.exports.findUserByEmail = (email, cb) ->
    connectDb (err, conn) ->
        findUserByFilter conn, email: email, cb
        do conn.close

module.exports.findUserById = (id, cb) ->
    connectDb (err, conn) ->
        findUserByFilter conn, id: id, cb
        do conn.close

findUserByFilter = (conn, filterObject, cb) ->
    rdb.db(dbConfig.db).table('users').filter(filterObject).limit(1).run conn, (err, cursor) ->
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
                    cb null, user


###*
 * Wrapper function for RethinkDB API `rdb.connect` method
 * to extend it (thinking about error handling) when necessary.
 * @param  {Function} cb Callback called with error and connection as parameters.
###
connectDb = (cb) ->
    rdb.connect {host: dbConfig.host, port: dbConfig.port}, (err, conn) ->
        cb err, conn