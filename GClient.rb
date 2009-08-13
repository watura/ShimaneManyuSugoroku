# -*- coding: utf-8 -*-
require 'rubygems'
require 'sdl'
require 'matrix'
require 'nkf'
require 'Map.rb'
require 'Roulette.rb'
require 'GSocket.rb'
require 'GMessage.rb'
require 'Action.rb'
require 'User.rb'
require 'Config.rb'
require 'pp' if Config::DEBUG

IMG_CHARA = ["./img/chara1.png","./img/chara2.png","./img/chara3.png","./img/chara4.png"]

# SDL init
SDL.init(SDL::INIT_VIDEO)
SDL::TTF.init	
$screen = SDL::Screen.open(Config::SCREEN_W,Config::SCREEN_H,32,SDL::SWSURFACE)
$screen.fill_rect(630,180,180,600,[0,255,255])

# read TILE && CHARA IMGs
Config::IMG_TILES.each_with_index do |value,index|
  Config::IMG_TILES[index] = SDL::Surface.load(value)
  Config::IMG_TILES[index].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
end
#IMG_CHARA.each_with_index do |value,index|
#  IMG_CHARA[index] = SDL::Surface.load(value)
#  IMG_CHARA[index].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
#end

$questions = Utils.read_questions(Config::QFILEPATH)
$events = Config::EVENTS


# open socket
GSocket::Client.open

# send init msg
msg = GMessage.mkmsg("init", "init", {:name => ARGV[0]})
GSocket::Client.send(msg)
pp "send INIT"  if Config::DEBUG

# wait for confirm
msg = GSocket::Client.recv
if msg[:type] == "init" && msg[:action] == "confirm"
	pp "recv CONFIRM" if Config::DEBUG
	# TODO: print alert
	$myuid = msg[:body][:uid]
	GMessage.init($myuid)
	Action.init($myuid)
else
	exit 1
end

# draw MAP
$view = Map.new
$dice = Roulette.new



# START GAME
msg = GSocket::Client.recv
exit 1 unless msg[:type] == "init" && msg[:action] == "start"
pp "recv START" if Config::DEBUG
# TODO: print alert
# register members
$imgs_chara = []
i = 0
msg[:body][:members].each do |m|
	User.new(*m)
	#$imgs_chara << SDL::Surface.load((Config::IMG_CHARA)[i])
	$imgs_chara << SDL::Surface.load(IMG_CHARA[i])
  $imgs_chara[i].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
	i += 1
end

msg[:body][:first] == $myuid ? Action.myturn : Action.yourturn(msg[:body][:first])

loop {
	msg = GSocket::Client.recv
	pp msg if Config::DEBUG
	GMessage.parse(msg)
 }

GSocket::Client.close

