extends Node2D   # NB: Node2D to use z_index()


var card = null
#var _selected = false  # TODO?


func set_card(card_):
    card = card_

    $BackGround.set_texture(load("res://ui/cards/%s.png" % card.name))


func size():
    return $BackGround.rect_size


func select(selected: bool):
#    assert(selected != _selected)
#    _selected = selected

    if selected:
        $AnimationPlayer.play("selected")
    else:
        $AnimationPlayer.stop()


#func is_selected():
#    return _selected
