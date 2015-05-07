express       = require 'express'
path          = require 'path'
morgan        = require 'morgan'
bodyParser    = require 'body-parser'
cookieParser  = require 'cookie-parser'
session       = require 'express-session'
connectFlash  = require 'connect-flash'
passport      = require 'passport'
localPassport = require 'passport-local'
bcrypt        = require 'bcryptjs'
db            = require './lib/db'
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

# Parse POST headers
app.use bodyParser.urlencoded({extended: false})

# Sessions and flash data
app.use cookieParser 'secret'
app.use session cookie: maxAge: 60000
app.use connectFlash()

# Setup db
db.setup()

# Passport authentication
app.use passport.initialize()
app.use passport.session()

passport.use new localPassport (email, password, done) ->
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

app.get '/', (req, res) ->
    res.render 'index'

app.get '/signup', (req, res) ->
    res.render 'signup'

app.post '/signup', (req, res) ->
    name            = req.body.inputName
    email           = req.body.inputEmail
    password        = req.body.inputPassword
    confirmPassword = req.body.inputConfirmPassword
    invalidFields   = []

    if name == ""
        invalidFields.push 'inputName'
        console.log 'name'
    if !validEmail email
        invalidFields.push 'inputEmail'
        console.log 'mail'
    if !(password == confirmPassword)
        invalidFields.push 'inputPassword'
        console.log 'psswd'

    if invalidFields.length > 0
        res.render 'signup', invalidFields: invalidFields
        return
    else
        user =
            name: name
            email: email
            password: bcrypt.hashSync password, 8

        db.saveUser user, (err, success) ->
            if success
                req.flash 'firstName', name.split(" ")[0]
                res.redirect '/thanks'
                return
            else
                console.log 'servererror'
                res.render 'signup', serverError: true
                return

app.get '/thanks', (req, res) ->
    res.render 'thanks', name: req.flash("firstName")

app.get '/login', (req, res) ->
    res.redirect '/'

app.get '/about-us', (req, res) ->
    res.redirect '/'

validEmail = (email) ->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return re.test email

app.listen port
console.log '[BIGSALES-WEB] Listening on port ' + port