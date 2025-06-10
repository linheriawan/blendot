extends CanvasLayer

signal control_scheme_changed(scheme)

@onready var control_scheme_option_button: OptionButton = $VBoxContainer/OptionButton
@onready var close_button: Button = $CloseButton

var now_ctrl_scheme_id: int = 0 # Default control scheme

func _ready():
	# Populate the OptionButton with control scheme choices
	control_scheme_option_button.add_item("Tank")
	control_scheme_option_button.add_item("Modern")
	
	now_ctrl_scheme_id = ConfigManager.get_value("ctrl_schema", 0)
	if now_ctrl_scheme_id != -1:
		control_scheme_option_button.select(now_ctrl_scheme_id)

	# Connect signals
	control_scheme_option_button.item_selected.connect(_on_control_scheme_selected)
	close_button.pressed.connect(_on_close_button_pressed)

func _on_control_scheme_selected(index: int):
	var selected_scheme = control_scheme_option_button.get_item_text(index)
	if now_ctrl_scheme_id != index:
		now_ctrl_scheme_id = index
		print("Control scheme changed to:", selected_scheme)
		# Emit a signal so other parts of your game can react to the change
		control_scheme_changed.emit(index)
		# Optionally save the setting here using ConfigFile

func _on_close_button_pressed():
	# Hide the options page
	ConfigManager.set_value("ctrl_schema", now_ctrl_scheme_id)
	self.hide()

func show_options():
	# Show the options page
	self.show()
