extends ColorRect

# TODO: in minigame base class/scene
signal game_over(ranking)

################################################################################
# TODO:
#  - more fair direction at start (avoid unattainable positions)
################################################################################

# TODO: in minigame base class/scene
var players = null  # PlayerList
#var is_demo = true
var is_demo = false

# TODO: re-<export> different speeds?

onready var ball: KinematicBody2D = $Ball

var eliminations  # : Eliminations


func _ready():
    if players == null:
        randomize()
        players = load("player_list.gd").new(is_demo)

    eliminations = load("eliminations.gd").new(players)

    # warning-ignore:return_value_discarded
    $StartCountDown.connect("finished", self, "_on_StartCountDown_finished")

    for player_id in players.size():
        var player = players.get_player(player_id)
        var racket = get_node("Racket%s" % (player_id + 1))
        racket.set_player(player)

        # warning-ignore:return_value_discarded
        racket.connect("killed", self, "_on_racket_killed")

    if is_demo:
        $StartCountDown.visible = false
        $DemoIndicator.start()
    else:
        $DemoIndicator.visible = false


func _process(_delta):
    # TODO: add a real pause menu with a 'quit' option
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

#    if Input.is_action_just_released("ui_page_down"):
#        start()


# MINI-GAME INTERFACE ----------------------------------------------------------
func get_players_positions():
    return [
        $Racket1.global_position,
        $Racket2.global_position,
        $Racket3.global_position,
        $Racket4.global_position,
    ]


func start():
    if is_demo:
        $Ball.start()
    else:
        $StartCountDown.start()


# CALLBACKS --------------------------------------------------------------------
func _on_StartCountDown_finished():
    $Ball.start()


func _on_racket_killed(player_id):
    eliminations.eliminate([player_id])

    # TODO: factorise better?
    if eliminations.not_eliminated_count() == 1:
        ball.deactivate()
        eliminations.fill()
#        print('GAME OVER')
        emit_signal("game_over", eliminations.final_ranking())
