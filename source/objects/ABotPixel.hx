package objects;

import flixel.system.FlxAssets.FlxShader;
import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import shaders.*;

class ABotPixel extends FlxTypedSpriteGroup<FlxSprite>
{

	public var head:FlxSprite;
	public var body:FlxSprite;
	public var speaker:FlxSprite;
	public var back:FlxSprite;
	public var visualizer:ABotVisualizer;

	public function new(x:Float, y:Float) {
		super(x, y);

		head = new FlxSprite(-325, 72);
		head.frames = Paths.getSparrowAtlas("week6/abot/abotHead");
		head.scale.set(6, 6);
		head.antialiasing = false;
		head.animation.addByPrefix("lookLeft", "toleft", 24, false);
		head.animation.addByPrefix("lookRight", "toright", 24, false);

		body = new FlxSprite(0, 0);
		body.frames = Paths.getSparrowAtlas("week6/abot/aBotPixelBody");
		body.scale.set(6, 6);
		body.origin.x = Math.round(body.origin.x);
		body.origin.y = Math.round(body.origin.y);
		body.antialiasing = false;
		//body.x = this.x;
		//body.y = this.y;
		body.animation.addByPrefix("bop", "danceLeft", 24, false);

		speaker = new FlxSprite(-78, 9);
		speaker.frames = Paths.getSparrowAtlas("week6/abot/aBotPixelSpeaker");
		speaker.scale.set(6, 6);
		speaker.origin.x = Math.round(speaker.origin.x);
		speaker.origin.y = Math.round(speaker.origin.y);
		speaker.antialiasing = false;
		//speaker.x = this.x;
		//speaker.y = this.y;
		speaker.animation.addByPrefix("bop", "danceLeft", 24, false);

		back = new FlxSprite(-55, 0).loadGraphic(Paths.image("week6/abot/aBotPixelBack"));
		back.scale.set(6, 6);
		back.antialiasing = false;
		//back.x = this.x;
		//back.y = this.y;

		visualizer = new ABotVisualizer(null, true);
		visualizer.setPosition(this.x - 160 - 298, this.y + 13 - 421);

		add(speaker);
		add(back);
		add(visualizer);
		add(body);
		add(head);
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
		speaker.animation.play("bop", true);
		body.animation.play("bop", true);
	}

	public function lookLeft():Void{
		head.animation.play("lookLeft", true);
	}

	public function lookRight():Void{
		head.animation.play("lookRight", true);
	}

	public function screenCenterAdjusted(axes:FlxAxes = XY):FlxObject{
		if (axes.x)
			x = (FlxG.width - body.width) / 2;

		if (axes.y)
			y = (FlxG.height - body.height) / 2;
	
		return this;
	}

	public function applyShader(shader:FlxShader):Void{

		switch(Type.getClass(shader)){
			case DropShadowShader:
				var dropShadowShader:DropShadowShader = cast(shader, DropShadowShader);
				var colorAdjustCopy = new AdjustColorShader(dropShadowShader.baseBrightness, dropShadowShader.baseHue, dropShadowShader.baseContrast, dropShadowShader.baseSaturation).shader;

				head.shader = colorAdjustCopy;	
				body.shader = colorAdjustCopy;	
				speaker.shader = colorAdjustCopy;	
				back.shader = colorAdjustCopy;

			default:
				head.shader = shader;	
				body.shader = shader;	
				speaker.shader = shader;	
				back.shader = shader;	
		}
	}

}