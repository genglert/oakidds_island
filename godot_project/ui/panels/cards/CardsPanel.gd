extends Node2D

signal cards_chosen(panel, cards)

enum Focus {
    DECK,
    CHOSEN,
    BUTTON,
}

const MAX_CHOSEN = 3
const DECK_RADIUS = Vector2(0, -300)
const MIN_DECK_ANGLE = PI/8

var active = true
var player = null
var focus = Focus.DECK
var ui_deck = []  # Array[CardUI]
var chosen_cards = []  # Array[CardUI]
var focused_deck_card_index = null
var focused_chosen_card_index = null

var card_ui_scene = preload("res://ui/panels/cards/CardUI.tscn")

################################################################################
# TODO: remove when cards are in separated module
class DummyCard:
    var id: int
    var name: String

    func _init(id_: int, name_: String = "boots"):
        self.id = id_
        self.name = name_

################################################################################


func _ready():
    # TODO: if DEBUG
    if player == null:
        var debug_player = load("player.gd").new(0)
        debug_player.cpu = false
        debug_player.controller_id = 'kb1'

        debug_player.deck.add_cards([
            DummyCard.new(0, "boots"),
            DummyCard.new(1, "mudwall"),
            DummyCard.new(2, "piggin"),
            DummyCard.new(3, "watershoot"),
            DummyCard.new(4, "boots"),
            DummyCard.new(5, "mudwall"),
            DummyCard.new(6, "piggin"),
            DummyCard.new(7, "watershoot"),
            DummyCard.new(8, "boots"),
        ])

        set_player(debug_player)


func set_player(player_):
    self.player = player_
    var deck = player.deck

    var size = deck.size()

    for i in size:
        var card_ui = card_ui_scene.instance()
        card_ui.set_card(deck.get_card(i))
        $DeckContainer.add_child(card_ui)

        # TODO: use a group instead? or just $DeckContainer's children?
        ui_deck.append(card_ui)

    if ui_deck:
        _focus_deck_card(0)
        _arrange_deck()
    else:
        _focus_button()
        $HelpPanel/Label.text = 'You have no card, so just roll the dice (press Action)'
        $ChosenBoard.hide()


func _arrange_deck():
    assert(focused_deck_card_index != null)
    
    var size = ui_deck.size()

    var z_index = 1
    var angle_coeff = -focused_deck_card_index

    # Angle between 2 cards
    var base_angle = min(MIN_DECK_ANGLE, 2*PI/size)

    # We want the sleected card to be centered
    for i in size:
        var card_ui = ui_deck[i]
        var angle = base_angle * angle_coeff
        
        card_ui.position = DECK_RADIUS.rotated(angle)
        card_ui.rotation = angle
        card_ui.z_index = z_index

        angle_coeff += 1

        if i >= focused_deck_card_index:
            z_index -= 1
        else:
            z_index += 1


func _unfocus_deck_card():
    assert(focused_deck_card_index != null)

    var card_ui = ui_deck[focused_deck_card_index]
    card_ui.select(false)
    # NB: keep as last selected  (TODO: rename)
    # focused_deck_card_index = null


func _focus_deck_card(index: int):
    focus = Focus.DECK

#    _unfocus_deck_card()
#    if focused_deck_card_index != null:
#        _unfocus_deck_card()

    focused_deck_card_index = index
    ui_deck[index].select(true)


func _unfocus_chosen():
#    assert(focused_chosen_card_index != null)
    var card_ui = chosen_cards[focused_chosen_card_index]
    card_ui.select(false)
    # NB: keep as last selected  (TODO: rename)
    # focused_chosen_card_index = null


func _focus_chosen(index: int):
    assert(index < chosen_cards.size())
    focus = Focus.CHOSEN

    focused_chosen_card_index = index
    chosen_cards[index].select(true)

func _unfocus_button():
    $RollDiceButtonPlayer.stop()
    # TODO: reset "rect_scale" value


func _focus_button():
    focus = Focus.BUTTON
    $RollDiceButtonPlayer.play("selected")


# TODO: use chosen_cards? VS only use nodes as container
func _get_empty_slot():
#    for i in 3:
    for i in MAX_CHOSEN:
        var slot = get_node("ChosenBoard/ChosenSlot%s" % i)

        if slot.get_child_count() == 0:
            return slot

    return null


# TODO: just got if chosen is not empty??
func _count_chosen_cards():
    var count = 0

    for i in MAX_CHOSEN:
        var slot = get_node("ChosenBoard/ChosenSlot%s" % i)

        if slot.get_child_count() != 0:
            count += 1

    return count


func _chose_card():
    assert(focused_deck_card_index != null)

    var slot: Node2D = _get_empty_slot()

    if slot == null:
        print('No available slot')
        return

    var card_index = focused_deck_card_index
    _unfocus_deck_card()

    var card_ui: Node2D = ui_deck.pop_at(card_index)

    $DeckContainer.remove_child(card_ui)
    # TODO: animation
    slot.add_child(card_ui)
    card_ui.position = Vector2.ZERO
    card_ui.rotation = 0
    card_ui.z_index = $DeckContainer.z_index + 1
    chosen_cards.append(card_ui)

    if not ui_deck:
        focused_deck_card_index = null
        _focus_button()
    else:
        _focus_deck_card(min(card_index, ui_deck.size() - 1) as int)
        _arrange_deck()


func _unchose_card():
    assert(focused_chosen_card_index != null)

    var card_index = focused_chosen_card_index
    _unfocus_chosen()

    var card_ui: Node2D = chosen_cards.pop_at(card_index)
    get_node("ChosenBoard/ChosenSlot%s" % card_index).remove_child(card_ui)

    # TODO: animation
    # TODO: separated method?
    $DeckContainer.add_child(card_ui)
    ui_deck.append(card_ui)
    if focused_deck_card_index == null:
        focused_deck_card_index = 0
    _arrange_deck()

    if not chosen_cards:
        focused_chosen_card_index = null
        # NB1: sure that <ui_deck> is not empty
        # NB2: beware if we focus button instead, the deck's state must be cleaned
        _focus_deck_card(focused_deck_card_index)
    else:
        # TODO: animation
        for idx in range(card_index ,chosen_cards.size()):
            var moved_card_ui = chosen_cards[idx]
            get_node("ChosenBoard/ChosenSlot%s" % (idx + 1)).remove_child(moved_card_ui)
            get_node("ChosenBoard/ChosenSlot%s" % idx).add_child(moved_card_ui)

        _focus_chosen(min(card_index, chosen_cards.size() - 1) as int)


func _process(_delta):
    # TODO: if DEBUG
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

    if not active:
        return

    if player.cpu:
        active = false
        # TODO: AI which choses cards smartly
        var cards = []
        emit_signal('cards_chosen', self, cards)
    else:
        var controller_id = player.controller_id

        if Input.is_action_just_released("%s_action" % controller_id):
            match focus:
                Focus.DECK:
                    _chose_card()

                Focus.CHOSEN:
                    _unchose_card()

                Focus.BUTTON:
                    active = false

                    var cards = []
                    for slot_idx in MAX_CHOSEN:
                        var slot = get_node("ChosenBoard/ChosenSlot%s" % slot_idx)
                        for card_ui in slot.get_children():
                            cards.append(card_ui.card)

#                    print('CHOSEN: ', cards)
                    emit_signal('cards_chosen', self, cards)
        if Input.is_action_just_released("%s_left" % controller_id):
            match focus:
                Focus.DECK:
                    if focused_deck_card_index != 0:
                        # TODO: animation
                        _unfocus_deck_card()
                        _focus_deck_card(focused_deck_card_index - 1)
                        _arrange_deck()

                Focus.CHOSEN:
                    if focused_chosen_card_index > 0:
                        _unfocus_chosen()
                        _focus_chosen(focused_chosen_card_index - 1)

                Focus.BUTTON:
                    _unfocus_button()

                    if ui_deck:
#                        _unfocus_button()
                        _focus_deck_card(ui_deck.size() - 1)
                    else:
                        assert(chosen_cards)
                        _focus_chosen(chosen_cards.size() - 1)
        elif Input.is_action_just_released("%s_right" % controller_id):
            match focus:
                Focus.DECK:
                    # assert focused_deck_card_index != null ??
                    if focused_deck_card_index < ui_deck.size() - 1:
                        # TODO: animation
                        _unfocus_deck_card()
                        _focus_deck_card(focused_deck_card_index + 1)
                        _arrange_deck()
                    else:
                        _unfocus_deck_card()
                        _focus_button()

                Focus.CHOSEN:
                    _unfocus_chosen()
                    if focused_chosen_card_index < chosen_cards.size() - 1:
                        _focus_chosen(focused_chosen_card_index + 1)
                    else:
                       _focus_button()

                Focus.BUTTON:
                    pass
        elif Input.is_action_just_released("%s_up" % controller_id):
            match focus:
                Focus.DECK:
                    if chosen_cards:
                        _unfocus_deck_card()
                        _focus_chosen(0)

                Focus.BUTTON:
                    if chosen_cards:
                        _unfocus_button()
                        _focus_chosen(0)

                Focus.CHOSEN:
                    pass
        elif Input.is_action_just_released("%s_down" % controller_id):
            if focus == Focus.CHOSEN:
                if ui_deck.size():
                    _unfocus_chosen()
                    _focus_deck_card(focused_deck_card_index)
