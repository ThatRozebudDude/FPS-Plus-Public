## Creating the Class File

First you need to create a new file in `data/stages/` called `{ClassName}.hxc`. Technically the file can be named whatever you want as the class name is defined in the script but keeping the name consistent makes it easier to keep track of. 

At the top of the file you need to define the class with `class {ClassName} extends BaseStage`. Inside the class you need to create a constructor with `public function new()` where you define all of the objects you want to add to the stage. Don't forget to call `super()`.

## Basic Stage Properties

There are a few basic stage properties that you want to set when creating a stage. Here are a few of the basic properties you'd want to use when setting up a basic stage:

- `name`: The name of the stage. `PlayState.curStage` gets assigned to this.
- `startingZoom`: The initial zoom level of the camera.
- `uiType`: The name of the UI skin that is used on the stage, e.g. the Pixel skin in the Week 6 stages.

There are more properties than these however they will be discussed in the other sections.

## Adding Objects to the Stage

To add objects to the stage you need to create the object/sprite how you would normally in Haxe and then use `addTo{Layer}()` where `{Layer}` is either `Background`, `Middle`, `Foreground`, `Overlay`, or `Hud`, in the constructor to have the game add the object to that specific layer once the stage is created.

You can also directly add and remove objects to the different stage layers directly with `addTo{Layer}Live()` and `removeFrom{Layer}Live()`. This is the only way to add new objects to the stage after it has been created. However, I don't recommend doing this unless it is required for whatever you are doing. This is because adding and loading objects to the stage may cause people's game to lag depending on how much needs to be loaded. For stages that change throughout I recommend adding everything at the begining and toggling its visibility. This is designed more for objects like the bullet casings from 2hot.

This is the layer order and what specifically each layer does:

- `Background`: Behind all the characters.
- `Gf`: The layer that the GF character is on. *Can only be added live.*
- `Middle`: In front of the GF layer but behind the singing characters.
- `Character`: The layer that the singing characters are on. *Can only be added live.*
- `Foreground`: In front of all characters.
- `Overlay`: A static camera in front of the game camera but below the HUD.
- `Hud`: The camera that the HUD is on. When added in the constructor object will be below all the other HUD elements but will bop and move with the HUD camera.

You can also use `addToUpdate()` and `removeFromUpdate()` to add an object to the stage's update loop while not adding it to a layer in PlayState.

## Positioning Characters

By default, characters are positioned with the variables `bfStart`, `dadStart`,and `gfStart`. The characters are positioned so that these points are at the bottom middle of the character's sprite. You can set `useStartPoints` to `false` and manually set the positions of the `boyfriend`, `dad`, and `gf` objects. These positions are at the top left of the sprite like how objects are usually positioned in Flixel. You can also set `overrideBfStartPoints`, `overrideDadStartPoints`, or `overrideGfStartPoints` to `true` to have that character use the opposite of whatever `useStartPoints` is set to.

## Stage Camera

Besides `startingZoom`, there are other stage properties that you can set to adjust the camera in the stage:

- `cameraMovementEnabled`: A boolean that deternines whether the camera moves on its own.
- `extraCameraMovementAmount`: The distance the camera will move when hitting a note with the Dynamic Camera setting turned on. This does not scale with the stage zoom so you may want to adjust this to have the camera move more with zoomed out stages.
- `cameraStartPosition`: The point that the camera will focus on before the song starts. By default the camera will be placed half way between the player and opponent characters.
- `globalCameraOffset`: A global offset applied to the position of the camera no matter what it is focusing on.
- `bfCameraOffset`: An offset applied to the camera when it is focused on the player.
- `dadCameraOffset`: An offset applied to the camera when it is focused on the opponent.
- `gfCameraOffset`: An offset applied to the camera when it is focused on the GF character. 

## Other Stage Properties

There are a few other miscellaneous stage properties that can be set:

- `instantStart`: A boolean that determines whether there should be a countdown at the begining of the song. Note that *this will be overwritten* by any cutscene that is set on the song.

You can also set extra data with `addExtraData(key, data)` that isn't a part of normal stage properties:

- `forceCenteredNotes`: A boolean that forces the stage to used a centered strumline. Used in Blazin'.

## Advanced Stage Scripting

You can add stage specific events that can be charted in the Chart Editor but only work when this specific stage is selected. To do this you use `addEvent(prefix, function)` where:

- `prefix`: A string that will match to the begining of the event before any arguments.
- `function`: A `Void` function that takes a `String` as an argument. The argument is the event tag. You can use `Events.getArgs(tag)` to automatically separate the arguments out of the tag into a string array for easier interpretation.

Additionally, you can override different functions similarly to a generic script that get automatically called by `PlayState`:

- `postCreate()`: This is run after the stage and `PlayState` is finished being created.
- `update(elapsed)`: This is run every frame. Don't forget to call `super.update(elapsed)` to make sure the stage's update loop is still called.
    - `elapsed`: The time in seconds between this frame and the previous frame.
- `beat(curBeat)`: This is run every song beat.
    - `curBeat`: The current beat of the song as an integer.
- `countdownBeat(curBeat)`: This is run every beat of the intro countdown.
    - `curBeat`: The current part of the countdown as an integer.
- `step(curStep)`: This is run every step of the song.
    - `curStep`: The current step of the song as an integer.
- `songStart()`: This is run once the song starts playing.
- `pause()`: This is run whenever the game is paused.
- `unpause()`: This is run whenever the game is unpaused.
- `gameOverStart()`: This is run when the death screen is started.
- `gameOverLoop()`: This is run when the death screen starts the character's looping animation.
- `gameOverEnd()`: This is run when you continue from the death screen.
- `exit()`: This is run when exiting `PlayState`.
- `noteHit(character, note)`: This is run when a character hits a note.
    - `character`: The character object that hit the note. Will either be `boyfriend` or `dad`.
    - `note`: The note object that was just hit.
- `noteMiss(direction, countedMiss)`: This is run when exiting `PlayState`.
    - `direction`: The direction that the player missed in as an integer.
    - `countedMiss`: A boolean that will be `true` if the miss was counted or `false` if it wasn't (for things like wrong taps).

## Examples

Here is the basic stage from Week 1:

```haxe
import flixel.FlxSprite;

class Stage extends BaseStage
{

    public function new(){
		super();

        name = "stage";
		startingZoom = 1.1;

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image("week1/stageback"));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		addToBackground(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image("week1/stagefront"));
		stageFront.scale.set(1.1, 1.1);
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		addToBackground(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image("week1/stagecurtains"));
		stageCurtains.scale.set(0.9, 0.9);
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
		addToBackground(stageCurtains);
    }
}
```

And here is a more advanced stage. This is the stage from Week 3:

```haxe
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;

class Philly extends BaseStage
{

	var phillyCityLights:FlxSprite;
	var phillyCityLightsGlow:FlxSprite;

	var phillyTrain:FlxSprite;

	var trainSound:FlxSound;
	var unpauseSoundCheck:Bool = false;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var startedMoving:Bool = false;

	var windowColorIndex:Int = -1;
	var windowColors:Array<FlxColor> = [0x31A2FD, 0x31FD8C, 0xFB33F5, 0xFD4531, 0xFBA633];

    public function new(){
		super();

        name = "philly";
		startingZoom = 1.1;

		var bg:FlxSprite = new FlxSprite(-100, -20).loadGraphic(Paths.image('week3/philly/sky'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.1, 0.1);
		addToBackground(bg);

		var city:FlxSprite = new FlxSprite(-81, 52).loadGraphic(Paths.image('week3/philly/city'));
		city.scrollFactor.set(0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		city.antialiasing = true;
		addToBackground(city);

		phillyCityLights = new FlxSprite(city.x + (71 * 0.85), city.y - (52 * 0.85)).loadGraphic(Paths.image("week3/philly/windowWhite"));
		phillyCityLights.scrollFactor.set(0.3, 0.3);
		phillyCityLights.setGraphicSize(Std.int(phillyCityLights.width * 0.85));
		phillyCityLights.updateHitbox();
		phillyCityLights.antialiasing = true;
		addToBackground(phillyCityLights);

		phillyCityLightsGlow = new FlxSprite(phillyCityLights.x, phillyCityLights.y).loadGraphic(Paths.image("week3/philly/windowWhiteGlow"));
		phillyCityLightsGlow.scrollFactor.set(0.3, 0.3);
		phillyCityLightsGlow.setGraphicSize(Std.int(phillyCityLightsGlow.width * 0.85));
		phillyCityLightsGlow.updateHitbox();
		phillyCityLightsGlow.antialiasing = true;
		phillyCityLightsGlow.blend = ScriptingUtil.add;
		phillyCityLightsGlow.alpha = 0;
		addToBackground(phillyCityLightsGlow);

		changeLightColor();

		var streetBehind:FlxSprite = new FlxSprite(178, 50+97).loadGraphic(Paths.image('week3/philly/behindTrain'));
		streetBehind.antialiasing = true;
		addToBackground(streetBehind);

		phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('week3/philly/train'));
		phillyTrain.antialiasing = true;
		phillyTrain.visible = false;
		addToBackground(phillyTrain);

		trainSound = new FlxSound().loadEmbedded(Paths.sound('week3/train_passes'));
		FlxG.sound.list.add(trainSound);

		var street:FlxSprite = new FlxSprite(streetBehind.x-341, streetBehind.y-93).loadGraphic(Paths.image('week3/philly/street'));
		street.antialiasing = true;
		addToBackground(street);

		dadStart.set(450, 875);
		bfStart.x += 50;

		dadCameraOffset.set(-50, 0);
		bfCameraOffset.set(-100, 0);
    }

	public override function update(elapsed:Float){
		super.update(elapsed);

		if (trainMoving){
			trainFrameTiming += elapsed;

			if (trainFrameTiming >= 1 / 24){
				updateTrainPos();
				trainFrameTiming = 0;
			}
		}
	}

	public override function beat(curBeat){
		if (!trainMoving){
			trainCooldown += 1;
		}

		if (curBeat % 4 == 0){
			changeLightColor();
		}

		if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 12){
			trainCooldown = FlxG.random.int(0, 4);
			trainStart();
		}
	}

	public override function pause() {
		if(trainSound.playing){
			unpauseSoundCheck = true;
			trainSound.pause();
		}
	}

	public override function unpause() {
		if(unpauseSoundCheck){
			unpauseSoundCheck = false;
			trainSound.play(false);
		}
	}

	function changeLightColor(){
		windowColorIndex = FlxG.random.int(0, 4, [windowColorIndex]);
		phillyCityLights.color = windowColors[windowColorIndex];
		phillyCityLightsGlow.color = windowColors[windowColorIndex];
		FlxTween.cancelTweensOf(phillyCityLightsGlow);
		phillyCityLightsGlow.alpha = 0.9;
		FlxTween.tween(phillyCityLightsGlow, {alpha: 0}, (Conductor.crochet/1000) * 3.5, {ease: FlxEase.quadOut});
	}

	function trainStart():Void{
		trainMoving = true;
		trainSound.play(true);
	}

	function updateTrainPos():Void{
		if (trainSound.time >= 4700){
			startedMoving = true;
			gf.playAnim('hairBlow');
			phillyTrain.visible = true;
		}

		if (startedMoving){
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing){
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0){
					trainFinishing = true;
				}
			}

			if (phillyTrain.x < -4000 && trainFinishing){
				trainReset();
			}
		}
	}

	function trainReset():Void{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
		phillyTrain.visible = false;
	}
}
```