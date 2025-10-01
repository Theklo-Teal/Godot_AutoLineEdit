extends LineEdit
class_name AutoLineEdit

## It's like LineEdit but it has auto-complete box when you type on it.[br]
## Each [code]AutoLineEdit[/code] instance relies on having its script extended to implement [code]get_suggestions()[/code] and [code]update_prompt()[/code].[br]
## Optionally you may override [code]fuzzy_match()[/code] to change the similiarity algorithm, ie. the edit distance between input and potential suggestions.
## Suggestions are selected by pressing the "Tab" key. The suggestion list is dismissed by pressing the "Esc" key.
#FIXME Why don't suggestion entry colors work with transparency?!

signal suggestions_updated(suggestions:PackedStringArray, replacements:PackedStringArray)

@export var max_height : int = 384 ## how tall the suggestion box can get.
@export var disable_window := false ## You might make the window with suggestions not show up, so intead you process the exceptions on another node.

#region Override these functions in an extension script
## Return array of pairs of words, which are text to display as suggestion and the actual token that's added in the prompt if suggestion is selected.[br]
## Optionally have a third element with a color code for the icon next to the entry. Having an empty string is the same as not setting color for a given entry.[br]
## Example return value: [code][["your wrote " + token, "replaced with foobar"], [token, token, "#00FF00"]][/code] in this example, the second suggestion entry doesn't make replacements.
func get_suggestions(_token:String) -> Array[PackedStringArray]:
	return []

## Add a token to the prompt from a selected suggestion, allowing for performing any necessary modifications or corrections.[br]
## This gives the opportunity to changes something about the text of the prompt beyond just adding the suggestion, or even the suggestion itself, if necessary.
func update_prompt(prompt:String, token:String) -> String:
	# Remove the token the user has been writing so far.
	var delimeter = prompt.rfind(" ")
	if delimeter == -1:
		prompt = ""
	else:
		prompt = prompt.left(delimeter)
	# add what we actually want to put in the prompt.
	return prompt + " " + token
#endregion


var _suggwind : Window
var _sugglist : ItemList

func _init() -> void:
	_suggwind = Window.new()
	_sugglist = ItemList.new()
	add_child(_suggwind)
	_suggwind.add_child(_sugglist)
	
	_sugglist.allow_reselect = true
	_sugglist.allow_search = false
	_sugglist.auto_height = true
	_sugglist.focus_mode = Control.FOCUS_NONE
	_sugglist.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	_suggwind.hide()
	_suggwind.wrap_controls = true
	_suggwind.transient = true
	_suggwind.unresizable = true
	_suggwind.borderless = true
	_suggwind.always_on_top = true
	_suggwind.unfocusable = true
	_suggwind.popup_window = true
	_suggwind.popup_wm_hint = true
	_suggwind.max_size.x = 15000


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	text_changed.connect(_on_text_changed)
	text_submitted.connect(_on_text_submitted)
	focus_entered.connect(_on_focus_entered)


var ignore_sugg : bool :
	set(val):
		ignore_sugg = val
		if val:
			_suggwind.hide()
func _on_focus_entered() -> void:
	ignore_sugg = false

var is_hovering : bool
func _on_mouse_entered():
	is_hovering = true
func _on_mouse_exited():
	is_hovering = false

var inhibit_sugg : bool
func _on_text_changed(txt:String):
	if inhibit_sugg: 
		inhibit_sugg = false
		return
	var tokens := txt.split(" ", false)
	var font_hei : float = 0
	if tokens.size() > 0:
		_sugglist.clear()
		var suggestions : PackedStringArray
		var replacements : PackedStringArray
		for sugg in get_suggestions(tokens[-1].strip_edges()):
			suggestions.append(sugg[0])
			replacements.append(sugg[1])
			var font : Font = _sugglist.get_theme_font("font")
			font_hei = max(font_hei, font.get_string_size(sugg[0]).y )
			var icon = null
			if sugg.size() == 3 and not sugg[2].is_empty():
				icon = GradientTexture2D.new()
				icon.width = font_hei * 0.6
				icon.height = font_hei * 0.6
				icon.fill = GradientTexture2D.FILL_SQUARE
				icon.fill_from = Vector2.ONE * 0.5
				icon.gradient = Gradient.new()
				icon.gradient.add_point(0, Color(sugg[2]))
				icon.gradient.add_point(0.6, Color(sugg[2]))
				icon.gradient.add_point(1, Color.TRANSPARENT)
			var i = _sugglist.add_item(sugg[0], icon)
			_sugglist.set_item_metadata(i, sugg[1])
		if _sugglist.item_count > 0:
			suggestions_updated.emit(suggestions, replacements)
			if not disable_window:
				_sugglist.select(0)
				var rect = Rect2(
					global_position.x + 20,
					global_position.y + size.y + 4,
					size.x - 20,
					clamp( font_hei * _sugglist.item_count, font_hei, max_height )
					)
				_suggwind.popup(rect)
		else:
			_suggwind.hide()

func _on_text_submitted(_txt:String):
	_suggwind.hide()


func _input(event: InputEvent) -> void:
	# Hide the window when the mouse is used outside the LineEdit
	if _suggwind.visible and event is InputEventMouseButton and event.is_pressed() and not is_hovering:
		if not event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT, MOUSE_BUTTON_WHEEL_UP]:
			_suggwind.hide()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var list_size = _sugglist.item_count
		var curr_sel = Array(_sugglist.get_selected_items()).pop_front()  #NOTE: We use «.pop_front()» because it will return null on an empty array, rather than throwing an error like «.front()».
		match event.keycode:
			KEY_ESCAPE:
				if _suggwind.visible:
					ignore_sugg = true
					accept_event()
			KEY_SPACE:
				ignore_sugg = false
				inhibit_sugg = true
				_suggwind.hide()
			KEY_TAB:
				if _suggwind.visible and list_size > 0:
					if curr_sel == null:
						curr_sel = 0
					text = update_prompt(text, _sugglist.get_item_metadata(curr_sel))
					caret_column = text.length()
					ignore_sugg = true
				accept_event()
			KEY_UP:
				if _suggwind.visible and list_size > 0:
					if curr_sel == null:
						curr_sel = 0
					_sugglist.select(wrapi(curr_sel - 1, 0, list_size))
					accept_event()
			KEY_DOWN:
				if curr_sel == null:
					curr_sel = -1
				if _suggwind.visible and list_size > 0:
					_sugglist.select(wrapi(curr_sel + 1, 0, list_size))
					accept_event()


# https://en.wikipedia.org/wiki/Approximate_string_matching
# https://www.datacamp.com/tutorial/fuzzy-string-python?dc_referrer=https%3A%2F%2Fduckduckgo.com%2F
## Algorithm that tells the edit distance between two strings.
func fuzzy_match(a:String, b:String) -> float:
	#var len = max(a.length(), b.length())
	return a.similarity(b)
