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

########test data#####

@inserts = (connection, pcId, date, cpu) ->
  console.log "querying for last insert"
  connection.query('insert into data (pc, dat, cpu ) values (?, ?, ?)',[pcId, date, cpu], (err, rows, fields) =>
    throw err if (err) 
    console.log(rows.insertId);
  )
#setInterval ( => @getLastDataWrapper('pc1')), 5000
setInterval ( => @inserts(connection, 'pc1', new Date(), Math.random())), 10000




getLastData = (connection, pcId, callback) ->
  console.log "querying for last insert"
  connection.query('SELECT m.* from data m where m.pc=? and m.dat=(select max(dat) from data m2 where m2.pc=?)',[pcId,pcId], (err, rows, fields) =>
    throw err if (err) 
    callback rows
  )

getAllData = (connection, pcId, callback) ->
  console.log "querying for all data"
  connection.query('SELECT m.* from data m where m.pc=?',[pcId], (err, rows, fields) ->
    throw err if (err) 
    callback rows
  )

# uncomment if you want to see sum test output
#getLastData(connection, 'pc1')
#getLastData(connection, 'pc2')

#getAllData(connection, 'pc1')
#getAllData(connection, 'pc2')

@getAllDataWrapper = (pcId) ->
  getAllData connection, pcId, (result) ->
    for item in result
      io.sockets.emit 'chart', {chartData: item}
      console.log item
  
@getLastDataWrapper = (pcId) ->
  getLastData connection, pcId, (result) ->
    io.sockets.emit 'chart', {chartData: result}
    console.log result

#getAllData connection, 'pc1', (result) ->
#  for item in result
#    io.sockets.emit 'chart', {chartData: item}
#    console.log item


#connection.end()
@getLastDataWrapper('pc1')
#setInterval ( => @getLastDataWrapper('pc1')), 5000
#  setInterval ( => @getAllDataWrapper('pc1')), 5000 

io.sockets.on 'connection', (socket) =>
  setInterval ( => @getLastDataWrapper('pc1')), 12000 
  @getAllDataWrapper('pc1')
  count++
#  io.sockets.emit 'count', { date: new Date(), number: Math.random() }

#  setInterval(() ->
#    io.sockets.emit 'count', { date: new Date(), number: Math.random(), count: count++ , number2: Math.random()}
#  , 5000)
   
  socket.on 'disconnect', () ->
    count--
    io.sockets.emit 'count', { number: count }

app.get '/', (req, res) ->
  res.render 'index', {title: 'node.js express socket.io realtime charts'}

if not module.parent
  app.listen 10927
  console.log "Express server listening on port %d", app.address().port

