package editors.ui;

import flixel.math.FlxMath;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Stepper extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	
	var textInput:TextInput;

	var plusBox:Box;
	var plusSymbol:FlxSprite;

	var minusBox:Box;
	var minusSymbol:FlxSprite;

	var label:UIText;

	public var value:Float = 0;
	public var stepSize:Float = 1;
	var min:Null<Float> = null;
	var max:Null<Float> = null;

	public var onValueChanged:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	public function new(_x:Float, _y:Float, _width:Float, _initialValue:Float, _stepSize:Float, _min:Null<Float> = null, _max:Null<Float> = null, _allowTyping:Bool = true, _label:String = ""){
		super(_x, _y);
		value = _initialValue;
		stepSize = _stepSize;
		min = _min;
		max = _max;

		textInput = new TextInput(0, 0, _width - 44, ""+value);
		textInput.allowTyping = _allowTyping;
		textInput.allowedCharacters = "0123456789.";
		textInput.onValueChanged.add(function(v:String){
			var parsed:Float = Std.parseFloat(v);
			if(!Math.isNaN(parsed)){
				value = Std.parseFloat(v);
				value = FlxMath.bound(value, min, max);
			}
			updateNumberLabel();
		});

		plusBox = new Box(textInput.x + _width - 24, 0, 24, 24);
		plusBox.fillColor = UIColors.INTERACTION_COLOR;
		plusBox.onClick.add(function(){
			if(manager.allowInteraction && manager.focused == null){ 
				value += stepSize;
				value = FlxMath.bound(value, min, max);
				updateNumberLabel();
				plusBox.fillColor = UIColors.SELECTED_COLOR;
				plusSymbol.color = UIColors.SELECTED_TEXT_COLOR;
				onValueChanged.dispatch(value);
			}
		});

		minusBox = new Box(plusBox.x + Box.BORDER_SIZE - 24, 0, 24, 24);
		minusBox.fillColor = UIColors.INTERACTION_COLOR;
		minusBox.onClick.add(function(){
			if(manager.allowInteraction && manager.focused == null){ 
				value -= stepSize;
				value = FlxMath.bound(value, min, max);
				updateNumberLabel();
				minusBox.fillColor = UIColors.SELECTED_COLOR;
				minusSymbol.color = UIColors.SELECTED_TEXT_COLOR;
				onValueChanged.dispatch(value);
			}
		});

		plusSymbol = new FlxSprite(plusBox.x, plusBox.y).loadGraphic(Paths.image("fpsPlus/editors/shared/stepperSymbol"), true, 24, 24);
		plusSymbol.antialiasing = false;
		plusSymbol.animation.add("plus", [0], 0, false);
		plusSymbol.animation.play("plus");
		plusSymbol.color = UIColors.INTERACTION_TEXT_COLOR;

		minusSymbol = new FlxSprite(minusBox.x, minusBox.y).loadGraphic(Paths.image("fpsPlus/editors/shared/stepperSymbol"), true, 24, 24);
		minusSymbol.antialiasing = false;
		minusSymbol.animation.add("minus", [1], 0, false);
		minusSymbol.animation.play("minus");
		minusSymbol.color = UIColors.INTERACTION_TEXT_COLOR;

		label = new UIText(textInput.x + _width + LABEL_PADDING, (textInput.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(textInput);
		add(plusBox);
		add(minusBox);
		add(plusSymbol);
		add(minusSymbol);
		add(label);

		elementWidth = _width;
		elementHeight = textInput.height;
	}

	override public function update(elapsed:Float):Void{
		if(FlxG.mouse.released){
			plusBox.fillColor = UIColors.INTERACTION_COLOR;
			minusBox.fillColor = UIColors.INTERACTION_COLOR;
			plusSymbol.color = UIColors.INTERACTION_TEXT_COLOR;
			minusSymbol.color = UIColors.INTERACTION_TEXT_COLOR;
		}
		super.update(elapsed);
	}

	override function set_manager(v:UIManager):UIManager{
		if(textInput != null){ textInput.manager = v; }
		return super.set_manager(v);
	}

	function updateNumberLabel():Void{
		textInput.value = ""+value;
	}

}