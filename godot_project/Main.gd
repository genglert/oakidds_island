extends Node

################################################################################
# TODO 1.0:
#  - ??
################################################################################

################################################################################
# TODO:
#  - arcade screen fx
#  - manage pause
#  - free play for minigames
#  - music (menu, world, minigame)
#  - sound fx:
#      - world: move, get card, get cartridge
#      - transition
#      - minigames (impact, explosion, grab)
#  - smoother camera move
#  - (improve game over => hide turn indicator & player panels?)
#  - "about" panel
#  - controller panel => can go back
#      - button + mouse?
#      - player #1 press cancel when no controller chosen?
#  - 3D arcade room
#  - improve existing minigames
#  - other mini games
#  - other types of card
#  - add more buildings
################################################################################

################################################################################
# DESIGN QUESTIONS:
#  - countdown in card panel?
#  - respawn cards/cartridges? top when all carrtridges have been collected?
#  - should the player chose the cards it want to use to buy a cartridge?
#  - can a player buy a cartridge before they moves (e.g. they've just won the minigame)?
################################################################################

# TODO: configuration file? export? user configuration maybe...
const MAX_TURN = 3

enum SceneMode {
    TITLE_SCREEN,
    TURN_START,
    PLAYER_START,
    PLAYER_ACTIONS,
    GO_TO_ARCADE,
    WORLD_TO_MINIGAME,
    MINIGAME,
    MINIGAME_REWARDS,
    GAMEOVER,
}

var available_games = [
    "death_racket/DeathRacket",
    "tanks_battle/TanksBattle",
    "caterpiwar/Caterpiwar",
]
var played_games = []


# Dice mutators ----------------------------------------------------------------
class AdderMutator:
    var value = 0
    var uses = 1  # Number of uses

    func _init(value_, uses_=1):
        value = value_
        uses = uses_

    func do(dice_result: int) -> int:
        return dice_result + value

    # TODO: sprite name instead?
    func as_str() -> String:
        if value >= 0:
            return "+%s" % value
        else:
            return "%s" % value


# Context ----------------------------------------------------------------------
class ActionContext:
    var _player_id: int
    var _players: PlayerList
    var _world  #: World
    var _hud  #: HUD

    func _init(player_id, players, world, hud):
        _player_id = player_id
        _players = players
        _world = world
        _hud = hud

    func get_hud():
        return _hud

    func get_player():
        return _players.get_player(_player_id)

    func get_player_id():
        return _player_id

    func get_players():
        return _players

    func get_world():
        return _world


# Cards ------------------------------------------------------------------------
enum CardType {
    DICE,
    ACTION,
#    ....,
}

class Card:
    var id: int
    var name: String
    var type  # : CardType
#    var use = 1  # Number of use

    func _init(id_: int, name_: String, type_=CardType.ACTION):
        self.id = id_
        self.name = name_
        self.type = type_

    func action(_context: ActionContext):
        if type != CardType.ACTION:
            printerr('The card "%s" is not an ACTION card' % name)

    func get_mutator():
        if type != CardType.DICE:
            printerr('The card "%s" is not a DICE card' % name)

        return null


class BootsCard extends Card:
    var mutator_uses = 1
    var power = 1  # Value added to the dice's result

    func _init(id_).(id_, "boots", CardType.DICE):
        pass

    func get_mutator():
        return AdderMutator.new(power, mutator_uses)


class PigginCard extends Card:
    var power = 1  # Number of stolen cards

    func _init(id_).(id_, "piggin"):
        pass

    func action(context):
        var stolen_cards = []
        var stolen_card = null
        var player_id = context.get_player_id()
        var players = context.get_players()

        for player in players.other_players(player_id):
            for _i in power:
                stolen_card = player.deck.remove_random_card()
                if stolen_card == null:
                    break

                stolen_cards.append(stolen_card)

        players.get_player(player_id).deck.add_cards(stolen_cards)


class MudWallCard extends Card:
    var power = -1  # Number substracted to the dices

    func _init(id_).(id_, "mudwall"):
        pass

    func action(context):
        for player in context.get_players().other_players(context.get_player_id()):
            player.mutators.append(AdderMutator.new(power))


class WaterShootCard extends Card:
    var power = 3  # Number of removed cards

    func _init(id_).(id_, "watershoot"):
        pass

    # TODO: it would probabbly be a good idea to split into methods/functions
    #       to factorise with future actions...
    func action(context):
        var player_id = context.get_player_id()
        var other_players = context.get_players().other_players(player_id)
        var other_indices = []

        for player in other_players:
            if not other_indices.has(player.road_idx):
                other_indices.append(player.road_idx)

        other_indices.sort()

        var base_road_idx = context.get_player().road_idx
        var target_idx = null
        for road_idx in other_indices:
            if road_idx >= base_road_idx:
                target_idx = road_idx
                break

        # farther player(s) have passed the end (or your are the first)
        if target_idx == null:
            target_idx = other_indices[0]

        var target_players = []
        for player in other_players:
            if player.road_idx == target_idx:
                target_players.append(player)

        for target in target_players:
            for _i in power:
                target.deck.remove_random_card()


# Cards generator --------------------------------------------------------------
class CardGenerator:
    var _card_counter = 0
    var _classes
    var _priority_total

    func _init(classes: Array):
        _classes = classes
        _priority_total = 0
        for item in classes:
            _priority_total += item[0]

    func generate_card(card_class=null):
        var key = randi() % _priority_total
        _card_counter += 1

        if card_class == null:
            for item in _classes:
                key -= item[0]
                if key < 0:
                    card_class = item[1]
                    break

            if card_class == null:
                printerr("Card generation bug!")
                card_class = _classes[0][1]

        return card_class.new(_card_counter)


# Array with [probability, card class]
var card_generator = CardGenerator.new([
    [9, BootsCard],
    [2, MudWallCard],
    [1, PigginCard],
    [1, WaterShootCard],
])


# Actions ----------------------------------------------------------------------
# TODO: better factorisation between different Actions?
class Action:
    var context

    func _init(ctxt: ActionContext):
        context = ctxt

    func do():
        printerr('Not implemented method.')


class MoveOnDiceAction extends Action:
    var result

    func _init(ctxt).(ctxt):
        pass

    func do():
        var player = context.get_player()
        var base_result = randi() % 6 + 1
        result = base_result

        var used_mutators = []
        var final_mutators = []

        # TODO: Dice component to show mutator etc...
        for mutator in player.mutators:
            result = mutator.do(result)
            used_mutators.append(mutator)
            if mutator.uses != null:
                mutator.uses -= 1

            if mutator.uses == null or mutator.uses >= 1:
                final_mutators.append(mutator)

        player.mutators = final_mutators

        var hud = context.get_hud()
        hud.connect("dice_shown", self, "_on_hud_dice_shown")
        hud.show_dice(base_result, used_mutators)

    func _on_hud_dice_shown():
        context.get_world().move_avatar(context.get_player_id(), result)


class CardAction extends Action:
    var card = null

    func _init(card_, ctxt).(ctxt):
        card = card_

    func do():
        card.action(context)

        context.get_world().use_card(card)


# Rewards ----------------------------------------------------------------------
# Number of cards won by players (1rst won the mini-game, etc...)
var REWARD_BOARD = [3, 2, 1, 0]


class Reward:
    var player
    var cards

    func _init(player_, cards_):
        player = player_
        cards = cards_

    func give():
        player.deck.add_cards(cards)


# TODO: RewardList class?
func build_rewards(ordered_players):
    var rewards = []
    
    for order in ordered_players.size():
        for player in ordered_players[order]:
            var cards = []
            for _i in REWARD_BOARD[order]:
                cards.append(card_generator.generate_card())

            rewards.append(Reward.new(player, cards))

    return rewards


# ------------------------------------------------------------------------------
var turn = 0  # Incremented when game starts
var mode = SceneMode.TITLE_SCREEN

var world_map = null
var hud = null
var title_scene = preload("res://ui/TitleScreen.tscn")
var title_screen = null
var mini_game = null
var cards_scene = preload("res://ui/panels/cards/CardsPanel.tscn")
#var cards_panel = null
var rewards_scene = preload("res://ui/panels/rewards/RewardsPanel.tscn")

var players: PlayerList = load("player_list.gd").new()
var current_player_idx = 0

var transition_scn = preload("res://transition/Jaws.tscn")
var transition = null

# TODO: real class ?
var current_actions = []
var current_action_idx = null

var last_ranking = null

var ARCADE_ROOM_WAITING_DURATION = 1.0

func _init():
    # Players ---
    # TODO: avatar selection system
#    players.get_player(0).deck.add_cards([
##        card_generator.generate_card(),
##        card_generator.generate_card(WaterShootCard),
##        card_generator.generate_card(BootsCard),
##        card_generator.generate_card(PigginCard),
#        card_generator.generate_card(MudWallCard),
#    ])
#    players.get_player(1).deck.add_cards([
##        card_generator.generate_card(),
##        card_generator.generate_card(WaterShootCard),
##        card_generator.generate_card(BootsCard),
#        card_generator.generate_card(PigginCard),
#    ])

    randomize()


func _ready():
    # warning-ignore:return_value_discarded
    $TurnStartTimer.connect("timeout", self, "_on_Timer_turn_start_timeout")
    # warning-ignore:return_value_discarded
    $PlayerStartTimer.connect("timeout", self, "_on_Timer_player_start_timeout")
    # warning-ignore:return_value_discarded
    $WorldToMinigameTimer.connect("timeout", self, "_on_Timer_world_to_minigame_timeout")

    show_title_screen(true)


func _process(_delta):
#    if Input.is_action_just_released("ui_cancel"):
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()


func show_title_screen(start_at_ready):
    assert(not is_instance_valid(title_screen))

    mode = SceneMode.TITLE_SCREEN
    title_screen = title_scene.instance()
    title_screen.players = players
    title_screen.start_at_ready = start_at_ready
    # warning-ignore:return_value_discarded
    title_screen.connect("completed", self, "_on_title_screen_completed")

    add_child_below_node($HUDContainer, title_screen)


func start_new_turn():
    turn += 1
    current_player_idx = 0
    mode = SceneMode.TURN_START

    hud.set_turn(turn)
    hud.show_players_panels()
    $TurnStartTimer.start()


func start_player():
    mode = SceneMode.PLAYER_START

    world_map.start_player_turn(current_player_idx)
    hud.set_active_player(current_player_idx)
    $PlayerStartTimer.start()


func launch_next_action():
    # NB: we do not consume actions (with current_actions.pop_front()) because
    #     actions can connect themselves to signal in do(), & so we need to keep
    #     a living reference.
    current_action_idx += 1
    if current_action_idx >= current_actions.size():
        return false

    current_actions[current_action_idx].do()

    return true


# Signal handlers --------------------------------------------------------------
func _on_Timer_turn_start_timeout():
    if turn <= MAX_TURN:
        start_player()
    else:
        mode = SceneMode.GAMEOVER

        var victory = load("victory.gd").new(players)
        var panel = load("res://ui/panels/game_over/GameOverPanel.tscn").instance()
        panel.set_players(players)
        panel.set_victory(victory)
        # warning-ignore:return_value_discarded
        panel.connect("shown", self, "_on_game_over_panel_shown")
        add_child_below_node($PanelContainer, panel)


# TODO: move
func _on_game_over_panel_shown(panel):
    assert(mode == SceneMode.GAMEOVER)
    assert(not is_instance_valid(transition))

    panel.queue_free()

    transition = transition_scn.instance()
    transition.connect("entered", self, "_on_transition_to_title_entered")

    add_child_below_node($TransitionContainer, transition)


# TODO: move
func _on_transition_to_title_entered():
    assert(is_instance_valid(transition))
    assert(mode == SceneMode.GAMEOVER)
    world_map.queue_free()
    world_map = null

    hud.queue_free()
    world_map = null

    turn = 0

    players.reset()
    show_title_screen(false)

    transition.connect("exited", self, "_on_transition_to_title_exited")
    transition.exit()


func _on_transition_to_title_exited():
    assert(is_instance_valid(title_screen))
    assert(title_screen.start_at_ready == false)
    title_screen.go()


func _on_Timer_player_start_timeout():
#    cards_panel = cards_scene.instance()
    var cards_panel = cards_scene.instance()
    cards_panel.set_player(players.get_player(current_player_idx))
    # warning-ignore:return_value_discarded
    cards_panel.connect("cards_chosen", self, "_on_cards_chosen")
    add_child_below_node($PanelContainer, cards_panel)


func _on_Timer_world_to_minigame_timeout():
    assert(mode == SceneMode.WORLD_TO_MINIGAME)

    transition = transition_scn.instance()
    transition.connect("entered", self, "_on_transition_to_minigame_entered")

    add_child_below_node($TransitionContainer, transition)


func _on_title_screen_completed():
    assert(mode == SceneMode.TITLE_SCREEN)
    assert(not is_instance_valid(transition))

    transition = transition_scn.instance()
    transition.connect("entered", self, "_on_transition_to_party_entered")

    add_child_below_node($TransitionContainer, transition)


func _on_transition_to_party_entered():
    assert(mode == SceneMode.TITLE_SCREEN)
    assert(is_instance_valid(transition))
    assert(is_instance_valid(title_screen))

    title_screen.queue_free()
    title_screen = null

    # HUD ---
    var hud_scn = load("res://ui/hud/HUD.tscn")
    hud = hud_scn.instance()
    hud.players = players
    hud.set_max_turn(MAX_TURN)
    hud.set_turn(turn)
    hud.connect("positions_indicated", self, "_on_hud_positions_indicated")

    # World ---
    var world_map_scn = load("res://world/Island.tscn")
    world_map = world_map_scn.instance()
    world_map.players = players
    world_map.card_generator = card_generator
    world_map.hud = hud

    add_child_below_node($MainContainer, world_map)

    world_map.connect("avatar_acted", self, "_on_world_avatar_acted")
    add_child_below_node($HUDContainer, hud)

    transition.connect("exited", self, "start_new_turn")
    transition.exit()


func _on_transition_to_minigame_entered():
    assert(mode == SceneMode.WORLD_TO_MINIGAME)
    assert(is_instance_valid(transition))
    remove_child(world_map)

    if not available_games:
        available_games.append_array(played_games)
        played_games.clear()

    var game_name = available_games.pop_at(randi() % available_games.size())
    played_games.append(game_name)

    # TODO: launch the loading in parallel of the transition entering...
    var mini_game_scene = load("res://games/%s.tscn" % game_name)
    mini_game = mini_game_scene.instance()
    mini_game.players = players
    mini_game.auto_start = false
    add_child_below_node($MainContainer, mini_game)

    transition.connect("exited", self, "_on_transition_to_minigame_exited")
    transition.exit()


func _on_transition_to_minigame_exited():
    assert(mode == SceneMode.WORLD_TO_MINIGAME)
    assert(is_instance_valid(mini_game))

    mode = SceneMode.MINIGAME

    # NB: emit "_on_hud_positions_indicated" when finished
    hud.indicate_players_positions(mini_game.get_players_positions())


func _on_hud_positions_indicated():
    assert(mode == SceneMode.MINIGAME)
    assert(is_instance_valid(mini_game))

    mini_game.connect("mini_game_ended", self, "_on_mini_game_ended")
    mini_game.start()


#func _on_cards_chosen(cards: Array):
func _on_cards_chosen(panel, cards: Array):
    assert(mode == SceneMode.PLAYER_START)

    mode = SceneMode.PLAYER_ACTIONS

#    cards_panel.queue_free()
#    cards_panel = null
    panel.queue_free()

    var player = players.get_player(current_player_idx)
    player.deck.remove_cards(cards)

    var ctxt = ActionContext.new(current_player_idx, players, world_map, hud)

    for card in cards:
        # TODO: match?
        if card.type == CardType.DICE:
            player.mutators.append(card.get_mutator())
        elif card.type == CardType.ACTION:
            current_actions.append(CardAction.new(card, ctxt))
        else:
            printerr("CARD TYPE NOT MANAGED YET: ", card.type)

    # TODO: actions per player??
    current_actions.append(MoveOnDiceAction.new(ctxt))

    current_action_idx = -1  # incremented by launch_next_action

    launch_next_action()  # assert not null ?


func _on_world_avatar_acted():
    assert(mode == SceneMode.PLAYER_ACTIONS)

    hud.update_scores()

    if not launch_next_action():
        current_actions.clear()
        current_action_idx = null

        current_player_idx += 1
        if current_player_idx < players.size():
            start_player()
        else:
            mode = SceneMode.GO_TO_ARCADE
            hud.set_active_player(null)
            var duration = world_map.focus_arcade_room() + ARCADE_ROOM_WAITING_DURATION
            yield(get_tree().create_timer(duration), "timeout")

            mode = SceneMode.WORLD_TO_MINIGAME
            $WorldToMinigameTimer.start()


func _on_mini_game_ended(ranking: Array):
    assert(mode == SceneMode.MINIGAME)
    assert(mini_game != null)

    last_ranking = ranking

    transition = transition_scn.instance()
    transition.connect("entered", self, "_on_transition_to_world_entered")

    add_child_below_node($TransitionContainer, transition)


func _on_transition_to_world_entered():
    assert(mode == SceneMode.MINIGAME)
    assert(last_ranking != null)

    mini_game.queue_free()
    mini_game = null

    add_child_below_node($MainContainer, world_map)

    transition.connect("exited", self, "_on_transition_to_world_exited")
    transition.exit()


func _on_transition_to_world_exited():
    assert(mode == SceneMode.MINIGAME)
    assert(last_ranking != null)

    mode = SceneMode.MINIGAME_REWARDS

    var rewards = build_rewards(last_ranking)
    last_ranking = null
    for reward in rewards:
        reward.give()
    hud.update_scores()

    var panel = rewards_scene.instance()
    panel.set_players(players)
    panel.set_rewards(rewards)
    panel.connect("shown", self, "_on_rewards_shown")
    add_child_below_node($PanelContainer, panel)


func _on_rewards_shown(panel):
    assert(mode == SceneMode.MINIGAME_REWARDS)

    panel.queue_free()
    start_new_turn()
