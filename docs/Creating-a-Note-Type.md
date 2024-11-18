## Creating the Class File

First you need to create a new file in `data/notetypes/` called `{ClassName}.hxc`. Technically the file can be named whatever you want as the class name is defined in the script but keeping the name consistent makes it easier to keep track of. 

At the top of the file you need to define the class with `class {ClassName} extends NoteType`. Inside the class you need to override a function called `defineTypes()`. When Polymod is loaded/reloaded the game will go through all `NoteType` scripts and call this function.

## Adding a Note Type

To add a note type you need to call one of the following functions inside of `defineTypes()`:

- `addNoteType(name, hitFunction, missFunction)`: 
    - `name`: Name of the note type.
    - `hitFunction(note, character)`: The function that is run when the note is hit. *(Optional)* If `null` it will use the default hit function.
        - `note`: The `Note` object that was just hit.
        - `character`: The `Character` object that just hit the note.
    - `missFunction(direction, character)`: The function that is run when the note is missed. *(Optional)* If `null` it will use the default miss function.
        - `direction`: The note direction that was just missed as an integer.
        - `character`: The `Character` object that just missed the note.

- `addSustainType(name, hitFunction, missFunction)`: Same as `addNoteType()` but this applies to sustain parts instead of full note hits.
- `addTypeSkin(name, noteSkinName)`: Any note of the type `name` will automatically have it's note skin set to `noteSkinName` instead of the current note skin.
    - `name`: Name of the note type.
    - `noteSkinName`: Class name of the note skin.

You are not limited to defining one note type per class so you can put similar note types into a single class for better organization.

## Hit and Miss Functions

Writing a custom hit or miss function works the same as any other type of script and you have access to all the scripting tools you would normally have.

### Custom Animations

When writing a custom hit or miss function the character will not automatically animate. You can use the following functions to use the default hit or miss behavior:

- `playstate.defaultNoteHit(note, character)`
    - `note`: The `Note` object that was just hit.
    - `character`: The `Character` object that just hit the note.
- `playstate.defaultNoteMiss(direction, character)`
    - `direction`: The note direction that was just missed as an integer.
    - `character`: The `Character` object that just missed the note.

If you want to make the character play a specific animation, it is recommended that you wrap the animation part of the code with this:

```haxe
if(character.canAutoAnim && shouldPlayAnimation(note, character)){
    //Animation code goes here.
}
```

This makes sure that the animation will only play when the game would normally let animations play. This is not required in case you want to do very specific things with note types but unless you absolutely require it I recommend adding the check before playing an animation. For note miss function you just need to check `character.canAutoAnim`.

### Adjusting Health

By default, the player's health will be automatically adjust how it normally would with a default note. To change the player's health you can set the variable `healthAdjust` to a specific value in the hit or miss function. After the function is run it is automatically set back to `null`. `healthAdjust` is not dependant on whether it is a hit or miss so a positive value will always add health and a negative value will always remove health. Remember that the player's health is a value from `0` to `2` so setting `healthAdjust` to something like `1` would add 50% health and setting `healthAdjust` to something like `-0.5` would remove 25% health. `healthAdjust` only works with the player character.

### Dynamic Camera Movement

By default the game will move the camera a little bit in the direction that you hit a note. It won't do this when note using the default behavior so you can use `playstate.getExtraCamMovement(note)` to do it automatically. If you want custom panning you can directly use `playstate.changeCamOffset()` to change the camera's offset. Note that if the player has `Dynamic Camera` turned off in the settings this extra camera movement won't happen, so don't use this for important camera movement, just use `playstate.camMove()` instead.

## Examples

Here is an example of a simple note type with the Week 2 cheer note:

```haxe
class CheerNote extends NoteType
{

    override function defineTypes():Void{
        addNoteType("week-2-cheer", cheerHit, null);
    }

    function cheerHit (note:Note, character:Character){
        if(character.canAutoAnim && shouldPlayAnimation(note, character)){
            character.singAnim("cheer", true);
        }
    }

}
```

And here is a more complex example from the notes used in 2hot:

```haxe
import flixel.tweens.FlxEase;
import flixel.FlxG;

class DarnellNotes extends NoteType
{

    override function defineTypes():Void{
        addNoteType("weekend-1-firegun", firegunHit, firegunMiss);
    }

    function firegunHit (note:Note, character:Character){
        if(character.canAutoAnim){
            character.playAnim('shoot', true);
        }
        character.danceLockout = true;
        playstate.getExtraCamMovement(note);
        FlxG.sound.play(Paths.sound("weekend1/shot" + FlxG.random.int(1, 4)));
        playstate.executeEvent("phillyStreets-stageDarken");
        playstate.executeEvent("phillyStreets-canShot");
        playstate.camFocusBF();
        playstate.camChangeZoom(0.85, (Conductor.crochet/1000) * 2, FlxEase.expoOut);
    }

    function firegunMiss (direction:Int, character:Character){
        if(character.canAutoAnim){
            character.playAnim('hit', true);
        }
        FlxG.sound.play(Paths.sound("weekend1/Pico_Bonk"));
        playstate.executeEvent("phillyStreets-canHit");
        playstate.camFocusBF();
        playstate.camChangeZoom(0.85, (Conductor.crochet/1000) * 2, FlxEase.expoOut);
        healthAdjust = 0;
        playstate.health -= 0.5;
        if(playstate.health <= 0){
            playstate.openGameOver("PicoDeadExplode");
        }
    }
}
```

Note that this is only one note type from the `DarnellNotes` class. The full thing contains multiple note types defined in a single class.