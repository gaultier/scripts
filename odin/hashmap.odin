package main
import "core:container/small_array"
import "core:fmt"
import "core:testing"

Word_Idx :: u32
Word_Indices :: small_array.Small_Array(9, Word_Idx)
HashMap :: struct {
  keys: [dynamic]u64,
  values: [dynamic]Word_Indices,
}

hashmap_make :: proc (capacity: u64) -> HashMap {
  hashmap := HashMap{
    keys = make([dynamic]u64, capacity),
    values = make([dynamic]Word_Indices, capacity),
  }

  return hashmap
}

hashmap_find_entry :: proc(hashmap: ^HashMap, word: string) -> u64 {
  capacity := u64(cap(hashmap.keys))
  hash := ascii_word_to_num(word)
  
  for i := hash % capacity; ; i = (i + 1) % capacity {
    key := hashmap.keys[i]
    if key == hash || key == 0 {
      return i
    }
  }
}

hashmap_add :: proc (hashmap: ^HashMap, word: string, word_idx: Word_Idx) {
  i := hashmap_find_entry(hashmap, word)
  hash := ascii_word_to_num(word)
  hashmap.keys[i] = hash
  small_array.append(&hashmap.values[i], word_idx)

}

@test
test_hashmap :: proc(t: ^testing.T) {
  hashmap := hashmap_make(100)

  i := hashmap_find_entry(&hashmap, "dog")
  entry := hashmap.values[i]
  testing.expect_value(t, entry.len, 0)

  hashmap_add(&hashmap, "dog", 1)
  i = hashmap_find_entry(&hashmap, "dog")
  entry = hashmap.values[i]
  testing.expect_value(t, entry.len, 1)
  testing.expect_value(t, entry.data[0], 1)

  hashmap_add(&hashmap, "god", 2)
  i = hashmap_find_entry(&hashmap, "god")
  entry = hashmap.values[i]
  testing.expect_value(t, entry.len, 2)
  testing.expect_value(t, entry.data[0], 1)
  testing.expect_value(t, entry.data[1], 2)

  hashmap_add(&hashmap, "derby", 3)
  i = hashmap_find_entry(&hashmap, "derby")
  entry = hashmap.values[i]
  testing.expect_value(t, entry.len, 1)
  testing.expect_value(t, entry.data[0], 3)


  hashmap_add(&hashmap, "fundamentally", 4)
  i = hashmap_find_entry(&hashmap, "fundamentally")
  entry = hashmap.values[i]
  testing.expect_value(t, entry.len, 1)
  testing.expect_value(t, entry.data[0], 4)
}
