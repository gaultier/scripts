package main

import "core:fmt"
import "core:mem"
import "core:testing"
import "core:os"
import "core:strings"

ascii_word_to_num :: proc(word: string) -> u64 {
  //                a   b c   d e    f  g    h  i    j  k    l  m    n  o    p  q    r  s    t  u    v  w    x  y    z
  primes := [26]u64{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101}
  res := u64(1)
  for c in word {
    res *= primes[u64(c) - u64('a')]
  }

  return res
}

collect_anagrams :: proc(words: []string) -> HashMap {
  hashmap := hashmap_make(250_000)
  for w, i in words {
    if !is_ascii(w) do continue
    hashmap_add(&hashmap, w, u32(i))
  }

  return hashmap
}

print_anagrams :: proc(words: []string) {
  hashmap := collect_anagrams(words)

  for v in hashmap.values {
    if v.len <= 1 do continue

    for i := 0; i < v.len; i += 1 {
      j := v.data[i]
      fmt.printf("%s ", words[j])
    }
    fmt.println("")
  }
}

is_ascii :: proc(word: string) -> bool {
  for c in word {
    switch c {
      case 'a'..'z': // no-op
      case: return false
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
  arena : mem.Arena
  memory := make([]byte, 100_000_000)
  mem.init_arena(&arena, memory)
  context.allocator = mem.arena_allocator(&arena)

  words, ok := slurp_words_from_file("/usr/share/dict/words")
  if !ok {
    os.write_string(os.stderr, "Failed to read from file")
    os.exit(1)
  }
  print_anagrams(words)

  fmt.eprintf("arena=%d %d", arena.offset, arena.peak_used) 
}

@test
test_ascii_word_to_num :: proc(t: ^testing.T) {
  testing.expect_value(t, ascii_word_to_num("dog"), 7*47*17)
}

/* @test */
/* test_collect_anagrams :: proc(t: ^testing.T) { */
/*   hashmap := collect_anagrams([]string{"dog", "god", "lite", "tile", "enormous"}) */

/*   entry := hashmap_find_entry(^hashmap, */ 
/*   testing.expect_value(t, */ 

/*   testing.expect_value(t, len(anagrams), len(expected)) */
/*   for k, v in expected { */
/*     testing.expect_value(t, len(v), len(anagrams[k])) */
/*     for a, i in v { */
/*       testing.expect(t, a == anagrams[k][i]) */
/*     } */
/*   } */
/* } */
