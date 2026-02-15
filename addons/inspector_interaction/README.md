# Godot Inspector Interaction

Invokes a callback when inspector values have **most likely** changed.  

> Made to bypass [#87840](https://github.com/godotengine/godot/issues/87840) and several other issues.

Tracks mouse clicks/drags and undo/redo actions in the inspector, which indicate the intention to change a property.

## Usage
Copy `inspector_interaction` into your `res://addons/`, enable under `Project > Project Settings > Plugins`.

```gdscript
func _enter_tree() -> void: InspectorInteraction.register(self, callback)
func _exit_tree() -> void: InspectorInteraction.unregister(self)
func callback() -> void: print('Inspector interaction on node: ', name)
```
