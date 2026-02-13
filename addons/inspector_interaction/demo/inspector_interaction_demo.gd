@tool
extends Node3D

# @export_tool_button('Button') var btn := func () -> void: print('Button clicked')
@export var color: Color
@export var checkbox: bool
@export var texture: Texture2D

func _ready() -> void:
	InspectorInteraction.register_inspector_interaction(self, on_inspector_interaction)

func on_inspector_interaction() -> void:
	print('Inspector interaction on node: ', self.name)
