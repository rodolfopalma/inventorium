express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
path = require 'path'
app = do express

# Servir contenido estático
app.use '/static/css', express.static 'public/css'
app.use '/static/fonts', express.static 'public/fonts'
app.use '/static/i', express.static 'public/i'
app.use '/static/js', express.static 'public/js'

# Jade
app.set 'views', path.join(__dirname, "../src/public/jade")
app.set 'view engine', 'jade'

# Logger
app.use morgan('combined')

# Parsear POST headers
app.use bodyParser.urlencoded({extended: false})

app.get '/', (req, res) ->
    res.render 'index'

app.get '/signup', (req, res) ->
    res.render 'signup'

app.post '/signup', (req, res) ->
    console.log req.body
    res.redirect '/thanks'

app.get '/thanks', (req, res) ->
    res.render 'thanks'

app.get '/login', (req, res) ->
    res.redirect('/')

app.get '/about-us', (req, res) ->
    res.redirect('/')

app.listen 2000