extends Spatial

signal avatar_acted

# TODO: export?
#const CAM_SPEED = 10.0
const CARDS_RATIO = 0.3  # ratio of road blocks which contain a card
#const CARDS_RATIO = 0  # ratio of road blocks which contain a card
#const CARTRIDGES_RATIO = 0.1  # ratio of road blocks which contain a cartridge
const CARTRIDGES_RATIO = 0.5  # ratio of road blocks which contain a cartridge
const AVATARS = 'avatars'
const ITEMS = 'items'

const Avatar = preload("res://avatar/Avatar.tscn")
# TODO: rename .tscn ?
const CardItem = preload("res://world/items/Card.tscn")
const CartridgeItem = preload("res://world/items/Cartridge.tscn")

# TODO: compute from blocks' rayon
var avatars_sprite_offsets = [
#    Vector3( 0.7, 0,  0.5),
#    Vector3( 0.2, 0,  0.2),
#    Vector3(-0.2, 0, -0.2),
#    Vector3(-0.7, 0, -0.5),
    Vector3( 0.5, 0,  0.7),
    Vector3(-0.5, 0,  0.23),
    Vector3( 0.5, 0, -0.23),
    Vector3(-0.5, 0, -0.7),
]

var players = null
var card_generator = null
var hud = null


func _init():
    assert(CARDS_RATIO + CARTRIDGES_RATIO <= 1.0)


func _ready():
    assert(players != null)
    assert(card_generator != null)
    assert(hud != null)
    
    var origin = $GroundBlocks.get_road_position(1)
    if origin == null:
        printerr('No road start found.')
        get_tree().quit(1)

    hud.connect('card_used', self, '_on_hud_card_used')

    # TODO: offset per type of sprite (to get the base centered)
    for player_idx in players.size():
        var player = players.get_player(player_idx)
        assert(player.road_idx == 1)

        var avatar = Avatar.instance()
        avatar.set_player(player)
        avatar.position_offset = avatars_sprite_offsets[player_idx]
        avatar.set_origin(origin)

        avatar.connect("moved", self, "_on_avatar_moved")

        avatar.add_to_group(AVATARS)
        add_child(avatar)

    # ITEMS ---------
    var road_end_idx = $GroundBlocks.road_end_idx
    var items_road_indices = {}

    # Cards ---
    for _i in ((road_end_idx + 1) * CARDS_RATIO):
        var item_idx = 2 + randi() % (road_end_idx - 2)
#        var item_idx = 2 + _i

        if item_idx in items_road_indices:
            continue

        items_road_indices[item_idx] = null  # Emulates a Set

        var item = CardItem.instance()
        item.road_idx = item_idx
        item.set_translation($GroundBlocks.get_road_position(item_idx))
        item.add_to_group(ITEMS)
        item.card = card_generator.generate_card()

        add_child(item)

    # Cartridges ---
    # TODO: factorise
    for _i in ((road_end_idx + 1) * CARTRIDGES_RATIO):
        # TODO avoid cartridge in the first quarter of the road??
        var item_idx = 2 + randi() % (road_end_idx - 2)
#        var item_idx = 2 + _i

        # TODO: retry !!!!
        if item_idx in items_road_indices:
            continue

        items_road_indices[item_idx] = null  # Emulates a Set

        var item = CartridgeItem.instance()
        item.road_idx = item_idx
        item.set_translation($GroundBlocks.get_road_position(item_idx))
        item.add_to_group(ITEMS)

        add_child(item)

    # ITEMS [END] ---------

    # BUILDING ---------
    $Arcade.set_translation($GroundBlocks.allocate_random_grass_block().top)

    # TODO: pick random building...
    var RockHouse = load("res://world/scenery/RockHouse.tscn")
    for _i in 2:
        var rock_house = RockHouse.instance()
        add_child(rock_house)
        rock_house.set_translation($GroundBlocks.allocate_random_grass_block().top)

    var Pine = load("res://world/scenery/Pine.tscn")
    for _i in 2:
        var pine = Pine.instance()
        add_child(pine)
        pine.set_translation($GroundBlocks.allocate_random_grass_block().top)

    var Herbs = load("res://world/scenery/Herbs01.tscn")
    for _i in 30:
        var herbs = Herbs.instance()
        add_child(herbs)
        herbs.set_translation($GroundBlocks.allocate_random_grass_block().top)

    # TODO: ...then fill with grass billboard

    # BUILDING [END] ---------


#func _process(delta):
#    if Input.is_action_pressed("ui_left"):
#        $Camera.translate(Vector3(-delta * CAM_SPEED, 0, 0))
#    elif Input.is_action_pressed("ui_right"):
#        $Camera.translate(Vector3(delta * CAM_SPEED, 0, 0))
#
#    if Input.is_action_pressed("ui_up"):
#        var cam = $Camera
#        cam.set_translation(cam.get_translation() + Vector3(0, 0, -delta * CAM_SPEED))
#    elif Input.is_action_pressed("ui_down"):
#        var cam = $Camera
#        cam.set_translation(cam.get_translation() + Vector3(0, 0, delta * CAM_SPEED))


func start_player_turn(player_id):
    var avatar = get_avatar(player_id)

    avatar.set_active()
    $Cam.track(avatar)


func focus_arcade_room() -> float:
    var duration = $Cam.estimate_duration($Arcade)
    $Cam.track($Arcade)

    return duration


func get_avatar(player_id):
    for node in get_tree().get_nodes_in_group(AVATARS):
        if node.player.id == player_id:
            return node

    print('get_avatar(): ERROR ->', player_id)
    get_tree().quit()


func get_item(road_idx):
    for node in get_tree().get_nodes_in_group(ITEMS):
        if node.road_idx == road_idx:
            return node

    return null


class RoadPosition:
    var index: int
    var position: Vector3

func get_road_position(road_idx) -> RoadPosition:
    var blocks = $GroundBlocks
    var road_end_idx = blocks.road_end_idx

    if road_idx > road_end_idx:
        road_idx %= road_end_idx

    var pos = blocks.get_road_position(road_idx)
    if pos == null:
        push_error('Cannot found next position for player')
        get_tree().quit()

    var result = RoadPosition.new()
    result.index = road_idx
    result.position = pos

    return result


func move_avatar(player_id, cases_incr):
    get_avatar(player_id).set_moving(cases_incr)


func _on_avatar_moved(player):
    var item = get_item(player.road_idx)

    # TODO: move this logic in main??
    if item != null:
        item.interact(player)

    emit_signal('avatar_acted')


func use_card(card):
    hud.show_card(card)


func _on_hud_card_used():
    emit_signal('avatar_acted')  # TODO: rename signal (VS other signal)
