@tool
extends MeshInstance3D

@export var Face: String = ":)":
	set(value):
		Face = value
		if is_node_ready():
			$FaceLabel.text = value

@export var FaceRotation: int = -90:
	set(value):
		FaceRotation = value
		if is_node_ready():
			$FaceLabel.rotation.z = deg_to_rad(value)

func _ready() -> void:
	$FaceLabel.text = Face
	$FaceLabel.rotation.z = deg_to_rad(FaceRotation)
