extends ColorRect

# TODO: in minigame base class/scene
signal game_over(ranking)

################################################################################
# TODO:
#  - more SFX (particules on impacts + shells explosions)
################################################################################

var players = null  # PlayerList
#var is_demo = true
var is_demo = false

# TODO: <export> different speeds?

var eliminations  # : Eliminations
var is_over = false

func _ready():
    if players == null:
        players = load("player_list.gd").new(is_demo)

    eliminations = load("eliminations.gd").new(players)

    $StartCountDown.connect("finished", self, "_on_StartCoutDown_finished")

    for player_id in players.size():
        var player = players.get_player(player_id)
        var tank = get_node("Tank%s" % (player_id + 1))
        tank.set_player(player)

        # warning-ignore:return_value_discarded
        tank.connect("killed", self, "_on_tank_killed")

    if is_demo:
        $StartCountDown.visible = false
        $DemoIndicator.start()
    else:
        $DemoIndicator.visible = false


func _process(_delta):
    # TODO if DEBUG
    # TODO: add a real pause menu with a 'quit' option (factorise with all mini games)
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

#    if Input.is_action_just_released("ui_page_down"):
#        start()


# MINI-GAME INTERFACE ----------------------------------------------------------
func get_players_positions():
    return [
        $Tank1.global_position,
        $Tank2.global_position,
        $Tank3.global_position,
        $Tank4.global_position,
    ]


func start():
    if is_demo:
        _on_StartCoutDown_finished()
    else:
        $StartCountDown.start()


# CALLBACKS --------------------------------------------------------------------
func _on_StartCoutDown_finished():
    for tank_node in get_tree().get_nodes_in_group('TANKS'):
        tank_node.active = true


func _on_tank_killed(player_id):
    if is_over:
        return

    eliminations.eliminate([player_id])

    # TODO: factorise better?
    if eliminations.not_eliminated_count() == 1:
        eliminations.fill()
        is_over = true
#        print('GAME OVER')
        emit_signal("game_over", eliminations.final_ranking())
