# クライアント・サーバ間のメッセージ用のモジュール
module GMessage
	require 'GSocket.rb'
	require 'Action.rb'
	require 'User.rb'
	require 'Utils.rb'
	@@current_uid = ""

	def self.init(uid)
		@@current_uid = uid
	end

	def self.mkmsg(type, action, body={})
		{ :from => @@current_uid, :type => type, :action => action, :body => body }
	end

	def self.parse(msg={})
		begin
			return unless Utils.allkeys?([:type,:action,:body], msg)
			# call process
			__send__("proc_#{msg[:type]}_#{msg[:action]}", msg) 
		rescue => ex
			puts ex.message
		end
	end

private
### init methods ###
	# cli -> serv
	def self.proc_init_init(msg={})
		body = {:alert => "No more members" }
		msg_new = mkmsg("init", "reject", body)
		GSocket::Server.send(msg_new, User.find(msg[:from]))
	end
 	
	# serv -> cli
	def self.proc_init_confirm(msg={})
	end
	
	# serv -> cli	
	def self.proc_init_reject(msg={})
	end

	# serv -> cli	
	def self.proc_init_start(msg={})
	end

### ctrl methods ###
	# serv -> cli	
	def self.proc_ctrl_turn(msg={})
		msg[:body][:user] == @@current_uid ? Action.myturn : Action.yourturn(msg[:body][:user])
	end

	# cli -> serv	
	def self.proc_ctrl_turn_end(msg={})
		msg_new = mkmsg("ctrl", "turn", {:user => Utils.get_next_uid(msg[:body][:user])})
		GSocket::Server.send_all(msg_new)
		puts "send TURN_END" if Config::DEBUG
	end

	# cli -> serv
	def self.proc_ctrl_dice(msg={})
		body = {:user => msg[:from], :value => msg[:body][:value]}
		msg_new = mkmsg("ctrl", "move", body)
		GSocket::Server.send_all(msg_new)
		puts "send MOVE" if Config::DEBUG
	end

	# serv -> cli	
	def self.proc_ctrl_move(msg={})
		# TODO
		Action.move()
	end

	
### event methods ###
	# cli -> serv
	def self.proc_event_question(msg={})
		msg_new = mkmsg("event", "start", msg[:body])
		puts msg_new
		GSocket::Server.send_all(msg_new)
		puts "send START" if Config::DEBUG
	end

	# serv -> cli
	def self.proc_event_start(msg={})
		
	end

	# cli -> serv
	def self.proc_event_answer(msg={})
		msg_new = mkmsg("event", "result", msg[:body])
		GSocket::Server.send_all(msg_new)
		puts "RESULT" if Config::DEBUG
	end

	# serv -> cli
	def self.proc_event_result(msg={})
		# TODO
		Action.show_result()
	end

	# cli -> serv
	def self.proc_event_action(msg={})
		msg_new = mkmsg("event", "command", msg[:body])
		GSocket::Server.send_all(msg_new)
		puts "send COMMAND" if Config::DEBUG
	end

	# serv -> cli
	def self.proc_event_command(msg={})
		# TODO
		#case msg[:body][:name]
		#when "move"
		#	Action.move
		#when "give_p"
		#	Action.give_p
		#end
		puts "exec COMMAND"
	end

end