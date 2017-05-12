var app = require('express')()
var server = require('http').Server(app)
var io = require('socket.io')(server)

server.listen(3000)

app.get('/channels', function(req, res) {
  var channelList = Object.keys(channels).map(function(key) {
    return channels[key]
  })
  res.send(channelList)
})

var channels = {}

io.on('connection', function(socket) {
  console.log("connected")
  socket.on('create_channel', function(channel) {
    if (!channel.key) {
      return
    }
    console.log('create channel:', channel)
    var channelKey = channel.key
    channels[channelKey] = channel
    socket.channelKey = channelKey
    socket.join(channelKey)
  })

  socket.on('close_channel', function(channelKey) {
    console.log('close channel:', channelKey)
    delete channels[channelKey]
  })

  socket.on('disconnect', function() {
    console.log('disconnect:', socket.channelKey)
    if (socket.channelKey) {
      delete channels[socket.channelKey]
    }
  })

  socket.on('join_channel', function(channelKey) {
    console.log('join channel:', channelKey)
    socket.join(channelKey)
  })

  socket.on('upvote', function(channelKey) {
    console.log('upvote:', channelKey)
    io.to(channelKey).emit('upvote')
  })

  socket.on('gift', function(data) {
    console.log('gift:', data)
    io.to(data.channelKey).emit('gift', data)
  })

  socket.on('comment', function(data) {
    console.log('comment:', data)
    io.to(data.channelKey).emit('comment', data)
  })

})

console.log('listening on port 3000...')