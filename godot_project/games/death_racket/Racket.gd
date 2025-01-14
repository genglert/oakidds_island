extends KinematicBody2D

signal killed(player_id)

enum Direction {
    HORIZONTAL,
    VERTICAL,
}

export(int, 0, 3) var player_id = 0
export(bool) var cpu = false
export(String) var controller_id = "kb1"

export(Direction) var direction = VERTICAL
export(float, 1.0, 1000.0) var speed = 500.0

export (float, 0.1, 100.0) var ball_acceleration = 1.2

export(NodePath) var ball_path
onready var ball = get_node(ball_path)

onready var initial_position = position
var explosion_scn = preload("res://games/BigExplosion.tscn")

# For I.A.
#var auto_replacing = false
var is_chill = true  # True means <the ball is going away it's cool>
var reaction_time = 1.0  # Time to quit the "chill" state
var remaining_reaction_time = reaction_time


func set_player(player):
    player_id = player.id
    cpu = player.cpu
    controller_id = player.controller_id
#    print(controller_id)
    $Gfx.color = player.color

    match player.smartness:
        player.Smartness.LOW:
            reaction_time = 1.0

        player.Smartness.MIDDLE:
#            auto_replacing = true
            reaction_time = 0.5

        player.Smartness.HIGH:
#            auto_replacing = true
            reaction_time = 0.2
    remaining_reaction_time = reaction_time

# TODO: use slerp() ???
func _physics_process(delta):
    if cpu:
        if (position - ball.position).dot(ball.vector) < 0:
            # The ball is going away
#            if auto_replacing:
            # warning-ignore:return_value_discarded
            move_and_collide((initial_position - position).normalized() * speed * delta)

            is_chill = true
            remaining_reaction_time = reaction_time
        else:
            if is_chill:
                remaining_reaction_time -= delta
                if remaining_reaction_time < 0.0:
                    is_chill = false
            else:
                # The ball is going closer
                var move_direction = Vector2.RIGHT
                if direction == VERTICAL:
                    move_direction = Vector2.UP

                var inters = Geometry.line_intersects_line_2d(
                    ball.position, ball.vector, position, move_direction
                )

                if inters != null:
                    # warning-ignore:return_value_discarded
                    move_and_collide((inters - position).normalized() * speed * delta)
    else:
        if direction == HORIZONTAL:
            if Input.is_action_pressed("%s_right" % controller_id):
                # warning-ignore:return_value_discarded
                move_and_collide(Vector2.RIGHT * speed * delta)
            elif Input.is_action_pressed("%s_left" % controller_id):
                # warning-ignore:return_value_discarded
                move_and_collide(Vector2.LEFT * speed * delta)
        else:  # VERTICAL
            if Input.is_action_pressed("%s_up" % controller_id):
                # warning-ignore:return_value_discarded
                move_and_collide(Vector2.UP * speed * delta)
            elif Input.is_action_pressed("%s_down" % controller_id):
                # warning-ignore:return_value_discarded
                move_and_collide(Vector2.DOWN * speed * delta)


func explode():
    var explosion = explosion_scn.instance()
    explosion.position = position
    get_parent().add_child(explosion)
    explosion.emitting = true

    emit_signal("killed", player_id)
    queue_free()


func hit_by_ball():
    return ball_acceleration
