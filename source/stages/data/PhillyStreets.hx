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
	var allowAbotInit:Bool = false;
	var abotInit:Bool = false;

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
		
		//cars
		
		var phillyTraffic = new FlxSprite(1840, 608);
		phillyTraffic.frames = Paths.getSparrowAtlas("weekend1/phillyStreets/phillyTraffic");
		phillyTraffic.scrollFactor.set(0.9, 1);
		phillyTraffic.antialiasing = true;
		phillyTraffic.animation.addByPrefix("togreen", "redtogreen", 24, false);
		phillyTraffic.animation.addByPrefix("tored", "greentored", 24, false);
		addToBackground(phillyTraffic);

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
		dimSprite.scale.set(1280/startingZoom, 720/startingZoom);
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
		kickedCan.addAnimationByLabel("hit", "Hit Pico", 24, false);
		kickedCan.addAnimationByLabel("shot", "Can Shot", 24, false);
		kickedCan.animationEndCallback = function(name) {
			if(name != "start"){
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

		if(FlxG.sound.music != null && FlxG.sound.music.playing && allowAbotInit && !abotInit){
			abot.setAudioSource(FlxG.sound.music);
			abot.startVisualizer();
			abotInit = true;
		}
	}

	override function beat(curBeat:Int) {
		if(curBeat == 0){
			new FlxTimer().start(1/24, function(t) {
				allowAbotInit = true;

				//tween rain intensity
				tween().tween(rainShader, {uIntensity: rainInensityEnd}, FlxG.sound.music.length/1000);
			});
		}

		abot.bop();
	}

	public function stageDarken():Void{
		tween().cancelTweensOf(dimSprite);
		dimSprite.alpha = 0.75;
		tween().tween(dimSprite, {alpha: 0}, 1, {startDelay: 0.2});
	}

	public function canKick():Void{
		kickedCan.visible = true;
		kickedCan.playAnim("start");
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
}