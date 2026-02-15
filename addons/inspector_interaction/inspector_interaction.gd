@tool class_name InspectorInteraction extends EditorPlugin

static var instance: InspectorInteraction

var throttle_ms: int = 100
var registered_nodes: Dictionary = {} # Dictionary[Node, Callable]
var inspector: EditorInspector
var undo_redo: EditorUndoRedoManager
var last_mouse_pos: Vector2 = Vector2.ZERO
var was_button_pressed: bool = false
var last_interaction_ms: float = 0.0

func _enter_tree() -> void:
	if not Engine.is_editor_hint(): return
	instance = self
	inspector = EditorInterface.get_inspector()
	undo_redo = get_undo_redo()
	undo_redo.version_changed.connect(_on_undo_redo)
	set_process(true)

func _exit_tree() -> void:
	undo_redo.version_changed.disconnect(_on_undo_redo)

func _on_undo_redo() -> void:
	var focused_node := get_focused_node()
	if focused_node: registered_nodes[focused_node].call_deferred()

func get_focused_node() -> Node:
	var selected_nodes := EditorInterface.get_selection().get_selected_nodes()
	var focused_node = selected_nodes[0] if selected_nodes.size() == 1 else null
	return focused_node if focused_node in registered_nodes else null

static func register(node: Node, callback: Callable) -> void:
	if not instance: return push_warning("InspectorInteraction plugin not enabled")
	instance.registered_nodes[node] = callback

static func unregister(node: Node) -> void:
	if not instance: return
	instance.registered_nodes.erase(node)

func _process(_delta: float) -> void:
	var focused_node := get_focused_node()
	if not focused_node: return

	var mouse_pos := inspector.get_viewport().get_mouse_position()
	var is_hovering := inspector.get_global_rect().has_point(mouse_pos) or _is_mouse_over_popup()
	var button_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if is_hovering:
		var mouse_moved := last_mouse_pos.distance_to(mouse_pos) > 0.1
		var button_released := was_button_pressed and not button_pressed
		var is_dragging := button_pressed and mouse_moved

		if (button_released or is_dragging) and Time.get_ticks_msec() - last_interaction_ms >= throttle_ms:
			last_interaction_ms = Time.get_ticks_msec()
			registered_nodes[focused_node].call_deferred()

	last_mouse_pos = mouse_pos if is_hovering else Vector2.ZERO
	was_button_pressed = button_pressed

func _is_mouse_over_popup() -> bool:
	var focused := inspector.get_viewport().gui_get_focus_owner()
	return focused is ColorPickerButton # TODO: any other popup type needed?
