package stages.data;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import stages.elements.*;

class PhillyStreets extends BaseStage
{

    public override function init(){
        name = "phillyStreets";
        startingZoom = 0.77;

		var scrollingSky = new FlxBackdrop(Paths.image("weekend1/phillyStreets/phillySkybox"), X);
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);
		scrollingSky.updateHitbox();
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
		
		var phillyConstruction = new FlxSprite(1800, 364).loadGraphic(Paths.image("weekend1/phillyStreets/phillyConstruction"));
		phillyConstruction.scrollFactor.set(0.7, 1);
		phillyConstruction.antialiasing = true;
		addToBackground(phillyConstruction);

		var phillyHighwayLights = new FlxSprite(284, 305).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighwayLights"));
		phillyHighwayLights.antialiasing = true;
		addToBackground(phillyHighwayLights);

		var phillyHighwayLights = new FlxSprite(284, 305).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighwayLights"));
		phillyHighwayLights.antialiasing = true;
		addToBackground(phillyHighwayLights);

		var phillyHighwayLights_lightmap = new FlxSprite(284, 305).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighwayLights_lightmap"));
		phillyHighwayLights_lightmap.antialiasing = true;
		phillyHighwayLights_lightmap.blend = ADD;
		phillyHighwayLights_lightmap.alpha = 0.6;
		addToBackground(phillyHighwayLights_lightmap);

		var phillyHighway = new FlxSprite(139, 209).loadGraphic(Paths.image("weekend1/phillyStreets/phillyHighway"));
		phillyHighway.antialiasing = true;
		addToBackground(phillyHighway);

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

		var spraycanPile = new FlxSprite(920, 1045).loadGraphic(Paths.image("weekend1/SpraycanPile"));
		spraycanPile.antialiasing = true;
		addToForeground(spraycanPile);
		
		bfStart.set(2151, 1228);
		dadStart.set(940, 1310);
		gfStart.set(1453, 900);

		gf().scrollFactor.set(1, 1);
		gf().visible = false;
    }
}