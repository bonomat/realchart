express = require('express')
io = require('socket.io')

app = module.exports = express.createServer() 

app.configure () -> 
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(require('stylus').middleware({ src: __dirname + '/public' }))
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))

app.configure 'development', () -> 
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })) 

app.configure 'production', () -> 
  app.use(express.errorHandler()) 

io = require('socket.io').listen(app)
count = 6

data = []


######################### mysql part 
sys = require('util')
mysql = require('mysql')
connection = mysql.createConnection {
  host     : 'localhost',
  user     : 'root',
  password : 'password',
  database : 'pep'
}


connection.connect()

getLastData = (connection, appId) ->
  console.log "querying for last insert"
  connection.query('SELECT m.* from data m where m.pc=? and m.id=(select max(id) from data m2 where m2.pc=?)',[appId,appId], (err, rows, fields) ->
    throw err if (err) 
    console.log('Query result: ', rows)

    return rows
  )


getAllData = (connection, appId) ->
  console.log "querying for all data"
  connection.query('SELECT m.* from data m where m.pc=?',[appId], (err, rows, fields) ->
    throw err if (err) 
    console.log('Query result: ', rows)

    return rows
  )


getLastData(connection, 'pc1')
getLastData(connection, 'pc2')

getAllData(connection, 'pc1')
getAllData(connection, 'pc2')


connection.end()

io.sockets.on 'connection', (socket) ->
  count++
  io.sockets.emit 'count', { date: new Date(), number: Math.random() }

  setInterval(() ->
    io.sockets.emit 'count', { date: new Date(), number: Math.random(), count: count++ , number2: Math.random()}
  , 5000)
   
  socket.on 'disconnect', () ->
    count--
    io.sockets.emit 'count', { number: count }

app.get '/', (req, res) ->
  res.render 'index', {title: 'node.js express socket.io realtime charts'}

if not module.parent
  app.listen 10927
  console.log "Express server listening on port %d", app.address().port

