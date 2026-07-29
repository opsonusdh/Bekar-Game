extends Node

const DEBUG = true

var path = "user://savegame.json"
signal Player_coin_changed(new_amount)


func save_data(data, path=path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_data(path=path):
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(text)

	if error == OK:
		print(json.data)
		return json.data
	else:
		push_error("Error while Loading data: ", error)
		return {}
