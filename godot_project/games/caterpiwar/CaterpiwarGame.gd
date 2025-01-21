extends ColorRect

# TODO: in minigame base class/scene
signal game_over(ranking)

################################################################################
# TODO:
#  - caterpillar tail
#  - move & slide
#  - better IA? (smarter choice of target? etc..)
#  - some SFX? (particules when eating?)
#  - jaws animation?
################################################################################

################################################################################
# DESIGN QUESTIONS:
#  - improve random places for seeds to be more fair/fun?
################################################################################

# TODO: in minigame base class/scene
var players = null  # PlayerList
#var is_demo = true
var is_demo = false

var pip_scene = preload("Pip.tscn")

const MAX_SEEDS = 10
const SEEDS_CHUNKS = 3
var seeds_number = 0

var scores = {}  # player_id => int


func _ready():
    if players == null:
        randomize()
        players = load("player_list.gd").new(is_demo)

    for player_id in players.size():
        # TODO: factorise
        scores[player_id] = 0
        var player = players.get_player(player_id)
        var order = player_id + 1

        get_node("Caterpillar%s" % order).set_player(player)

    _spawn_seeds(MAX_SEEDS)

    # warning-ignore:return_value_discarded
    $StartCountDown.connect("finished", self, "_on_StartCoutDown_finished")

    if is_demo:
        $StartCountDown.visible = false
        $DemoIndicator.start()
    else:
        $DemoIndicator.visible = false


func _process(_delta):
    # TODO: add a real pause menu with a 'quit' option (factorise with all mini games)
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

#    if Input.is_action_just_released("ui_page_down"):
#        start()


func _spawn_seeds(count):
    for _i in count:
        var pip = pip_scene.instance()
        pip.connect("eaten", self, "_on_seed_eaten")
        add_child(pip)
        pip.add_to_group('pips')

        while true:
            var pos = Vector2(rand_range(0, rect_size.x), rand_range(0, rect_size.y))
            pip.position = pos

            # TODO: can we detect collison without moving?
            var collision_info = pip.move_and_collide(pos)

            if collision_info == null:
                break

    seeds_number += count


# MINI-GAME INTERFACE ----------------------------------------------------------
func get_players_positions():
    return [
        $Caterpillar1.global_position,
        $Caterpillar2.global_position,
        $Caterpillar3.global_position,
        $Caterpillar4.global_position,
    ]


# TODO: factorise
func start():
    if is_demo:
        _on_StartCoutDown_finished()
    else:
        $StartCountDown.start()


# CALLBACKS --------------------------------------------------------------------
func _on_StartCoutDown_finished():
    $SpiralCountDown.connect("over", self, "_on_countdown_over")
    $SpiralCountDown.start()

    for cat_node in get_tree().get_nodes_in_group('CATERPILLARS'):
        cat_node.active = true


func _on_countdown_over():
    for cat_node in get_tree().get_nodes_in_group('CATERPILLARS'):
        cat_node.active = false

    # TODO: factorise?
    var ranking = []

    # We remove duplicated scores
    var values_set = {}
    for value in scores.values():
        values_set[value] = null

    # Ascending sort of scores
    var score_values = values_set.keys()
    score_values.sort()
    score_values.invert()

    for value in score_values:
        var tier_players = []

        for player_id in scores:
            if scores[player_id] == value:
                tier_players.append(players.get_player(player_id))

        ranking.append(tier_players)

        # NB: if there are 2 players at first place, there is no player at second place etc...
        for _extra in range(1, tier_players.size()):
            ranking.append([])

#    print('GAME OVER')
    emit_signal("game_over", ranking)


func _on_seed_eaten(player_id):
    seeds_number -= 1

    if MAX_SEEDS - seeds_number >= SEEDS_CHUNKS:
        _spawn_seeds(SEEDS_CHUNKS)

    scores[player_id] += 1
