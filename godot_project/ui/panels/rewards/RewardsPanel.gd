extends Panel

signal shown(panel)

var active = false
var players = null  # Array[Player]


func _ready():
    if players == null:
        set_players(load("player_list.gd").new())
#    assert(players != null)

    var timer = $ActivationTimer
    timer.connect("timeout", self, "_on_timer_timeout")
    timer.start()


func _process(_delta):
#    if active and (
#        Input.is_action_just_released("p1_action")
#        or Input.is_action_just_released("p2_action")
#    ):
    if not active:
        return

    for player_id in players.size():
        var player = players.get_player(player_id)
        if not player.cpu and Input.is_action_just_released("%s_action" % player.controller_id):
            # print("shown")
            emit_signal("shown", self)
            break


func set_players(players_):
    players = players_


func set_rewards(rewards: Array):
    var i = 1
    for reward in rewards:
        get_node("RewardLine%s" % i).set_reward(reward)
        i += 1


func _on_timer_timeout():
    active = true
    $Help.visible = true
