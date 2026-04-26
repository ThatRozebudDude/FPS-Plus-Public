package editors.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxAxes;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;
import extensions.flixel.FlxTextExt;
import editors.ui.Box;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import shaders.UIBoxShader;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Button extends FlxTypedSpriteGroup<FlxSprite>
{

	var box:Box;
	var label:FlxBitmapText;

	public var pressed:Bool = false;

	public var onPress:FlxSignal = new FlxSignal();

	public function new(_x:Float, _y:Float, _width:Float, _label:String = ""){
		super(_x, _y);

		box = new Box(0, 0, _width, 24);
		box.onClick.add(function(){ buttonPressed(); });

		label = new FlxBitmapText(box.width/2, box.height/2, _label, FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		label.x -= label.width/2;
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(label);
	}

	override public function update(elapsed:Float):Void{
		if(pressed && !FlxG.mouse.pressed){
			pressed = false;
			box.fillColor = UIColors.FILL_COLOR;
			label.color = UIColors.FILL_TEXT_COLOR;
		}
		super.update(elapsed);
	}

	function buttonPressed():Void{
		pressed = true;
		box.fillColor = UIColors.SELECTED_COLOR;
		label.color = UIColors.SELECTED_TEXT_COLOR;
		onPress.dispatch();
	}
	
}