cat server.pid | xargs kill -9
node private/server.js &
$! > server.pid