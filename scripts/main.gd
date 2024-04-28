extends Node

class_name Main

@onready var GameScreenScene = preload("res://scenes/GameScreen.tscn")

const SETTINGS_FILE_PATH = "user://settings.cfg"
const HIGH_SCORE_FILE_PATH = "user://high_score.cfg"
const BKRD_MUSIC_DEFAULT_DB = -20
const DODGE_DEFAULT_DB = 0
const JUMP_DEFAULT_DB = -20
const DASH_DEFAULT_DB = -12
const TAG_DEFAULT_DB = -6
const GAME_OVER_DEFAULT_DB = -6
const GASP_DEFAULT_DB = -6
const MIN_DB = -60

var game_screen_scene: Node
var game_scene: Node
var player_scene: Node
var music_player: Node
var dodge_player: Node
var jump_player: Node
var dash_player: Node
var tag_player: Node
var game_over_player: Node
var gasp_player: Node
var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_screen_scene = get_node("GameScreen")
	game_scene = game_screen_scene.get_node("Game")
	player_scene = game_scene.get_node('Player')
	music_player = game_scene.get_node('MusicAudioStreamPlayer')
	dodge_player = game_scene.get_node('DodgeAudioStreamPlayer')
	jump_player = player_scene.get_node('JumpAudioStreamPlayer')
	dash_player = player_scene.get_node('DashAudioStreamPlayer')
	tag_player = player_scene.get_node('TagAudioStreamPlayer')
	game_over_player = player_scene.get_node('GameOverAudioStreamPlayer')
	gasp_player = player_scene.get_node('GaspAudioStreamPlayer')
	
	_init_volume()
	
	if OS.has_feature("web"):
		$TitleScreen/ExitButton.hide()
		$SettingsScreen/ExitButton.hide()
		$GameOverScreen/ExitButton.hide()
	elif OS.has_feature("android"):
		$TitleScreen/FullscreenButton.hide()
		$SettingsScreen/FullscreenButton.hide()
	elif OS.has_feature("ios"):
		$TitleScreen/ExitButton.hide()
		$SettingsScreen/ExitButton.hide()
		$GameOverScreen/ExitButton.hide()
		$TitleScreen/FullscreenButton.hide()
		$SettingsScreen/FullscreenButton.hide()
	
	
	# set button size and locations
	set_button_size_and_locations()
	
	$TitleScreen.show()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	$GameOverScreen.hide()
	$TermsScreen.hide()
	$InitialHelpScreen.hide()
	
	# connect button signals
	$TitleScreen/StartGameButton.connect("pressed", self._on_start_game_button_pressed)
	$TitleScreen/SettingsButton.connect("pressed", self._on_settings_button_pressed)
	$TitleScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$TitleScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$TitleScreen/FullscreenButton.connect("pressed", self._on_fullscreen_button_pressed)
	
	$TermsScreen/IAcceptButton.connect("pressed", self._on_i_accept_button_pressed)
	$TermsScreen/BackButton.connect("pressed", self._on_terms_back_button_pressed)
	
	$InitialHelpScreen/PlayButton.connect("pressed", self._on_ihelp_play_button_pressed)
	$InitialHelpScreen/BackButton.connect("pressed", self._on_ihelp_back_button_pressed)
	
	$SettingsScreen/BackButton.connect("pressed", self._on_settings_back_button_pressed)
	$SettingsScreen/HelpButton.connect("pressed", self._on_help_button_pressed)
	$SettingsScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$SettingsScreen/FullscreenButton.connect("pressed", self._on_fullscreen_button_pressed)
	$SettingsScreen/VolumeSlider.connect("value_changed", self._on_volume_changed)
	
	$HelpScreen/BackButton.connect("pressed", self._on_help_back_button_pressed)
	
	game_screen_scene.get_node("CanvasLayer/SettingsButton").connect("pressed", self._on_game_settings_button_pressed)
	
	$GameOverScreen/ExitButton.connect("pressed", self._on_exit_button_pressed)
	$GameOverScreen/PlayAgainButton.connect("pressed", self._on_play_again_pressed)

func _on_start_game_button_pressed() -> void:
	print("_on_start_game_button_pressed")
	var terms_accepted = config.get_value("main", "terms_accepted")
	if terms_accepted == true:
		_init_volume()
		$TitleScreen.hide()
		game_screen_scene.show()
		game_scene.start_game()
	else:
		$TermsScreen.show()
		$TitleScreen.hide()
	
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
	_set_volume(value)
	
func _init_volume() -> void:
	var err = config.load(SETTINGS_FILE_PATH)
	if err != OK:
		config.set_value("main", "volume", 10.0)
	
	var volume = config.get_value("main", "volume")
	$SettingsScreen/VolumeSlider.value = volume
	_set_volume(volume)
	
func _set_volume(value: float) -> void:
	config.set_value("main", "volume", value)
	config.save(SETTINGS_FILE_PATH)	
	
	if !is_instance_valid(music_player):
		player_scene = game_scene.get_node('Player')
		music_player = game_scene.get_node('MusicAudioStreamPlayer')
		dodge_player = game_scene.get_node('DodgeAudioStreamPlayer')
		jump_player = player_scene.get_node('JumpAudioStreamPlayer')
		dash_player = player_scene.get_node('DashAudioStreamPlayer')
		tag_player = player_scene.get_node('TagAudioStreamPlayer')
		game_over_player = player_scene.get_node('GameOverAudioStreamPlayer')
		gasp_player = player_scene.get_node('GaspAudioStreamPlayer')
	
	music_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(BKRD_MUSIC_DEFAULT_DB)))
	dodge_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(DODGE_DEFAULT_DB)))
	jump_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(JUMP_DEFAULT_DB)))
	dash_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(DASH_DEFAULT_DB)))
	tag_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(TAG_DEFAULT_DB)))
	game_over_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(DASH_DEFAULT_DB)))
	gasp_player.volume_db = -1000 if value == 0 else MIN_DB + (value / 10 * (abs(MIN_DB) - abs(GASP_DEFAULT_DB)))
	
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
	
	set_button_size_and_locations()
	
	$TitleScreen.show()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	$GameOverScreen.hide()
	
func _on_i_accept_button_pressed():
	config.set_value("main", "terms_accepted", true)
	config.save(SETTINGS_FILE_PATH)	
	
	$TermsScreen.hide()
	$InitialHelpScreen.show()

func _on_terms_back_button_pressed():
	$TermsScreen.hide()
	$TitleScreen.show()
	
func _on_ihelp_play_button_pressed():
	_init_volume()
	$TitleScreen.hide()
	$InitialHelpScreen.hide()
	game_screen_scene.show()
	game_scene.start_game()
	
func _on_ihelp_back_button_pressed():
	$InitialHelpScreen.hide()
	$TitleScreen.show()
	
func set_button_size_and_locations():
	# set button sizes
	const SMALL_BUTTON_SIZE = Vector2(300, 200)
	const MEDIUM_BUTTON_SIZE = Vector2(600, 200)
	const LARGE_BUTTON_SIZE = Vector2(1200, 200)
	const MARGIN = 60
	const PADDING = 30
	var SCREEN_WIDTH = get_viewport().get_visible_rect().size.x
	var SCREEN_HEIGHT = get_viewport().get_visible_rect().size.y
	var SCREEN_HORIZONTAL_CENTER = SCREEN_WIDTH / 2
	var SCREEN_VERTICAL_CENTER = SCREEN_HEIGHT / 2
	
	$TitleScreen/StartGameButton.custom_minimum_size = LARGE_BUTTON_SIZE
	$TitleScreen/SettingsButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$TitleScreen/HelpButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$TitleScreen/ExitButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$TitleScreen/FullscreenButton.custom_minimum_size = SMALL_BUTTON_SIZE
	
	$TermsScreen/IAcceptButton.custom_minimum_size = LARGE_BUTTON_SIZE
	$TermsScreen/BackButton.custom_minimum_size = SMALL_BUTTON_SIZE
	
	$InitialHelpScreen/PlayButton.custom_minimum_size = LARGE_BUTTON_SIZE
	$InitialHelpScreen/BackButton.custom_minimum_size = SMALL_BUTTON_SIZE

	$SettingsScreen/BackButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$SettingsScreen/HelpButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$SettingsScreen/ExitButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$SettingsScreen/FullscreenButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$SettingsScreen/VolumeSlider.custom_minimum_size = SMALL_BUTTON_SIZE

	$HelpScreen/BackButton.custom_minimum_size = SMALL_BUTTON_SIZE

	game_screen_scene.get_node("CanvasLayer/SettingsButton").custom_minimum_size = SMALL_BUTTON_SIZE

	$GameOverScreen/ExitButton.custom_minimum_size = SMALL_BUTTON_SIZE
	$GameOverScreen/PlayAgainButton.custom_minimum_size = LARGE_BUTTON_SIZE
	
	# set button positions
	$TitleScreen/StartGameButton.set_position(Vector2(
		SCREEN_HORIZONTAL_CENTER - LARGE_BUTTON_SIZE.x / 2,
		SCREEN_HEIGHT - MARGIN - LARGE_BUTTON_SIZE.y
	))
	$TitleScreen/SettingsButton.set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x,
		MARGIN
	))
	$TitleScreen/HelpButton.set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x - PADDING - SMALL_BUTTON_SIZE.x,
		MARGIN
	))
	$TitleScreen/ExitButton.set_position(Vector2(
		MARGIN,
		SCREEN_HEIGHT - MARGIN - SMALL_BUTTON_SIZE.y
	))
	$TitleScreen/FullscreenButton.set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x,
		SCREEN_HEIGHT - MARGIN - SMALL_BUTTON_SIZE.y
	))
	
	$TermsScreen/IAcceptButton.set_position(Vector2(
		SCREEN_HORIZONTAL_CENTER - LARGE_BUTTON_SIZE.x / 2,
		SCREEN_HEIGHT - MARGIN - LARGE_BUTTON_SIZE.y
	))
	$TermsScreen/BackButton.set_position(Vector2(
		MARGIN,
		MARGIN
	))
	
	$InitialHelpScreen/PlayButton.set_position(Vector2(
		SCREEN_HORIZONTAL_CENTER - LARGE_BUTTON_SIZE.x / 2,
		SCREEN_HEIGHT - MARGIN - LARGE_BUTTON_SIZE.y
	))
	$InitialHelpScreen/BackButton.set_position(Vector2(
		MARGIN,
		MARGIN
	))
#
	$SettingsScreen/BackButton.set_position(Vector2(
		MARGIN,
		MARGIN
	))
	$SettingsScreen/HelpButton.set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x,
		MARGIN
	))
	$SettingsScreen/ExitButton.set_position(Vector2(
		MARGIN,
		SCREEN_HEIGHT - MARGIN - SMALL_BUTTON_SIZE.y
	))
	$SettingsScreen/FullscreenButton.set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x,
		SCREEN_HEIGHT - MARGIN - SMALL_BUTTON_SIZE.y
	))
	$SettingsScreen/VolumeSlider.set_position(Vector2(
		SCREEN_HORIZONTAL_CENTER - $SettingsScreen/VolumeSlider.size.x / 2,
		$SettingsScreen/VolumeSlider.position.y
	))
#
	$HelpScreen/BackButton.set_position(Vector2(
		MARGIN,
		MARGIN
	))
#
	game_screen_scene.get_node("CanvasLayer/SettingsButton").set_position(Vector2(
		SCREEN_WIDTH - MARGIN - SMALL_BUTTON_SIZE.x,
		MARGIN
	))
#
	$GameOverScreen/ExitButton.set_position(Vector2(
		MARGIN,
		SCREEN_HEIGHT - MARGIN - SMALL_BUTTON_SIZE.y
	))
	$GameOverScreen/PlayAgainButton.set_position(Vector2(
		SCREEN_HORIZONTAL_CENTER - LARGE_BUTTON_SIZE.x / 2,
		SCREEN_HEIGHT - MARGIN - LARGE_BUTTON_SIZE.y
	))
	
func on_game_over(points: int) -> void:
	var high_score
	var new_high_score = false
	var config = ConfigFile.new()
	var err = config.load(HIGH_SCORE_FILE_PATH)
	if err != OK:
		high_score = points
		config.set_value("main", "high_score", points)
		new_high_score = true
	else:
		high_score = config.get_value("main", "high_score")
		if points > high_score:
			high_score = points
			config.set_value("main", "high_score", points)
			new_high_score = true
	config.save(HIGH_SCORE_FILE_PATH)
	
	$TitleScreen.hide()
	$SettingsScreen.hide()
	$HelpScreen.hide()
	game_screen_scene.hide()
	if new_high_score:
		$GameOverScreen/ScoreLabel.text = "[center]%s[/center]" % str(points) + (" point" if points == 1 else " points")
		$GameOverScreen/HighScoreLabel.text = "[center]%s[/center]" % "New High Score!"
	else:
		$GameOverScreen/ScoreLabel.text = "[center]%s[/center]" % str(points) + (" point" if points == 1 else " points")
		$GameOverScreen/HighScoreLabel.text = "[center]%s[/center]" % "High Score: " + str(high_score) + (" point" if points == 1 else " points")
	$GameOverScreen.show()

func _input(event):
	if event is InputEventKey:
		if !OS.has_feature("web") && event.is_action_pressed("ui_cancel"):
			get_tree().quit()
