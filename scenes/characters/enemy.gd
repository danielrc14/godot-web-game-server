extends CharacterBody2D

@export_enum("Left:-1", "Right:1") var direction = 1
@export var left_weapon_name: String
@export var right_weapon_name: String
@export var sprite_frames_name: String
var enemy_id: int
