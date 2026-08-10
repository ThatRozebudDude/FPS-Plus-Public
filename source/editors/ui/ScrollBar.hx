package editors.ui;

import editors.ui.Box;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxSignal;

using StringTools;

class ScrollBar extends UIElement
{

	var grabBox:Box;
	var backBar:Box;

	public var allowGrabbing:Bool = true;
	public var grabbing:Bool = false;

	public var value(default, set):Float = 0;
	var vertical:Bool = true;

	public var onGrab:FlxSignal = new FlxSignal();
	public var onValueChanged:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();
	public var onRelease:FlxSignal = new FlxSignal();

	public function new(_x:Float, _y:Float, _length:Float, _initialValue:Float, _vertical:Bool){
		super(_x, _y);
		vertical = _vertical;

		backBar = new Box(0, 0, vertical ? 12 : _length, vertical ? _length : 12);

		grabBox = new Box(vertical ? backBar.x - 6 : backBar.x, vertical ? backBar.y : backBar.y - 6, 24, 24);
		grabBox.fillColor = UIColors.INTERACTION_COLOR;
		grabBox.onClick.add(function(){
			if(allowGrabbing){
				grabbing = true;
				grabBox.fillColor = UIColors.SELECTED_COLOR;
				onGrab.dispatch();
			}
		});

		add(backBar);
		add(grabBox);

		value = _initialValue;
		elementWidth = backBar.width;
		elementHeight = backBar.height;
	}

	override public function update(elapsed:Float):Void{
		if(grabbing){
			if(FlxG.mouse.justReleased || !allowGrabbing){
				grabbing = false;
				grabBox.fillColor = UIColors.INTERACTION_COLOR;
				onRelease.dispatch();
			}
			else{
				setValueBasedOnMousePosition();
				onValueChanged.dispatch(value);
			}
		}
		super.update(elapsed);
	}

	function setValueBasedOnMousePosition():Void{
		if(vertical){
			value = FlxMath.bound(((FlxG.mouse.viewY - 12) - backBar.y) / ((elementHeight - 24)), 0, 1);
		}
		else{
			value = FlxMath.bound(((FlxG.mouse.viewX - 12) - backBar.x) / ((elementWidth - 24)), 0, 1);
		}
	}

	public function set_value(v:Float):Float{
		value = v;

		if(vertical){
			grabBox.y = backBar.y + FlxMath.bound((value * (elementHeight - 24)), 0, elementHeight - 24);
		}
		else{
			grabBox.x = backBar.x + FlxMath.bound((value * (elementWidth - 24)), 0, elementWidth - 24);
		}
		
		return value;
	}

}