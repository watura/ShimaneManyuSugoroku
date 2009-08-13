class Roulette
  require 'rubygems'
	require 'sdl'

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
              SDL::Surface.transform_blit(rlt,$screen, 0, 1, 1, 0, 0,633,-2, 0)
              delta_angle = rlt_num - n
              angle += delta_angle
              move = SDL::Surface.transform_blit(image,$screen,angle,1,1,0,0,724,86,0)
              $screen.update_rect(0, 0, 0, 0)
              sleep 0.01
            end
            $screen.fill_rect(630,0,Config::SCREEN_W,180,[0,0,0])
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
