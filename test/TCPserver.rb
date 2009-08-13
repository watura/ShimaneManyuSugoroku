#!/usr/bin/ruby

require 'socket'
require 'thread'

gs = TCPServer.open(12345)
addr = gs.addr
addr.shift
printf("server is on %s\n", addr.join(":"))

while true
  Thread.start(gs.accept) do |s| 
    print(s, " is accepted\n")
    p Marshal.load(s.read)
    p s.peeraddr
    print(s, " is gone\n")
    s.close
  end
 end

