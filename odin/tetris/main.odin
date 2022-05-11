package tetris 
import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

block_size :: 20
window_width : i32 : 1024
window_height : i32 : 768

block_O := [3][3]u8{{0, 0, 0},
                    {0, 1, 1},
                    {0, 1, 1}}

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

make_block_texture :: proc (renderer: ^SDL.Renderer) -> ^SDL.Texture {
  surface := SDL.CreateRGBSurface(0, block_size, block_size, 32, 0, 0, 0, 0)
  SDL.FillRect(surface, nil, SDL.MapRGB(surface.format, 255, 0, 0))
  texture := SDL.CreateTextureFromSurface(renderer, surface)
  SDL.FreeSurface(surface)

  return texture
}

main :: proc () {
  window, renderer := init()

  block_texture := make_block_texture(renderer)

  for {
    e : SDL.Event
    SDL.WaitEvent(&e)
    if e.type == SDL.EventType.QUIT do return
    if e.type == SDL.EventType.KEYDOWN {
      #partial switch e.key.keysym.sym {
        case .ESCAPE: return
      }
    }

    // TODO gameplay

    SDL.RenderClear(renderer)

    dst := SDL.Rect{
      x = (window_width - block_size) / 2,
      y = (window_height - block_size) / 2,
      w = block_size,
      h = block_size,
    }
    SDL.RenderCopy(renderer, block_texture, nil, &dst)
    dst.x += block_size
    dst.y += block_size
    SDL.RenderCopy(renderer, block_texture, nil, &dst)

    SDL.RenderPresent(renderer)
  }
}
