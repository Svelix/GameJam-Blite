init = ->
  if setupOrientationHandler()
    setupPlayground()

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

playground = width = height = null
MAXASPECT = 0.75
MINASPECT = 0.5

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
