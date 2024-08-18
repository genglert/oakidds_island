extends Panel

signal completed

export(bool) var active = true
var complete = false
var players = null  # Array[Player]


func _ready():
    if players == null:
        set_players(load("player_list.gd").new())

    # warning-ignore:return_value_discarded
    $CompleteTimer.connect("timeout", self, "_on_CompleteTime_timeout")

    # TODO: back Button (when mouse is OK)


var controllers = {
    "kb1": "Keyboard #1",
    "kb2": "Keyboard #2",
    "jp1": "Joypad #1",
    "jp2": "Joypad #2",
    "jp3": "Joypad #3",
    "jp4": "Joypad #4",
}

func _process(_delta):
    if not active or complete:
        return

    # TODO: do not inspect not detected joypads?
    for controller_id in controllers.keys():
        if Input.is_action_just_pressed("%s_action" % controller_id):
            affect(controller_id, controllers[controller_id])
        if Input.is_action_just_pressed("%s_cancel" % controller_id):
            unaffect(controller_id)

    if not complete and is_complete():
        complete = true
        $CompleteLabel.show()
        $CompleteTimer.start()

#        emit_signal("completed")


func affect(controller_id, controller_name):
    for order in range(1, 5):
        var line = get_node("PlayerLine%s" % order)
        if not line.get_controller_id():
            line.set_controller(controller_id, controller_name)
            return


func unaffect(controller_id):
    for order in range(1, 5):
        var line = get_node("PlayerLine%s" % order)
        if line.get_controller_id() == controller_id:
            line.set_controller(null, '')


func set_players(players_):
    players = players_
    
    for player_id in players.size():
        get_node("PlayerLine%s" % (player_id + 1)).set_player(
            players.get_player(player_id)
        )


func is_complete():
    for order in range(1, 5):
        if not get_node("PlayerLine%s" % order).get_controller_id():
            return false

    return true


func _on_CompleteTime_timeout():
    emit_signal("completed")
