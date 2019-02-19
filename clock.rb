require 'clockwork'
require './bot.rb'
include Clockwork

every(5.minutes, 'upTweet.job') do
    upTweet
end