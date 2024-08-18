extends Spatial

# TODO: export?
const COST = 3
# const COST = 1

# TODO: in a base Item class? (see Card)
var road_idx = 0


func _ready():
    # warning-ignore:return_value_discarded
    $AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')


# TODO: in base Item
func interact(player):
    if player.deck.size() >= COST:
        for _i in COST:
            player.deck.remove_random_card()
        player.add_cartridge()

        $AnimationPlayer.play("disappear")
    else:
        get_node('/root/Main/HUD').display_message(
            'The player "{player}" needs {cost} cards to buy the cartridge.'.format({
                'player': player.name,
                'cost': COST,
            })
        )


func _on_animation_finished(anim_name):
    if anim_name == 'disappear':  # useless
        queue_free()
