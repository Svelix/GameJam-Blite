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

MAXASPECT = 0.75
MINASPECT = 0.5
SCALE = 50
DEBUG = false

requestAnimFrame = (() ->
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)
)()


class Game
  playground = null
  width = null
  height = null
  world = null
  gravity = new b2Vec2 0, 0
  bodyDef = null
  fixDef = null
  b2heigth = null
  b2width = null
  balls = []
  platforms = []
  topBorder = null
  levels = []

  createAudio = (src) ->
    audio = new Audio()
    audio.src = src
    audio

  background = createAudio('sound/background.wav')

  lastTime: null
  running:  false


  init: ->
    #if setupOrientationHandler()
    if setupMotionHandler()
      setupPlayground()
      setupB2()
      setupDebugDraw() if DEBUG
      @setupButtons()
      createLevels()

  reset: (event) =>
    element.remove() for element in balls.concat(platforms)

  addAnimationElement: (element) ->
    element.bind "animationend webkitAnimationEnd oAnimationEnd MSAnimationEnd",
      -> element.remove()
    $('#front').append(element)

  taunt: (text) ->
    @addAnimationElement $("<div class='taunt'>#{text}</div>")

  countdown: (time, func) ->
    if time <= 0
      @addAnimationElement $("<div class='countdown'>Go!</div>")
      func()
    else
      @addAnimationElement $("<div class='countdown'>#{time}</div>")
      setTimeout( 
        => @countdown(time-1, func),
        1000)



  start: (event) =>
    @taunt "Level: #{Math.round(Math.random() * 10)}"
    @reset()
    @currentLevel = levels[0]
    @currentLevel.load()
    background.play()

    setTimeout @startCountDown, 1000

  startCountDown: =>
    @countdown 3, =>
      @lastTime = Date.now()
      @running = true
      new Ball(@, b2width / 2 - 2, b2heigth - 2, true)
      new Ball(@, b2width / 2 + 2, b2heigth - 2, false)
      requestAnimFrame @update

  stop: (event) =>
    @running = false

  gameOver: ->
    @stop()

  levelEnd: ->
    @taunt @currentLevel.taunt
    @currentLevel.sound.play()
    @stop()

  setupButtons: ->
    $('#start').click @start
    $('#stop').click @stop
    return

  setupDebugDraw = ->
    canvas = $("<canvas id='canvas' style='width:#{width}px; height:#{height}px; position:absolute; top:0; left:0;'/>")
    playground.append canvas
    debugDraw = new b2DebugDraw()
    context = document.getElementById("canvas").getContext("2d")
    context.canvas.width = width
    context.canvas.height = height
    debugDraw.SetSprite(context)
    debugDraw.SetDrawScale(SCALE)
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

    createStaticBox = (x1, y1, x2 , y2, sensor = false) ->
      bodyDef.type = b2Body.b2_staticBody
      bodyDef.position.x = (x1 + x2)/2
      bodyDef.position.y = (y1 + y2)/2
      fixDef.shape = new b2PolygonShape
      fixDef.shape.SetAsBox((x2-x1)/2, (y2-y1)/2)
      fixDef.filter.maskBits = 0xFF
      fixDef.filter.categoryBits = 0xFF
      fixDef.isSensor = sensor
      body = world.CreateBody(bodyDef)
      body.CreateFixture(fixDef)
      body

    # create ground and walls
    # bottom
    createStaticBox(-0.5, -0.5, b2width + 0.5, 0)
    # left
    createStaticBox(-0.5, 0, 0, b2heigth)
    # right
    createStaticBox(b2width, 0, b2width+0.5, b2heigth)
    # top
    topBorder = createStaticBox(-0.5, b2heigth, b2width + 0.5, b2heigth + 0.5, true)
    fixDef.isSensor = false



  minfps = 2000
  maxfps = 0
  update: =>
    now = Date.now()
    step = (now - @lastTime) / 1000
    fps = Math.round(1/step)
    minfps = Math.min minfps, fps
    maxfps = Math.max maxfps, fps
    $('#fps').html "FPS: #{fps} min:#{minfps} max:#{maxfps}"
    @lastTime = now
    world.SetGravity(gravity)
    world.Step( step ,  10 ,  10)
    element.update() for element in balls.concat(platforms)
    world.DrawDebugData() if DEBUG
    world.ClearForces()
    @checkForLevelEnd()
    requestAnimFrame @update if @running

  checkForLevelEnd: ->
    contacts = topBorder.GetContactList()
    @gameOver() if contacts?.contact.IsTouching()
    @levelEnd() if platforms.length == 0


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

  class GameObj
    constructor: (@div, @white) ->
      bodyDef.position.x = @x
      bodyDef.position.y = @y
      if @white
        @div.addClass('white')
        fixDef.filter.categoryBits = 0x01
        fixDef.filter.maskBits = 0x01
      else
        @div.addClass('black')
        fixDef.filter.categoryBits = 0x02
        fixDef.filter.maskBits = 0x02
      @physicsBody = world.CreateBody(bodyDef)
      @physicsBody.CreateFixture(fixDef)
      playground.append @div

    update: ->
      {@x, @y} = @physicsBody.GetPosition()
      left = @x * SCALE - @div.width()/2
      top = height - @y * SCALE - @div.height()/2
      @div.css {left, top}

    remove: ->
      world.DestroyBody(@physicsBody)
      @div.remove()

  class Ball extends GameObj
    constructor: (@game, @x, @y, @white) ->
      bodyDef.type = b2Body.b2_dynamicBody
      bodyDef.linearVelocity = new b2Vec2 0, 0
      fixDef.shape = new b2CircleShape(0.5)
      fixDef.filter.groupIndex = 1
      div = $("<div class='ball'/>")
      super(div, @white)
      balls.push @
    remove: ->
      balls = balls.splice balls.indexOf(@)+1, 1
      super

  class Platform extends GameObj
    constructor: (x1, y1, x2, y2, speed, white) ->
      @x = (x1 + x2) / 2
      @y = (y1 + y2) / 2
      w = Math.abs(x2 - x1)
      h = Math.abs(y2 - y1)
      bodyDef.type = b2Body.b2_kinematicBody
      bodyDef.linearVelocity = new b2Vec2 0, speed
      fixDef.shape = new b2PolygonShape
      fixDef.shape.SetAsBox(w/2, h/2)
      fixDef.filter.groupIndex = 0
      div = $("<div class='platform' style='width:#{w*SCALE}px; height=#{h*SCALE}px'/>")
      super(div, white)
      platforms.push @
    update: ->
      position = @physicsBody.GetPosition()
      if position.y > b2heigth + 0.25
        @remove()
      super
    remove: ->
      platforms = platforms.splice platforms.indexOf(@)+1, 1
      super

  class Level
    constructor: (@nummer, @speed, @balls, @taunt, @sound) ->
      @platforms = []

    addPlatform: (left, right, top, white) ->
      @platforms.push {left, right, top, white}

    load: ->
      for {left, right, top, white} in @platforms
        x1 = left * b2width / 10
        x2 = right * b2width / 10
        y1 = -top * 0.5
        y2 = y1 - 0.5
        new Platform(x1, y1, x2, y2, @speed, white)

  createLevels = ->
    level = new Level(1, 1, 2, "Good!", createAudio("sound/1.wav"))
    level.addPlatform(0,6,0,true)
    level.addPlatform(4,10,5,false)
    levels[0] = level



window.onload = () ->
  game = new Game()
  game.init()
