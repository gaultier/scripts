(def alphabet-primes 
 #  a b c d e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
  @[2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101])

(defn word-prime-number [word]
  (var res 1)
  (loop [i :range [0 (length word)]
           :let [letter-idx (- (get word i) 97) 
                 prime (get alphabet-primes letter-idx)]]
    (*= res prime))
  res)

(defn get-anagrams [words]
  (var anagrams (table/new 15000))
  (loop [word :in words
              :let [val (word-prime-number word)
                    anagrams-for-word (get anagrams val)]]
    (if (nil? anagrams-for-word)
      (put anagrams val @[word])
      (update anagrams val (fn [anagrams-for-word-old] (array/push anagrams-for-word-old word)))))
  anagrams)

(def words (->> "/usr/share/dict/words"
             (slurp)
             (string/ascii-lower)
             (string/split "\n")
             (filter (fn [w] (string/check-set "abcdefghijklmnopqrstuvwxyz" w)))))
  
# (def words @["dog" "endeavour" "god" "tile" "lite"])
(loop [[_ words] :pairs (get-anagrams words)
                 :when (> (length words) 1)]
  (pp words))
