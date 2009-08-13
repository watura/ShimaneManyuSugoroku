module Config
  
	## debug info
	DEBUG = true
	
	## map info
	SCREEN_W = 810
	SCREEN_H = 600
	ICON_SIZE = 90
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
	
	## GServer.rb
	NUM_USERS = 2     # number of members to play
	INIT_POINT = 1000 


	## GSocket.rb
	#HOST = "anbey.sakura.ne.jp" # server host
	HOST = "localhost"
	PORT = 12345 								# server port
	MAXMSGLEN = 65536						# max recv msg size

	## User.rb
	THRD1 = 1500      # POINT threshold : stage 1 -> 2 
	THRD2 = 2000      # POINT threshold : stage 2 -> 3
	
	## question
	QFILEPATH = "questions.txt"

	## event
	EVENTS = [{:name => "move", :value => 1}, {:name => "move", :value => 3},
					  {:name => "move", :value => 5}, {:name => "move", :value => -1},
					  {:name => "move", :value => -3}, {:name => "move", :value => -5}]

	## questionマス
	MAP_QUESTION = [[0,2],[0,17],[0,7],[0,12],[1,1],[1,7],[2,0],[2,2]]

	## eventマス
	MAP_EVENT = [[0,4],[0,10],[0,14],[1,2],[1,4],[1,6],[1,9]]

	## check point
	MAP_CHKP = [[0,0],[1,0],[2,1]]
end
