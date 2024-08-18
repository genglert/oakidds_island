extends KinematicBody2D

export(int, 0, 3) var player_id = 0
export(bool) var cpu = false
export(String) var controller_id = "kb1"

export(float, 1.0, 1000.0) var speed = 150.0
export(float, 0.1, 360.0) var rotation_speed = 2.0

export(bool) var active = true

#enum CPUMode {
#    TURN_START,
#}
# IA
onready var navigation_agent = $NavigationAgent
var target_pip = null


func set_player(player):
    player_id = player.id
    cpu = player.cpu
    controller_id = player.controller_id
#    print(controller_id)


func _find_target():
    var pips = get_tree().get_nodes_in_group('pips')
    if not pips:
        return null

    var target = pips.pop_back()

    for pip in pips:
        if position.distance_squared_to(target.position) > position.distance_squared_to(pip.position):
            target = pip

    return target


# TODO: use slerp() ???
func _physics_process(delta):
    if not active:
        return

    if cpu:
        if not is_instance_valid(target_pip):
            target_pip = _find_target()

        if target_pip != null:
            navigation_agent.set_target_location(target_pip.global_position)
            # TODO: useful???
            # navigation_agent.set_velocity(Vector2.RIGHT.rotated(rotation) * speed * delta)

            if not navigation_agent.is_navigation_finished():
                var direction = navigation_agent.get_next_location() - global_position
                var angle_to_dest = Vector2.RIGHT.rotated(rotation).angle_to(direction)
                var angle_sign = sign(angle_to_dest)
                var angle_value = min(rotation_speed * delta, abs(angle_to_dest))

                rotate(angle_sign * angle_value)
    else:
        if Input.is_action_pressed("%s_right" % controller_id):
            rotate(rotation_speed * delta)
        elif Input.is_action_pressed("%s_left" % controller_id):
            rotate(-rotation_speed * delta)

    # TODO: move_and_slide(...) ??
#    for i in get_slide_count():
#        var collision = get_slide_collision(i)
#        print("Collided with: ", collision.collider.name)
    var collision_info = move_and_collide(Vector2.RIGHT.rotated(rotation) * speed * delta)

    if collision_info != null:
        var eaten_by_ref = funcref(collision_info.collider, "eaten_by")

        if eaten_by_ref.is_valid():
            eaten_by_ref.call_func(player_id)
