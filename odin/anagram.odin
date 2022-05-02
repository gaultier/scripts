package main

import "core:fmt"
import "core:os"
import "core:strings"

word_to_num :: proc(word: string) -> u64 {
  //                a   b c   d e    f  g    h  i    j  k    l  m    n  o    p  q    r  s    t  u    v  w    x  y    z
  primes := [26]u64{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101}
  res := u64(1)
  for c, i in word {
    res *= primes[u64(c) - u64('a')]
  }

  return res
}

Word_Idx :: distinct u32
collect_anagrams :: proc(words: []string) -> (map[u64][dynamic]Word_Idx) {
  anagrams := make(map[u64][dynamic]Word_Idx, 12_000)
  for w, i in words {
    if !is_ascii(w) do continue

    num := word_to_num(w)
    if !(num in anagrams) {
      anagrams[num] = make([dynamic]Word_Idx, 0, 9)
    }
    append(&anagrams[num], Word_Idx(i))
  }

  return anagrams
}

print_anagrams :: proc(words: []string) {
  anagrams := collect_anagrams(words)

  for k, a in anagrams {
    if len(a) > 1 {
      for i in a {
        fmt.printf("%s ", words[i])
      }
      fmt.println("")
    }
  }
}

is_ascii :: proc(word: string) -> bool {
  for c in word {
    switch c {
      case 'a'..'z':
      case:
        return false
    }
  }
  return true
}

slurp_words_from_file :: proc(path: string) -> (words: []string, success: bool) {
  bytes := os.read_entire_file_from_filename(path) or_return

  words = strings.split(string(bytes), "\n")

  return words, true
}

main :: proc() {
  /* words := []string{"dog", "god", "lite", "tile", "enormous"} */
  words, ok := slurp_words_from_file("/usr/share/dict/words")
  if !ok {
    os.write_string(os.stderr, "Failed to read from file")
    os.exit(1)
  }
  print_anagrams(words)
}
