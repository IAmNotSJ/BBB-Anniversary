extends Node2D

@onready var ui = get_parent().get_parent()
@onready var screen_container = get_parent()

const card_position = Vector2(855, 125)
const card_scene = preload("res://minigames/bbbattle/cards/card.tscn")

var started:bool = false
var money:int = 0

var win:bool

func create(won:bool):
	win = won
	ui.game.manager.clear_peer_ids()
	ui.game.manager.clear_peer_ids.rpc()
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.RESULTS, false, true)
	
	var card = card_scene.instantiate()
	if ui.game.strongest_card_self:
		card.stats = ui.game.strongest_card_self
		card.is_preview = true
		card.set_card_scale(Vector2(0.75, 0.75))
		card.position.x = ($Strongest.size.x / 2) - card.size.x
		card.position.y = $Strongest.size.y + 20
		card.visible = false
		$Strongest.add_child(card)
	
	Saves.battle_stats["Games Played"] += 1
	if won:
		Saves.battle_stats["Wins"] += 1
	else:
		Saves.battle_stats["Losses"] += 1
	Saves.save(Saves.SaveTypes.BATTLE)
	
	$music.play()
	
	money = money_calculation(ui.game.turn_count, won)
	started = true
	#visible = true
	if won:
		$Result.text = "Congratulations!"
	else:
		$Result.text = "oooh you suck"
	$Money.text = "Coppper Coins Earned: " + str(money)
	$Turns.text = "Turns: " + str(ui.game.turn_count)
	$Cards.text = "Cards Played: " + str(ui.cards_played.size())
	
	await get_tree().create_timer(1).timeout
	$Result.visible = true
	await get_tree().create_timer(1.3).timeout
	$Turns.visible = true
	await get_tree().create_timer(0.3).timeout
	$Cards.visible = true
	await get_tree().create_timer(0.3).timeout
	$Money.visible = true
	if ui.game.strongest_card_self:
		await get_tree().create_timer(0.5).timeout
		card.visible = true
	await get_tree().create_timer(1).timeout
	$Continue.visible = true

func _input(event: InputEvent) -> void:
	if started:
		if event is InputEventKey:
			if event.pressed:
				if ui.game.manager.peer_id != -1:
					print('disconnecting!')
					ui.game.manager.close_peer()
				Transition.change_scene_to_preset("Battle", true, money)
func money_calculation(turn_count:int, won:bool) -> int:
	
	#Minimum amount per game
	var amount:int = 10
	
	# See how many different series you have
	var series_array = []
	var ability_array = []
	for card in Saves.battle_deck[ui.game.match_rules["Deck Size"]]:
		var resource_file = load("res://minigames/bbbattle/cards/card_variants/stats/" + card + ".tres")
		if !series_array.has(resource_file.card_series):
			series_array.append(resource_file.card_series)
		if !ability_array.has(resource_file.ability_name):
			ability_array.append(resource_file.ability_name)
	
	if turn_count > 8:
		amount += randi_range(2, 5) * (turn_count - 8)
	
	
	for i in range(series_array.size()):
		amount += i * randi_range(1, 3)
	for i in range(ability_array.size()):
		amount += i * randi_range(1, 3)
	
	if won:
		amount += randi_range(10, 20)
	
	# DEMO TAX
	amount /= 6
	
	if ui.kromer:
		amount *= 2
	return amount


func _on_music_finished() -> void:
	$music.play()
