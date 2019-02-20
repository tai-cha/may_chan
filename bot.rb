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

@dropbox_client = DropboxApi::Client.new(ENV['DROPBOX_ACCESS_TOKEN'])

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

def checkFollowers
    current_followers = @client.follower_ids(MY_ID).take(7500)
    older_followers = ""
    last_tweet_id_file = @dropbox_client.download "/may_chan/followers.txt" do |chunk|
        older_followers << chunk
    end
    older_followers = older_followers.gsub("[","").gsub("]","").split(", ").map(&:to_i)
    newFollowers = current_followers - older_followers
    unFollowed = older_followers - current_followers

    @client.follow(newFollowers)
    @client.unfollow(unFollowed)

    @dropbox_client.upload(
        sprintf("%s","/may_chan/followers.txt"),
        current_followers.to_s,
        :mode =>:overwrite
    )
end

# For debug
# tweets = @client.home_timeline(count: 200)
# 10.times do
#     puts makeText(makeTextArray(tweets))
# end