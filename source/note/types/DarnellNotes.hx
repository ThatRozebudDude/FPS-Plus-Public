package note.types;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class DarnellNotes extends NoteType
{

    override function defineTypes():Void{
        addNoteType("weekend-1-lightcan", lightcanHit, null);
        addNoteType("weekend-1-kickcan", kickcanHit, null);
        addNoteType("weekend-1-kneecan", kneecanHit, null);
        addNoteType("weekend-1-cockgun", cockgunHit, cockgunMiss);
        addNoteType("weekend-1-firegun", firegunHit, firegunMiss);
    }

    function lightcanHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('lightCan', true);
        }
        FlxG.sound.play(Paths.sound("weekend1/Darnell_Lighter"));
    }

    function kickcanHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('kickUp', true);
        }
        FlxG.sound.play(Paths.sound("weekend1/Kick_Can_UP"));
        playstate().executeEvent("phillyStreets-canKick");
    }

    function kneecanHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('kneeForward', true);
        }
        FlxG.sound.play(Paths.sound("weekend1/Kick_Can_FORWARD"));
        playstate().executeEvent("phillyStreets-canKickForward");
    }

    function cockgunHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('reload', true);
        }
        playstate().getExtraCamMovement(note);
        FlxG.sound.play(Paths.sound("weekend1/Gun_Prep"));
        playstate().executeEvent("phillyStreets-playerGlow");
    }

    function firegunHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('shoot', true);
        }
        character.danceLockout = true;
        playstate().getExtraCamMovement(note);
        FlxG.sound.play(Paths.sound("weekend1/shot" + FlxG.random.int(1, 4)));
        playstate().executeEvent("phillyStreets-stageDarken");
        playstate().executeEvent("phillyStreets-canShot");
        playstate().camFocusBF();
        playstate().camChangeZoom(0.85, (Conductor.crochet/1000) * 2, FlxEase.expoOut);
    }

    function firegunMiss (direction:Int, character:Character){
        if(character.canAutoAnim){
            character.playAnim('hit', true);
        }
        FlxG.sound.play(Paths.sound("weekend1/Pico_Bonk"));
        playstate().executeEvent("phillyStreets-canHit");
        playstate().camFocusBF();
        playstate().camChangeZoom(0.85, (Conductor.crochet/1000) * 2, FlxEase.expoOut);
        playstate().health -= 0.5;
        if(playstate().health <= 0){
            playstate().openGameOver("PicoDeadExplode");
        }
    }

    function cockgunMiss (direction:Int, character:Character){
        playstate().defaultNoteMiss(direction, character);
        playstate().forceMissNextNote = true;
    }

}