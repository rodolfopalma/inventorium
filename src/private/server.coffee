express      = require 'express'
path         = require 'path'
morgan       = require 'morgan'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
session      = require 'express-session'
connectFlash = require 'connect-flash'
db           = require './lib/db'
app          = do express
port         = process.env.port || 2000

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

app.get '/', (req, res) ->
    res.render 'index'

app.get '/signup', (req, res) ->
    res.render 'signup'

app.post '/signup', (req, res) ->
    fullName = req.body.inputName
    req.flash "firstName", fullName.split(" ")[0]
    res.redirect '/thanks'

app.get '/thanks', (req, res) ->
    res.render 'thanks', name: req.flash("firstName")

app.get '/login', (req, res) ->
    res.redirect '/'

app.get '/about-us', (req, res) ->
    res.redirect '/'

app.listen port
console.log '[BIGSALES-WEB] Listening on port ' + port