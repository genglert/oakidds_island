extends ColorRect

signal shown

export(float, 0.1, 10) var pre_duration = 1.5
export(float, 0.1, 10) var post_duration = 1.5


func display():
    yield(get_tree().create_timer(pre_duration), "timeout")
    visible = true
    yield(get_tree().create_timer(post_duration), "timeout")
    emit_signal("shown")
