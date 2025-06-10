extends Node

var config_data = {}

const CONFIG_PATH := "user://config.cfg"
signal value_changed(key, new_value)

func _ready():
	load_config()

func load_config():
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		config_data = JSON.parse_string(content) if content else {}
	else:
		config_data = {}

func save_config():
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(config_data))

func get_value(key: String, default = null):
	return config_data.get(key, default)

func set_value(key: String, value):
	config_data[key] = value
	emit_signal("value_changed", key, value)
	save_config()
