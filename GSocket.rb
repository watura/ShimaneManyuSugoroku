# クライアント・サーバ間で通信するためのモジュール
module GSocket
	require 'socket'
	require 'Config.rb'
	
	class Client
		def self.open
			@udps = UDPSocket.new
			@udps.connect(Config::HOST, Config::PORT)
		end

		def self.close
			@udps.close
		end

		def self.send(obj)
			@udps.send(Marshal.dump(obj), 0)
		end

		def self.recv
			Marshal.load(@udps.recv(Config::MAXMSGLEN))
		end
	end
	
	class Server
		def self.open
			@udps = UDPSocket.new
			@udps.bind(nil, Config::PORT)
			@sockaddrs = {}
		end

		def self.close
			@udps.close
		end

		def self.set_uaddr(user)
		  @sockaddrs[user.uid] = Socket.pack_sockaddr_in(user.port, user.addr)
		end

		def self.send(obj, user_to)
			@udps.send(Marshal.dump(obj), 0, @sockaddrs[user_to.uid])
		end

		def self.send_direct(obj, addr, port)
			@udps.send(Marshal.dump(obj), 0, addr, port)
		end	

		def self.send_all(obj)
			@sockaddrs.each do |k, s|
				@udps.send(Marshal.dump(obj), 0, s)
			end
		end

		def self.recvfrom
			rcv_msg, rcv_addr = @udps.recvfrom(Config::MAXMSGLEN)
			return Marshal.load(rcv_msg), rcv_addr
		end
	end
end
