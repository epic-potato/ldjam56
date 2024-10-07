class_name AudioPlayer

extends AudioStreamPlayer2D


@export var sounds: Array[NamedSound]
var sound_dict: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	for sound in sounds:
		sound_dict[sound.name] = sound.stream


func play_sound(sound_name: String) -> void:
	stream = sound_dict.get(sound_name)
	play()
