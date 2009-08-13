#!/usr/bin/ruby

require 'socket'

s = TCPSocket.open("localhost", 12345)
#s.write(["apple", 1, [3, 4]].to_yaml)
s.write(Marshal.dump(["apple", 1, [3, 4]]))
s.close

