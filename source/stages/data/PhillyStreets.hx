package stages.data;

import openfl.filters.ShaderFilter;
import shaders.RainShader;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class PhillyStreets extends BaseStage
{
	var rainShader:RainShader;
	var rainInensityEnd:Float = 0;

	var dimSprite:FlxSprite;
	var kickedCan:AtlasSprite;
	var characterGlow:FlxSprite;

	var abot:ABot;
	var abotLookDir:Bool = false;

	var phillyTraffic:FlxSprite;
	var phillyCars:FlxSprite;
	var phillyCarsBack:FlxSprite;

	var lightsStop:Bool = false; // state of the traffic lights
	var lastChange:Int = 0;
	var changeInterval:Int = 8; // make sure it doesnt change until AT LEAST this many beats

	var carWaiting:Bool = false; // if the car is waiting at the lights and is ready to go on green
	var carInterruptable:Bool = true; // if the car can be reset
	var car2Interruptable:Bool = true;

    public override function init(){
        name = "phillyStreets";
        startingZoom = 0.75;

		var scrollingSky = new FlxBackdrop(Paths.image("weekend1/phillyStreets/phillySkybox"), X);
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);
		scrollingSky.velocity.x = -22;
		scrollingSky.antialiasing = true;
		addToBackground(scrollingSky);

		var phillySkyline = new FlxSprite(-545, -273).loadGraphic(Paths.image("weekend1/phillyStreets/phillySkyline"));
		phillySkyline.scrollFactor.set(0.2, 0.2);
		phillySkyline.antialiasing = true;
		addToBackground(phillySkyline);

		var phillyForegroundCity = new FlxSprite(625, 94).loadGraphic(Paths.image("weekend1/phillyStreets/phillyForegroundCity"));
		phillyForegroundCity.scrollFactor.set(0.3, 0.3);
		phillyForegroundCity.antialiasing = true;
		addToBackground(phillyForegroundCity);

		var phillyHighwayLights = new FlxSprite(284-400, 305).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighwayLights"));
		phillyHighwayLights.scrollFactor.set(0.7, 1);
		phillyHighwayLights.antialiasing = true;
		addToBackground(phillyHighwayLights);

		var phillyHighwayLights_lightmap = new FlxSprite(284-400, 305).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighwayLights_lightmap"));
		phillyHighwayLights_lightmap.scrollFactor.set(0.7, 1);
		phillyHighwayLights_lightmap.antialiasing = true;
		phillyHighwayLights_lightmap.blend = ADD;
		phillyHighwayLights_lightmap.alpha = 0.6;
		addToBackground(phillyHighwayLights_lightmap);

		var phillyHighway = new FlxSprite(139-400, 209).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighway"));
		phillyHighway.scrollFactor.set(0.7, 1);
		phillyHighway.antialiasing = true;
		addToBackground(phillyHighway);

		var phillyConstruction = new FlxSprite(1800, 364).loadGraphic(Paths.image("weekend1/phillyStreets/phillyConstruction"));
		phillyConstruction.scrollFactor.set(0.7, 1);
		phillyConstruction.antialiasing = true;
		addToBackground(phillyConstruction);

		var phillySmog = new FlxSprite(-6, 245).loadGraphic(Paths.image("weekend1/phillyStreets/phillySmog"));
		phillySmog.scrollFactor.set(0.8, 1);
		phillySmog.antialiasing = true;
		addToBackground(phillySmog);
		
		phillyCarsBack = new FlxSprite(1748, 818);
		phillyCarsBack.frames = Paths.getSparrowAtlas("weekend1/phillyStreets/phillyCars");
		phillyCarsBack.scrollFactor.set(0.9, 1);
		phillyCarsBack.antialiasing = true;
		phillyCarsBack.flipX = true;
		phillyCarsBack.animation.addByPrefix("car1", "car1", 0, false);
		phillyCarsBack.animation.addByPrefix("car2", "car2", 0, false);
		phillyCarsBack.animation.addByPrefix("car3", "car3", 0, false);
		phillyCarsBack.animation.addByPrefix("car4", "car4", 0, false);
		addToBackground(phillyCarsBack);

		phillyCars = new FlxSprite(1748, 818);
		phillyCars.frames = Paths.getSparrowAtlas("weekend1/phillyStreets/phillyCars");
		phillyCars.scrollFactor.set(0.9, 1);
		phillyCars.antialiasing = true;
		phillyCars.animation.addByPrefix("car1", "car1", 0, false);
		phillyCars.animation.addByPrefix("car2", "car2", 0, false);
		phillyCars.animation.addByPrefix("car3", "car3", 0, false);
		phillyCars.animation.addByPrefix("car4", "car4", 0, false);
		addToBackground(phillyCars);
		
		phillyTraffic = new FlxSprite(1840, 608);
		phillyTraffic.frames = Paths.getSparrowAtlas("weekend1/phillyStreets/phillyTraffic");
		phillyTraffic.scrollFactor.set(0.9, 1);
		phillyTraffic.antialiasing = true;
		phillyTraffic.animation.addByPrefix("togreen", "redtogreen", 24, false);
		phillyTraffic.animation.addByPrefix("tored", "greentored", 24, false);
		addToBackground(phillyTraffic);

		resetCar(true, true);

		var phillyHighwayLights_lightmap = new FlxSprite(1840, 608).loadGraphic(Paths.image("weekend1/phillyStreets/phillyTraffic_lightmap"));
		phillyHighwayLights_lightmap.scrollFactor.set(0.9, 1);
		phillyHighwayLights_lightmap.antialiasing = true;
		phillyHighwayLights_lightmap.blend = ADD;
		phillyHighwayLights_lightmap.alpha = 0.6;
		addToBackground(phillyHighwayLights_lightmap);

		var phillyForeground = new FlxSprite(88, 317).loadGraphic(Paths.image("weekend1/phillyStreets/phillyForeground"));
		phillyForeground.antialiasing = true;
		addToBackground(phillyForeground);

		dimSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		dimSprite.scale.set(1280/.5, 720/.5);
		dimSprite.updateHitbox();
		dimSprite.screenCenter(XY);
		dimSprite.scrollFactor.set();
		dimSprite.alpha = 0;
		addToBackground(dimSprite);

		characterGlow = new FlxSprite();
		characterGlow.visible = false;
		addToMiddle(characterGlow);

		var spraycanPile = new FlxSprite(920, 1045).loadGraphic(Paths.image("weekend1/phillyStreets/SpraycanPile"));
		spraycanPile.antialiasing = true;
		addToForeground(spraycanPile);

		kickedCan = new AtlasSprite(spraycanPile.x - 430, spraycanPile.y - 840, Paths.getTextureAtlas("weekend1/spraycanAtlas"));
		kickedCan.antialiasing = true;
		kickedCan.visible = false;
		kickedCan.addAnimationByLabel("start", "Can Start", 24, false);
		kickedCan.addAnimationByFrame("kickUp", 0, 8, 24, false);
		kickedCan.addAnimationByFrame("kickUpSlow", 0, 8, 17, false);
		kickedCan.addAnimationByFrame("kickForward", 8, 11, 24, false);
		kickedCan.addAnimationByLabel("hit", "Hit Pico", 24, false);
		kickedCan.addAnimationByLabel("shot", "Can Shot", 24, false);
		kickedCan.animationEndCallback = function(name) {
			if(name == "hit" || name == "shot"){
				kickedCan.visible = false;
			}
		}
		addToForeground(kickedCan);

		bfStart.set(2151, 1228);
		dadStart.set(900, 1110);
		gfStart.set(1453, 900);

		bfCameraOffset.set(-390, 0);

		abot = new ABot(gfStart.x - 365, gfStart.y - 165);
		abot.lookLeft();
		addToBackground(abot);

		gf().scrollFactor.set(1, 1);

		rainShader = new RainShader(0, FlxG.height / 200);
		playstate().camGame.filters = [new ShaderFilter(rainShader.shader)];
		addToUpdate(rainShader);

		switch(PlayState.SONG.song.toLowerCase()){
			case "darnell":
				rainShader.uIntensity = 0;
				rainInensityEnd = 0.1;
			case "2hot":
				rainShader.uIntensity = 0.2;
				rainInensityEnd = 0.3;
			default:
				rainShader.uIntensity = 0.1;
				rainInensityEnd = 0.2;
		}

		addEvent("phillyStreets-stageDarken", stageDarken);
		addEvent("phillyStreets-canKick", canKick);
		addEvent("phillyStreets-canKickSlow", canKickSlow);
		addEvent("phillyStreets-canKickForward", canKickForward);
		addEvent("phillyStreets-canHit", canHit);
		addEvent("phillyStreets-canShot", canShot);
		addEvent("phillyStreets-playerGlow", createCharacterGlow);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if(playstate().camFocus == "dad" && abotLookDir){
			abotLookDir = !abotLookDir;
			abot.lookLeft();
		}
		else if(playstate().camFocus == "bf" && !abotLookDir){
			abotLookDir = !abotLookDir;
			abot.lookRight();
		}
	}

	override function songStart() {
		abot.setAudioSource(FlxG.sound.music);
		abot.startVisualizer();
		tween().tween(rainShader, {uIntensity: rainInensityEnd}, FlxG.sound.music.length/1000);
	}

	override function beat(curBeat:Int) {
		abot.bop();

		// Try driving a car when its possible
		if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true){
			if(lightsStop == false){
				driveCar(phillyCars);
			}
			else{
				driveCarLights(phillyCars);
			}
		}
	
		// try driving one on the right too. in this case theres no red light logic, it just can only spawn on green lights
		if(FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false) driveCarBack(phillyCarsBack);
	
		// After the interval has been hit, change the light state.
		if (curBeat == (lastChange + changeInterval)) changeLights(curBeat);
	}

	public function stageDarken():Void{
		tween().cancelTweensOf(dimSprite);
		dimSprite.alpha = 0.75;
		tween().tween(dimSprite, {alpha: 0}, 1, {startDelay: 0.2});
	}

	public function canKick():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("kickUp");
	}
	
	public function canKickSlow():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("kickUpSlow");
	}

	public function canKickForward():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("kickForward");
	}

	public function canHit():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("hit");
	}

	public function canShot():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("shot");
	}

	public function createCharacterGlow():Void{
		tween().cancelTweensOf(characterGlow);
		tween().cancelTweensOf(characterGlow.scale);

		characterGlow.loadGraphicFromSprite(boyfriend().getSprite());
		characterGlow.setPosition(boyfriend().getSprite().x, boyfriend().getSprite().y);
		characterGlow.scale.set(boyfriend().getScale().x, boyfriend().getScale().y);
		characterGlow.antialiasing = boyfriend().getAntialising();
		characterGlow.visible = true;
		characterGlow.alpha = 0.3;

		tween().tween(characterGlow.scale, {x: characterGlow.scale.x * 1.4, y: characterGlow.scale.y * 1.4}, (Conductor.crochet / 1000), {ease: FlxEase.quadOut});
		tween().tween(characterGlow, {alpha: 0}, ((Conductor.crochet / 1000) / 2), {startDelay: ((Conductor.crochet / 1000) / 2)});
	}

	//car code basically just taken from base game, ily fabs

	/**
 	* Changes the current state of the traffic lights.
	* Updates the next change accordingly and will force cars to move when ready
  	*/
  	function changeLights(beat:Int):Void{

		lastChange = beat;
		lightsStop = !lightsStop;

		if(lightsStop){
			phillyTraffic.animation.play('tored');
			changeInterval = 20;
		} else {
			phillyTraffic.animation.play('togreen');
			changeInterval = 30;

			if(carWaiting == true) finishCarLights(phillyCars);
		}
	}

	/**
	* Resets every value of a car and hides it from view.
	*/
	function resetCar(left:Bool, right:Bool){
		if(left){
			carWaiting = false;
			carInterruptable = true;
			if (phillyCars != null) {
				tween().cancelTweensOf(phillyCars);
				phillyCars.x = 1200;
				phillyCars.y = 818;
				phillyCars.angle = 0;
			}
		}

		if(right){
			car2Interruptable = true;
			if (phillyCarsBack != null) {
				tween().cancelTweensOf(phillyCarsBack);
				phillyCarsBack.x = 1200;
				phillyCarsBack.y = 818;
				phillyCarsBack.angle = 0;
			}
		}
	}

	/**
  	* Drive the car away from the lights to the end of the road.
	* Used when the lights turn green and the car is waiting in position.
  	*/
	function finishCarLights(sprite:FlxSprite):Void{
		carWaiting = false;
		var duration:Float = FlxG.random.float(1.8, 3);
		var rotations:Array<Int> = [-5, 18];
		var offset:Array<Float> = [306.6, 168.3];
		var startdelay:Float = FlxG.random.float(0.2, 1.2);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		tween().angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay} );
		tween().quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.sineIn,
			startDelay: startdelay,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	/**
	* Drives a car towards the lights and stops.
	* Used when a car tries to drive while the lights are red.
	*/
	function driveCarLights(sprite:FlxSprite):Void{
		carInterruptable = false;
		tween().cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;

		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.9, 1.5);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		
		var rotations:Array<Int> = [-7, -5];
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
			FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
		];
		// debug shit!!! keeping it here just in case
		// for(point in path){
		// 	var debug:FlxSprite = new FlxSprite(point.x - 5, point.y - 5).makeGraphic(10, 10, 0xFFFF0000);
		// 	add(debug);
		// }
		tween().angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut} );
		tween().quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				carWaiting = true;
				if(lightsStop == false) finishCarLights(phillyCars);
			}
		});
	}

	/**
	* Drives a car across the screen without stopping.
	* Used when the lights are green.
	*/
	function driveCar(sprite:FlxSprite):Void{
		carInterruptable = false;
		tween().cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		// setting an offset here because the current implementation of stage prop offsets was not working at all for me
		// if possible id love to not have to do this but im keeping this for now
		var extraOffset = [0, 0];
		var duration:Float = 2;
		// set different values of speed for the car types (and the offset)
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		// random arbitrary values for getting the cars in place
		// could just add them to the points but im LAZY!!!!!!
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		// start/end rotation
		var rotations:Array<Int> = [-8, 18];
		// the path to move the car on
		var path:Array<FlxPoint> = [
			FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		tween().angle(sprite, rotations[0], rotations[1], duration, null );
		tween().quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarBack(sprite:FlxSprite):Void{
		car2Interruptable = false;
		tween().cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		// setting an offset here because the current implementation of stage prop offsets was not working at all for me
		// if possible id love to not have to do this but im keeping this for now
		var extraOffset = [0, 0];
		var duration:Float = 2;
		// set different values of speed for the car types (and the offset)
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		// random arbitrary values for getting the cars in place
		// could just add them to the points but im LAZY!!!!!!
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		// start/end rotation
		var rotations:Array<Int> = [18, -8];
		// the path to move the car on
		var path:Array<FlxPoint> = [
				FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
				FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
				FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)

		];

		tween().angle(sprite, rotations[0], rotations[1], duration, null );
		tween().quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				car2Interruptable = true;
			}
		});
	}
}