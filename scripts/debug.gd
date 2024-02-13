extends PanelContainer

@onready var property_container = %VBoxContainer

func _ready():
	Global.debug = self
	visible = true

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

func add_debug_property(title: String, value):
	var target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
