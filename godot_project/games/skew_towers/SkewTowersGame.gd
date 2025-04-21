extends ColorRect

# TODO: in minigame base class/scene
signal game_over(ranking)

################################################################################
# TODO:
#  - Physics for inactive bricks too?
################################################################################

var players = null  # PlayerList
#var is_demo = true
var is_demo = false

# TODO: <export> different speeds?

var scores  # : Scores
var is_over = false


func _ready():
    if players == null:
        players = load("player_list.gd").new(is_demo)

    scores = load("scores.gd").new(players)

    $StartCountDown.connect("finished", self, "_on_StartCoutDown_finished")

    for player_id in players.size():
        var player = players.get_player(player_id)
        var manager = get_node("BrickManager%s" % (player_id + 1))
        manager.set_player(player)
        # warning-ignore:return_value_discarded
        manager.connect("filled", self, "_on_brick_manager_filled")

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

    # TODO: comment
    if Input.is_action_just_released("ui_page_down"):
        start()


# MINI-GAME INTERFACE ----------------------------------------------------------
func get_players_positions():
    return [
        $BrickManager1.global_position,
        $BrickManager2.global_position,
        $BrickManager3.global_position,
        $BrickManager4.global_position,
    ]


func start():
    if is_demo:
        _on_StartCoutDown_finished()
    else:
        $StartCountDown.start()


# CALLBACKS --------------------------------------------------------------------
func _on_StartCoutDown_finished():
    for manager_node in get_tree().get_nodes_in_group('MANAGERS'):
        manager_node.active = true


func _on_brick_manager_filled(player_id, score):
#    if is_over:  TODO??
#        return

    scores.increment_score(player_id, score)
    
    var score_node = get_node('Score%s' % (player_id + 1))
    score_node.set_text(String(score))
    score_node.visible = true

    for manager_node in get_tree().get_nodes_in_group('MANAGERS'):
        if not manager_node.filled:
            return
    is_over = true
    print('GAME OVER')
    emit_signal("game_over", scores.final_ranking())
