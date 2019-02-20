require 'natto'
require_relative './marcov.rb'
require 'uri'
require 'twitter'
require 'cgi'
require 'dropbox_api'

@marcov = Marcov.new
@client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CK']
    config.consumer_secret     = ENV['TWITTER_CS']
    config.access_token        = ENV['TWITTER_TOKEN']
    config.access_token_secret = ENV['TWITTER_SECRET']
end

MY_ID = ENV['MY_ID'].to_i

@dropbox_client = DropboxApi::Client.new(ENV['DROPBOX_ACCESS_TOKEN'])

def reply(tweet,message="")
    tweet_text = "@#{tweet.user.screen_name} #{message}"
    @client.update(tweet_text, options = {:in_reply_to_status_id => tweet.id})
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
    tweets.each do |tweet|
        @client.favorite(tweet, options={}) if tweet.text.include?("めいちゃん") && !tweet.favorited?
        if tweet.in_reply_to_user_id == MY_ID
            has_my_reply = false
            tweet.entities.user_mentions.each do |mention_tweet|
                has_my_reply = true
            end
            unless has_my_reply
                text=''
                while(text.length <= 4 || text.length >= 130)
                    text = makeText(makeTextArray(tweets))
                end
                reply(tweet, text)
            end
        end
    end
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