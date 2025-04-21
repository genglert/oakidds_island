extends ColorRect

# TODO: inherit PolyLabel?
signal finished

export(float, 0.1, 5.0) var wait_time = 1.0

var count = 3

func _ready():
    var timer = $Timer
    
    # warning-ignore:return_value_discarded
    timer.connect("timeout", self, '_on_Time_time_out')
    timer.wait_time = wait_time


func _on_Time_time_out():
    if count == 1:
        emit_signal("finished")
        queue_free()
    else:
        get_node("Number%s" % count).visible = false

        count -= 1
        get_node("Number%s" % count).visible = true


func start():
    $Timer.start()
