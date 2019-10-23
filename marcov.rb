class Marcov

    DEBUG = ENV['DEBUG'] || false

    def initialize(text="")
        @text = text
        if DEBUG
            @nm = Natto::MeCab.new
        else
            @nm = Natto::MeCab.new(dicdir: "/app/vendor/mecab/dic/mecab-ipadic-neologd")
        end
    end

    def makeWordsArray(text)
        words = []
        @nm.parse(text) do |n|
            words.push "#{n.surface}"
        end
        words -= [""]
        return words
    end

    def makeFourWordsArray(words)
        fourWords = []
        words.unshift(nil)
        words.push(nil)
        (0..words.length-4).each do |i|
            fourWords.push [words[i], words[i+1], words[i+2], words[i+3]]
        end
        return fourWords
    end

    def findAndSelectBlock(fourWordsArray, target)
        options = []
        puts "targetは#{[target].to_s}です" if DEBUG
        fourWordsArray.each do |fourWords|
            options.push fourWords if fourWords[0] == target
        end
        random = Random.new
        # puts options.to_s.gsub("\n","\t") if DEBUG
        return [nil,nil,nil,nil] if options.length <= 0
        return options[random.rand(0..(options.length - 1))]
    end

    def makeSentence(fourWords)
        puts fourWords.to_s if DEBUG
        fourBlocks = []
        result = ""
        fourBlocks.push findAndSelectBlock(fourWords, nil)
        while fourBlocks.last.last != nil do
            fourBlocks.push findAndSelectBlock(fourWords, fourBlocks.last.last)
        end
        puts fourBlocks.to_s if DEBUG
        fourBlocks.each do |block|
            (1..3).each do |i|
                if block[i] =~ %r(^[a-zA-Z0-9!-/:-@¥\[-`{-~]*$)
                    block[i] << " "
                end
                result << block[i] unless block[i].nil?
            end
        end
        result
    end

    def result
        makeSentence(makeFourWordsArray(makeWordsArray(@text)))
    end

end