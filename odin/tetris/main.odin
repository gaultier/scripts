package tetris 
import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

init :: proc () -> (^SDL.Window, ^SDL.Renderer) {
  if SDL.Init(SDL.INIT_VIDEO) < 0 {
    fmt.eprintf("Failed to init sdl: %v", SDL.GetError())
    os.exit(1)
  }

  screen_width : i32 = 1024
  screen_height : i32 = 768
  window := SDL.CreateWindow("Tetris", SDL.WINDOWPOS_UNDEFINED,
                                          SDL.WINDOWPOS_UNDEFINED, screen_width,
                                          screen_height, SDL.WindowFlags{.SHOWN, .RESIZABLE})
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

main :: proc () {
  window, renderer := init()

  surface := SDL.CreateRGBSurface(0, 20, 20, 32, 0, 0, 0, 0)
  SDL.FillRect(surface, nil, SDL.MapRGB(surface.format, 255, 0, 0))
  texture := SDL.CreateTextureFromSurface(renderer, surface)
  SDL.FreeSurface(surface)

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

    SDL.RenderCopy(renderer, texture, nil, nil)

    SDL.RenderPresent(renderer)
  }
}
