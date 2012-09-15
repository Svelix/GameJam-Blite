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

ball = null
world = null
gravity = new b2Vec2 0, 0

init = ->
  #if setupOrientationHandler()
  if setupMotionHandler()
    setupPlayground()
    setupB2()

setupB2 = ->
  world = new b2World gravity

  fixDef = new b2FixtureDef
  fixDef.density = 1.0
  fixDef.friction = 0.5
  fixDef.restitution = 0.2

  bodyDef = new b2BodyDef

  b2width = width / SCALE
  b2heigth = height / SCALE

  # create ground
  bodyDef.type = b2Body.b2_staticBody
  bodyDef.position.x = 0
  bodyDef.position.y = 0
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox(b2width, 0.5)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  # create walls
  bodyDef.type = b2Body.b2_staticBody
  bodyDef.position.x = 0
  bodyDef.position.y = 0
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox(0.5, b2heigth)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  bodyDef.type = b2Body.b2_staticBody
  bodyDef.position.x = b2width
  bodyDef.position.y = 0
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox(0.5, b2heigth)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  bodyDef.type = b2Body.b2_staticBody
  bodyDef.position.x = 0
  bodyDef.position.y = b2heigth
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox(b2width, 0.5)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  # create Ball
  bodyDef.type = b2Body.b2_dynamicBody
  fixDef.shape = new b2CircleShape(1);

  bodyDef.position.x = b2width / 2
  bodyDef.position.y = b2heigth - 2
  physicsBody = world.CreateBody(bodyDef)
  physicsBody.CreateFixture(fixDef)
  ball = new GameObj($('#ball'), physicsBody)

  window.setInterval(update, 1000 / 60)

class GameObj
  constructor: (@div, @physicsBody) ->

  update: ->
    left = @physicsBody.GetPosition().x * SCALE - @div.width()/2
    top = height - @physicsBody.GetPosition().y * SCALE - @div.height()/2
    @div.css 'left',  left + 'px'
    @div.css 'top', top + 'px'

update = ->
  world.SetGravity(gravity)
  world.Step( 1 / 60 ,  10 ,  10)
  ball.update()
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
    playground.width width
  if aspect < MINASPECT
    height = width / MINASPECT
    playground.height height
  bodyWith = $('body').width()
  playground.css 'left', (bodyWith - width) / 2 + 'px'




deviceOrientationHandler = (tiltLR, tiltFB, dir, motUD) ->
    orientation = $ '#orientation'
    orientation.html "tiltLR:#{tiltLR} tiltFB:#{tiltFB} dir:#{dir} motUD:#{motUD} W:#{width} H:#{height}"

window.onload = () ->
  init()
