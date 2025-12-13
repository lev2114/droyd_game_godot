extends CanvasLayer

signal upgrade_chosen(name: String)

@onready var buttons: Array[TextureButton] = [
	$Control/VBoxContainer/HBoxContainer/TextureButton,
	$Control/VBoxContainer/HBoxContainer/TextureButton2,
	$Control/VBoxContainer/HBoxContainer/TextureButton3
]

var weapons_info = {
	"Gun": {
		"title": "Пистолет",
		"desc": "Стреляет пулями в ближайшего врага.",
		"picture": "res://assets/optionsPictures/PistolPicture.png"
	},
	"FentBeamGun": {
		"title": "Фент-луч",
		"desc": "Мощный луч, поражающий всех на линии, вращается вокруг оси",
		"picture": "res://assets/optionsPictures/FentBeam.png"
	},
	"jewrikenGun": {
		"title": "Святые сюрикены",
		"desc": "Бросает вращающиеся клинки по врагам.",
		"picture": "res://assets/klipartz.com.png"
	},
	"AirstrikeGun": {
		"title": "Авиаудар Моссада",
		"desc": "Вызывает авиаудар на ближайшего врага.",
		"picture": "res://assets/optionsPictures/AirDrop.png"
	}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	for b in buttons:
		b.pressed.connect(_on_button_pressed.bind(b))
	_fill_random_options()

func _fill_random_options():
	var names = weapons_info.keys()
	names.shuffle()
	var choices = names.slice(0, buttons.size())

	for i in range(buttons.size()):
		var weapon_name = choices[i]
		var info = weapons_info[weapon_name]

		var title_label = buttons[i].get_node("Title")
		var desc_label = buttons[i].get_node("Description")
		var picture: TextureRect = buttons[i].get_node("Control").get_node("Picture")
		
		title_label.text = info["title"]
		desc_label.text = info["desc"]
		picture.texture = load(info["picture"])
		
		buttons[i].set_meta("weapon_name", weapon_name)

func _on_button_pressed(button: TextureButton):
	get_tree().paused = false
	var chosen = button.get_meta("weapon_name")
	emit_signal("upgrade_chosen", chosen)
	queue_free()
