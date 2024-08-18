extends KinematicBody2D

signal eaten(player_id)


func eaten_by(player_id):
    emit_signal("eaten", player_id)
    queue_free()
