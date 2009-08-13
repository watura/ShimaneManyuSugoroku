require 'sdl'

SCREEN_W = 800
SCREEN_H = 600

SDL::init(SDL::INIT_VIDEO)
SDL::TTF.init

$screen = SDL.set_video_mode(SCREEN_W, SCREEN_H, 16, SDL::SWSURFACE)

class Status
### class method ###
	#SDL::TTF.init
	@@font = SDL::TTF.open('../sazanami-gothic.ttf',24)

	def self.print_status(players)
		@@font.draw_solid_utf8($screen,"Player/Point",SCREEN_W-175,180,212,41,41)
		players.each_with_index do |(key, value), n|
			@@font.draw_solid_utf8($screen,key,SCREEN_W-175,200+50*n,0,0,0)
			@@font.draw_solid_utf8($screen,"  "+value,SCREEN_W-175,230+50*n,0,0,0)
			$screen.update_rect(0,0,0,0)
			
		end
	end

### instance method ###
	def initialize
		#@player = {"坪川" => "100","雄平" => "20","name" =>"300","player" => "300","川村" => "600"}
		#@player = {} #playerのhashを初期化
		@font = SDL::TTF.open('../sazanami-gothic.ttf',24)
	end
	

	def print
		@font.draw_solid_utf8($screen,"Player/Point",SCREEN_W-175,180,212,41,41)
		@player.to_a.sort.each_with_index do |(key, value), n|
			@font.draw_solid_utf8($screen,key,SCREEN_W-175,200+50*n,0,0,0)
			@font.draw_solid_utf8($screen,"  "+value,SCREEN_W-175,230+50*n,0,0,0)
			$screen.update_rect(0,0,0,0)
		end
	end
end

#Status.print_status({"坪川" => "100","雄平" => "20","name" =>"300","player" => "300","川村" => "600"})

#status = Status.new
#status.print

#msg = Status.new
#msg.print

#sleep 2

=begin
player = {"yuhei" => "100","tubo" => "20"}
player.each_with_index do |(key, value), n|
	p [key, value]
end
=end
