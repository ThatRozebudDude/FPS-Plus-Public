package editors.ui;

import flixel.math.FlxMath;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

//TODO: MAKE IT WORK BECAUSE IT DOES NOTHING RIGHT NOW

class TextInput extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	
	var box:Box;
	var inputText:UIText;

	var label:UIText;

	public var value:String;

	var inputingText:Bool = false;
	var inputString:String;

	public var onValueChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public function new(_x:Float, _y:Float, _width:Float, _initialValue:String, _label:String = ""){
		super(_x, _y);
		value = _initialValue;

		box = new Box(0, 0, _width, 24);
		box.fillColor = UIColors.INTERACTION_COLOR;
		box.onClick.add(function(){
			if(!inputingText && manager.allowInteraction && manager.focused == null){ startTextInput(); }
		});

		inputText = new UIText(LABEL_PADDING, (box.height/2), value);
		inputText.y -= inputText.height/2;
		inputText.color = UIColors.INTERACTION_TEXT_COLOR;

		label = new UIText(box.width + LABEL_PADDING, (box.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(inputText);
		add(label);

		elementWidth = box.width;
		elementHeight = box.height;
	}

	override public function update(elapsed:Float):Void{
		if((FlxG.mouse.justPressed || FlxG.keys.anyJustPressed([ENTER])) && inputingText && manager.allowInteraction && (!box.mouseOverlaps || FlxG.keys.anyJustPressed([ENTER]))){
			stopTextInput();
		}

		super.update(elapsed);
	}

	function startTextInput():Void{
		trace("starting text input");
		inputingText = true;
		manager.focused = this;
	}

	function stopTextInput():Void{
		trace("stopping text input");
		inputingText = false;
		manager.clearFocused();
		onValueChanged.dispatch(value);
	}

}