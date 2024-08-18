extends Object

class_name Victory

var reason: String
var winners: Array  # [Player]


# TODO: i18n
func _init(players: PlayerList):
    # Cartrdige victory --------------------------------------------------------
    var max_cartridges = -1

    for player_id in players.size():
        max_cartridges = max(players.get_player(player_id).cartridges_count, max_cartridges) as int

    var cartridges_winners = []
    for player_id in players.size():
        var player = players.get_player(player_id)
        if player.cartridges_count == max_cartridges:
            cartridges_winners.append(player)

    if cartridges_winners.size() == 1:
        reason = "Collected the biggest number of cartridges (%s)." % max_cartridges
        winners = cartridges_winners
        return

    # Cards victory ------------------------------------------------------------
    # TODO: factorise ?
    var max_cards = -1
    for player in cartridges_winners:
        max_cards = max(player.deck.size(), max_cards) as int

    var cards_winners = []
    for player in cartridges_winners:
        if player.deck.size() == max_cards:
            cards_winners.append(player)

    if cards_winners.size() == 1:
        reason = "Collected the biggest number of cards (%s)." % max_cards
        winners = cards_winners
        return

    # Move victory -------------------------------------------------------------
    var max_cases = -1
    for player in cards_winners:
#        if player.cases_count >= max_cases:
#            max_cases = player.cases_count
        max_cases = max(player.cases_count, max_cases) as int

    var cases_winners = []
    for player in cards_winners:
        if player.cases_count == max_cases:
            cases_winners.append(player)

    if cards_winners.size() == 1:
        reason = "Traveled the biggest distance (%s cases)." % max_cases
        winners = cases_winners
        return

    reason = """{cartridges} cartridges collected,
 {cards} cards collected,
 {cases} cases traveled.""".format({
        "cartridges": max_cartridges,
        "cards": max_cards,
        "cases": max_cases,
    })
    winners = cases_winners
