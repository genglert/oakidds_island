extends Node2D

signal completed

export(bool) var start_at_ready = true

var players = null  # PlayerList
var back = false


func _ready():
    if players == null:
        players = load("player_list.gd").new()

    # warning-ignore:return_value_discarded
    $MainMenu/StartButton.connect("pressed", self, '_on_start_button_pressed')
    # warning-ignore:return_value_discarded
    $MainMenu/ExitButton.connect("pressed", self, '_on_exit_button_pressed')

    # TODO: disable useless buttons (e.g. 2 keyboards + 1 joypad => "4 players" is useless)
    # warning-ignore:return_value_discarded
    $PlayerCountMenu/OneButton.connect("pressed", self, '_on_count_button_pressed', [1])
    # warning-ignore:return_value_discarded
    $PlayerCountMenu/TwoButton.connect("pressed", self, '_on_count_button_pressed', [2])
    # warning-ignore:return_value_discarded
    $PlayerCountMenu/ThreeButton.connect("pressed", self, '_on_count_button_pressed', [3])
    # warning-ignore:return_value_discarded
    $PlayerCountMenu/FourButton.connect("pressed", self, '_on_count_button_pressed', [4])
    # warning-ignore:return_value_discarded
    $PlayerCountMenu/BackButton.connect("pressed", self, '_on_back_to_main_button_pressed')

    # warning-ignore:return_value_discarded
    $ControllersPanel.connect('completed', self, '_on_controllers_panel_completed')

    # warning-ignore:return_value_discarded
    $MenuPlayer.connect('animation_finished', self, '_on_animation_finished')

    # TODO: use event "joy_connection_changed" (?) to detect new joypads
    var joypad_count = Input.get_connected_joypads().size()
    if joypad_count == 0:
        $MainHelp.text += '\nNo joypad detected'
    else:
        $MainHelp.text += '\n%s joypad(s) detected (D-Pad + 2 buttons)' % joypad_count

    if start_at_ready:
        go()


#func _process(_delta):
#    if Input.is_action_just_pressed("ui_accept"):
#        go()


func go():
#    print('GO')
    $TitlePlayer.play("appearance")
    $MenuPlayer.play("main_appearance")


func _on_start_button_pressed():
    $MenuPlayer.play("main_disappearance")


func _on_exit_button_pressed():
#    print("EXIT")
    get_tree().quit()


func _on_count_button_pressed(count):
    $MenuPlayer.play("count_disappearance")

    for player_id in players.size():
        var player = players.get_player(player_id)
        player.cpu = (player_id >= count)

    $ControllersPanel.set_players(players)


func _on_back_to_main_button_pressed():
    $MenuPlayer.play("count_disappearance")
    back = true


func _on_controllers_panel_completed():
#    print('HERE WE GOOOOO')
    emit_signal("completed")


func _on_animation_finished(anim_name):
    match anim_name:
        "main_appearance":
            $MainMenu/StartButton.grab_focus()

        "main_disappearance":
            $MainMenu/StartButton.disabled  = true
            $MainMenu/ExitButton.disabled  = true

            $PlayerCountMenu/OneButton.disabled  = false
            $PlayerCountMenu/TwoButton.disabled  = false
            $PlayerCountMenu/ThreeButton.disabled  = false
            $PlayerCountMenu/FourButton.disabled  = false
            $PlayerCountMenu/BackButton.disabled  = false

            $MenuPlayer.play("count_appearance")

        "count_appearance":
            $PlayerCountMenu/OneButton.grab_focus()

        "count_disappearance":
            if back:
                back = false

                $MainMenu/StartButton.disabled  = false
                $MainMenu/ExitButton.disabled  = false

                $MenuPlayer.play("main_appearance")
            else:
                $MenuPlayer.play("controllers_appearance")

            $PlayerCountMenu/OneButton.disabled  = true
            $PlayerCountMenu/TwoButton.disabled  = true
            $PlayerCountMenu/ThreeButton.disabled  = true
            $PlayerCountMenu/FourButton.disabled  = true
            $PlayerCountMenu/BackButton.disabled  = true

        "controllers_appearance":
            $ControllersPanel.active = true
