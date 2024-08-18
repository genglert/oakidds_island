extends Spatial

signal moved(player)

# TODO: export?
#const MOVE_SPEED = 3.0
#const MOVE_SPEED = 6.0
const MOVE_SPEED = 20.0

enum State {
    IDLE,
    ACTIVE,
    MOVING,
}

var state = State.IDLE
var player = null
var position_offset = Vector3.ZERO

# MOVING data
var moving_blocks_count = 0
# TODO: Curve instead
var moving_start = null
var moving_vector = null
var moving_length = 0.0  # Total length of the current block to block move
var moving_traveled = 0.0  # Traveled distance for the current move


func _ready():
    assert(player != null)
    $AnimationPlayer.play('idle')


func _process(delta):
#    if state == State.ACTIVE:
#        pass
#    elif state == State.MOVING:
    if state == State.MOVING:
        if moving_blocks_count:
            if moving_vector == null:
                var next_road_pos = get_node('/root/Main/World').get_road_position(player.road_idx + 1)
                player.road_idx = next_road_pos.index
                moving_start = translation
                var move: Vector3 = (next_road_pos.position + position_offset) - moving_start
                moving_vector = move.normalized()
                moving_length = move.length()
            else:
                moving_traveled += delta * MOVE_SPEED

                if moving_traveled < moving_length:
                    set_translation(
                        moving_start + moving_vector * moving_traveled
                    )
                else:
                    set_translation(
                        moving_start + moving_vector * moving_length
                    )
                    moving_blocks_count -= 1
                    player.increment_cases_count(1)
                    _reset_move()
        else:
            _reset_move()  # Not really useful
            set_idle()
            emit_signal('moved', player)


func _reset_move():
    moving_vector = null
    moving_length = 0.0
    moving_traveled = 0.0


func set_player(player_):
    player = player_
    $Sprite.sprite_name = player_.avatar_id


func set_active():
    if state == State.IDLE:
        state = State.ACTIVE
        $AnimationPlayer.play("active")


func set_moving(cases_count):
    assert(state == State.ACTIVE)
    state = State.MOVING
    moving_blocks_count = cases_count
    _reset_move()


func set_idle():
    if state != State.IDLE:
        state = State.IDLE
        $AnimationPlayer.play("idle")


func set_origin(origin: Vector3):
    set_translation(origin + position_offset)
