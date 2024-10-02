package note.types;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class AnimSetNotes extends NoteType
{

    override function defineTypes():Void{
        addNoteType("censor", censorHit, null);
    }

    function censorHit(note:Note, character:Character){
        var prevAnimSet = character.animSet;
        character.animSet = "censor";
        playstate.defaultNoteHit(note, character);
        character.animSet = prevAnimSet;
    }

}