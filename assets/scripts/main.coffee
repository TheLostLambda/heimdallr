## Constants
fps = 60#fps
isPaused = false#bool
trails = false
orbit = true
simSpeed = 5120000#x
scale = 1263955670
scale2 = 10000000
mousePos = new Phys.Celestial(0,0)
viewPort = new Util.Vector2(0,0)#Tuple
lastView = new Util.Vector2(0,0)#Tuple
lastClick = new Util.Vector2(0,0)#Tuple

## Initialize
screenSize = Util.sizeCanvas()
viewPort = viewPort.add(screenSize.multiply(1/2))
scale2 = Math.round(6.957e7 * 2 / screenSize.Y) * 1.1

## Functions

# This function updates the movement of an object.
updateObject = (object, allObjects) ->
  # Get acceleration of gravity on an object, scaled by the fps and speed of the simulation.
  acceleration = Phys.totalGravityVector(object, allObjects).multiply(1 / fps).multiply(simSpeed)
  # Add acceleration of gravity to the velocity vector.
  object.velocity = object.velocity.add(acceleration)
  # Update xCoord and yCoord using 'velocity' and scale by the fps and speed of the simulation.
  object.xCoord -= (object.velocity.X / fps) * simSpeed # Figure this '-=' shit out later...
  object.yCoord -= (object.velocity.Y / fps) * simSpeed

# Draws a graphical representation of each object.
drawObject = (object) ->
  # Gets the context of the screen.
  canvasContext = $('#screen')[0].getContext('2d')
  s = if orbit then scale else scale2
  canvasContext.drawImage($(object.tex)[0]
    , (object.xCoord / s) - (object.radius / s) + viewPort.X
    , (object.yCoord / s) - (object.radius / s) + viewPort.Y
    , (object.radius / s) * 2
    , (object.radius / s) * 2)

## Streams

# Stream of window resize events.
resizeS = $(window).asEventStream('resize')
# Stream of mouse events on the screen.
clickS = $('#screen').asEventStream('mousedown mouseup mousemove mousewheel')
# Stream of 'reset' strings created when the 'reset' button is clicked.
resetS = $('#reset').asEventStream('click').map('reset')
# Stream of click events created when the 'pause' button is clicked.
pauseS = $('#pause').asEventStream('click')
trailS = $('#trail').asEventStream('click')
orbitS = $('#orbit').asEventStream('click')
# Stream of '1/2' created when the 'slower' button is clicked.
slowS = $('#slower').asEventStream('click').map(1/2)
# Stream of '2' created when the 'faster' button is clicked.
fastS = $('#faster').asEventStream('click').map(2)
# Combines 'slowS' and 'fastS' into one stream of faster and slower click events.
speedS = slowS.merge(fastS)
# Creates a Bacon Bus that allows events to be manually pushed to it.
inputS = new Bacon.Bus()
# Combines 'clickS' and 'resetS' streams into a single input stream and feeds them to 'inputS'.
inputS.plug(clickS.merge(resetS))

## Subscriptions

# Calls 'sizeCanvas()' function when resize stream has a new value.
resizeS.onValue(() -> Util.sizeCanvas())

## Testing Initialization Code.
initState = () ->
  if orbit
    quarter = scale * (screenSize.X / 4)
    lich = new Phys.Celestial('#LICH', -quarter, 0, 2.7846e30, 3e9, 'Lich', 0)
    heimdallr = new Phys.Celestial('#HEIM', -quarter, 4.4880e11, 2.0921e26, 1e10, 'Heimdallr', 0)
    sol = new Phys.Celestial('#SOL', quarter, 0, 1.989e30, 1e10, 'Sol', 1)
    earth = new Phys.Celestial('#POL', quarter, 1.496e11, 5.972e24, 3e9, 'Earth', 1)
    s = [lich, heimdallr, sol, earth]
    s[0].velocity = new Util.Vector2(0, 0)
    s[1].velocity = new Util.Vector2(20343.13599, 0)
    s[2].velocity = new Util.Vector2(0, 0)
    s[3].velocity = new Util.Vector2(29290, 0)
  else
    lich = new Phys.Celestial('#LICH', 0, 0, 2.7846e30, 1.0436e4, 'Lich')
    sol = new Phys.Celestial('#SOL', 0, 0, 1.989e30, 6.957e7, 'Sol')
    earth = new Phys.Celestial('#POL', 0, 0, 5.972e24, 6.371e6, 'Earth')
    heimdallr = new Phys.Celestial('#HEIM', 0, 0, 2.0921e26, 2.5484e7, 'Heimdallr')
    s = [sol, heimdallr, earth, lich]
  return s
# To be removed in the future.

## Properties

# Defines a property as the result of a folded input stream.
modelP = inputS.scan(initState(), (model, event) ->
  # If 'event', which comes from the input stream, is a string variable...
  if typeof event is 'string'
    # And if the first 7 characters of that string are 'delete' plus SPACE...
    if event.slice(0, 7) is 'delete '
      # Return the model without the object whose UUID is equal to the remaining characters after 'delete' and SPACE.
      return model.filter((x) -> x.UUID != event.slice(7))
    # If the string is 'reset'...
    if event is 'reset'
      # Return the initial state.
      Util.clear()
      return initState()
  if event.type is 'mousedown'
    #if event.which == 1
      # Return an updated model that is the same plus a new object with the mouse's X and Y coords.
      #return model.concat(new Phys.Celestial((event.offsetX - viewPort.X) * scale, (event.offsetY - viewPort.Y) * scale, 5.972e24, 6.371e6))
    if event.which == 2
      # Comment this section
      lastView = viewPort
      lastClick = new Util.Vector2(event.offsetX, event.offsetY)
      return model
    else
      return model
  if event.type is 'mouseup' or event.type is 'mousemove'
    if event.which == 2
      # Comment this section
      shift = new Util.Vector2(event.offsetX - lastClick.X, event.offsetY - lastClick.Y)
      viewPort = lastView.add(shift)
      return model
    else
      s = if orbit then scale else scale2
      mousePos.xCoord = (event.offsetX - viewPort.X) * s
      mousePos.yCoord = (event.offsetY - $('#navbar').height() - viewPort.Y) * s

      # Ignore input and return the same model.
      return model
  if event.type is 'mousewheel'
    if event.originalEvent.wheelDelta > 0
      if orbit then scale = Math.round(scale * 0.9) else scale2 = Math.round(scale2 * 0.9)
    else
      if orbit then scale = Math.round(scale * 1.1) else scale2 = Math.round(scale2 * 1.1)
    return model
)

# Changes 'isPaused' value when pause stream has new value.
pauseP = pauseS.map(1).scan(1, (accumulator, value) -> accumulator + value).map((value) -> value % 2 == 0)
pauseP.onValue((newPause) -> isPaused = newPause)
pauseP.map((pause) -> if pause then 'Play' else 'Pause').assign($('#pause'), 'text')

trailP = trailS.map(1).scan(1, (accumulator, value) -> accumulator + value).map((value) -> value % 2 == 0)
trailP.onValue((newTrails) -> trails = newTrails)
trailP.map((trails) -> if trails then 'Trails Off' else 'Trails On').assign($('#trail'), 'text')

orbitP = orbitS.map(1).scan(0, (accumulator, value) -> accumulator + value).map((value) -> value % 2 == 0)
orbitP.onValue((newOrbit) -> orbit = newOrbit; inputS.push('reset'))
orbitP.map((orbits) -> if orbit then 'Concentric' else 'Orbit').assign($('#orbit'), 'text')

# Changes the 'simSpeed' value when a faster or slower event occurs.
speedP = speedS.scan(simSpeed, (accumulator, factor) -> Math.round(accumulator * factor))
speedP.onValue((newSpeed) -> simSpeed = newSpeed)
speedP.assign($('#speed'), 'text')

## Game Loop
modelP.sample(Util.ticksToMilliseconds(fps)).onValue((model) ->
  if orbit then $('#scale').text('Scale: ' + scale) else $('#scale').text('Scale: ' + scale2)

  # Clears the screen.
  if not trails then Util.clear()

  # For every object...
  for object in model
    # Update if the simulation is not paused.
    if not isPaused and orbit then updateObject(object, model)

  # For every object...
  #for object in model
    # Check collisions and remove colliding objects by sending a delete request to the 'inputS' bus.
    #if Phys.checkCollisions(object, model).length > 0 then inputS.push('delete ' + object.UUID)

  for l in [0..1]
    mousePos.layer = l
    for object in Phys.checkCollisions(mousePos,model)
      console.log(object)
      objectInfo = 'UUID: ' + object.UUID + ';\t'

      if orbit
        objectInfo += 'Velocity: (' + Math.round(object.velocity.X) + 'm/s , ' + Math.round(object.velocity.Y) + 'm/s );\t'
      else
        objectInfo += 'Mass: ' + object.mass + 'kg;\t'
        objectInfo += 'Radius: ' + object.radius + 'm;\t'

      $('#objectInfo').text(objectInfo)

  # For every object...
  for object in model
    # Draw the object.
    drawObject(object)
  )
