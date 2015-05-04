express = require 'express'
app = do express

app.use express.static 'public'

app.listen 2000