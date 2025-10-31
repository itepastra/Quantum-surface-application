extends Node

const LS_DEFAULT_KEY := "qec_macros_default_v1"
const LS_USER_KEY := "qec_macros_user_v1" 

const USR_FILE := "user://qubit-quilt/user_macros.json"
const DEFAULT_FILE := "user://qubit-quilt/default_macros.json"

signal user_macros_updated(macros: Array)

func load_defaults() -> void:
	print_debug("[MacroStore] load_defaults()")

	var is_web := OS.has_feature("web")

	if is_web:
		var ls: Variant = JavaScriptBridge.get_interface("localStorage")
		if ls == null:
			push_warning("localStorage not available.")
			return
	
	# Read all macros from res://macros set recursive=true for subfolders
	var seeded_arr: Array = _read_all_res_macros("res://macros", false)

	if seeded_arr.is_empty():
		push_warning("No default macros detected")

	var json: String = JSON.stringify(seeded_arr)
	
	if is_web:
		var ls2: Variant = JavaScriptBridge.get_interface("localStorage")
		ls2.setItem(LS_DEFAULT_KEY, json)
	else:
		var da = DirAccess.open("user://")
		da.make_dir("qubit-quilt")
		var file: FileAccess = FileAccess.open(DEFAULT_FILE, FileAccess.WRITE)
		var error_str: String = error_string(FileAccess.get_open_error())
		push_warning("Couldn't open file because: %s" % error_str)

		file.store_string(json)
	
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

static func _read_text_from_user_file(file: String) -> String:
	if not FileAccess.file_exists(file):
		return ""
	var f := FileAccess.open(file, FileAccess.READ)
	var s := f.get_as_text()
	f.close()
	return s


func load_all(LS_KEY: String = LS_DEFAULT_KEY) -> Array[Dictionary]:
	var empty: Array[Dictionary] = []

	var json := ""
	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		json = str(ls.getItem(LS_KEY))
		if json == "null" or json.strip_edges() == "":
			return empty
	else:
		json = _read_text_from_user_file(LS_KEY)
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
	if OS.has_feature("web"):
		for d in load_all(LS_DEFAULT_KEY):
			result.append(Macro.from_dict(d))
		for u in load_all(LS_USER_KEY):
			result.append(Macro.from_dict(u))
	else:
		for d in load_all(DEFAULT_FILE):
			result.append(Macro.from_dict(d))
		for u in load_all(USR_FILE):
			result.append(Macro.from_dict(u))
	return result

static func _parse_json_array_or_empty(raw: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if raw == null:
		return out

	var s: Variant = raw
	if not (s is String):
		s = str(raw)
		
	if s == "" or s == "null" or s == "Null":
		return out

	var parsed: Variant = JSON.parse_string(s)
	if parsed is Array:
		for it in (parsed as Array):
			if it is Dictionary:
				out.append(it as Dictionary)
	elif parsed is Dictionary:
		out.append(parsed as Dictionary)
	return out

func get_user_macros() -> Array[Dictionary]:
	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		if ls == null:
			push_warning("localStorage not available (web).")
			return []
		return _parse_json_array_or_empty(str(ls.getItem(LS_USER_KEY)))
	else:
		var p := USR_FILE
		if not FileAccess.file_exists(p):
			return []
		var f := FileAccess.open(p, FileAccess.READ)
		var txt := f.get_as_text()
		f.close()
		return _parse_json_array_or_empty(txt)

func _set_user_macros(arr: Array[Dictionary]) -> void:
	var json_txt := JSON.stringify(arr)
	if OS.has_feature("web"):
		var ls := JavaScriptBridge.get_interface("localStorage")
		if ls == null:
			push_warning("localStorage not available (web).")
			return
		ls.setItem(LS_USER_KEY, json_txt)
	else:
		var file = FileAccess.open(USR_FILE, FileAccess.WRITE)
		file.store_string(json_txt)
	emit_signal("user_macros_updated", arr)

func append_user_macro(macro_dict: Dictionary) -> void:
	# very light schema check
	if not macro_dict.has("instructions"):
		push_warning("append_user_macro: missing 'instructions'.")
		return
	var arr := get_user_macros()
	arr.append(macro_dict)
	_set_user_macros(arr)

func replace_all_user_macros(macros_arr: Array[Dictionary]) -> void:
	_set_user_macros(macros_arr)

func clear_user_macros() -> void:
	_set_user_macros([])

func _ready() -> void:
	print_debug("STARTING MACRO STORE")
	load_defaults()
