init = ->
  if window.DeviceOrientationEvent
    window.addEventListener 'deviceorientation',
      (event) ->
        tiltLR = event.gamma
        tiltFB = event.beta
        dir = event.alpha
        motUD = null
        deviceOrientationHandler tiltLR, tiltFB, dir, motUD
      , false
  else if window.OrientationEvent
    window.addEventListener 'MozOrientation',
      (event) ->
        tiltLR = event.x * 90
        tiltFB = event.y * -90
        dir = null
        motUD = event.z
        deviceOrientationHandler(tiltLR, tiltFB, dir, motUD)
      , false
  else
    alert "Sorry your device/browser is not supported"

  deviceOrientationHandler 'n/a','n/a','n/a'

deviceOrientationHandler = (tiltLR, tiltFB, dir, motUD) ->
    orientation = document.getElementById 'orientation'
    orientation.innerHTML = "tiltLR:#{tiltLR} tiltFB:#{tiltFB} dir:#{dir} motUD:#{motUD}"

window.onload = () ->
  init()
