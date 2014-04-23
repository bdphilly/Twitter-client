require 'twitter_session'

class User < ActiveRecord::Base
	validates :screen_name, :twitter_user_id, uniqueness: true
	validates :twitter_user_id, :twitter_user_id, presence: true


	def self.fetch_by_screen_name!(screen_name)
		params = TwitterSession.get(
									"users/show",
								{ :screen_name => screen_name } )

		user = self.parse_twitter_user(params)
		user.save!

		user
	end

	def self.get_by_screen_name(screen_name)
		user = User.find_by_screen_name(screen_name)

		if user.nil?
			user = User.fetch_by_screen_name!(screen_name)
		end

		user
	end

	def self.parse_twitter_user(twitter_user_params)
		User.new( 
			  :screen_name => twitter_user_params["screen_name"],
				:twitter_user_id => twitter_user_params["id_str"]
			)
	end

end
