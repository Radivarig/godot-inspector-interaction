# Godot Inspector Interaction

Raises a signal when inspector values have **most likely** changed.  

> Made to bypass [#87840](https://github.com/godotengine/godot/issues/87840) and several other issues.

Tracks mouse clicks/drags and undo/redo actions in the inspector, which indicate the intention to change a property.

## Usage
Copy `inspector_interaction` into your `res://addons/`, enable under `Project > Project Settings > Plugins`.

```gdscript
func _ready() -> void:
	InspectorInteraction.register_inspector_interaction(self, on_inspector_interaction)

func on_inspector_interaction() -> void:
	print('Inspector interaction on node: ', self.name)
```
