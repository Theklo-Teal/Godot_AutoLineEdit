extends AutoLineEdit

## Example extending script for an instance of AutoLineEdit

func _ready() -> void:  # Set size forthe LineEdit
	custom_minimum_size.x = 400
	super()


const SIMI = 0.6  # How similar the input token and a word must be to be accepted as suggestion token.

const CATALOG = [  # Potential suggestions for something the user types.
	"foobar",
	"foofighter",
	"superhot",
	"supermario",
	"superman",
	"superheterodyne",
	"test_text",
	"other_otter"
	]
var ICONS = [  # Colors next to the suggestion entries
	Color.DARK_SLATE_GRAY.to_html(false),
	Color.WEB_GRAY.to_html(false),
	"FF0000",
	"FF0088",
	"FF8800",
	"",  # No color for this one
	str(Color(0.74, 0.74, 0.0, 1.0).to_rgba32()),
	str(Color(0.24, 0.291, 1.0, 0.596).to_rgba32()),  # Transparency should work, if you think it makes sense.
	]

## Return list of pairs of words, which are text to display as suggestion and the actual token that's added in the prompt if suggestion is selected.
func get_suggestions(token:String) -> Array[PackedStringArray]:
	var suggestions : Array[PackedStringArray]
	var i : int = 0
	for word in CATALOG:
		if fuzzy_match(word, token) >= SIMI:
			suggestions.append([
				token + " -> " + word,  # What to show as entry in the suggestion box.
				word,  # The token that's actually added to the prompt on selection.
				ICONS[i]  # Icon color for this entry.
				] as PackedStringArray)
		i += 1
	return suggestions

## Add a token to the prompt, allowing for performing any necessary modifications or corrections.
func update_prompt(prompt:String, token:String) -> String:
	token = token.to_upper()  # Just make tokens that are auto added into uppercase, in this case.
	return super(prompt, token)
