require 'clockwork'
require './bot.rb'
require 'time'
include Clockwork

every(1.minutes, 'upTweet.job') do
    if Time.now.min % 5 == 0
        puts "実行中..."
        upTweet
    end
end