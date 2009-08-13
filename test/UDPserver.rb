#!/usr/bin/ruby

require 'socket'
require 'thread'

udps = UDPSocket.open()
udps.bind("0.0.0.0", 12345)
addr = udps.addr
addr.shift
printf("server is on %s\n", addr.join(":"))

while true
  rcv, caddr = udps.recvfrom(65535)
  p caddr
  p Marshal.load(rcv)
end

