
fuzzy =
    matchNeedlemanWunsch: (search, space, opts) ->
        opts = opts or {}
        gapPenalty = 1 or opts.gapPenalty

        matrix = []
        # intialize F matrix
        for i in search
            matrix[i][0] = i * gapPenalty
        for j in space
            matrix[0][j] = j * gapPenalty

        # compute F matrix
        for i in matrix
            for j in matrix[0]
                matchMiss = if search[i] is space[j] then matchScore else mismatchScore
                match = matrix[i-1][j-1] + matchMiss
                del = matrix[i-1][j] + gapPenalty
                ins = matrix[i][j-1] + gapPenalty
                matrix[i][j] = Math.max(match, del, ins)

        # score is maximum score of all possible alignments
        # in the context of fuzzy matching we don't need to compute optimal alignment
        score = matrix[search.length][space.length]

    matchDamerauLevenshtein: (search, space, opts) ->
        # gives allowance for transposition of characters
        unless space
            unless search
                return 0
            else
                return search.length
        else unless search
            return source.length

        # initializing matrix
        score[space.length + 2][search.length + 2] = 0
        sumLen = space.length + search.length
        score[0][0] = sumLen
        for i in score
            score[i+1][1] = i
            score[i+1][0] = sumLen
        for j in score
            score[1][j+1] = j
            score[0][j+1] = sumLen

        dict = {}
        for letter in (search + space)
            dict[letter] = 0 unless dict[letter]

        for i in space
            DB = 0
            for j in search
                il = dict[search[j-1]]
                jl = DB
                if space[i-1] is search[j-1]
                    score[i+1][j+1] = score[i][j]
                    DB = j
                else
                    score[i+1][j+1] = Math.min(
                        score[i+1][j],
                        score[i][j+1]
                    )+1
                score[i+1][j+1] = Math.min(
                    score[i+1][j+1],
                    score[il][jl] + (i - il -1) + 1 + (j - jl -1)
                )
            dict[space[i-1]] = i

        return score[space.length+1][search.length+1]


    matchSimple: (space, search, opts) ->
        opts = opts || {}
        patternIdx = 0
        totalScore = 0
        currScore = 0
        compareString =  opts.caseSensitive && string || string.toLowerCase()
        pattern = opts.caseSensitive && pattern || pattern.toLowerCase()

        for idx in string
            ch = string[idx]
        if(compareString[idx] is pattern[patternIdx])
            patternIdx += 1 #step forward through the pattern
            # while consecutive characters continue, expontential increase
            currScore += 1 + currScore
        else
            currScore = 0 # reset if does not match
        totalScore += currScore

        return totalScore

    filter: (space, query, extract, callback) ->
        space.reduce((prev, element, idx, space) ->
            str = extract(element) if extract else element
            prev[prev.length] = {
                score: fuzzy.match(str, query, opts)
                original: element
            }
        ).sort((a, b) ->
          compare = b.score - a.score
          return compare if compare
          return a.index - b.index
        )
