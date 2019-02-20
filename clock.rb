require 'clockwork'
require './bot.rb'
require 'active_support/all'
require 'time'
include Clockwork

every(1.minute, 'upTweet.job') do
    if Time.now.min % 5 == 0
        upTweet
    end
    checkFollowers
end