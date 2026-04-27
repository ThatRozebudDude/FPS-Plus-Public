- Editor UI Components
	- Stepper
	- Text Input (Scary)
	- Custom Cursor (Maybe)

- New Chart Format
	- No more sections.
	- Still need to figure out how I want to handle BPM change stuff.
		- Possibly events or maybe it's own thing kinda like base game? The current implementation needs it to at least be on a step, no smaller interval, so maybe it'll be it's own thing.
	- Make sure that the old format is still supported and can load and auto convert to the new format.
		- Also update the base-game chart port Python script if I'm not lazy but if this works I could just auto convert it later.

- Chart Editor
	- Make it. Lol.
	- More robust event / note type UI that's more intuitive to use.
		- I want events and note types to have definable argument types and the editor will auto generate text input fields and type hints and put together the tag automatically so you don't need to manually type out the tag but you still can if you want to. 

- Character Editor
	- Kinda like a mix of the offset editor and the debug Character Compare thing.
	- Hopefully it would be nice to be able to add animations and stuff and not just adjust offsets.

- Maybe Stage Editor?
	- I have this old internal tool I made a while ago that sucks that I sometimes still use maybe I can work off of that.

# Needs Fixing Before Implementing

- Fix Polymod macro issue <- THIS ONE IS IMPORTANT IF YOU CAN FIX THIS OR HAVE ANY IDEAS PLEASE LET ME KNOW (also if you are having this issue you just need to add a trace or something into Polymod.hx to force it to recompile and run the macro.)

# Possible Future Version Features

- Localiztion files.