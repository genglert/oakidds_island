extends Node2D

# TODO: in minigame base class/scene
signal mini_game_ended(ranking)

################################################################################
# TODO:
#  - more fair direction at start (avoid unattainable positions)
################################################################################

var players = null  # Array[Player]
var auto_start = true

# TODO: re-<export> different speeds?

onready var ball: KinematicBody2D = $ArcadeScreen/Ball

var eliminations  # : Eliminations


func _ready():
    if players == null:
        randomize()
        players = load("player_list.gd").new()

    eliminations = load("eliminations.gd").new(players)

    # warning-ignore:return_value_discarded
    $ArcadeScreen/StartCountDown.connect("finished", self, "_on_StartCountDown_finished")
    # warning-ignore:return_value_discarded
    $GameOver.connect("shown", self, "_on_game_over_shown")

    for player_id in players.size():
        var player = players.get_player(player_id)
        var racket = get_node("ArcadeScreen/Racket%s" % (player_id + 1))
        racket.set_player(player)

        # warning-ignore:return_value_discarded
        racket.connect("killed", self, "_on_racket_killed")

    if auto_start:
        start()


func _process(_delta):
    # TODO: add a real pause menu with a 'quit' option
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

    # TODO: remove
    # TODO: if DEBUG
    # TODO: factorise?
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
        $ArcadeScreen/Racket1.global_position,
        $ArcadeScreen/Racket2.global_position,
        $ArcadeScreen/Racket3.global_position,
        $ArcadeScreen/Racket4.global_position,
    ]


# TODO: factorise
func start():
    $ArcadeScreen/StartCountDown.start()


# CALLBACKS --------------------------------------------------------------------
func _on_StartCountDown_finished():
    $ArcadeScreen/Ball.start()


func _on_racket_killed(player_id):
    eliminations.eliminate([player_id])

    # TODO: factorise better?
    if eliminations.not_eliminated_count() == 1:
        ball.deactivate()
        eliminations.fill()
        $GameOver.display()


# TODO: factorise 
func _on_game_over_shown():
    emit_signal("mini_game_ended", eliminations.final_ranking())
