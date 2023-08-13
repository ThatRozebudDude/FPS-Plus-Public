package stages;

import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class Philly extends BasicStage
{

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;

	var trainSound:FlxSound;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var startedMoving:Bool = false;

    public override function init(){
        name = 'philly';

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('week3/philly/sky'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.1, 0.1);
		addToBackground(bg);

		var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('week3/philly/city'));
		city.scrollFactor.set(0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		city.antialiasing = true;
		addToBackground(city);

		phillyCityLights = new FlxTypedGroup<FlxSprite>();
		addToBackground(phillyCityLights);

		for (i in 0...5)
		{
			var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('week3/philly/win' + i));
			light.scrollFactor.set(0.3, 0.3);
			light.visible = false;
			light.setGraphicSize(Std.int(light.width * 0.85));
			light.updateHitbox();
			light.antialiasing = true;
			phillyCityLights.add(light);
		}

		changeLightColor();

		var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('week3/philly/behindTrain'));
		streetBehind.antialiasing = true;
		addToBackground(streetBehind);

		phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('week3/philly/train'));
		phillyTrain.antialiasing = true;
		addToBackground(phillyTrain);

		trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		FlxG.sound.list.add(trainSound);

		var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('week3/philly/street'));
		street.antialiasing = true;
		addToBackground(street);
    }

	public override function update(elapsed:Float){
		if (trainMoving){
			trainFrameTiming += elapsed;

			if (trainFrameTiming >= 1 / 24){
				updateTrainPos();
				trainFrameTiming = 0;
			}
		}
	}

	public override function beat(curBeat){
		if (!trainMoving)
			trainCooldown += 1;

		if (curBeat % 4 == 0){
			changeLightColor();
		}

		if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
		{
			trainCooldown = FlxG.random.int(-4, 0);
			trainStart();
		}
	}


	function changeLightColor(){
		phillyCityLights.forEach(function(light:FlxSprite){
			light.visible = false;
		});

		var curLight = FlxG.random.int(0, phillyCityLights.length - 1);

		phillyCityLights.members[curLight].visible = true;
		// phillyCityLights.members[curLight].alpha = 1;
	}

	function trainStart():Void{
		trainMoving = true;
		if (!trainSound.playing){
			trainSound.play(true);
		}
	}

	function updateTrainPos():Void{
		if (trainSound.time >= 4700){
			startedMoving = true;
			gf().playAnim('hairBlow');
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
		gf().playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}
}