extends Object

class_name Deck

var _cards = []

# TODO ?
#func filter(type):
#    var filtered = []
#    for card in cards:
#        if card.type == type:
#            filtered.append(card)
#
#    return filtered

func add_card(card):
    _cards.append(card)


func add_cards(cards: Array):
    _cards.append_array(cards)


func get_card(card_index):
    return _cards[card_index]


func remove_card(card):
    for card_i in _cards.size():
        if _cards[card_i].id == card.id:
            _cards.pop_at(card_i)
            return

    printerr("The Card is not found in deck: ", card.id, " ", card)


func remove_cards(removed_cards: Array):
    for card in removed_cards:
        remove_card(card)


func remove_random_card():
    if not _cards:
        return null

    return _cards.pop_at(randi() % _cards.size())

func size():
    return _cards.size()
