extends Node2D

signal filled(player_id, score)

var brick_scenes = [
    preload("Brick01.tscn"),
    preload("Brick02.tscn"),
    preload("Brick03.tscn"),
    preload("Brick04.tscn"),
    preload("Brick05.tscn"),
    preload("Brick06.tscn"),
    preload("Brick07.tscn"),
    preload("Brick08.tscn"),
    preload("Brick09.tscn"),
    preload("Brick10.tscn"),
]
var explosion_scn = preload("res://games/BigExplosion.tscn")

var current_brick = null
var current_brick_old_position = null
var brick_color = Color.red
var frozen_bricks_count = 0

export(int, 0, 3) var player_id = 0
export(bool) var cpu = false
export(String) var controller_id = "kb1"

export(float, 1.0, 1000.0) var vertical_speed = 80.0
export(float, 1.0, 1000.0) var horizontal_speed = 100.0
export(float, 0.1, 360.0) var rotation_speed = 5.0

export(bool) var active = true

var filled = false
var threshold = null


func _ready():
    # TODO: assert
    threshold = get_node('Threshold')
#    threshold.collision_layer = 2
    threshold.collision_mask = 8
    threshold.connect("body_entered", self, "_on_threshold_collided")
    threshold.connect("body_exited", self, "_on_threshold_not_collided")


func set_player(player):
    player_id = player.id
    cpu = player.cpu
    controller_id = player.controller_id
    brick_color = player.color

# TODO ??
#    match player.smartness:
#        player.Smartness.LOW:
#            ...
#
#        player.Smartness.MIDDLE:
#            ...
#
#        player.Smartness.HIGH:
#            ...


func _physics_process(_delta):
    # TODO: remove
    if Input.is_action_just_released("ui_quit"):
        get_tree().quit()

    if not active or filled:
        return

    if current_brick == null:
        current_brick = brick_scenes[randi() % brick_scenes.size()].instance()
        current_brick.get_node('Gfx').color = brick_color
        current_brick.connect("frozen", self, "_on_brick_frozen")
        current_brick.collision_layer = 1
#        current_brick.collision_mask = 2
        add_child(current_brick)

    if cpu:
        # TODO: factorise
        var new_position = current_brick.position

        if (
            current_brick_old_position != null
            # TODO: allow to slide a certain time??
            and (current_brick_old_position - new_position).y > 0.0
        ):
            current_brick.stop_player_control()

            current_brick = null  # A new brick will be spawned
            current_brick_old_position = null
        else:
            current_brick_old_position = new_position

            var linear_velocity = Vector2.ZERO
            var angular_velocity = 0.0

# TODO:
#            if Input.is_action_pressed("%s_right" % controller_id):
#                if Input.is_action_pressed("%s_action" % controller_id):
#                    angular_velocity = rotation_speed
#                else:
#                    linear_velocity = Vector2.RIGHT * horizontal_speed
#
#            elif Input.is_action_pressed("%s_left" % controller_id):
#                if Input.is_action_pressed("%s_action" % controller_id):
#                    angular_velocity = -rotation_speed
#                else:
#                    linear_velocity = Vector2.LEFT * horizontal_speed

            current_brick.player_linear_velocity = linear_velocity
            current_brick.player_angular_velocity = angular_velocity
    else:
        var new_position = current_brick.position

        if (
            current_brick_old_position != null
            # TODO: allow to slide a certain time??
            and (current_brick_old_position - new_position).y > 0.0
        ):
            current_brick.stop_player_control()

            current_brick = null  # A new brick will be spawned
            current_brick_old_position = null
        else:
            current_brick_old_position = new_position

            var linear_velocity = Vector2.ZERO
            var angular_velocity = 0.0

            if Input.is_action_pressed("%s_right" % controller_id):
                if Input.is_action_pressed("%s_action" % controller_id):
                    angular_velocity = rotation_speed
                else:
                    linear_velocity = Vector2.RIGHT * horizontal_speed

            elif Input.is_action_pressed("%s_left" % controller_id):
                if Input.is_action_pressed("%s_action" % controller_id):
                    angular_velocity = -rotation_speed
                else:
                    linear_velocity = Vector2.LEFT * horizontal_speed

            current_brick.player_linear_velocity = linear_velocity
            current_brick.player_angular_velocity = angular_velocity

#            print(current_brick.get_node('HitBox').polygon)


func _on_brick_frozen(brick):
    frozen_bricks_count += 1

    if brick.collides_threshold:
        active = false # TODO: explode the current brick

        if is_instance_valid(current_brick):
            # TODO: remove when finished? autoremove?
            var explosion = explosion_scn.instance()
            explosion.position = current_brick.position
            add_child(explosion)
            explosion.emitting = true

            current_brick.queue_free()

        filled = true
        emit_signal("filled", player_id, frozen_bricks_count)


func _on_threshold_collided(brick):
    brick.collides_threshold = true

func _on_threshold_not_collided(brick):
    brick.collides_threshold = false
