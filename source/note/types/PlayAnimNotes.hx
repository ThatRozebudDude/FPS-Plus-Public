package note.types;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class PlayAnimNotes extends NoteType
{

    override function defineTypes():Void{
        addNoteType("shit", shitHit, null);
        addNoteType("shit-play", shitPlayHit, null);

        addNoteType("shit-censor", shitCensorHit, null);
        addNoteType("shit-censor-play", shitCensorPlayHit, null);

        addNoteType("burp", burpHit, null);
        addNoteType("burp-play", burpPlayHit, null);

        addNoteType("burpBig", burpBigHit, null);
        addNoteType("burpBig-play", burpBigPlayHit, null);
    }

    function shitHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.singAnim("shit", true);
        }
    }

    function shitPlayHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.playAnim("shit", true);
        }
    }

    function shitCensorHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.singAnim("shit-censor", true);
        }
    }

    function shitCensorPlayHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.playAnim("shit-censor", true);
        }
    }

    function burpHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.singAnim("burp", true);
        }
    }

    function burpPlayHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.playAnim("burp", true);
        }
    }

    function burpBigHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.singAnim("burpBig", true);
        }
    }

    function burpBigPlayHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.playAnim("burpBig", true);
        }
    }

}