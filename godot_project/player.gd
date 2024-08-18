extends Object

class_name Player

var id = 0  # getter
var cpu = true
var name = "XXX"
var controller_id = null
var road_idx = 1
var cartridges_count = 0
var avatar_id = "woodlouse"
var deck = load("deck.gd").new()
var mutators = []  # Array[Mutator]
var cases_count = 0  # TODO: getter


func _init(id_):
    self.id = id_


func add_cartridge():
    cartridges_count += 1


func remove_card(card):
    deck.remove_card(card)


func increment_cases_count(moved: int):
    cases_count += moved


func _to_string():
    return "Player %s" % id
