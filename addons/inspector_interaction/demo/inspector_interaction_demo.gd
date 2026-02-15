@tool extends Node

# @export_tool_button('Button') var btn := func () -> void: print('Clicked') # test order
@export var color: Color # test mouse drag
@export var checkbox: bool # test mouse click
@export var texture: Texture2D # test click/drag in a sub-resource

func _enter_tree() -> void: InspectorInteraction.register(self, callback)
func _exit_tree() -> void: InspectorInteraction.unregister(self)
func callback() -> void: print('Inspector interaction on node: ', name)
