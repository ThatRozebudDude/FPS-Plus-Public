package editors.ui;

import flixel.util.FlxColor;
import shaders.UIBoxShader;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import flixel.FlxG;

using StringTools;

class Box extends FlxSliceSprite
{

	public static inline var BORDER_SIZE:Int = 2;

	var boxShader:UIBoxShader;
	public var fillColor(default, set):FlxColor;
	public var borderColor(default, set):FlxColor;

	public var mouseOverlaps:Bool = false;
	public var onOverlap:FlxSignal = new FlxSignal();
	public var onOverlapStop:FlxSignal = new FlxSignal();
	public var onClick:FlxSignal = new FlxSignal();
	public var onRightClick:FlxSignal = new FlxSignal();
	public var onMiddleClick:FlxSignal = new FlxSignal();

	public function new(_x:Float, _y:Float, _width:Float, _height:Float){
		super(Paths.image("fpsPlus/editors/shared/box"), new FlxRect(2, 2, 256-4, 256-4), _width, _height);
		setPosition(_x, _y);
		stretchCenter = true;
		antialiasing = false;

		boxShader = new UIBoxShader(2, UIColors.FILL_COLOR, UIColors.BORDER_COLOR);
		fillColor = UIColors.FILL_COLOR;
		borderColor = UIColors.BORDER_COLOR;
		shader = boxShader.shader;
	}

	override public function update(elapsed:Float):Void{
		if(FlxG.mouse.overlaps(this) && visible && isMouseOverCenter()){
			if(!mouseOverlaps){
				mouseOverlaps = true;
				onOverlap.dispatch();
			}
			if(FlxG.mouse.justPressed){ onClick.dispatch(); }
			if(FlxG.mouse.justPressedRight){ onRightClick.dispatch(); }
			if(FlxG.mouse.justPressedMiddle){ onMiddleClick.dispatch(); }
		}
		else{
			if(mouseOverlaps){
				mouseOverlaps = false;
				onOverlapStop.dispatch();
			}
		}
		super.update(elapsed);
	}

	function set_fillColor(v:FlxColor):FlxColor{
		fillColor = v;
		boxShader.fillColor = fillColor;
		return fillColor;
	}

	function set_borderColor(v:FlxColor):FlxColor{
		borderColor = v;
		boxShader.borderColor = borderColor;
		return borderColor;
	}

	inline function isMouseOverCenter():Bool{
		return FlxG.mouse.viewX >= x + BORDER_SIZE && FlxG.mouse.viewX < x + width - BORDER_SIZE && FlxG.mouse.viewY >= y + BORDER_SIZE && FlxG.mouse.viewY < y + height - BORDER_SIZE;
	}
	
}