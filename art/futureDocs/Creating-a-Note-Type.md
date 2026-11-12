## Creating the Class File

First you need to create a new file in `data/notetypes/` called `{ClassName}.hxc`. Technically the file can be named whatever you want as the class name is defined in the script but keeping the name consistent makes it easier to keep track of. 

At the top of the file you need add the class to the note type package with `package notetypes;`. Then you need to define the class with `class {ClassName} extends NoteType`. Inside the class you need to override a function called `defineTypes()`. When Polymod is loaded/reloaded the game will go through all `NoteType` scripts and call this function.

## Adding a Note Type

To add a note type you need to call `registerNoteType()` which takes an object that contains all of the note's data. Fields can be omitted from the object if they are not used as the game will fall back to default values when not provided. The object consists of the following values:

- `prefix`: A string that is used as the name of the note type.
- `noteHit`: A function of type `(Note, Character)->Void` that is called when you hit a note.
- `noteMiss`: A function of type `(Note, Character)->Void` that is called when you miss a note.
- `sustainHit`: A function of type `(NoteSustain, Character)->Void` that is called every step while holding a sustain.
- `sustainMiss`: A function of type `(NoteSustain, Character)->Void` that is called when you miss or drop a sustain.
- `scoring`: A `NoteScoringProperties` object that contains a bunch of information about how your score or health should react to the note, whether the note counts towards combos/breaks and the note's hit region.
	- `scoring`: Either an integer or a function of type `(Note, Float, String)->Int`. This number is added to the player's score when they hit the note.
		- The `Note` passed into the function is the note object that was hit.
		- The `Float` passed into the function is the timing difference the note what hit with.
		- The `String` passed into the function is the rating the note was given. It will either be `sick`, `good`, `bad`, or `shit`.
	- `healing`: Either a float or a function of type `(Note, Float, String)->Float`. This number is added to the player's health when they hit the note.
		- The `Note` passed into the function is the note object that was hit.
		- The `Float` passed into the function is the timing difference the note what hit with.
		- The `String` passed into the function is the rating the note was given. It will either be `sick`, `good`, `bad`, or `shit`.
	- `penalty`: Either an integer or a function of type `(Note)->Int`. This number is added to the player's score when they miss the note.
		- The `Note` passed into the function is the note object that was missed.
	- `damage`: Either a float or a function of type `(Note)->Float`. This number is added to the player's health when they miss the note.
		- The `Note` passed into the function is the note object that was missed.

	- `sustainScoring`: Either an integer or a function of type `(NoteSustain)->Int`. This number per second is added to the player's score each step while holding the sustain.
	- `sustainHealing`: Either a float or a function of type `(NoteSustain)->Float`. This number per second is added to the player's health each step while holding the sustain.
	- `sustainPenalty`: Either an integer or a function of type `(NoteSustain)->Int`. This number per second is added to the player's score for each step remaining when you drop a sustain.
	- `sustainDamage`: Either a float or a function of type `(NoteSustain)->Float`. This number per second is added to the player's health for each step remaining when you drop a sustain.
	
	- `countHit`: Either a boolean or a function of type `(Note)->Bool`. If this is set hitting the note will count towards your hit total and affect your accuracy.
	- `countMiss`: Either a boolean or a function of type `(Note)->Bool`. If this is set missing the note will count towards your misses and break your combo.

	- `autoplayIgnore`: A boolean that when set will cause the opponent and autoplay to miss the note. This is useful for things like mines or other types of note you are supposed to avoid.

	- `hitRegion`: A `HitRegion` object containing the different millisecond timings for the note's ratings. *(Note that these hit regions apply to both sides of the note so a sick region of `45` creates a `90` milliseond region around the note.)*
		- `sick`: The timing difference for hitting a sick.
		- `good`: The timing difference for hitting a good.
		- `bad`: The timing difference for hitting a bad.
		- `shit`: The timing difference for hitting a shit. You are not able to hit the note outside of this region.
- `skin`: The name of the note skin class that gets applied to the note.
- `editor`: An `EventEditorProperties` object that helps build the editable fields that display in the chart editor. This is not required to use arguments but it can make it easier to work with.
	- `description`: A string that displays on the bottom of the chart editor panel when the note type is selected.
	- `arguments`: An array of `EventArgument` used to build the editable fields in the chart editor.
	- `hidden`: A boolean that when set hides the note type in the chart editor. This is used by legacy types that are included for backwards compatibility but shouldn't be used.

## Hit and Miss Functions

Writing a custom hit or miss function works the same as any other type of script and you have access to all the scripting tools you would normally have.

### Arguments

Much like Events, you can pass arguments into a note type by adding them after the name of the note type, separated by semicolons. To parse out the arguments you can use `NoteType.getArgs(tag, defaultArguments)` to return an array of strings with the provided arguments and default arguments if they are omitted. If you do not provide `defaultArguments` it will try to get the default arguments based on the tag provided. Ex:

```haxe
var args = NoteType.getArgs(note.type, ["", "", "true"]);
```

This will return `["", "", "true"]` if no arguments are provided and would return `["hey", "cheer", "false"]` if the provided tag was `playAnim;hey;cheer;false`. All arguments are strings, you can use `Events.parseInt()`, `Events.parseFloat()`, `Events.parseBool()`, `Events.parseTime()`, or `Events.parseEase()` to convert to other types.

### Custom Animations

When writing a custom hit or miss function the character will not automatically animate. You can use the following functions to use the default hit or miss behavior:

- `playstate.defaultNoteHit(note, character)`
	- `note`: The `Note` object that was just hit.
	- `character`: The `Character` object that just hit the note.
- `playstate.defaultNoteMiss(note, character)`
	- `note`: The `Note` object that was just missed. This can also be a direction as an integer.
	- `character`: The `Character` object that just missed the note.

If you want to make the character play a specific animation, it is recommended that you wrap the animation part of the code with this:

```haxe
if(character.canAutoAnim && shouldPlayAnimation(note, character)){
	//Animation code goes here.
}
```

This makes sure that the animation will only play when the game would normally let animations play. This is not required in case you want to do very specific things with note types but unless you absolutely require it I recommend adding the check before playing an animation. For note miss function you just need to check `character.canAutoAnim`.

You can also make the note use a specific game over character by setting `deathCharacter` to the name of the character that you want to use for the game over animations.

### Dynamic Camera Movement

By default the game will move the camera a little bit in the direction that you hit a note. It won't do this when note using the default behavior so you can use `playstate.getExtraCamMovement(note)` to do it automatically. If you want custom panning you can directly use `playstate.changeCamOffset()` to change the camera's offset. Note that if the player has `Dynamic Camera` turned off in the settings this extra camera movement won't happen, so don't use this for important camera movement, just use `playstate.camMove()` instead.

## Examples

Here is an example of a simple note type with the Week 2 cheer note:

```haxe
class CheerNote extends NoteType
{

	override function defineTypes():Void{
		registerNoteType({prefix: "week-2-cheer", noteHit: cheerHit});
	}

	function cheerHit(note:Note, character:Character){
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
		registerNoteType({prefix: "weekend-1-firegun", noteHit: firegunHit, noteMiss: firegunMiss, scoring:{damage: -0.5}});
	}

	function firegunHit(note:Note, character:Character){
		if(character.canAutoAnim){
			character.playAnim("shoot", true);
		}
		character.danceLockout = true;
		playstate.getExtraCamMovement(note);
		playstate.playSound(Paths.sound("weekend1/shot" + FlxG.random.int(1, 4)));
		playstate.executeEvent("phillyStreets-stageDarken");
		playstate.executeEvent("phillyStreets-canShot");
		playstate.camFocusBF();
		playstate.camChangeZoom(0.85, Conductor.getCrotchet() * 2, FlxEase.expoOut);
	}

	function firegunMiss(note:Note, character:Character){
		if(character.canAutoAnim){
			boyfriend.danceLockout = character.playAnim("hit", true);
		}
		playstate.playSound(Paths.sound("weekend1/Pico_Bonk"));
		playstate.executeEvent("phillyStreets-canHit");
		playstate.camFocusBF();
		playstate.camChangeZoom(0.85, Conductor.getCrotchet() * 2, FlxEase.expoOut);
		deathCharacter = "PicoDeadExplode";
	}
}
```

Note that this is only one note type from the `DarnellNotes` class. The full thing contains multiple note types defined in a single class.