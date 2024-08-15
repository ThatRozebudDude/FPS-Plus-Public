package note.types;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class CheerNote extends NoteType
{

    override function defineTypes():Void{
        addNoteType("week-2-cheer", cheerHit, null);
        //addTypeSkin("week-2-cheer", "Pixel"); //for testing
    }

    function cheerHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('singCHEER', true);
        }
    }

}