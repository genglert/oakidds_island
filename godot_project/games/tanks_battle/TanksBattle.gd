extends Node2D

# TODO: rename tanks_battle/main.gd??

# TODO: in minigame base class/scene
signal mini_game_ended(ranking)

var players = null  # PlayerList
var auto_start = true

# TODO: <export> different speeds?

var eliminations  # : Eliminations
var is_over = false

################################################################################
# TODO:
#  - more SFX (particules on impacts + shells explosions)
################################################################################

func _ready():
    if players == null:
        players = load("player_list.gd").new()

    eliminations = load("eliminations.gd").new(players)

    # warning-ignore:return_value_discarded
    $ArcadeScreen/StartCountDown.connect("finished", self, "_on_StartCoutDown_finished")
    # warning-ignore:return_value_discarded
    $GameOver.connect("shown", self, "_on_game_over_shown")

    for player_id in players.size():
        var player = players.get_player(player_id)
        var tank = get_node("ArcadeScreen/Tank%s" % (player_id + 1))
        tank.set_player(player)

        # warning-ignore:return_value_discarded
        tank.connect("killed", self, "_on_tank_killed")

    if auto_start:
        start()


func _process(_delta):
    # TODO if DEBUG
    # TODO: add a real pause menu with a 'quit' option (factorise with all mini games)
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

    # TODO: remove
#    if Input.is_action_just_released("ui_page_down"):
#        emit_signal(
#            "mini_game_ended",
#            [
#                [players.get_player(0)],
#                [players.get_player(1)],
#                [players.get_player(2)],
#                [players.get_player(3)],
#            ]
#        )


# MINI-GAME INTERFACE ----------------------------------------------------------
func get_players_positions():
    return [
        $ArcadeScreen/Tank1.global_position,
        $ArcadeScreen/Tank2.global_position,
        $ArcadeScreen/Tank3.global_position,
        $ArcadeScreen/Tank4.global_position,
    ]


# TODO: factorise
func start():
    $ArcadeScreen/StartCountDown.start()


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
        $GameOver.display()


# TODO: factorise 
func _on_game_over_shown():
    emit_signal("mini_game_ended", eliminations.final_ranking())
