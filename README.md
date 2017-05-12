# iOS-Live

### 0. Used library:
```
**RTMP server** - Nginx RTMP module(https://github.com/arut/nginx-rtmp-module)
**WebSocket server** - Socket.io(http://socket.io/)
**iOS client** - LFLiveKit(https://github.com/LaiFengiOS/LFLiveKit) to push stream
**IJKPlayer** - ijkplayer(https://github.com/Bilibili/ijkplayer) to play stream
```

### 1. Nginx RTMP server

You need to can set up your own rtmp server, the guidance can be found here:

https://github.com/arut/nginx-rtmp-module

### 2. Run backend

```
cd backend
npm install
node app.js
```

### 3. Run client

```
pod install
open iLive.xcworkspace
```
