package data.events;

import note.*;

class NoteEvent extends GameplayEvent
{
	// (maybe) it will be able to do like "event.note"
	
	public var note:Note;

	public var character:Character;

	public function new(_note:Note, _character:Character){
		super("NoteEvent", false);

		note = _note;
		character = _character;
	}
}