extends Node2D

signal animation_finished


func _ready():
    # warning-ignore:return_value_discarded
    $AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')


func close():
    $AnimationPlayer.play("close")


func open():
    $AnimationPlayer.play("open")


func _on_animation_finished(_anim_name):
    emit_signal("animation_finished")
