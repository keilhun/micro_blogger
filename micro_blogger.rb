###########################################################################################################################################################
#
# Micro_blogger. Program that interacts with twitter.com. Allowing tweets to be sent, direct messages to be sent and also get the KLOUT score for all
# your friends.
#
##########################################################################################################################################################

require 'jumpstart_auth'
require 'bitly'
require 'klout'


class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end
  
  #
  # Send out a tweet
  #
  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message entered is too long to tweet, please try again"
    end  
  end
  
  #
  # Send a direct message to a user following you
  #
  
  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      tweet (message)
    else
      puts "You can't send a direct message to #{target} because they do not follow you"
    end
  end
  
  #
  # Get list of the screen names of everyone following you
  #
  def followers_list()
    screen_names = Array.new
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    return screen_names
  end
  
  #
  # Send a tweet out to all people following you
  $
  def spam_my_followers(message)
    followers = followers_list()
    followers.each {|follower| dm(follower,message)}
  end
  
  #
  # Get the last tweet from all of your friends.
  #
  def everyones_last_tweet
    # get list of all your friends sorted alphabetically
    friends = @client.friends.collect { |friend| @client.user(friend) }.sort_by {|friend| friend.screen_name.downcase}
    friends.each do |friend|
     # puts friend.screen_name
      timestamp = friend.status.created_at
      printf("%s said this on %s\n", friend.screen_name, timestamp.strftime("%A, %b %d"))
      puts friend.status.text
      puts ""
    end
  end
  
  #
  # Use Bitly to generate a shortened URL
  #
  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
    #puts "Shortening this URL: #{original_url}"
  end
  
  #
  # Get all friends KLOUT score
  #
  def klout_score()
     friends = @client.friends.collect { |friend| @client.user(friend) }.sort_by {|friend| friend.screen_name.downcase}
     puts "KLOUT Scores"
     friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend.screen_name)
      user = Klout::User.new(identity.id)
      puts "#{friend.screen_name}: #{user.score.score}"
      puts ""
     end
  end
  
  def run
    puts "welcome to the JSL Twitter Client!"
    command = ""
    while command != 'q'
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet()
        when 's' then shorten(parts[1])
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when 'klout' then klout_score()
        else
          puts "Sorry, I don't how to #{command}"
      end
    end
  end
  
  
end

blogger = MicroBlogger.new
blogger.run
