extends Node2D

# TODO: share with other transitions...
signal entered
signal exited

enum State {
    OPENED,
    CLOSING,
    CLOSED,
    OPENING,
}

var state = State.OPENED

# TODO: remove
func _ready():
    # warning-ignore:return_value_discarded
    $RightJaw.connect('animation_finished', self, '_on_animation_finished')

    enter()


func enter():
    state = State.CLOSING

    $RightJaw.close()
    $LeftJaw.close()


func exit():
    # TODO: assert state ?
    state = State.OPENING
    $RightJaw.open()
    $LeftJaw.open()


func _on_animation_finished():
    # TODO: switch?
    if state == State.CLOSING:
        state = State.CLOSED
        emit_signal("entered")
    elif state == State.OPENING:
        state = State.OPENED  # Useless...
        emit_signal("exited")
        queue_free()
    else:
        printerr('Jaws animation with unexpected state')
