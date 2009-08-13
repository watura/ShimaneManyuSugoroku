class Map
	require 'rubygems'
	require 'sdl'
	require 'nkf'
	require 'Config.rb'


	def self.print_status(players)
		$screen.fill_rect(630,180,180,420,[0,255,255])
		write_status($screen,"Player/Point",Config::SCREEN_W-175,180,[212,41,41])
		players.each_with_index do |player, n|
			write_status($screen,player.name,Config::SCREEN_W-175,200+50*n,[0,0,0])
			write_status($screen,"  "+player.point.to_s,Config::SCREEN_W-175,230+50*n,[0,0,0])
			$screen.update_rect(0,0,0,0)
		end
	end

	def self.write_status(screen, str, x, y, color=[255,255,150], font=["./sazanami-gothic.ttf",24])
		@font = SDL::TTF.open(*font)
  	@font.draw_solid_utf8(screen,NKF.nkf("-	w", str),x,y,*color)
		$screen.update_rect(0,0,0,0)	
	end

  def write_str(screen, str, x, y, color=[255,255,150], font=["./sazanami-gothic.ttf",20])  
		@font = SDL::TTF.open(*font)
  	@font.draw_solid_utf8(screen,NKF.nkf("-	w", str),x,y,*color)
		$screen.update_rect(0,0,0,0)	
	end
	
	def render_samep_chara(uid, place)
		User.get_upositions.each_with_index do |value,index|
			render_chara($imgs_chara[index],place) if value[0] != uid && cordinates([value[1],value[2]]) == cordinates(place)
		end
	end
	
  def initialize
		20.times do |i|
  		self.render_tile([0,i])
		end
		12.times do |i|
  		self.render_tile([1,i])
		end
		3.times do |i|
  		self.render_tile([2,i])
		end
  end

	# get tile image
  def tiles(x,y) 
    return Config::IMG_TILES[Config::MAP_TILES[y][x] ]
  end
  
  def render_chara(img,place)
    x,y = cordinates(place)
    $screen.put(img,x*90,y*90)
    $screen.updateRect( 0, 0, 0, 0 ) 
  end

  def cordinates(place)
    if place[0] == 0
      x = Config::MAP[place[0]][place[1]%20][0]
      y = Config::MAP[place[0]][place[1]%20][1]
    elsif place[0] ==1
      x = Config::MAP[place[0]][place[1]%12][0]
      y = Config::MAP[place[0]][place[1]%12][1]
    else
      x = Config::MAP[place[0]][place[1]%3][0]
      y = Config::MAP[place[0]][place[1]%3][1]
    end
    return x,y
  end
  
  def render_tile(place)
    x,y = cordinates(place)
    $screen.put(tiles(x,y),x*90,y*90)
    $screen.updateRect( 0, 0, 0, 0 ) 
  end
  
  def move(usr,place,distance)
		if distance > 0
	    distance.times do |i|
	      render_tile(place)
				render_samep_chara('%03d' % ($imgs_chara.index(usr)+1), place)
	      place[1] += 1
	      render_chara(usr,place)
				render_samep_chara('%03d' % ($imgs_chara.index(usr)+1), place)
	      x_mark
      	sleep(0.1)
    	end
		else
			distance.abs.times do |i|
      	render_tile(place)
				render_samep_chara('%03d' % ($imgs_chara.index(usr)+1), place)
      	place[1] -= 1
      	render_chara(usr,place)
				render_samep_chara('%03d' % ($imgs_chara.index(usr)+1), place)
      	x_mark
      	sleep(0.1)
    	end
		end
    return place
  end

  def x_mark # x button
    while event = SDL::Event2.poll
      case event
      when SDL::Event2::Quit
        exit
      end  
    end	
  end

### for event ###
  def event_question_first(uid,qid)
    @question = $questions.select{|x| x[:qid] == qid.to_s}
    @question = [
                @question[0][:question],
                @question[0][:choice],
                @question[0][:answer],
                @question[0][:point]
               ]
    event_render_question
    return event_get_answer if uid == $myuid
  end

  def event_render_question
		$screen.fill_rect(0,450,630,350,[0,0,0])
    write_str($screen,"Question",10,450)
    write_str($screen,@question[0],10,470)
    write_str($screen,"1."+ @question[1][0],10,490)
    write_str($screen,"2."+@question[1][1],10,510)
    write_str($screen,"3."+@question[1][2],10,530)
    $screen.updateRect( 0, 0, 0, 0 )
  end

  def event_get_answer
    while true
      while event = SDL::Event2.poll
        case event
        when SDL::Event2::Quit
          exit
        when SDL::Event2::KeyDown
          return  0 if event.sym == SDL::Key::K1
          return  1 if event.sym == SDL::Key::K2
          return  2 if event.sym == SDL::Key::K3
        end
      end
      sleep 0.01
    end
  end

  def event_question_last(uid,answer)
		user = User.find(uid)
    write_str($screen,user.name + " さんの選択肢： " + (@question[2]+1).to_s + "番",10,570)
    if @question[2].to_i == answer
      correct = 0
     	write_str($screen," 正解です。 " + @question[3].to_s + "point 獲得" ,300,570)
			user.point += @question[3]
    else
      correct = 1
      write_str($screen," 不正解です。",300,570)
    end
		$screen.updateRect( 0, 0, 0, 0 )
    return correct
  end 
end
