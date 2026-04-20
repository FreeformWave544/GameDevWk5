extends Node

@onready var http_request = $WordAPIRequester
var words = []
var move := true
var offlineList := ["revealer","uncrowns","forewarning","rehires","decarbonizer","scatts","inhibits","swith","anonymously","bestudded","creditability","stomachics","terrace","baptised","unman","mossbacked","gammoner","misspoken","cebids","hootier","okehs","drained","fungibilities","nittier","caudations","pantheistic","madreporite","erythroblast","boarhound","charry","meditate","butane","homonuclear","polyhedrosis","polemoniums","sones","omnific","gratine","pols","penultimas","highth","nonactors","tipcat","gaddis","closet","whirligig","monstrosities","enigmatic","insinuators","disabusal"]
var offlineMode = true

func _ready() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("typeJump") and $Player.cooldown <= 0 and move: fetch_words()

func fetch_words():
	move = false
	$Player.cooldown = $Player.defaultCD
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request()
	if offlineMode:
		words = offlineList
		spawn_words()
		return
	var url = "http://random-word-api.herokuapp.com/word"
	var err = http_request.request(url)
	if err != OK:
		print("Request failed to start ", err)
	else:
		print("HTTP REQUESTING ", err)
		await get_tree().create_timer(0.5).timeout
		print("BLAH! ", http_request.get_http_client_status())
		if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
			offlineMode = true
			http_request.cancel_request()
			print("REQUEST FAILED.")
			words = offlineList
			spawn_words()

func _on_word_api_requester_request_completed(result, response_code, headers, body):
	print("HTTP REQUESTED")
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		words = json
		spawn_words()
	else:
		print("Failed to fetch words")

func spawn_words():
	var word = words.pick_random()
	var word_node = preload("res://Scenes/word.tscn").instantiate()
	word_node.set_word(word)
	word_node.position = Vector2($Player.position.x, $Player.position.y - 50)
	add_child(word_node)
	move = false

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_death_visibility_changed() -> void:
	if $Death.visible:
		$Death/Death/CenterContainer/VBoxContainer/SCORE.text = str(roundf($Player.score))
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
