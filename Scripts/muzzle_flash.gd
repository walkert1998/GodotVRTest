class_name MuzzleFlash extends Node

@export var muzzle_flashes: Array[Node3D]
@onready var timer: Timer = $Timer
var current_flash: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", stop_flash)

func muzzle_flash():
	var random = randi_range(0, muzzle_flashes.size() - 1)
	muzzle_flashes[random].show()
	current_flash = muzzle_flashes[random]
	timer.start(0.02)

func stop_flash():
	current_flash.hide()
