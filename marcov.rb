class Marcov

    def initialize(text="")
        @text = text
        @nm = Natto::MeCab.new(dicdir: "/app/vendor/mecab/dic/mecab-ipadic-neologd")
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
        # puts "targetは#{[target].to_s}です"
        fourWordsArray.each do |fourWords|
            options.push fourWords if fourWords[0] == target
        end
        random = Random.new()
        # puts options.to_s.gsub("\n","\t")
        return [nil,nil,nil,nil] if options.length <= 0
        return options[random.rand(0..(options.length - 1))]
    end

    def makeSentence(fourWords)
        # puts threeWords.to_s
        fourBlocks = []
        result = ""
        fourBlocks.push findAndSelectBlock(fourWords, nil)
        while fourBlocks.last.last != nil do
            fourBlocks.push findAndSelectBlock(fourWords, fourBlocks.last.last)
        end
        # puts threeBlocks.to_s
        fourBlocks.each do |block|
            for i in (1..2) do
                result << block[i] unless block[i].nil?
            end
        end
        return result
    end

    def result
        return makeSentence(makeFourWordsArray(makeWordsArray(@text)))
    end

end