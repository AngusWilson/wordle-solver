//Get all words
words: read0 `$":wordle-words.txt"

//Get five letter words
words:words where (5=count each words) and all each words in .Q.a

//Get most populous letters to get starter word
letterDist:desc count each group raze words

//No words have 5 most, but some have the 6
starterWord:words where 5=sum each (6#key letterDist) in\:/:  words

show"best starter word is ",first starterWord

//Set up global dict to maintain wordle state
init:{[]
        .wordle.dict:`currentWord`correct`inword`outword!("";00000b;.Q.a!26#0N();"")
        }

//User input func for word tried, and colours given
/ turn["arise";"BBYGB"]
turn:{[word;result]

        /Add the word and any greens
        .wordle.dict,:`currentWord`correct!(word;"G"=result);

        outs:word where result="B";
        ins:(word where result="Y")!where result="Y";
        ins:.wordle.dict[`inword],'ins;
        ins:(k!ins k:where any each not null ins) except\: 0N;
        outs:outs except key ins;


        .wordle.dict,:`inword`outword!(ins;.wordle.dict[`outword],outs);
        }


//Func to generate new word choice
/ currentWord - input word - string
/ correct - 5 length boolean list, true if in correct place
/ inword -  dict of letters and locations that it cannot be in
/ outword - list of character not in word

newWord:{[dict]
        currentWord:dict`currentWord;
        correct:dict`correct;
        inword:dict`inword;
        inword:(k!inword k:where any each not null inword) except\: 0N;
        outword:dict`outword;

        //Filter words on correct
        candidateWords:words where all each (currentWord where correct)=/:words@\:where correct;

        //Filter out words where outwords are contained
        candidateWords:candidateWords where not any each candidateWords in outword;

        //Filter out words that have an inword in a disallowed slot;
        lookup:candidateWords @\: inword;
        candidateWords:candidateWords where {not any key[x] in' value[x]}each lookup;

        //Filter out words that don't have an inword
        candidateWords:candidateWords where all each (distinct where any each  not null inword) in/: candidateWords;

        candidateWords
        }


optimiseWord:{[wordList]

        //Get words with distinct characters for best score
        candidateWords:wordList where 5= count each distinct each wordList;

        /If there isnt, try a four, if not three
        if[not count candidateWords;
                candidateWords:wordList where 4= count each distinct each wordList;
                ];
        if[not count candidateWords;
                candidateWords:wordList where 3= count each distinct each wordList;
                ];

        / get best pop rank for remaining slots
        trimWords:candidateWords @\: where not .wordle.dict`correct;
        remainingDist:desc count each group raze trimWords;

        popRanks:sum each key[remainingDist] ?/: trimWords;
        candidateWords where popRanks=min popRanks

        }



play:{[word;result]
        turn[word;result];
        cw:newWord[.wordle.dict];
        optimiseWord cw
        };

init[]
