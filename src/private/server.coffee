express       = require 'express'
path          = require 'path'
morgan        = require 'morgan'
cookieParser  = require 'cookie-parser'
session       = require 'express-session'
bodyParser    = require 'body-parser'
multer        = require 'multer'
connectFlash  = require 'connect-flash'
passport      = require 'passport'
localPassport = require 'passport-local'
bcrypt        = require 'bcryptjs'
db            = require './lib/db'
rInterface    = require('./lib/r-interface')

app           = do express
port          = process.env.port || 2000

# Static content
app.use '/static/css', express.static 'public/css'
app.use '/static/fonts', express.static 'public/fonts'
app.use '/static/i', express.static 'public/i'
app.use '/static/js', express.static 'public/js'

# Jade
app.set 'views', path.join(__dirname, "../src/public/jade")
app.set 'view engine', 'jade'

# Logger
app.use morgan('dev')

# Sessions and flash data
app.use cookieParser()
app.use session(
    cookie:
        maxAge: 1000 * 60 * 60 * 24 * 31
    secret: "easy money"
    saveUninitialized: false
    resave: false
    store: db.getSessionStore session
    maxAge: new Date(Date.now() + 1000 * 60 * 60 * 24 * 31)
    rolling: true
)
app.use connectFlash()

# Setup db
db.setup()

# Passport authentication
app.use passport.initialize()
app.use passport.session()

passport.use new localPassport {
        usernameField: 'inputEmail'
        passwordField: 'inputPassword'
    }, (email, password, done) ->
    db.findUserByEmail email, (err, user) ->
        # Database error
        if err
            return done err
        # Unknown user
        if !user
            return done err, false

        # Match!
        if bcrypt.compareSync password, user.password
            return done null, user
        # Incorrect password
        else
            return done null, false

passport.serializeUser (user, done) ->
    done null, user.id

passport.deserializeUser (id, done) ->
    db.findUserById id, (err, user) ->
        done err, user

# Middleware to add render data
app.use (req, res, next) ->
    res.locals.user = req.user
    #res.locals.baseUrl = 'https://' + req.get('host')
    res.locals.baseUrl = 'http://' + req.get('host')
    do next

# Middleware to ensure https:// is being used
#app.use (req, res, next) ->
#    if req.secure
#        do next
#        return
#    res.redirect 'https://' + req.headers.host + req.url

app.get '/', (req, res) ->
    res.render 'index'

app.get '/signup', (req, res) ->
    if typeof req.user != 'undefined'
        res.redirect '/dashboard'
        return

    res.render 'signup'

app.post '/signup', bodyParser.urlencoded(extended: false), (req, res) ->
    name            = req.body.inputName
    email           = req.body.inputEmail
    password        = req.body.inputPassword
    confirmPassword = req.body.inputConfirmPassword
    invalidFields   = []

    if name == ""
        invalidFields.push 'inputName'
    if !validEmail email
        invalidFields.push 'inputEmail'
    if !(password == confirmPassword) || password.length == 0
        invalidFields.push 'inputPassword'

    if invalidFields.length > 0
        res.render 'signup', invalidFields: invalidFields
        return
    else
        user =
            name: name
            email: email
            password: bcrypt.hashSync password, 8

        db.saveUser user, (err, success, id) ->
            if success
                user["id"] = id
                req.login user, (err) ->
                    req.flash 'firstName', name.split(" ")[0]
                    res.redirect '/dashboard'
                    return
            else
                res.render 'signup', serverError: true
                return

app.get '/login', (req, res) ->
    if typeof req.user != 'undefined'
        res.redirect '/dashboard'
        return

    res.render 'login'

app.post '/login', bodyParser.urlencoded(extended: false), passport.authenticate 'local', {
    successRedirect: '/dashboard'
    failureRedirect: '/login',
    failureFlash: true
}

app.get '/thanks', (req, res) ->
    res.render 'thanks', name: req.flash("firstName")

app.get '/dashboard', (req, res) ->
    if typeof req.user == 'undefined'
        res.redirect '/login'
        return
    
    db.getPredictionsByUserId req.user.id, (err, predictions) ->
        res.render 'dashboard', predictions: predictions

app.get '/prediccion/crear', (req, res) ->
    res.render 'prediccion/crear'

app.post '/prediccion/crear', multer(dest: path.join(__dirname, '../', 'uploads')), (req, res) ->
    prediction =
        name: req.body.inputName
        ownerId: req.user.id
        status: 'pending'
        filePath: req.files.inputFile.path

    db.savePrediction prediction, (err, success, id) ->
        if success
            rInterface.getHoltWintersPrediction(id, prediction.filePath, db.updatePredictionStatus)
            res.redirect '/dashboard'

app.get '/prediccion/:id', (req, res) ->
    db.getPredictionById req.params.id, (err, prediction) ->
        if prediction.ownerId != req.user.id || prediction.status == "pending"
            res.redirect '/dashboard'
            return
        
        res.download prediction.results.resultsPath
    
app.get '/logout', (req, res) ->
    do req.logout
    res.redirect '/'

app.get '/about-us', (req, res) ->
    res.redirect '/'

validEmail = (email) ->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return re.test email

app.listen port
console.log '[BIGSALES-WEB] Listening on port ' + port
