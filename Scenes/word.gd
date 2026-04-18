extends Area2D

var word: String
var typed = ""

func set_word(w: String):
	word = w
	$Label.text = word

func _input(event):
	if event is InputEventKey and event.pressed:
		var character = char(event.unicode)
		if character.is_valid_identifier():
			if character == $Label.text[0]: typed += character
			update_display()
			if typed == word:
				await get_tree().create_timer(0.1).timeout
				get_parent().move = true
				queue_free()
				get_parent().get_node("Player").boost_jump()

func update_display():
	$Label.text = word.substr(typed.length())
