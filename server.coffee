express = require('express')
@io = require('socket.io')

app = module.exports = express() 

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


count = 6

data = []


######################### mysql start connection
sys = require('util')
mysql = require('mysql')
connection = mysql.createConnection {
  host     : 'localhost',
  user     : 'root',
  password : 'password',
  database : 'realtime'
}
connection.connect()

########test data#####
@inserts = (connection, pcId, date, cpu) ->
  connection.query('insert into data (pc, dat, cpu ) values (?, ?, ?)',[pcId, date, cpu], (err, rows, fields) =>
    throw err if (err) 
    console.log "inserted " +  rows.insertId
  )
setInterval ( => @inserts(connection, 'pc1', new Date(), Math.random())), 10000

#######method to retrieve last value
getLastData = (connection, pcId, callback) ->
  console.log "querying for last insert"
  connection.query('SELECT m.* from data m where m.pc=? and m.dat=(select max(dat) from data m2 where m2.pc=?)',[pcId,pcId], (err, rows, fields) =>
    throw err if (err) 
    callback rows
  )
#######method to retrieve all data per pc
getAllData = (connection, pcId, callback) ->
  console.log "querying for all data"
  connection.query('SELECT m.* from data m where m.pc=? order by dat asc',[pcId], (err, rows, fields) ->
    throw err if (err) 
    callback rows
  )
########wrapper methods for socket.io
@getAllDataWrapper = (connection, pcId) =>
  getAllData connection, pcId, (result) =>
    for item in result
      io?.sockets.emit 'chart', {chartData: item}
    setInterval ( => @getLastDataWrapper(connection, 'pc1')), 10000 

@getLastDataWrapper = (connection, pcId) ->
  getLastData connection, pcId, (result) ->
    for item in result
      io?.sockets.emit 'chart', {chartData: item}


if not module.parent
  http_server=app.listen 10927
  io = @io.listen(http_server)
  console.log "Express server listening on port %d", 10927

io.sockets.on 'connection', (socket) =>
  ############create a new mysql connection for each user
  mys = mysql.createConnection {
    host     : 'localhost',
    user     : 'root',
    password : 'password',
    database : 'realtime'
  }

  mys.connect()
  @getAllDataWrapper(mys, 'pc1')

  socket.on 'disconnect', () ->
    #mys.end()

app.get '/', (req, res) ->
  res.render 'index', {title: 'node.js express socket.io realtime charts'}


