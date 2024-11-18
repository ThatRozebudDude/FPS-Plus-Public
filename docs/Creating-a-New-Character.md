## Creating the Class File

First you need to create a new file in `data/characters/` called `{ClassName}.hxc`. Technically the file can be named whatever you want as the class name is defined in the script but keeping the name consistent makes it easier to keep track of. 

At the top of the file you need to define the class with `class {ClassName} extends CharacterInfoBase`. Inside the class you need to create a constructor with `public function new()` where you define the character info. Don't forget to call `super()`.

## Basic Character Info

To set the info of a character you use `info.{field}`. The following isn't a complete list of fields but a list of basic fields required to set up a character:

- `name`: The name of the character when you use `Character.curCharacter`. (Optional, if not defined it will be set as the class name in lowercase.)
- `spritePath`: The path to the sprite sheet or texture atlas folder.
- `frameLoadType`: The method of loading the sprite for the character. It can be one of the following:
    - `setSparrow()` for standard sparrow sprite sheets.
    - `setPacker()` for texture packer sprite sheets. *(Spirit uses this.)*
    - `setLoad(width, height)` for fixed frame width sprite sheets. You must specify the frame height and width to use this.
    - `setAtlas()` for sprites that use a texture atlas.
- `iconName`: The name of the icon image used for the character. (Optional, if not defined it will default to `"face"`.)
- `deathCharacter`: The name of the character class to use on the death screen. (Optional, if not defined it will default to `"Bf"`.)
- `resultsCharacter`: The name of the results character class to use on the results screen. (Optional, if not defined it will default to `"BoyfriendResults"`.)
- `facesLeft`: Whether or not the character faces left in their sprite sheet or not. (Optional, if not defined it will default to `false`.)
- `antialiasing`: Whether or not the character has antialiasing applied to them. (Optional, if not defined it will default to `true`.)

## Adding Animations

To add an animation to the character you use one of the add animation functions. These functions share many arguments so I will only list the unique arguments of each function past the first one:

- `add(name, offset, frames, frameRate, looped, flipX, flipY)`
    - `name`: The string used to play the animation.
    - `offset`: The offset to be applied to the animation. Use the function `offset(x, y)` to set this.
    - `frames`: An array of integers that act as a frame index on to the sprite sheet.
    - `frameRate`: The framerate the animation plays at. (Optional, if not defined it will default to `30`.)
    - `looped`: Loop information for the animation. Use the function `loop(looped, frame)` to set this. (Optional, if not defined it will default to `loop(true)`.) Here is how you use `loop()`:
        - `looped`: A boolean that determines whether the animation will loop or not.
        - `frame`: If loop is set to `true`, this is the frame that the animation will be set to upon looping. If a negative number is used it acts as an offset from the end of the animtion, e.g. setting this to `-4` on a 10 frame animation would be the same as setting it to `5` (Keep in mind that the frames are 0 indexed so 5 would be frame 6).
    - `flipX`: A boolean that determines whether the animation should be flipped horizontally. (Optional, if not defined it will default to `false`.)
    - `flipY`: A boolean that determines whether the animation should be flipped vertically. (Optional, if not defined it will default to `false`.)

- `addByPrefix(name, offset, prefix, frameRate, looped, flipX, flipY)`
    - `prefix`: The prefix of the animation name on the sprite sheet. This matches to the begining of the animation name so putting something like `"Sing Up"` would match to both `"Sing Up"` and `"Sing Up Miss"`.

- `addByIndices(name, offset, prefix, indices, postfix, frameRate, looped, flipX, flipY)`
    - `prefix`: The prefix of the animation name on the sprite sheet. This matches exactly to the animation name so putting something like `"Sing Up"` would match to `"Sing Up"` but not `"Sing Up Miss"`.
    - `indices`: An array of integers that act as a frame index on to the animation specified with `prefix` sheet.
    - `postfix`: Same as `prefix` but for after the frame numbers. This usually just left as `""`. 

The following functions can only be used by texture atlases:

- `addByLabel(name, offset, label, frameRate, looped)`
    - `label`: The name of the frame label that the animation starts at. The animation will go from the begining of this label to the begining of the next label or the end of the animation if there is no next label. 

- `addByFrame(name, offset, start, length, frameRate, looped)`
    - `start`: The frame index to start start the animation on. (Remember that the frames are 0 indexed so 0 would be frame 1).
    - `length`: How long the animation is in frames. The animation will end after this many frames have been played.

- `addByStartingAtLabel(name, offset, label, length, frameRate, looped)`
    - `label`: The name of the frame label that the animation starts at.
    - `length`: How long the animation is in frames. The animation will end after this many frames have been played.

## Custom Health Icon

To add a new health icon to a character, you have to create an image with the same name as `info.iconName` in the `images/ui/healthIcons/` folder. A health icon has to include 3 parts: a neutral icon, a losing icon, and a winning icon, in that order. They must be layed out next to each other horizontally. The icon can be any resolution as long as each part is the same resolution since the game automatically divides the icon image up into 3 equal width parts. You can also include a JSON file with the same name as the icon to adjust a few properites about it. It can contain the following fields: 

- `antialiasing`: A boolean that determines whether to apply antialiasing to the icon. Week 6 icons set this to false.
- `offset`: An object with an `x` and `y` field that are used to reposition the icon.
    - `x`: Amount in pixel to reposition the icon horizontally.
    - `y`: Amount in pixel to reposition the icon vertically.

If you are making a 150 x 150 icon like what base game uses, make a JSON file with the following properties to have it be aligned the same way it would normally be aligned in base game.

```json
{
    "offset": {
        "x": 10,
        "y": -10
    }
}
```

## Extra Character Info

That is all you really need to know to set up a basic character, however there are more options you can use to create more advanced characters. None of these fields need to manually be set but they can help make a character more interesting.

- `healthColor`: The color of this character's side of the health bar. By default the health bar will be red and green depending on whether the character is the player or not but this overrides that. 
- `idleSequence`: An array of animation names that will play in order when the character does their idle dance. Characters like GF and the Spooky Kids use this for their left and right idles but you can have as many as you want.
- `focusOffset`: An FlxPoint that adds an offset from the center of a character when the camera focuses on them. The `x` value is multipled by -1 when on the player's side.
- `deathOffset`: An FlxPoint that adds an offset from the center of a character when the camera moves towards them on the death screen.
- `functions`: A set of functions that you can define that will be called at certain times. There will be more information about these in the **Advanced Character Scripting** section.

You can also use the function `addExtraData(key, data)` to add addition info that isn't part of the base character info class. The data is `Dynamic` so the keys aren't all going to refer to the same type. Here are the different keys you can use:

- `stepsUntilRelease`: The minimum number of steps a character will hold a note for. Most characters have 4 by default but Dad has 6.1.
- `scale`: An array of 2 numbers that change the `x` and `y` scale of the character. Useful for pixel art.
- `reposition`: An array of 2 numbers that change the `x` and `y` position of the character after it has been position by the stage. Useful if the character is off-center or position weirdly in the sprite's frame.
- `deathDelay`: The time before the camera pans over on the death screen.
- `deathSound`: The path to the sound effect that plays when you die.
- `deathSong`: The path to the song that plays when you die.
- `deathSongEnd`: The path to the audio that plays when you retry from the death screen.
- `worldPopupOffset`: An array of 2 numbers that change the `x` and `y` offset of the combo graphics if the player has them set to appear in the world instead of on the HUD.

## Animation Chains

An animation chain is a set of 2 animations set to automatically play back to back. You can set an animation chain with `addAnimChain(firstAnim, chainedAnim)` where:
- `firstAnim`: The name of the animation that the chained animation will play after.
- `chainedAnim`: The name of the animation that will play after the first animation.

## Actions

An action is a function that you can run by calling `doAction({actionName})` on a character. You can set an action with `addAction(name, function)` where:
- `name`: The name of the action that is used with `doAction()` to call the function.
- `function`: A `Void` function with no arguments that will be run when the action is called.

## Advanced Character Scripting

The character info has a field called `functions` which is an object containing a variety of functions that you are able to define similarly to a generic script. Each function has at least 1 argument with the `Character` type that is used to refer to this character however some have additional arguments to pass through data. Here are all the functions:

- `create(character)`: This is run after the character is created but before they are added.
- `add(character)`: This is run after the character is added to `PlayState`.
- `update(character, elapsed)`: This is run every frame.
    - `elapsed`: The time in seconds from the previous frame to this frame as a float.
- `songStart(character)`: This is run once the current song starts playing.
- `beat(character, beat)`: This function is run every beat.
    - `beat`: The current beat number as an integer.
- `step(character, step)`: This function is run every step.
    - `step`: The current step number as an integer.
- `dance(character)`: This is run after the character does their idle dance. 
- `danceOverride(character)`: This replaces the default dance logic with custom dance logic. You can use `character.defaultDanceBehavior()` if you want to incorporate the default logic into part of the new logic. The `dance` function is still run after this.
- `idleEnd(character)`: This is run after the `idleEnd()` function is run. Note that this *isn't* called whenever the idle finishes playing but instead when the game specifically want to play the idle animation starting at the end.
- `idleEndOverride(character)`: This replaces the default `idleEnd()` logic with custom logic. You can use `character.defaultIdleEndBehavior()` if you want to incorporate the default logic into part of the new logic. The `idleEnd` function is still run after this.
- `frame(character, animation, index)`: This is run after every an animation frame is changed.
    - `animation`: The name of the current animation that is playing as a string.
    - `index`: The current frame of the animation that is playing as an integer.
- `animationEnd(character, animation)`: This is run after an animation is finished playing.
    - `animation`: The name of the current animation that is playing as a string.
- `deathCreate(character)`: This is run after the character is created but before they are added on the death screen.
- `deathAdd(character)`: This is run after the character is added to `GameOverSubstate`.
- `noteHit(character, note)`: This is run when a character hits a note.
    - `note`: The note object that was just hit.
- `noteMiss(character, direction, countedMiss)`: This is run when exiting `PlayState`.
    - `direction`: The direction that the player missed in as an integer.
    - `countedMiss`: A boolean that will be `true` if the miss was counted or `false` if it wasn't (for things like wrong taps).

You can also use one of the following functions to add or remove sprites to either the Character object or directly to the current state or substate:

- `addToCharacter(FlxSprite)`
- `removeToCharacter(FlxSprite)`
- `addToState(FlxBasic)`
- `removeFromState(FlxBasic)`
- `addToSubstate(FlxBasic)`
- `removeFromSubstate(FlxBasic)`

## Examples

The following is the character class for Boyfriend:

```haxe
class Bf extends CharacterInfoBase
{

    public function new(){
        super();

        info.name = "bf";
        info.spritePath = "BOYFRIEND";
        info.frameLoadType = setSparrow();
        
        info.iconName = "bf";
        info.facesLeft = true;
        info.focusOffset.set(100, -120);

        addByPrefix('idle', offset(), 'BF idle dance', 24, loop(false));

        addByPrefix('singUP', offset(-42, 31), 'BF NOTE UP0', 24, loop(false));
        addByPrefix('singLEFT', offset(9, -7), 'BF NOTE LEFT0', 24, loop(false));
        addByPrefix('singRIGHT', offset(-44, -6), 'BF NOTE RIGHT0', 24, loop(false));
        addByPrefix('singDOWN', offset(-22, -50), 'BF NOTE DOWN0', 24, loop(false));

        addByPrefix('singUPmiss', offset(-37, 29), 'BF NOTE UP MISS', 24, loop(true, -4));
        addByPrefix('singLEFTmiss', offset(9, 19), 'BF NOTE LEFT MISS', 24, loop(true, -4));
        addByPrefix('singRIGHTmiss', offset(-38, 21), 'BF NOTE RIGHT MISS', 24, loop(true, -4));
        addByPrefix('singDOWNmiss', offset(-25, -20), 'BF NOTE DOWN MISS', 24, loop(true, -4));

        addByPrefix('hey', offset(1, 5), 'BF HEY', 24, loop(false));
        addByPrefix('cheer', offset(-20, 20), 'Cheer', 24, loop(false));
        addByPrefix('scared', offset(-2, 0), 'BF idle shaking', 24);

        addByPrefix('firstDeath', offset(27, 6), "BF dies", 24, loop(false));
        addByPrefix('deathLoop', offset(27, 0), "BF Dead Loop", 24, loop(true));
        addByPrefix('deathConfirm', offset(27, 64), "BF Dead confirm", 24, loop(false));
    }

}
```

And here is an example of a more complex character with Nene:

```haxe
import objects.ABot;
import flixel.FlxG;

class Nene extends CharacterInfoBase
{

    public function new(){
        super();

        includeInCharacterList = false;
        includeInGfList = true;

        info.name = "nene";
        info.spritePath = "weekend1/Nene";
        info.frameLoadType = setSparrow();
        
        info.iconName = "face";
        info.focusOffset.set();

		addByIndices("danceLeft", offset(0, 0), "Idle", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, loop(false, 0));
        addByIndices("danceRight", offset(0, 0), "Idle", [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, loop(false, 0));
        addByPrefix("idleLoop", offset(0, 0), "Idle", 24, loop(true, 0));
        addByIndices("sad", offset(0, 0), "Laugh", [0,1,2,3], "", 24, loop(false, 0));
        addByPrefix("laugh", offset(0, 0), "Laugh", 24, loop(true, -6));
        addByIndices("laughCutscene", offset(0, 0), "Laugh", [0,1,2,3,4,5,6,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11,7,8,9,10,11], "", 24, loop(false, 0));
        addByPrefix("comboCheer", offset(-120, 53), "ComboCheer", 24, loop(false, 0));
        addByIndices("comboCheerHigh", offset(-40, -20), "ComboFawn", [0,1,2,3,4,5,6,4,5,6,4,5,6,4,5,6], "", 24, loop(false, 0));
        addByPrefix("raiseKnife", offset(0, 51), "KnifeRaise", 24, loop(false, 0));
        addByPrefix("idleKnife", offset(-98, 51), "KnifeIdle", 24, loop(false, 0));
        addByIndices("lowerKnife", offset(135, 51), "KnifeLower", [0,1,2,3,4,5,6,7,8], "", 24, loop(false, 0));

        addAnimChain("raiseKnife", "idleKnife");
        addAnimChain("laughCutscene", "idleLoop");

        info.idleSequence = ["danceLeft", "danceRight"];

        info.functions.create = create;
        info.functions.songStart = songStart;
        info.functions.update = update;
        info.functions.beat = beat;
        info.functions.danceOverride = danceOverride;

        addExtraData("reposition", [0, -165]);
    }

    var knifeRaised:Bool = false;
    var blinkTime:Float = 0;

    var abot:ABot;
    var abotLookDir:Bool = false;

    var BLINK_MIN:Float = 1;
    var BLINK_MAX:Float = 3;

    function create(character:Character):Void{
        abot = new ABot(-134.5, 311);
		abot.lookLeft();
        addToCharacter(abot);
    }

    function update(character:Character, elapsed:Float):Void{
        
        if(character.curAnim == "idleKnife"){
            blinkTime -= elapsed;

            if(blinkTime <= 0){
                character.playAnim("idleKnife", true);
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
            }
        }

        if(!character.debugMode){
            if(playstate.camFocus == "dad" && abotLookDir){
                abotLookDir = !abotLookDir;
                abot.lookLeft();
            }
            else if(playstate.camFocus == "bf" && !abotLookDir){
                abotLookDir = !abotLookDir;
                abot.lookRight();
            }
        }
        
    }

    function beat(character:Character, beat:Int) {
        abot.bop();

        //raise knife on low health
        if(PlayState.SONG.song.toLowerCase() != "blazin"){
            if(PlayState.instance.health < 0.4 && !knifeRaised){
                knifeRaised = true;
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
                character.playAnim("raiseKnife", true);
            } 
            else if(PlayState.instance.health >= 0.4 && knifeRaised && (character.curAnim == "idleKnife" || character.curAnim == "sad")){
                knifeRaised = false;
                character.playAnim("lowerKnife", true);
                character.idleSequenceIndex = 1;
                character.danceLockout = true;
            }
        }

    }

    function danceOverride(character:Character):Void{
        if(!knifeRaised){
            character.defaultDanceBehavior();
        }
    }

    function songStart(character:Character):Void{
        abot.setAudioSource(FlxG.sound.music);
		abot.startVisualizer();
    }

}
```