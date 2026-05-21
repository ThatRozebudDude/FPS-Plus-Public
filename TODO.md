# TODO

- Fix thing with the characters doing extra bopping stuff after the song ends?

- Editor UI Components
	- Custom Cursor (Maybe)
	- Text Input QOL
		- Selectable Text in Text Input (Maybe)
			- Stuff like selecting a region of text and deleting it all at once.

- New Chart Format
	- Make sure that the old format is still supported and can load and auto convert to the new format.
		- Also update the base-game chart port Python script if I'm not lazy but if this works I could just auto convert it later.

- Chart Editor
	- Finish new icons.
		- Add icon for `setBopFreq`.
	- Event descriptions.
	- Better Note Type (Maybe Event) sorting.
	- Autosave.
	- Sound effects? Maybe?
	- Look into small memory leak when recycling notes/events?

- Character Editor
	- Kinda like a mix of the offset editor and the debug Character Compare thing.
	- Hopefully it would be nice to be able to add animations and stuff and not just adjust offsets.

- Maybe Stage Editor?
	- I have this old internal tool I made a while ago that sucks that I sometimes still use maybe I can work off of that.

# Needs Fixing Before Implementing

- Fix Polymod macro issue <- THIS ONE IS IMPORTANT IF YOU CAN FIX THIS OR HAVE ANY IDEAS PLEASE LET ME KNOW (also if you are having this issue you just need to add a trace or something into Polymod.hx to force it to recompile and run the macro.)

# Possible Future Version Features

- Localiztion files.