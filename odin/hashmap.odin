package main
import "core:container/small_array"
import "core:testing"

Word_Idx :: u32
Word_Indices :: small_array.Small_Array(9, Word_Idx)
HashMap :: struct {
  keys: [dynamic]u64,
  values: [dynamic]Word_Indices,
}

hashmap_make :: proc (capacity: u16) -> HashMap {
  hashmap := HashMap{
    keys = make([dynamic]u64, capacity),
    values = make([dynamic]Word_Indices, capacity),
  }

  /* for v in &hashmap.values { */
  /*   ^v = Word_Indices() */
  /* } */

  return hashmap
}

hashmap_find_entry :: proc(hashmap: ^HashMap, key: string) -> ^Word_Indices {
  capacity := u64(cap(hashmap.keys))
  hash := ascii_word_to_num(key)
  i := hash % capacity
  
  for ; ; i = (i + 1) % capacity {
    key := hashmap.keys[i]
    if key == hash || key == 0 do return &hashmap.values[i]
  }
}

hashmap_add :: proc (hashmap: ^HashMap, word: string, word_idx: Word_Idx) {
  val := hashmap_find_entry(hashmap, word)
  small_array.append(val, word_idx)
}

@test
test_hashmap :: proc(t: ^testing.T) {
  hashmap := hashmap_make(10)

  entry := hashmap_find_entry(&hashmap, "dog")
  testing.expect_value(t, entry.len, 0)

  hashmap_add(&hashmap, "dog", 1)
  entry = hashmap_find_entry(&hashmap, "dog")
  testing.expect_value(t, entry.len, 1)

  hashmap_add(&hashmap, "god", 2)
  entry = hashmap_find_entry(&hashmap, "god")
  testing.expect_value(t, entry.len, 2)
}

