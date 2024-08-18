extends Node2D

export (int, 1, 3600) var countdown = 10
export (bool) var auto_start = true

signal over

const SQUARES = 16
var square_id = 0

func _ready():
    # warning-ignore:return_value_discarded
    $Timer.connect("timeout", self, "_on_countdown_timeout")

    if auto_start:
        start()


func start():
    var timer = $Timer
    timer.wait_time = float(countdown) / SQUARES
    timer.start()


func _on_countdown_timeout():
#    print(square_id)
    get_node("BG/Gauge%s" % square_id).visible = false

    square_id += 1
    if square_id == SQUARES:
        $Timer.stop()
        emit_signal("over")
#        queue_free()
