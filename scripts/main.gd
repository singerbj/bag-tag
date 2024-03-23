extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TitleScreen.show()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	$GameScreen.hide()
	$GameOverScreen.hide()
	
	$TitleScreen/StartGameButton.connect("pressed", self._on_start_game_button_pressed)
	$TitleScreen/SettingsButton.connect("pressed", self._on_settings_button_pressed)
	$TitleScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$TitleScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	
	$SettingsScreen/BackButton.connect("pressed", self._on_settings_back_button_pressed)
	$SettingsScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$SettingsScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	
	$HelpScreen/BackButton.connect("pressed", self._on_help_back_button_pressed)
	
	$GameScreen/CanvasLayer/SettingsButton.connect("pressed", self._on_game_settings_button_pressed)


func _on_start_game_button_pressed() -> void:
	print("_on_start_game_button_pressed")
	$TitleScreen.hide()
	$GameScreen.show()
	$GameScreen/Game.start_game()
	
func _on_help_button_pressed() -> void:
	print("_on_help_button_pressed")
	$HelpScreen.show()
	
func _on_settings_button_pressed() -> void:
	print("_on_settings_button_pressed")
	$SettingsScreen.show()
		
func _on_exit_button_pressed() -> void:
	print("_on_exit_button_pressed")
	get_tree().quit()
	
func _on_settings_back_button_pressed() -> void:
	print("_on_settings_back_button_pressed")
	$SettingsScreen.hide()
	if !$TitleScreen.visible:
		$GameScreen.show()
		$GameScreen/Game.start_game()
	
func _on_help_back_button_pressed() -> void:
	print("_on_help_back_button_pressed")
	$HelpScreen.hide()

func _on_game_settings_button_pressed() -> void:
	print("_on_game_settings_button_pressed")
	$GameScreen.hide()
	$GameScreen/Game.pause_game()
	$SettingsScreen.show()
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

