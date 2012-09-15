b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

playground = width = height = null
MAXASPECT = 0.75
MINASPECT = 0.5

SCALE = 50

DEBUG = false

lastTime = ball1 = ball2 = null
world = null
gravity = new b2Vec2 0, 0

requestAnimFrame = (() ->
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)
)()

init = ->
  #if setupOrientationHandler()
  if setupMotionHandler()
    setupPlayground()
    setupB2()
    setupDebugDraw() if DEBUG

    lastTime = Date.now()
    requestAnimFrame update

setupDebugDraw = ->
  canvas = $("<canvas id='canvas' style='width:#{width} height:#{height} position:absolute top:0 left:0'/>")
  playground.append canvas
  debugDraw = new b2DebugDraw()
  debugDraw.SetSprite(document.getElementById("canvas").getContext("2d"))
  debugDraw.SetDrawScale(5)
  debugDraw.SetFillAlpha(0.3)
  debugDraw.SetLineThickness(1.0)
  debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
  world.SetDebugDraw(debugDraw)

setupB2 = ->
  world = new b2World gravity

  fixDef = new b2FixtureDef
  fixDef.density = 1.0
  fixDef.friction = 0.5
  fixDef.restitution = 0.2

  bodyDef = new b2BodyDef

  b2width = width / SCALE
  b2heigth = height / SCALE

  createStaticBox = (x1, y1, x2 , y2) ->
    bodyDef.type = b2Body.b2_staticBody
    bodyDef.position.x = (x1 + x2)/2
    bodyDef.position.y = (y1 + y2)/2
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox((x2-x1)/2, (y2-y1)/2)
    world.CreateBody(bodyDef).CreateFixture(fixDef)

  # create ground and walls
  createStaticBox(-0.5, -0.5, b2width + 0.5, 0)
  createStaticBox(-0.5, 0, 0, b2heigth)
  createStaticBox(b2width, 0, b2width+0.5, b2heigth)
  createStaticBox(-0.5, b2heigth, b2width + 0.5, b2heigth + 0.5)

  createBall = (x, y, color) ->
    bodyDef.type = b2Body.b2_dynamicBody
    fixDef.shape = new b2CircleShape(0.5)

    bodyDef.position.x = x
    bodyDef.position.y = y
    physicsBody = world.CreateBody(bodyDef)
    physicsBody.CreateFixture(fixDef)
    div = $("<div class='ball #{color}'/>")
    playground.append div
    ball = new GameObj(div, physicsBody)

  ball1 = createBall(b2width / 2 - 2, b2heigth - 2, 'white')
  ball2 = createBall(b2width / 2 + 2, b2heigth - 2, 'black')

class GameObj
  constructor: (@div, @physicsBody) ->

  update: ->
    {@x, @y} = @physicsBody.GetPosition()
    left = @x * SCALE - @div.width()/2
    top = height - @y * SCALE - @div.height()/2
    @div.css 'left',  left + 'px'
    @div.css 'top', top + 'px'

minfps = 2000
maxfps = 0
update = ->
  requestAnimFrame update
  now = Date.now()
  step = (now - lastTime) / 1000
  fps = Math.round(1/step)
  minfps = Math.min minfps, fps
  maxfps = Math.max maxfps, fps
  $('#fps').html "FPS: #{fps} min:#{minfps} max:#{maxfps}"
  lastTime = now
  world.SetGravity(gravity)
  world.Step( step ,  10 ,  10)
  ball1.update()
  $('#position1').html "X:#{ball1.x} Y#{ball1.y}"
  ball2.update()
  $('#position2').html "X:#{ball2.x} Y#{ball2.y}"
  world.DrawDebugData() if DEBUG
  world.ClearForces()

setupOrientationHandler = ->
  if window.DeviceOrientationEvent
    window.addEventListener 'deviceorientation',
      (event) ->
        tiltLR = event.gamma
        tiltFB = event.beta
        dir = event.alpha
        motUD = null
        deviceOrientationHandler tiltLR, tiltFB, dir, motUD
      , false
    true
  else if window.OrientationEvent
    window.addEventListener 'MozOrientation',
      (event) ->
        tiltLR = event.x * 90
        tiltFB = event.y * -90
        dir = null
        motUD = event.z
        deviceOrientationHandler(tiltLR, tiltFB, dir, motUD)
      , false
    true
  else
    alert "Sorry your device/browser is not supported"
    false

  deviceOrientationHandler 'n/a','n/a','n/a'

setupMotionHandler = ->
  if window.DeviceMotionEvent
    window.addEventListener 'devicemotion',
      (event) ->
        acceleration = event.accelerationIncludingGravity
        orientation = $ '#orientation'
        orientation.html "X:#{acceleration.x} Y:#{acceleration.y} Z:#{acceleration.z}"
        gravity.Set(-acceleration.x, -acceleration.y)
      , false
    true
  else
    alert "Sorry your device/browser is not supported"
    false


setupPlayground = ->
  playground = $ '#playground'
  width = playground.width()
  height = playground.height()
  aspect = width / height
  if aspect > MAXASPECT
    width = height * MAXASPECT
  if aspect < MINASPECT
    height = width / MINASPECT
  playground.width width
  playground.height height
  bodyWith = $('body').width()
  playground.css 'left', (bodyWith - width) / 2 + 'px'


deviceOrientationHandler = (tiltLR, tiltFB, dir, motUD) ->
    orientation = $ '#orientation'
    orientation.html "tiltLR:#{tiltLR} tiltFB:#{tiltFB} dir:#{dir} motUD:#{motUD} W:#{width} H:#{height}"

window.onload = () ->
  init()
