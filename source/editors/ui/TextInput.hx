package editors.ui;

import flixel.math.FlxMath;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

//TODO: make text scroll in the box and clip to the box bounds

class TextInput extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	static inline final CARET_VERTICAL_PADDING:Float = 2;
	static inline final CARET_BLINK_TIME:Float = 0.5;

	static inline final KEY_ENTER:Int = 13;
	static inline final KEY_BACKSPACE:Int = 8;
	static inline final KEY_DELETE:Int = 46;

	//Because of bitmap font thank you FlxText memory.
	static inline final ALLOWED_CHARACTERS:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!;%:?*_+-=.,/|\"'@#$^&(){}[] ";
	
	var box:Box;
	var inputText:UIText;

	var caret:FlxSprite;
	var caretTimer:Float = 0;

	var label:UIText;

	//Does not update until text entry is over.
	public var value:String;

	var inputtingText:Bool = false;
	var inputString:String;
	var inputIndex:Int = 0;

	public var onValueChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public function new(_x:Float, _y:Float, _width:Float, _initialValue:String, _label:String = ""){
		super(_x, _y);
		value = _initialValue;

		box = new Box(0, 0, _width, 24);
		box.fillColor = UIColors.INTERACTION_COLOR;
		box.onClick.add(function(){
			if(!inputtingText && manager.allowInteraction && manager.focused == null){
				startTextInput();
			}
			else if(inputtingText){
				inputIndex = Math.round(FlxMath.bound((FlxG.mouse.viewX - inputText.x)/UIText.X_ADVANCE, 0, inputString.length));
				resetCaret(true);
			}
		});

		inputText = new UIText(LABEL_PADDING, (box.height/2), value);
		inputText.y -= inputText.height/2;
		inputText.color = UIColors.INTERACTION_TEXT_COLOR;

		caret = Utils.makeColoredSprite(2, 24 - Box.BORDER_SIZE*2 - CARET_VERTICAL_PADDING*2, 0xFFFFFFFF);
		caret.setPosition(inputText.x + inputText.width, box.y + Box.BORDER_SIZE + CARET_VERTICAL_PADDING);
		caret.alpha = 0;
		caret.color = UIColors.INTERACTION_TEXT_COLOR; 

		label = new UIText(box.width + LABEL_PADDING, (box.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(inputText);
		add(caret);
		add(label);

		elementWidth = box.width;
		elementHeight = box.height;

		openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, keyPress);
	}

	override public function update(elapsed:Float):Void{
		if((FlxG.mouse.justPressed || FlxG.keys.anyJustPressed([ENTER])) && inputtingText && manager.allowInteraction && (!box.mouseOverlaps || FlxG.keys.anyJustPressed([ENTER]))){
			stopTextInput();
		}

		if(inputtingText){
			caretTimer += elapsed;
			if(caretTimer >= CARET_BLINK_TIME){
				caretTimer = 0;
				caret.alpha = 1 - caret.alpha;
			}
			inputText.text = inputString;

			if(FlxG.keys.anyJustPressed([LEFT])){
				inputIndex--;
				if(inputIndex < 0){ inputIndex = 0; }
				caret.alpha = 1;
				caretTimer = 0;
			}

			if(FlxG.keys.anyJustPressed([RIGHT])){
				inputIndex++;
				if(inputIndex > inputString.length){ inputIndex = inputString.length; }
				caret.alpha = 1;
				caretTimer = 0;
			}
		}

		updateCaretPositon();

		super.update(elapsed);
	}

	override function destroy() {
		openfl.Lib.current.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, keyPress);
		super.destroy();
	}

	inline function updateCaretPositon():Void{
		caret.x = inputText.x + (inputIndex * UIText.X_ADVANCE);
	}

	inline function resetCaret(shown:Bool = true):Void{
		caret.alpha = shown ? 1 : 0;
		caretTimer = 0;
	}

	function startTextInput():Void{
		trace("starting text input");
		inputtingText = true;
		manager.focused = this;
		resetCaret(true);
		inputString = value;
		inputIndex = value.length;
		updateCaretPositon();
	}

	function stopTextInput():Void{
		trace("stopping text input");
		inputtingText = false;
		manager.clearFocused();
		value = inputString;
		inputText.text = value;
		onValueChanged.dispatch(value);
		resetCaret(false);
	}

	function keyPress(e:openfl.events.KeyboardEvent):Void{
		if(!inputtingText) { return; }
		if(e.charCode <= 0){ return; }
		//trace(e.keyCode + "\t" + e.charCode + "\t" + String.fromCharCode(e.charCode));
		switch(e.keyCode){
			case KEY_ENTER:
			case KEY_BACKSPACE:
				if(inputIndex == 0){ return; }
				var start:String = inputString.substring(0, inputIndex-1);
				var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
				inputString = start + end;
				inputIndex--;
			case KEY_DELETE:
				if(inputIndex == inputString.length){ return; }
				var start:String = inputString.substring(0, inputIndex);
				var end:String = inputString.substring(inputIndex+1);
				inputString = start + end;
			default:
				var char:String = String.fromCharCode(e.charCode);
				if(!ALLOWED_CHARACTERS.contains(char)){ return; }
				var start:String = inputString.substring(0, inputIndex);
				var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
				inputString = start + char + end;
				inputIndex++;
		}
	}
}