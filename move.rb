# -*- coding: utf-8 -*-
require 'rubygems'
require 'sdl'
require 'matrix'
require 'nkf'

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
             [0 ,1, 2, 3, 1 ,2, 4],
             [15,16,17,18,17,19,5],
             [14,24,25,27,26,20,6],
             [13,22,17,18,17,21,7],
             [12,10, 9,11,10, 9,8]
            ]

IMG_TILES = [
             "./img/start-1.jpg","./img/soto6.jpg" , "./img/soto5.jpg",
             "./img/hata1.jpg","./img/hatena4-1.jpg" , "./img/soto8.jpg",
             "./img/hata3-1.jpg","./img/soto7.jpg" , "./img/hatena5-1.jpg",
             "./img/soto2.jpg","./img/soto1.jpg","./img/hata2.jpg",
             "./img/hatena6-1.jpg","./img/soto4.jpg","./img/hata4-1.jpg",
             "./img/soto3.jpg","./img/hata5-1.jpg","./img/c2.jpg",
             "./img/hatena1.jpg","./img/c3.jpg","./img/hasi2.jpg",
             "./img/hatena2-1.jpg","./img/hatena3.jpg","./img/c1.jpg",
             "./img/b1.jpg","./img/hasi3.jpg","./img/hasi5-1.jpg",
             "./img/gorl.jpg"
            ]
IMG_CHARA =['./img/chara.bmp','./img/1.bmp']

IMG_TILES.each_with_index do |value,index|
  IMG_TILES[index] = SDL::Surface.load(value)
  IMG_TILES[index].set_color_key(SDL::SRCCOLORKEY, [255,255,255])
end
class Map
  def write_str(screen, str, x, y, color=[255,255,150], font=["./sazanami-gothic.ttf",20])
    @font = SDL::TTF.open(*font)  
  	@font.draw_solid_utf8(screen,NKF.nkf("-	w", str),x,y,*color)
	end
  def initialize
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
    distance.times do |i|
      render_tile(place)
      place[1] += 1
      render_chara(usr,place)
      x_mark
      sleep(0.1)
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
=begin  
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
=end

  ##イベント関係
  def event_question_first(uid,qid)
    @question = QUESTIONS.select{|x| x[:qid] == qid.to_s}
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
    return event_check_answer(uid,answer)
  end 
  
  def event_check_answer(uid,answer)
    @font.draw_solid_utf8($screen,
                          "Answer is No." + 
                          (@question[2]+1).to_s + ". " + uid.to_s+ " chose ",
                          10,570,255,255,255)
    if @question[2].to_i == answer
      correct = 0
      @font.draw_solid_utf8($screen,(1 + answer).to_s + " " + @question[3].to_s + "point get." ,
                            320,570,255,255,255)
    else
      correct = 1
      @font.draw_solid_utf8($screen,(1 + answer).to_s + " WRONG",
                            320,570,255,255,255)
    end
    return correct
    $screen.updateRect( 0, 0, 0, 0 )
  end
  
end


class Roulette
  
  #difine function
  def load_image(fname)          
    image = SDL::Surface.load(fname)
    image.set_color_key(SDL::SRCCOLORKEY, [255,255,255])
    return image
	end
  # ルーレットの実行
  def run
    # input image
    image = load_image("img/darts.png")
    rlt = load_image("img/rlt.png")
    #ダミーの回転数
    rlt_num = rand(100)+100
    #サイコロの目
		dice_num = rand(6) +1
    angle = 0
    while true
      while event = SDL::Event.poll
        case event
        when SDL::Event::Quit
          exit 
        when SDL::Event::KeyDown
          SDL::Key.scan
          if SDL::Key.press?(SDL::Key::SPACE)
            #ダミーの回転
            (rlt_num).times do |n|
              #ルーレット画面の初期化
              #$screen.fill_rect(630,0,SCREEN_W,180,[0,0,0])
              SDL::Surface.transform_blit(rlt,
                                          $screen, 0, 1, 1, 0, 0,
                                         633,-2, 0)
              delta_angle = rlt_num - n
              angle += delta_angle
              move = SDL::Surface.transform_blit(image,
                                                 $screen,angle,1,1,0,0,724,86,0)
              $screen.update_rect(0, 0, 0, 0)
              sleep 0.01
            end
            $screen.fill_rect(630,0,SCREEN_W,180,[0,0,0])
            #さいころの目とルーレットを合わせる
            angle = 60 * (dice_num-1)
            SDL::Surface.transform_blit(rlt, $screen, 0, 1, 1, 0, 0, 633, -2, 0)
            move = SDL::Surface.transform_blit(image,$screen,angle,1,1,0,0,724,90,0)
            $screen.update_rect(0, 0, 0, 0)
            return dice_num
          end
        end
      end
    end
  end  
end


view = Map.new
dice = Roulette.new
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
      view.event_question_first("001","001")
      view.event_question_last("001",1)
      if event.sym == SDL::Key::SPACE
        view.move(IMG_CHARA[0],$basho,dice.run)
        #      else
        #        $basho = [1,1]
        #        view.move(IMG_CHARA[0],$basho,view.dice(660,10,2))
      end
    end
 end
  sleep 0.01
end

# $basho -> [user.current_map, user.position]
view.move(IMG_CHARA[0],$basho,dice.run)

# uid, qid
view.event_question_first("001","001")

# uid, answer
view.event_question_last("001",1)