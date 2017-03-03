import strutils
import csfml
import math

type
  Direction = enum
    north, east, west, south

type 
  Force =   object
    dir:    Direction
    amount: float


proc is_float(x: string): bool = 
  try:
    discard parseFloat x
    result = true 
  except:
    result = true

proc add_force(): Force =
  stdout.write "What direction is the force going in? [north/south/east/west]: "
  var resp = toLowerAscii(readLine(stdin))
  while resp != "north" and resp != "east" and resp != "south" and resp != "west":
    stdout.write "Please enter a proper direction [north/south/east/west]: "
    resp = toLowerAscii(readLine(stdin))
  let direc = parseEnum[Direction] resp
  stdout.write "Please enter an amount (float): "
  var parsedRespFloat: float = 0.0
  resp = readLine(stdin)
  while not is_float(resp):
    stdout.write "Please enter a valid float amount (float): "
    resp = readLine(stdin)
  parsedRespFloat = parseFloat(resp)
  result = Force(dir: direc, amount: parsedRespFloat)

proc force_request_loop(): seq[Force] =
  var forces: seq[Force] = @[]
  stdout.write "Would you like to add a force? [y/n]: "
  var resp = toLowerAscii(readLine(stdin))
  while resp != "y" and resp != "n":
    stdout.write "Please enter a valid response [y/n]: "
    resp = toLowerAscii(readLine(stdin))
  if resp == "y":
    forces.add add_force()
    forces.add force_request_loop()
  return forces



# points (SHOULD BE) are midpoints of rectangles...
proc make_line(fr: Vector2f, to: Vector2f, width: float64): (float64, float64, float64) =
  let
    mpx    = max(fr.x, to.x)
    lpx    = min(fr.x, to.x)
    mpy    = max(fr.y, to.y)
    lpy    = min(fr.y, to.y)
    length = float64(mpx - lpx)
    height = mpy - lpy
    rot_by = radToDeg arctan float64(height / length)
  return (length, width, rot_by)
  
# fucking memory...
proc make_line_prim(fr: Vector2i, to: Vector2i): VertexArray =
  var line = newVertexArray(PrimitiveType.Lines)
  line.append vertex(fr, Black)
  line.append vertex(to, Black)
  return line

proc main() =
  let forces = force_request_loop()
  # setup window and shit..
  var window = newRenderWindow(
    videoMode(1000, 1000), "SOF FBD Generator",
    WindowStyle.TitleBar|WindowStyle.Close
  )
  window.verticalSyncEnabled = true

  let proggy = newFont("res/font.ttf")


  while window.open:
    var event: Event
    while window.pollEvent event:
      if event.kind == EventType.Closed:
        window.close()
        break

      window.clear color(255, 255, 255)
      

      let text = newText("$1 force$2" % [$forces.len, if forces.len != 1: "s" else: ""], proggy, 40)
      text.color = Black
      text.position = vec2(20, 980 - (text.globalBounds.height + 20))
      window.draw text

      let x_text = newText("x", proggy, 40)
      x_text.color = Black
      x_text.position = vec2(20, 500 - (x_text.globalBounds.height + 15))
      window.draw x_text

      let y_text = newText("y", proggy, 40)
      y_text.color = Black
      y_text.position = vec2(500 - (x_text.globalBounds.height - 5), -10)
      window.draw y_text


      # axis lines
      let
        prim_line_x = newVertexArray(PrimitiveType.Lines)
        prim_line_y = newVertexArray(PrimitiveType.Lines)
      prim_line_x.append vertex(vec2(50, 500), Black)
      prim_line_x.append vertex(vec2(950, 500), Black)
      prim_line_y.append vertex(vec2(500, 50), Black)
      prim_line_y.append vertex(vec2(500, 950), Black)
      window.draw prim_line_x
      window.draw prim_line_y

      var
        n_count = 0
        s_count = 0
        e_count = 0
        w_count = 0

      for force in forces:
        let 
          index = forces.find(force) + 1
          line = newRectangleShape(vec2(if force.dir == north or force.dir == south: 375 else: 5, if force.dir == north or force.dir == south: 5 else: 375))
        line.fillColor = Black
        if force.dir == north or force.dir == south:
          line.position = vec2(500 + ((if force.dir == north: n_count + 1 else: s_count + 1) * 20), 500)
          line.rotate if force.dir == south: 90 else: 270
          if force.dir == north: n_count += 1 else: s_count += 1
        elif force.dir == east or force.dir == west:
          line.position = vec2(500, 500 + ((if force.dir == east: e_count + 1 else: w_count + 1) * 20))
          line.rotate if force.dir == west: 90 else: 270
          if force.dir == Direction.east: e_count += 1 else: w_count += 1
        window.draw line
        let text = newText("f$1" % $((forces.find force) + 1), proggy, 20)
        text.position = vec2(if force.dir == east: 890 else: 475 + ((if force.dir == north: n_count + 1 else: s_count + 1) * 20), 
                             if force.dir == east: 475 + (e_count + 1) * 15 elif force.dir == west: 420 elif force.dir == south: 880 else: 90)
        text.color = Black
        window.draw text

      
      window.display()


main()