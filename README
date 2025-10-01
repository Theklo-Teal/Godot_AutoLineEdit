For Paracortical Initiative, 2025, Diogo "Theklo" Duarte

Other projects:
https://bsky.app/profile/diogo-duarte.bsky.social
https://diogo-duarte.itch.io/
https://github.com/Theklo-Teal


#DESCRIPTION
A version of the LineEdit node for Godot, but which displays a suggestion box for auto-completion.

#INSTALLATION
This isn't technically a Godot Plugin, it doesn't use the special Plugin features of the Editor, so don't put it inside the "plugin" folder. The folder of the tool can be anywhere else you want, though, but I suggest having it in a "modules" folder.

You can add an AutoLineEdit by just going into the "Create New Node" menu in the Godot editor, or typing `AutoLineEdit.new()` in code.
Each new instance must be have its script extended to implement the suggestion and replacement logic and define sources of data. See the comments of the class script for instructions on this, or check the "Example_Implementation.gd".

#USAGE
All native behavior from LineEdit is still accessible.
As the user types a prompt, it will try to guess what the last word after a space is and show a list with those guesses that can be selected with the arrow keys and accepted by pressing the "Tab" key. Pressing the "Esc" key will dismiss the suggestion box.
The entries in the suggestion box can be made to just outright show what replacement will be made in the prompt, but can also have other arbritrary string, like «You Typed "X", it will be replaced with "Y"». This might allow to inform the user of some seemingly unexpected replacement that might happen.
The entries can also be optionally associated with a color which is displayed as little icon. The developer might choose to group entries of the same color together in the suggestion box.

All the implementation details mentioned are to be written by the developer in the extending script. See "Example_Implementation.gd" for a demonstration.
