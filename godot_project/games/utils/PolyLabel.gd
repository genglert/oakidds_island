extends Node2D

# BEWARE: currently on numerics 0..9 are available in font/

export(String) var text = ''

const BASE_WIDTH = 96
#const BASE_HEIGHT = 128


func _ready():
    _build()


# TODO: alignment policy (centered, right align...) ?
func _build():
    var position = Vector2(- (text.length() - 1) * BASE_WIDTH / 2, 0)

    for c in text:
        # TODO: what about invalid char (no glyph found)?
        var char_scn = load("res://games/utils/font/%s.tscn" % c)
        var char_instance = char_scn.instance()
        char_instance.position = position
        $Container.add_child(char_instance)

        position += Vector2(BASE_WIDTH, 0)

    $Background.scale = Vector2(text.length(), 1)


func set_text(new_text):
    text = new_text
    
    for child in $Container.get_children():
        $Container.remove_child(child)

    _build()
