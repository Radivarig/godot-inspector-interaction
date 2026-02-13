@tool class_name InspectorInteraction extends EditorPlugin

signal inspector_interacted()

var inspector: EditorInspector
var undo_redo: EditorUndoRedoManager
var last_mouse_pos: Vector2 = Vector2.ZERO
var was_button_pressed: bool = false
var last_interaction_ms: float = 0.0
var throttle_ms: int = 100

const META_NAME := 'inspector_interaction_plugin'

func _enter_tree() -> void:
	var base := EditorInterface.get_base_control()
	base.set_meta(META_NAME, self)

	inspector = EditorInterface.get_inspector()
	undo_redo = get_undo_redo()
	undo_redo.version_changed.connect(_on_undo_redo)
	set_process(true)

func _exit_tree() -> void:
	set_process(false)

	if undo_redo and undo_redo.version_changed.is_connected(_on_undo_redo):
		undo_redo.version_changed.disconnect(_on_undo_redo)

	var base := EditorInterface.get_base_control()
	base.remove_meta(META_NAME)

func _on_undo_redo() -> void:
	inspector_interacted.emit()

static func register_inspector_interaction(node: Node, callback: Callable) -> void:
	if not Engine.is_editor_hint(): return

	await node.get_tree().process_frame

	var plugin: InspectorInteraction = EditorInterface.get_base_control().get_meta(META_NAME, null)
	if not plugin: return

	var wrapped_callback := func() -> void:
		if is_instance_valid(node) and node in EditorInterface.get_selection().get_selected_nodes():
			callback.call()

	plugin.inspector_interacted.connect(wrapped_callback)

	node.tree_exiting.connect(func() -> void:
		if plugin.inspector_interacted.is_connected(wrapped_callback):
			plugin.inspector_interacted.disconnect(wrapped_callback))

func _process(_delta: float) -> void:
	if not inspector: return

	var mouse_pos := inspector.get_viewport().get_mouse_position()
	var is_hovering := inspector.get_global_rect().has_point(mouse_pos) or _is_mouse_over_popup()
	
	var button_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if is_hovering:
		var mouse_moved := last_mouse_pos != Vector2.ZERO and last_mouse_pos.distance_to(mouse_pos) > 0.1
		var button_released := was_button_pressed and not button_pressed
		var is_dragging := button_pressed and mouse_moved

		if (button_released or is_dragging) and Time.get_ticks_msec() - last_interaction_ms >= throttle_ms:
			last_interaction_ms = Time.get_ticks_msec()
			await get_tree().process_frame
			inspector_interacted.emit()

		last_mouse_pos = mouse_pos
	else:
		last_mouse_pos = Vector2.ZERO

	was_button_pressed = button_pressed

func _is_mouse_over_popup() -> bool:
	var focused := inspector.get_viewport().gui_get_focus_owner()
	if focused:
		var current: Node = focused
		while current:
			# TODO: how to detect any popup window
			if current is ColorPickerButton: return true
			current = current.get_parent()
	return false
