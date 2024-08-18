extends Control

signal card_used
signal dice_shown
signal positions_indicated

var players = null
var _indicated_poistions_count = 0


func _ready():
    assert(players != null)

    for player_id in players.size():
#        _get_player_panel(player_id).set_player(players.get_player(player_id))
        var panel = _get_player_panel(player_id)
        panel.set_player(players.get_player(player_id))
        panel.connect("position_indicated", self, "_on_position_indicated")

    # warning-ignore:return_value_discarded
    $ActiveCardTimer.connect("timeout", self, "_on_Timer_active_card_timeout")
    # warning-ignore:return_value_discarded
    $DiceTimer.connect("timeout", self, "_on_Timer_dice_timeout")
#    # warning-ignore:return_value_discarded
#    $MessageTimer.connect("timeout", self, "_on_Timer_message_timeout")


# Message ----------------------------------------------------------------------
func display_message(message):
#    print(message)
#    var label = $MessageLabel
#    label.text = message
#    label.visible = true
#
#    $MessageTimer.start()
    $MessagePanel/Label.text = message
    $MessagePlayer.play("show_message")

#func _on_Timer_message_timeout():
#    $MessageLabel.visible = false


# Turn -------------------------------------------------------------------------
func set_max_turn(turn: int):
    $TurnIndicator.max_turn = turn


func set_turn(turn: int):
#    $TurnIndicator.text = "Turn: {turn}/{max}".format({"turn": turn, "max": self.max_turn})
    $TurnIndicator.set_turn(turn)


# Card -------------------------------------------------------------------------
func show_card(card):
    var rect = $ActiveCardRect
    rect.texture = load("res://ui/cards/%s.png" % card.name)
    rect.visible = true
    $ActiveCardPlayer.play("main")
    $ActiveCardTimer.start()


func _on_Timer_active_card_timeout():
    $ActiveCardRect.visible = false
    $ActiveCardPlayer.stop()
    emit_signal("card_used")


# Dice -------------------------------------------------------------------------
func show_dice(result, mutators):
    if result > 6:
        print(" MAX reached !?")
        result = 6
    
    var dice = $DiceSprite
    dice.region_rect.position = Vector2(0, (result - 1) * 128)
    dice.visible = true
    
    var mutators_strings = []
    for mutator in mutators:
        mutators_strings.append(mutator.as_str())
    
    var label = $DiceMutatorsLabel
    label.text = ", ".join(mutators_strings)
    label.visible = true
    $DiceTimer.start()


func _on_Timer_dice_timeout():
    $DiceSprite.visible = false
    $DiceMutatorsLabel.visible = false
    emit_signal("dice_shown")


# Players ----------------------------------------------------------------------
func _get_player_panel(player_id):
    return get_node("PlayerPanel%s" % (player_id + 1))


func set_active_player(active_player_id):
    if active_player_id == null:  # <null> means <no secific active player>
        for player_id in players.size():
            _get_player_panel(player_id).set_active(true)
    else:
        for player_id in players.size():
            _get_player_panel(player_id).set_active(player_id == active_player_id)


func indicate_players_positions(positions):
    _indicated_poistions_count = 0

    var player_id = 0
    for position in positions:
        _get_player_panel(player_id).indicate_players_position(position)
        player_id += 1


func _on_position_indicated():
    _indicated_poistions_count += 1
    if _indicated_poistions_count >= 4:
        emit_signal("positions_indicated")


func update_scores():
    for player_id in players.size():
        _get_player_panel(player_id).update_score()


func show_players_panels():
    for player_id in players.size():
        _get_player_panel(player_id).visible = true
