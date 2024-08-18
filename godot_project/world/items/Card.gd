extends Spatial


var road_idx = 0  # TODO: in base Item
var card = null


# TODO: in base Item
func interact(player):
    player.deck.add_card(card)

    var anims = $AnimationPlayer
    anims.connect('animation_finished', self, '_on_animation_finished')
    anims.play("disappear")


func _on_animation_finished(anim_name):
    if anim_name == 'disappear':  # useless
        queue_free()
