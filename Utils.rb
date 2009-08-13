module Utils

	require 'csv'
	def self.allkeys?(keys, hash)
		keys.each do |k|
			return false unless hash.key? k
		end	
		return true
	end

	def self.get_next_uid(uid)
		'%03d' % ((uid.to_i) % Config::NUM_USERS + 1)
	end

	def self.read_questions(path)
		questions = []
		CSV.open(path, "r") {|row|
			questions << {:qid => row[0],
										:question => row[1],
										:question => row[1],
										:choice => [row[2], row[3], row[4]],
										:answer => row[5].to_i,
										:point => row[6].to_i}
		}
		return questions
	end
	
	def self.get_mapno(map)
		case map.size
		when 20
			return 0
		when 12
			return 1
		when 3
			return 2
		end
	end
end
