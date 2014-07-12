local socket = require "socket.c"
local sock, err = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
assert(sock, err)
print("connect:", sock:connect("127.0.0.1", 8858))
print("peer name:", sock:getpeername())
print("sock name:", sock:getsockname())
print("send:", sock:send("hello, world!\n"))
print("recv:", sock:recv(100))

