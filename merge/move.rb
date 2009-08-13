# -*- coding: utf-8 -*-
require 'rubygems'
require 'sdl'
require 'matrix'

SCREEN_W = 810
SCREEN_H = 600
ICON_SIZE = 90
SDL.init(SDL::INIT_VIDEO)
SDL::TTF.init	
$screen = SDL::Screen.open(SCREEN_W, SCREEN_H,32,SDL::SWSURFACE)
$screen.fill_rect(630,180,180,600,[0,255,255])
QSAMPLE = {
  :qid => "000",
  :question => "QWERTYUIOPLKJHGFDSAZXCVBNMQWERTYUIOPLKJHGFDSAZXCVBNM",
  :choice => [
              "fooooooo",
              "baaaar",
              "fizz"
             ],
  :answer => 2,
  :point => 100
}
QUESTIONS = [QSAMPLE,{
  :qid => "001",
  :question => "This is a question 001, and answer is 2",
  :choice => [
              "buzz",
              "fizzbuzz",
              "lambda"
             ],
  :answer => 1,
  :point => 100
}]

MAP = [
       [[0,0],[0,1],[0,2],[0,3],[0,4],
        [1,4],[2,4],[3,4],[4,4],[5,4],
        [6,4],[6,3],[6,2],[6,1],[6,0],
        [5,0],[4,0],[3,0],[2,0],[1,0]],
       [[1,1],[1,2],[1,3],[2,3],[3,3],[4,3],
        [5,3],[5,2],[5,1],[4,1],[3,1],[2,1]],
       [[2,2],[3,2],[4,2]]
      ]
MAP_TILES = [
             [1,0,0,4,0,0,7],
             [0,3,0,0,0,0,0],
             [4,5,6,2,6,5,4],
             [0,0,0,0,0,0,0],
             [7,0,0,4,0,0,7]
            ]

IMG_TILES = [
             "./img/tile1.jpg","./img/tile2.jpg" , "./img/tile3.jpg",
             "./img/tile1.jpg","./img/tile2.jpg" , "./img/tile3.jpg",
             "./img/tile1.jpg","./img/tile2.jpg" , "./img/tile3.jpg"
            ]
IMG_CHARA =['./img/chara.bmp','./img/1.bmp']

IMG_TILES.each_with_index do |value,index|
  IMG_TILES[index] = SDL::Surface.load(value)
  IMG_TILES[index].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
end
class Map
  def initialize
    @font = SDL::TTF.open('./sazanami-gothic.ttf',24)
  end
  def tiles(x,y) #タイルのイメージ番号を取得
    return IMG_TILES[MAP_TILES[y][x] ]
  end
  
  def render_chara(img,place)#キャラクターを描画
    x,y = cordinates(place)
    $screen.put(img,x*90+rand(10),y*90+rand(10))
    $screen.updateRect( 0, 0, 0, 0 ) 
  end
  def cordinates(place)
    if place[0] == 0
      x = MAP[place[0]][place[1]%20][0]
      y = MAP[place[0]][place[1]%20][1]
    elsif place[0] ==1
      x = MAP[place[0]][place[1]%12][0]
      y = MAP[place[0]][place[1]%12][1]
    else
      x = MAP[place[0]][place[1]%3][0]
      y = MAP[place[0]][place[1]%3][1]
    end
    return x,y
  end
  
  def render_tile(place)#タイルを描画
    x,y = cordinates(place)
    $screen.put(tiles(x,y),x*90,y*90)
    $screen.updateRect( 0, 0, 0, 0 ) 
  end
  
  def move(usr,place,distance)
    distance.each do |n|
      n.times do |i|
        render_tile(place)
        place[1] += 1
        render_chara(usr,place)
        x_mark
        sleep(0.1)
      end
    end
    $basho = place
    return place
  end

  def x_mark#バツボタン
    while event = SDL::Event2.poll
      case event
      when SDL::Event2::Quit
        exit
      end  
    end	
  end
  
  def dice(x,y,time=1)
    num= 0
    ret =[] 
    time.times do
      wait=0.01
      while wait < 0.5
        srand
        num = rand(60)+1
        $screen.fill_rect(x,y, 32,32, [155,0,145])
        @font.draw_solid_utf8($screen,num.to_s,x+10,y,255,255,255)
        $screen.updateRect( 0, 0, 0, 0 )
        sleep(wait)
        wait *= 1.1
        x_mark
      end
      @font.draw_solid_utf8($screen,num.to_s,x+10,y+50,255,255,255)
      ret << num
    end
    return ret	
  end
  def event_check_answer(array,uanswer)
    
 #   @font.draw_solid_utf8($screen,"3." + question[1][2],10,540,255,255,255)
#    return array[2] == uanswer?0:1 ##0 = true 1 = false
  end
  def event_puts_question(qid)
    question = QUESTIONS.select{|x| x[:qid] == qid.to_s}
    question = [
                question[0][:question],
                question[0][:choice],
                question[0][:answer]
               ]
    @font.draw_solid_utf8($screen,"Question!",10,450,255,255,255)
    @font.draw_solid_utf8($screen,question[0],10,480,255,255,255)
    @font.draw_solid_utf8($screen,"1." + question[1][0],10,500,255,255,255)
    @font.draw_solid_utf8($screen,"2." + question[1][1],10,520,255,255,255)

  end
end

view = Map.new
#view.event_puts_question("000")
20.times do |i|
  view.render_tile([0,i])
end
12.times do |i|
  view.render_tile([1,i])
end
3.times do |i|
  view.render_tile([2,i])
end

IMG_CHARA.each_with_index do |value,index|
  srand
  IMG_CHARA[index] = SDL::Surface.load(value)
  IMG_CHARA[index].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
  $screen.put(IMG_CHARA[index],rand(30),rand(30))
  $screen.updateRect( 0, 0, 0, 0 )
end


$basho = [0,0]
while true
  while event = SDL::Event2.poll
    case event
    when SDL::Event2::Quit
      exit
    when SDL::Event2::KeyDown
      if event.sym == SDL::Key::SPACE
        view.move(IMG_CHARA[0],$basho,view.dice(660,10))
      else
        $basho = [1,1]
        view.move(IMG_CHARA[0],$basho,view.dice(660,10,2))
      end
    end
 end
  sleep 0.01
end
