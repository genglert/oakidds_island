extends Control

var current_turn = 0
var max_turn = 0


func _ready():
    # warning-ignore:return_value_discarded
    $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")


func set_turn(turn: int):
    var old_turn = current_turn
    current_turn = turn

    if old_turn:
        $AnimationPlayer.play("hide")
    else:
        _print_and_show()


func _print_and_show():
    $Label.text = "Turn: {turn}/{max}".format({"turn": current_turn, "max": max_turn})
    $AnimationPlayer.play("show")


func _on_animation_finished(anim_name):
    if anim_name == "hide":
        _print_and_show()
