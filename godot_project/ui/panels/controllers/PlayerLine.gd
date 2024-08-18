extends Control

var player = null
#var _controller_id = null
#var _controller_name = null


func set_player(player_):
    player = player_
    $Portrait.texture = load('res://avatar/images/%s-portrait.png' % player.avatar_id)
    
    if player.cpu:
#        _controller_id = "cpu"
        player.controller_id = "cpu"
        $Portrait.modulate = Color(1.0, 1.0, 1.0, 0.5)
        $CPUMarker.visible = true
        $Message.visible = false
        $MessagePlayer.stop()
    else:
        $CPUMarker.visible = false
        $Message.visible = true
#        $MessagePlayer.play("idle")
        set_controller(null, '')


func get_controller_id():
    return player.controller_id


func set_controller(id, name):
#    _controller_id = id
#    _controller_name = name

    if id:
        $MessagePlayer.stop()
        $Message.text = "Ready (%s)" % name
    else:
        $MessagePlayer.play("idle")
        $Message.text = "Press Action to select controller"

    player.controller_id = id
