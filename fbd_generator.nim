import strutils
import csfml

type
  Direction = enum
    north, east, west, south

type 
  Force =   object
    dir:    Direction
    amount: float


var window = new_RenderWindow(video_mode(1600, 1600), "Force Body Diagram Viewer")

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

proc main() =
    let forces = force_request_loop()
    # setup window and shit..


main()