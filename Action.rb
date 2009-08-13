module Action
	require 'User.rb'
	require 'Config.rb'
	require 'Map.rb'

	def self.init(myuid)
		@myuid = myuid
	end

### my turn ###
	def self.myturn
		puts "myturn" if Config::DEBUG
		$screen.fill_rect(0,450,630,350,[0,0,0])
		$view.write_str($screen,"あなたの番です",10,470)
		$view.write_str($screen,"[space]：ルーレット",10,490)
		Map.print_status(User.all)

		d = nil
		# DICE: catch user key
		while d == nil
			while event = SDL::Event2.poll
    		case event
    		when SDL::Event2::Quit
      		exit
    		when SDL::Event2::KeyDown
      		d = $dice.run if event.sym == SDL::Key::SPACE
    		end
			end
		end
		
		# send DICE
		msg = GMessage.mkmsg("ctrl", "dice", {:value => d})
		GSocket::Client.send(msg)
		
		# recv MOVE
		msg = GSocket::Client.recv
		$screen.fill_rect(0,450,630,350,[0,0,0])
		$view.write_str($screen,"#{msg[:body][:value]} マス進みます",10,470)
		move(msg[:body][:value], msg[:body][:user]) if msg[:type] == "ctrl" && msg[:action] == "move"
		Map.print_status(User.all)
		$screen.updateRect( 0, 0, 0, 0 )

		user = User.find(msg[:body][:user])
		user_map = [Utils.get_mapno(user.current_map), user.position%user.current_map.size]

		if Config::MAP_QUESTION.member? user_map
			$screen.fill_rect(0,450,630,350,[0,0,0])
			$view.write_str($screen,"あなたに問題です",10,470)
			# send QUESTION
			msg = GMessage.mkmsg("event", "question", self.get_question)
			GSocket::Client.send(msg)

			# recv START
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "start"
			answer = self.show_question(msg[:body][:user], msg[:body][:qid])
			
			# send ANSWER
			body = {:user => user.uid, :qid => msg[:body][:qid], :answer => answer}
			msg = GMessage.mkmsg("event", "answer", body)
			GSocket::Client.send(msg)

			# recv RESULT
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "result"
			self.show_result(msg[:body][:user], msg[:body][:answer])
			sleep 1

		elsif Config::MAP_EVENT.member? user_map
			# send ACTION
			msg = GMessage.mkmsg("event", "action", self.get_event)
			GSocket::Client.send(msg)
			# recv COMMAND
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "command"
			self.exec_command(msg)
		end

		User.check_map

		# send TURN_END
		msg = GMessage.mkmsg("ctrl", "turn_end", {:user => @myuid})
		GSocket::Client.send(msg)
		puts "send TURN_END" if Config::DEBUG

		$screen.fill_rect(0,450,630,350,[0,0,0])
		Map.print_status(User.all)
		$screen.updateRect( 0, 0, 0, 0 )
	end

### your turn ###
	def self.yourturn(uid)
		you = User.find(uid)
		puts "yourturn" if Config::DEBUG
		$screen.fill_rect(0,450,630,350,[0,0,0])
		$view.write_str($screen,"#{you.name} さんの番です",10,470)

		# recv MOVE
		msg = GSocket::Client.recv
		$screen.fill_rect(0,450,630,350,[0,0,0])
		$view.write_str($screen,"#{User.find(msg[:body][:user]).name} さんが#{msg[:body][:value]} マス進みます",10,470)
		move(msg[:body][:value], msg[:body][:user]) if msg[:type] == "ctrl" && msg[:action] == "move"
		Map.print_status(User.all)
		$screen.updateRect( 0, 0, 0, 0 )
		
		user = User.find(msg[:body][:user])
		user_map = [Utils.get_mapno(user.current_map), user.position%user.current_map.size]

		# recv START
		if Config::MAP_QUESTION.member? user_map
			$screen.fill_rect(0,450,630,350,[0,0,0])
			$view.write_str($screen,"#{you.name} さんに問題です",10,470)
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "start"
			self.show_question(msg[:body][:user], msg[:body][:qid])
			
			# recv RESULT
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "result"
			self.show_result(msg[:body][:user], msg[:body][:answer])
			sleep 1

		# recv COMMAND
		elsif Config::MAP_EVENT.member? user_map
			msg = GSocket::Client.recv
			return unless msg[:type] == "event" && msg[:action] == "command"
			self.exec_command(msg)

		end
		
		User.check_map

		$screen.fill_rect(0,450,630,350,[0,0,0])
		Map.print_status(User.all)
		$screen.updateRect( 0, 0, 0, 0 )
	end

	def self.move(value, uids=[@myuid])
		puts "----move----" if Config::DEBUG
		uids.each do |uid|
			user = User.find(uid)
			# move each user by value
			$view.move($imgs_chara[(uid.to_i)-1], [Utils.get_mapno(user.current_map), user.position], value)
			user.position += value
			user.point += value * 20
		end
	end

	def self.get_question(uid=@myuid)
		{:user => uid, :qid => '%03d' % rand($questions.size)}
	end

	def self.get_event(uids=[@myuid])
		# TODO: make various event
		event =$events[rand($events.size)]
		{:user => uids, :to => '', :name => event[:name], :value => event[:value] }
	end

	def self.show_question(uid, qid)
		puts "show_question" if Config::DEBUG
		$view.event_question_first(uid, qid)
	end

	def self.show_result(uid, answer)
		puts "show_result" if Config::DEBUG
		$view.event_question_last(uid, answer)
	end

	def self.exec_command(msg={})
		puts "exec_command" if Config::DEBUG
		puts msg
		case msg[:body][:name]
		when "move"
			puts "command: move" if Config::DEBUG
			$screen.fill_rect(0,450,630,350,[0,0,0])
			msg[:body][:user].each do |uid|
				$view.write_str($screen,"#{User.find(uid).name} さんにイベント発生！",10,470)
				$view.write_str($screen,"#{msg[:body][:value]} マス進みます",10,490)
				move(msg[:body][:value], uid)
			end
		when "give_p"
			#TODO
			puts "command: give_p" if Config::DEBUG
		end
	end
end
