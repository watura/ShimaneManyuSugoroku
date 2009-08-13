require 'GSocket.rb'
require 'GMessage.rb'
require 'User.rb'
require 'Config.rb'
require 'pp' if Config::DEBUG

# open socket
GSocket::Server.open

# set myuid - server:"000"
GMessage.init("000")

### INITIALIZE USERS ###
pp "wait for members" if Config::DEBUG
Config::NUM_USERS.times {|x|
	begin
		# wait for init msg from clients
  	msg, addr = GSocket::Server.recvfrom 
		pp "---inituser:#{x+1}---",msg, addr if Config::DEBUG
	
	  # ADD USER if correct msg recved	
		if msg[:type] == "init" && msg[:action] == "init"
			# create user
			User.new('%03d' % (User.all.size + 1), msg[:body][:name], Config::INIT_POINT, addr[3], addr[1])
			# store user address
			GSocket::Server.set_uaddr(User.all[-1])
			# send CONFIRM
			body = {:uid => User.all[-1].uid, :name => User.all[-1].name, :alert => "Wait until START"}
			msg = GMessage.mkmsg("init", "confirm", body) 
			GSocket::Server.send(msg, User.all[-1])
			pp "send CONFIRM to #{User.all[-1].uid} " if Config::DEBUG
		else
			# send REJECT
			body = {:alert => "Illegal message"}
			msg = GMessage.mkmsg("init", "reject", body) 
			GSocket::Server.send_direct(msg, addr[3], addr[1])
			raise "INIT: illegal request"
		end
	rescue => ex
	 	STDERR.puts ex.message	
		redo
	end
}

### START GAME ###
# send START to all
body = {:members => User.get_profiles, :first => User.choice.uid, :alert => "START GAME"}
msg = GMessage.mkmsg("init", "start", body) 
GSocket::Server.send_all(msg)
pp msg if Config::DEBUG

### CONTINUE GAME ###
loop {
	msg, addr = GSocket::Server.recvfrom
	pp msg if Config::DEBUG
	GMessage.parse(msg)
}

GSocket::Server.close
