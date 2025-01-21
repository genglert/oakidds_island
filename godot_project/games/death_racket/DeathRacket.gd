extends Node2D

# TODO: in minigame base class/scene
signal mini_game_ended(ranking)

# TODO: in minigame base class/scene
var players = null  # PlayerList
var ranking = null  # Array[Player]

# TODO: re-<export> different speeds?

var screen_scene = preload("res://games/death_racket/DeathRacketGame.tscn")
var screen_node = null


func _ready():
    $GameOver.visible = false
    # warning-ignore:return_value_discarded
    $GameOver.connect("shown", self, "_on_game_over_screen_shown")

    start_demo()


#func _process(_delta):
#    if Input.is_action_just_released("ui_page_up"):
#        if screen_node.is_demo:
#            quit_demo()
#        else:
#            start()
#
#    # TODO: if DEBUG
#    # TODO: factorise?
##    if Input.is_action_just_released("ui_page_down"):
##        emit_signal(
##            "mini_game_ended",
##            [
##                [players.get_player(0)],
##                [players.get_player(1)],
##                [players.get_player(2)],
##                [players.get_player(3)],
##            ]
##        )


# ARCADE MACHINE INTERFACE -----------------------------------------------------
func get_players_positions():
    return screen_node.get_players_positions()


func set_players(players_):
    players = players_


func start_demo():
    if screen_node != null:
        screen_node.queue_free()
        screen_node = null

    screen_node = screen_scene.instance()
    screen_node.is_demo = true
    # screen_node.players = players  # Not useful in demo mode
    # warning-ignore:return_value_discarded
    screen_node.connect("game_over", self, "_on_game_over")

    $ScreenContainer.add_child(screen_node)

    screen_node.start()


# TODO: factorise
func quit_demo():
    if screen_node != null:
        assert(screen_node.is_demo)

        screen_node.queue_free()
        screen_node = null

    screen_node = screen_scene.instance()
    screen_node.is_demo = false
    screen_node.players = players

    # warning-ignore:return_value_discarded
    screen_node.connect("game_over", self, "_on_game_over")

    $ScreenContainer.add_child(screen_node)


func start():
    assert(is_instance_valid(screen_node))
    assert(not screen_node.is_demo)

    screen_node.start()



# CALLBACKS --------------------------------------------------------------------
func _on_game_over(ranking_):
    if screen_node.is_demo:
        start_demo()
    else:
        ranking = ranking_
        $GameOver.display()


func _on_game_over_screen_shown():
    assert(ranking != null)
#    print('END SIGNAL')
    emit_signal("mini_game_ended", ranking)
