package tetris 
import "core:fmt"
import "core:mem"
import "core:os"
import SDL "vendor:sdl2"

block_size :: 20
window_width : i32 : 800
window_height : i32 : 600

arena : mem.Arena

Piece :: struct {
  shape: Shape,
  x, y, w, h: i32,
}

Shape :: [3][3]u8

PieceIdx :: u8
GameState :: struct {
  pieces: [dynamic]Piece,
  locked_pieces: [dynamic]PieceIdx,
  playing_piece: PieceIdx,
}

get_piece :: proc (using game_state: ^GameState, piece_idx: PieceIdx) -> ^Piece {
  if piece_idx < 0 || int(piece_idx) >= len(pieces) do return nil

  return &pieces[piece_idx]
}

init :: proc () -> (^SDL.Window, ^SDL.Renderer) {
  if SDL.Init(SDL.INIT_VIDEO) < 0 {
    fmt.eprintf("Failed to init sdl: %v", SDL.GetError())
    os.exit(1)
  }

  window := SDL.CreateWindow("Tetris", SDL.WINDOWPOS_UNDEFINED,
                                          SDL.WINDOWPOS_UNDEFINED, window_width,
                                          window_height, SDL.WindowFlags{.SHOWN, .RESIZABLE})
  if window == nil {
    fmt.eprintf("Failed to create window: %v", SDL.GetError())
    os.exit(1)
  }

  renderer := SDL.CreateRenderer(window, -1, SDL.RendererFlags{.ACCELERATED})
  if renderer == nil {
    fmt.eprintf("Failed to create renderer: %v", SDL.GetError())
    os.exit(1)
  }

  SDL.SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff)

  return window, renderer
}

exit :: proc () {
  fmt.eprintf("arena=%d %d", arena.offset, arena.peak_used) 
  os.exit(0)
}

make_block_texture :: proc (renderer: ^SDL.Renderer) -> ^SDL.Texture {
  surface := SDL.CreateRGBSurface(0, block_size, block_size, 32, 0, 0, 0, 0)
  SDL.FillRect(surface, nil, SDL.MapRGB(surface.format, 255, 255, 0))
  texture := SDL.CreateTextureFromSurface(renderer, surface)
  SDL.FreeSurface(surface)

  return texture
}

render_piece :: proc (renderer: ^SDL.Renderer, piece: Piece, texture: ^SDL.Texture) {
  rect := SDL.Rect{x=i32(piece.x), y=i32(piece.y), w=block_size, h=block_size} 

  for yrow, yi in piece.shape {
    for cell, xi in yrow {
      if cell == 0 do continue

      rect.x = i32(piece.x) + i32(xi) * block_size 
      rect.y = i32(piece.y) + i32(yi) * block_size 
      SDL.RenderCopy(renderer, texture, nil, &rect)
    }
  }
}

update_piece_dimensions :: proc () {}

rotate_counter_clockwise :: proc (game_state: ^GameState) {
  rotate_clockwise(game_state)
  rotate_clockwise(game_state)
  rotate_clockwise(game_state)
}

rotate_clockwise :: proc (game_state: ^GameState) {
  /*
  x . .     . . .
  x . .  => . . x
  x x .     x x x
  */
  playing_piece := get_piece(game_state, game_state.playing_piece)
  assert(playing_piece != nil)
  using playing_piece
  w, h = h, w
  s : Shape

  /*
  x . O     O . .
  x . .  => . . x
  x x .     x x x
  */
  s[0][0] = shape[0][2]
  /*
  x . .     . O .
  x . O  => . . x
  x x .     x x x
  */
  s[0][1] = shape[1][2]
  /*
  x . .     . . O
  x . .  => . . x
  x x O     x x x
  */
  s[0][2] = shape[2][2]
  /*
  x O .     . . .
  x . .  => O . x
  x x .     x x x
  */
  s[1][0] = shape[0][1]
  s[1][1] = shape[1][1]
  /*
  x . .     . . .
  x . .  => . . O
  x O .     x x x
  */
  s[1][2] = shape[2][1]
  /*
  O . .     . . .
  x . .  => . . x
  x x .     O x x
  */
  s[2][0] = shape[0][0]
  /*
  x . .     . . .
  O . .  => . . x
  x x .     x O x
  */
  s[2][1] = shape[1][0]
  /*
  x . .     . . .
  x . .  => . . x
  O x .     x x O
  */
  s[2][2] = shape[2][0]
  shape = s
}

handle_inputs :: proc(game_state: ^GameState) {
  e : SDL.Event
  for SDL.PollEvent(&e) > 0 {
    if e.type == SDL.EventType.QUIT do exit()
    if e.type == SDL.EventType.APP_TERMINATING do return
    if e.type == SDL.EventType.KEYDOWN {
      #partial switch e.key.keysym.sym {
        case .ESCAPE: exit()
        case .LEFT: go_left(game_state)
        case .RIGHT: go_right(game_state)
        case .UP: rotate_counter_clockwise(game_state)
        case .X: rotate_clockwise(game_state)
        case .DOWN: go_down(game_state)
      }
    }
  }
  SDL.Delay(17) // FIXME track dt
}

go_down :: proc (game_state: ^GameState) {
  playing_piece := get_piece(game_state, game_state.playing_piece)
  assert(playing_piece != nil)
  playing_piece.y += /* FIXME */ block_size
}

go_left :: proc (game_state: ^GameState) {
  playing_piece := get_piece(game_state, game_state.playing_piece)
  assert(playing_piece != nil)
  playing_piece.x -= /* FIXME */ block_size
}

go_right :: proc (game_state: ^GameState) {
  playing_piece := get_piece(game_state, game_state.playing_piece)
  assert(playing_piece != nil)
  playing_piece.x += /* FIXME */ block_size
}

locked_pieces_disappear :: proc (using game_state: ^GameState) {
  resize(&locked_pieces, 0)
}

main :: proc () {
  memory := make([]byte, 20_000)
  mem.init_arena(&arena, memory)
  context.allocator = mem.arena_allocator(&arena)

  window, renderer := init()

  block_texture := make_block_texture(renderer)

  O_piece := Piece {
    shape ={{1, 1, 0},
            {1, 1, 0},
            {0, 0, 0}},
    x = (window_width - block_size) / 2,
    y = (window_height - block_size) / 2,
    w = block_size*2,
    h = block_size*2,
  }
  L_piece := Piece {
    shape ={{1, 0, 0},
            {1, 0, 0},
            {1, 1, 0}},
            
    x =  block_size,
    y =  block_size,
    w = block_size*2,
    h = block_size*3,
  }
  I_piece := Piece {
    shape = {{1, 0, 0},
             {1, 0, 0},
             {1, 0, 0}},
    x =  block_size*5,
    y =  block_size*5,
    w = block_size*1,
    h = block_size*3,
  }

  pieces := make([dynamic]Piece, 0, 100)
  append(&pieces, O_piece, I_piece, L_piece)

  locked_pieces := make([dynamic]PieceIdx, 0,100)
  append(&locked_pieces, 0, 1)

  game_state := GameState {
    pieces = pieces,
    locked_pieces = locked_pieces,
    playing_piece = 2,
  }

  for {
    handle_inputs(&game_state)

    SDL.RenderClear(renderer)

    for piece_idx in game_state.locked_pieces {
      piece := get_piece(&game_state, piece_idx)
      assert(piece != nil)
      render_piece(renderer, piece^, block_texture)
    }

    playing_piece := get_piece(&game_state, game_state.playing_piece)
    assert(playing_piece != nil)
    render_piece(renderer, playing_piece^, block_texture)

    SDL.RenderPresent(renderer)
  }
}
