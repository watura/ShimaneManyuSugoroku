class User
	include Enumerable, Comparable
	require 'Config.rb'
	require 'Utils.rb'

	attr_accessor :uid, :name, :point, :port, :addr, :current_map, :position
	@@users = []

### class methods ###
	def self.all
		@@users
	end

	def self.ranking
		@@users.sort.reverse
	end

	def self.top
		@@users.max
	end

	def self.last
		@@users.min
	end

	def self.find(uid="")
		@@users.select {|x| x.uid == uid}.first
	end

	def self.remove(uid="")
		@@users.delete_if {|x| x.uid == uid }
	end

	def self.choice
		@@users[rand(@@users.size)]
	end

	def self.get_profiles
		@@users.map {|user| [user.uid, user.name, user.point]}
	end

	def self.check_map
		@@users.each do |user|
			if user.point > Config::THRD1 && user.current_map == Config::MAP[0]
				place = [Utils.get_mapno(user.current_map), user.position]
				$view.render_tile(place)
				$view.render_samep_chara(user.uid, place)
				user.position = 0
				user.current_map = Config::MAP[1]
				place = [Utils.get_mapno(user.current_map), user.position]
				$view.render_chara($imgs_chara[(user.uid.to_i)-1], place)
				$view.render_samep_chara(user.uid, place)
			elsif user.point > Config::THRD2 && user.current_map == Config::MAP[1]
				place = [Utils.get_mapno(user.current_map), user.position]
				$view.render_tile(place)
				$view.render_samep_chara(user.uid, place)
				user.position = ( (user.position+2)%12 < 6 ) ? 0 : 2
				user.current_map = Config::MAP[2]
				place = [Utils.get_mapno(user.current_map), user.position]
				$view.render_chara($imgs_chara[(user.uid.to_i)-1], place)
				$view.render_samep_chara(user.uid, place)
			end
		end
	end

	def self.get_upositions
		positions = []
		@@users.each do |user|
			positions << [user.uid, Utils.get_mapno(user.current_map), user.position]
		end
		return positions
	end
### instance methods ###
	def initialize(uid, name, point=1000, addr="", port="")
		@uid, @name, @point = uid, name, point
		@port, @addr = port, addr
		@current_map = Config::MAP[0]
		@position = 0
		@@users << self
	end

	def destroy
		@@users.delete(self)
	end

	def to_a
		[@uid, @name, @point, @port, @addr]
	end

	def to_s
		self.to_a.join(":")
	end

	def <=>(other)
		return nil unless other.instance_of? User
		@point <=> other.point
	end
end
