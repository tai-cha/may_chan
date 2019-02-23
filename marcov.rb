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

    def makeThreeWordsArray(words)
        threeWords = []
        words.unshift(nil)
        words.push(nil)
        (0..words.length-3).each do |i|
            threeWords.push [words[i], words[i+1], words[i+2]]
        end
        return threeWords
    end

    def findAndSelectBlock(threeWordsArray, target)
        options = []
        # puts "targetは#{[target].to_s}です"
        threeWordsArray.each do |threeWords|
            options.push threeWords if threeWords[0] == target
        end
        random = Random.new()
        # puts options.to_s.gsub("\n","\t")
        return [nil,nil,nil] if options.length <= 0
        return options[random.rand(0..(options.length - 1))]
    end

    def makeSentence(threeWords)
        # puts threeWords.to_s
        threeBlocks = []
        result = ""
        threeBlocks.push findAndSelectBlock(threeWords, nil)
        while threeBlocks.last.last != nil do
            threeBlocks.push findAndSelectBlock(threeWords, threeBlocks.last.last)
        end
        # puts threeBlocks.to_s
        threeBlocks.each do |block|
            for i in (1..2) do
                result << block[i] unless block[i].nil?
            end
        end
        return result
    end

    def result
        return makeSentence(makeThreeWordsArray(makeWordsArray(@text)))
    end

end