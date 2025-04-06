package objects;

import flixel.system.FlxAssets.FlxShader;
import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import shaders.*;

class ABot extends FlxTypedSpriteGroup<FlxSprite>
{

	public var system:AtlasSprite;
	public var eyes:AtlasSprite;
	public var eyeBack:FlxSprite;
	public var bg:FlxSprite;
	public var visualizer:ABotVisualizer;

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

	public function applyShader(shader:FlxShader):Void{
		switch(Type.getClass(shader)){
			case DropShadowShader:
				var dropShadowShader:DropShadowShader = cast(shader, DropShadowShader);
				var colorAdjustCopy = new AdjustColorShader(dropShadowShader.baseBrightness, dropShadowShader.baseHue, dropShadowShader.baseContrast, dropShadowShader.baseSaturation).shader;

				bg.shader = colorAdjustCopy;	
				eyeBack.shader = colorAdjustCopy;	
				eyes.shader = colorAdjustCopy;	
				system.shader = colorAdjustCopy;

			default:
				bg.shader = shader;	
				eyeBack.shader = shader;	
				eyes.shader = shader;	
				system.shader = shader;
		}
	}

}