package editors.ui;

import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;

using StringTools;

class Button extends UIElement
{

	var box:Box;
	var label:UIText;

	public var pressed:Bool = false;

	public var onPress:FlxSignal = new FlxSignal();

	public function new(_x:Float, _y:Float, _width:Float, _label:String = ""){
		super(_x, _y);

		box = new Box(0, 0, _width, 24);
		box.onClick.add(function(){ if(manager.allowInteraction && manager.focused == null){ buttonPressed(); } });

		label = new UIText(box.width/2, (box.height/2), _label);
		label.x -= label.width/2;
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(label);

		elementWidth = box.width;
		elementHeight = box.height;
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