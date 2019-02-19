require 'natto'
require_relative './marcov.rb'
require 'uri'
require 'twitter'
require 'cgi'

@marcov = Marcov.new
@client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CK']
    config.consumer_secret     = ENV['TWITTER_CS']
    config.access_token        = ENV['TWITTER_TOKEN']
    config.access_token_secret = ENV['TWITTER_SECRET']
end

def removeURL(text)
    URI.extract(text).uniq.each {|url| text.gsub!(url, '')}
    return text
end

def removeMention(text)
    return text.gsub(/@[^\s\R]+[\s\R$]*|@[^\s]*$/,"")
end

def removeHashTags(text)
    return text.gsub(/#[^\s\R]+[\s\R$]*|#[^\s]*$/,"")
end

def removeRT(text)
    return text.gsub(/^RT/,"")
end

def makeText(texts)
    threeWordsArray = []
    texts.each do |text|
        text = removeURL(removeHashTags(removeMention(removeRT(text))))
        @marcov.makeThreeWordsArray(@marcov.makeWordsArray(text)).each do |threeWords|
            threeWordsArray.push threeWords
        end
    end
    return @marcov.makeSentence(threeWordsArray)
end

def makeTextArray(tweets)
    texts = []
    tweets.each do |tweet|
        texts.push CGI.unescapeHTML(removeMention(tweet.text))
    end
    return texts
end

def upTweet
    tweets = @client.home_timeline(count: 200)
    text=''
    while(text.length <= 5 || text.length >= 140)
        text = makeText(makeTextArray(tweets))
    end
    @client.update(text, options = {})
    puts text
end

# For debug
# tweets = @client.home_timeline(count: 200)
# 10.times do
#     puts makeText(makeTextArray(tweets))
# end