#!/usr/bin/ruby

require 'socket'

data = {:uid => "001",
	:msg_type => :move,
	:msg => {
	  :action => "move",
	  :from => {:x => 1, :y => 1},
	  :to => {:x => 3, :y => 4},
	  :get_point => 25}}

data2 = {:uid => "001",
	:msg_type => :present,
	:msg => {
	  :action => "present",
	  :target => ["002", "003"],
	  :point => -25}}

s = UDPSocket.open()
sockaddr = Socket.pack_sockaddr_in(12345, IPSocket::getaddress("anbey.sakura.ne.jp"))
s.send(Marshal.dump(data), 0, sockaddr)
s.send(Marshal.dump(data2), 0, sockaddr)
s.close

