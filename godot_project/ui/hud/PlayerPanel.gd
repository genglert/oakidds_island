extends Control

signal position_indicated

#var score_fmt = 'cartridges: {cartridges} / cards: {cards} / Moves: {moves}'
var player = null
var original_position = null
var original_modulate = null


func _ready():
    original_position = rect_position
    original_modulate = modulate


func set_player(player_):
    self.player = player_
    $Name.text = player_.name
    $Portrait.texture = load('res://avatar/images/%s-portrait.png' % player_.avatar_id)


# TODO: animation
func set_active(active):
    if active:
        modulate = original_modulate
    else:
        modulate = Color(1.0, 1.0, 1.0, 0.5)


# TODO: animation when changes
func update_score():
    $CartridgeLabel.text = '%02d' % player.cartridges_count
    $CartLabel.text = '%02d' % player.deck.size()
    # player.cases_count ??


func indicate_players_position(position):
    var tween = get_tree().create_tween()
    tween.tween_property(self, "rect_position", position - rect_size / 2, 1).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1).set_delay(1)
    tween.tween_callback(self, "_on_indicate_finished")
#    tween.play()  # useless


func _on_indicate_finished():
    rect_position = original_position
    modulate = original_modulate
    visible = false

    emit_signal("position_indicated")
