express = require 'express'
bodyParser = require 'body-parser'
path = require 'path'
app = do express

# Servir contenido estático
app.use '/static/css', express.static 'public/css'
app.use '/static/fonts', express.static 'public/fonts'
app.use '/static/i', express.static 'public/i'
app.use '/static/js', express.static 'public/js'

# Parsear POST headers
app.use bodyParser.urlencoded({extended: false})

app.get '/', (req, res) ->
    res.sendFile 'index.html', {root: path.join(__dirname, "../public")}

app.get '/signup', (req, res) ->
    res.sendFile 'signup.html', {root: path.join(__dirname, "../public")}

app.post '/signup', (req, res) ->
    console.log req.body
    res.redirect '/thanks'

app.get '/thanks-buddy', (req, res) ->
    res.sendFile 'thanks.html', {root: path.join(__dirname, "../public")}

app.get '/login', (req, res) ->
    res.redirect('/')

app.get '/about-us', (req, res) ->
    res.redirect('/')

app.listen 2000