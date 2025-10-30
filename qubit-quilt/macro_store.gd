extends Node

const LS_DEFAULT_KEY := "qec_macros_default_v1"
const LS_USER_KEY := "qec_macros_user_v1" 

func load_defaults() -> void:
	print_debug("[MacroStore] load_defaults()")

	var is_web := OS.has_feature("web")

	if is_web:
		var ls: Variant = JavaScriptBridge.get_interface("localStorage")
		if ls == null:
			push_warning("localStorage not available.")
			return
	else:
		print_debug("[MacroStore] Not web, no default macros loaded")
		return
		
	# Read all macros from res://macros set recursive=true for subfolders
	var seeded_arr: Array = _read_all_res_macros("res://macros", false)

	if seeded_arr.is_empty():
		push_warning("No default macros detected")

	var json := JSON.stringify(seeded_arr)

	if is_web:
		var ls2: Variant = JavaScriptBridge.get_interface("localStorage")
		ls2.setItem(LS_DEFAULT_KEY, json)
	else:
		_write_text_to_user_file(json)

	print_debug("[MacroStore] defaults seeded from res://macros/")


static func _read_res_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var text := f.get_as_text()
	f.close()
	if text.strip_edges() == "":
		return null
	return JSON.parse_string(text)

static func _read_all_res_macros(dir_path: String = "res://macros", recursive: bool = false) -> Array:
	var out: Array = []

	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("[MacroStore] Macro folder not found: %s" % dir_path)
		return out

	for fname in dir.get_files():
		if not String(fname).to_lower().ends_with(".json"):
			continue
		var full := dir_path.path_join(fname)
		var v: Variant = _read_res_json(full)
		match typeof(v):
			TYPE_DICTIONARY:
				out.append(v)
			TYPE_ARRAY:
				for it in (v as Array):
					if typeof(it) == TYPE_DICTIONARY:
						out.append(it)
			_:
				push_warning("[MacroStore] Skipping invalid JSON: %s" % full)

	# recursion into subfolders
	if recursive:
		for sub in dir.get_directories():
			var sub_path := dir_path.path_join(sub)
			out.append_array(_read_all_res_macros(sub_path, true))

	return out


func save_one(macro: Variant) -> void:
	var arr := load_all()
	arr.append(macro if typeof(macro) == TYPE_DICTIONARY else macro.to_dict())
	var json := JSON.stringify(arr)
	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		ls.setItem(LS_USER_KEY, json)
	else:
		_write_text_to_user_file(json)

static func _read_text_from_user_file() -> String:
	if not FileAccess.file_exists("user://macros.json"):
		return ""
	var f := FileAccess.open("user://macros.json", FileAccess.READ)
	var s := f.get_as_text()
	f.close()
	return s

static func _write_text_to_user_file(text: String) -> void:
	var f := FileAccess.open("user://macros.json", FileAccess.WRITE)
	f.store_string(text)
	f.close()

func save_all(macros: Array) -> void:
	var payload := []
	for m in macros:
		payload.append(m if typeof(m) == TYPE_DICTIONARY else m.to_dict())
	var json := JSON.stringify(payload)

	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		ls.setItem(LS_USER_KEY, json)
	else:
		_write_text_to_user_file(json)

func load_all() -> Array[Dictionary]:
	var empty: Array[Dictionary] = []

	var json := ""
	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		json = str(ls.getItem(LS_DEFAULT_KEY))
		if json == "null" or json.strip_edges() == "":
			return empty
	else:
		json = _read_text_from_user_file()
		if json.strip_edges() == "":
			return empty

	var parsed: Variant = JSON.parse_string(json)
	if typeof(parsed) != TYPE_ARRAY:
		return empty

	var out: Array[Dictionary] = []
	for it in (parsed as Array):
		if typeof(it) == TYPE_DICTIONARY:
			out.append(it as Dictionary)
		else:
			push_warning("[MacroStore] Skipping non-dictionary item in saved macros")
	return out

# dicts into Macro nodes
func instantiate_loaded_macros() -> Array[Macro]:
	var result: Array[Macro] = []
	for d in load_all():
		result.append(Macro.from_dict(d))
	return result

# export to a downloadable JSON file in the browser
func export_download(macros: Array) -> void:
	var payload := []
	for m in macros:
		payload.append(m if typeof(m) == TYPE_DICTIONARY else m.to_dict())
	var json := JSON.stringify(payload)

	if not OS.has_feature("web"):
		_write_text_to_user_file(json)
		return

	var window: Variant = JavaScriptBridge.get_interface("window")
	var URLintf: Variant = JavaScriptBridge.get_interface("URL")
	var document: Variant = JavaScriptBridge.get_interface("document")
	if window == null or URLintf == null or document == null:
		push_warning("Browser interfaces unavailable; cannot export.")
		return

	# Blob([json], {type:'application/json'})
	var blob: Variant = JavaScriptBridge.create_object("Blob", [[json], {"type":"application/json"}])
	var url: Variant = URLintf.call("createObjectURL", blob)

	var body: Variant = document.get("body")
	var a: Variant = document.call("createElement", "a")
	a.set("href", url)
	a.set("download", "macros.json")
	body.call("appendChild", a)
	a.call("click")
	body.call("removeChild", a)
	URLintf.call("revokeObjectURL", url)

#  import from browser
func import_from_file_picker(callback: Callable) -> void:
	if not OS.has_feature("web"):
		push_warning("File picker import is browser-only; use user://macros.json on desktop.")
		return

	var document: Variant = JavaScriptBridge.get_interface("document")
	if document == null:
		callback.call([])
		return

	var body: Variant = document.get("body")
	var input: Variant = document.call("createElement", "input")
	input.set("type", "file")
	input.set("accept", "application/json,.json")
	input.set("style", "display:none")
	body.call("appendChild", input)

	var onchange_cb: Variant = JavaScriptBridge.create_callback(func(_ev):
		var files: Variant = input.get("files")
		if files == null:
			body.call("removeChild", input)
			callback.call([])
			return
		var length := int(files.get("length"))
		if length <= 0:
			body.call("removeChild", input)
			callback.call([])
			return

		var file0: Variant = files.call("item", 0)
		var reader: Variant = JavaScriptBridge.create_object("FileReader")

		var onload_cb: Variant = JavaScriptBridge.create_callback(func(_e):
			var result_text := String(reader.get("result"))
			var parsed: Variant = JSON.parse_string(result_text)
			body.call("removeChild", input)
			if typeof(parsed) != TYPE_ARRAY:
				callback.call([])
				return
			callback.call((parsed as Array) as Array[Dictionary])
		)

		reader.set("onload", onload_cb)
		reader.call("readAsText", file0)
	)

	input.set("onchange", onchange_cb)
	input.call("click")

func _ready() -> void:
	print_debug("STARTING MACRO STORE")
	load_defaults()
