var express = require("express");
var app = express();
var server = require("http").createServer(app);
var io = require("socket.io")(server);
server.listen(8080);

app.use(express.static("public"));
app.get("/", function(req, res) {
  res.sendFile(__dirname + "/public/html/index.html");
})

app.get("/sign-in", function(req, res) {
  res.sendFile(__dirname + "/public/html/signin.html")
})

console.log("Server listening on port 8080");
