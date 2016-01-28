require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end
  
  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message entered is too long to tweet, please try again"
    end  
  end
  
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
  
  def followers_list
    screen_names = Array.new
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    return screen_names
  end
  
  def spam_my_followers(message)
    followers = followers_list
    followers.each {|follower| dm(follower,message)}
  end
  
  def everyones_last_tweet
    friends = @client.friends.collect { |friend| @client.user(friend) }
    friends.each do |friend|
      puts friend.screen_name
      puts friend.status.text
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
        else
          puts "Sorry, I don't how to #{command}"
      end
    end
  end
  
  
end

blogger = MicroBlogger.new
blogger.run
