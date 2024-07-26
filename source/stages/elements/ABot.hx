package stages.elements;

import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class ABot extends FlxTypedSpriteGroup<FlxSprite>
{

	var system:AtlasSprite;
	var eyes:AtlasSprite;
	var eyeBack:FlxSprite;
	var bg:FlxSprite;
	var visualizer:ABotVisualizer;

	public function new(x:Float, y:Float) {
		super(x, y);

		system = new AtlasSprite(0, 0, Paths.getTextureAtlas("weekend1/abot/abotSystem"));
		system.antialiasing = true;
		system.addFullAnimation("bop", 24, false);

		eyeBack = new FlxSprite(50, 250).makeGraphic(1, 1, 0xFFFFFFFF);
		eyeBack.scale.set(120, 50);
		eyeBack.updateHitbox();

		eyes = new AtlasSprite(-506, -494, Paths.getTextureAtlas("weekend1/abot/systemEyes"));
		eyes.antialiasing = true;
		eyes.addAnimationByFrame("lookLeft", 8, 6, 24);
		eyes.addAnimationByFrame("lookRight", 22, 6, 24);
		//8, 22

		bg = new FlxSprite(147, 31).loadGraphic(Paths.image("weekend1/abot/stereoBG"));
		bg.antialiasing = true;

		visualizer = new ABotVisualizer(null);
		visualizer.setPosition(203, 88);

		add(bg);
		add(eyeBack);
		add(eyes);
		add(visualizer);
		add(system);
	}

	public function setAudioSource(source:FlxSound):Void{
		visualizer.snd = source;
	}

	public function startVisualizer():Void{
		if(visualizer.snd != null){
			visualizer.initAnalyzer();
		}
	}

	public function bop():Void{
		system.playAnim("bop", true);
	}

	public function lookLeft():Void{
		eyes.playAnim("lookLeft", true);
	}

	public function lookRight():Void{
		eyes.playAnim("lookRight", true);
	}

	public function screenCenterAdjusted(axes:FlxAxes = XY):FlxObject{
		if (axes.x)
			x = (FlxG.width - system.width) / 2;

		if (axes.y)
			y = (FlxG.height - system.height) / 2;
	
		return this;
	}

}