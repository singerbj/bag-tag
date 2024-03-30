extends Node

class_name Main

@onready var GameScreenScene = preload("res://scenes/GameScreen.tscn")

const BKRD_MUSIC_DEFAULT_DB = -20
const JUMP_DEFAULT_DB = -20
const DASH_DEFAULT_DB = -12
const MIN_DB = -60

var game_screen_scene: Node
var game_scene: Node
var background_music_player: Node
var jump_player: Node
var dash_player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_screen_scene = get_node("GameScreen")
	game_scene = game_screen_scene.get_node("Game")
	background_music_player = game_scene.get_node('AudioStreamPlayer')
	jump_player = game_scene.get_node('Player').get_node('JumpAudioStreamPlayer')
	dash_player = game_scene.get_node('Player').get_node('DashAudioStreamPlayer')
	
	background_music_player.volume_db = BKRD_MUSIC_DEFAULT_DB
	jump_player.volume_db = JUMP_DEFAULT_DB
	dash_player.volume_db = DASH_DEFAULT_DB
	
	$TitleScreen.show()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	$GameOverScreen.hide()
	
	$TitleScreen/StartGameButton.connect("pressed", self._on_start_game_button_pressed)
	$TitleScreen/SettingsButton.connect("pressed", self._on_settings_button_pressed)
	$TitleScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$TitleScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$TitleScreen/FullscreenButton.connect("pressed", self._on_fullscreen_button_pressed)
	
	$SettingsScreen/BackButton.connect("pressed", self._on_settings_back_button_pressed)
	$SettingsScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$SettingsScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$SettingsScreen/FullscreenButton.connect("pressed", self._on_fullscreen_button_pressed)
	$SettingsScreen/VolumeSlider.connect("value_changed", self._on_volume_changed)
	
	$HelpScreen/BackButton.connect("pressed", self._on_help_back_button_pressed)
	
	game_screen_scene.get_node("CanvasLayer/SettingsButton").connect("pressed", self._on_game_settings_button_pressed)
	
	$GameOverScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$GameOverScreen/PlayAgainButton.connect("pressed", self._on_play_again_pressed)

#func _unhandled_input(event: InputEvent) -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_start_game_button_pressed() -> void:
	print("_on_start_game_button_pressed")
	$TitleScreen.hide()
	game_screen_scene.show()
	game_scene.start_game()
	
func _on_help_button_pressed() -> void:
	print("_on_help_button_pressed")
	$HelpScreen.show()
	
func _on_settings_button_pressed() -> void:
	print("_on_settings_button_pressed")
	$SettingsScreen.show()
		
func _on_exit_button_pressed() -> void:
	print("_on_exit_button_pressed")
	get_tree().quit()

func _on_fullscreen_button_pressed() -> void:
	print("_on_fullscreen_button_pressed")
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _on_volume_changed(value: float) -> void:
	background_music_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(BKRD_MUSIC_DEFAULT_DB)))
	jump_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(JUMP_DEFAULT_DB)))
	dash_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(DASH_DEFAULT_DB)))
	
func _on_settings_back_button_pressed() -> void:
	print("_on_settings_back_button_pressed")
	$SettingsScreen.hide()
	if !$TitleScreen.visible:
		game_screen_scene.show()
		game_scene.start_game()
	
func _on_help_back_button_pressed() -> void:
	print("_on_help_back_button_pressed")
	$HelpScreen.hide()

func _on_game_settings_button_pressed() -> void:
	print("_on_game_settings_button_pressed")
	game_screen_scene.hide()
	game_scene.pause_game()
	$SettingsScreen.show()
	
func _on_play_again_pressed() -> void:
	game_screen_scene.queue_free()
	game_screen_scene = GameScreenScene.instantiate()
	game_scene = game_screen_scene.get_node("Game")
	game_screen_scene.get_node("CanvasLayer/SettingsButton").connect("pressed", self._on_game_settings_button_pressed)
	add_child(game_screen_scene)
	
	$TitleScreen.show()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	$GameOverScreen.hide()
	
func on_game_over(points: int) -> void:
	$TitleScreen.hide()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	$GameOverScreen/ScoreLabel.text = str(points) + (" point" if points == 1 else " points")
	$GameOverScreen.show()
	
