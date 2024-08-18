extends Panel

signal shown(panel)

var active = false
var players = null  # Array[Player]


func _ready():
    if players == null:
        set_players(load("player_list.gd").new())
#    assert(players != null)

    var timer = $ActiveTimer
    timer.connect("timeout", self, "_on_ActiveTimer_timeout")
    timer.start()


func _process(_delta):
    if not active:
        return
    
    for player_id in players.size():
        var player = players.get_player(player_id)
        if not player.cpu and Input.is_action_just_released("%s_action" % player.controller_id):
#            print("shown")
            emit_signal("shown", self)
            break


func set_players(players_):
    players = players_


func set_victory(victory):
    for player in victory.winners:
        var portrait = TextureRect.new()
        # TODO: factorise (method in Player?)
        portrait.texture = load('res://avatar/images/%s-portrait.png' % player.avatar_id)
        $Portraits.add_child(portrait)

    $Reason.text = victory.reason


func _on_ActiveTimer_timeout():
    active = true
    $Help.visible = true
