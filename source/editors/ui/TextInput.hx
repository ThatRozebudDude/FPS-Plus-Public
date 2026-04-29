package editors.ui;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

//TODO: Make it so using volume binds doesn't cause the volume to change when inputting text.

class TextInput extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	static inline final CARET_VERTICAL_PADDING:Float = 2;
	static inline final CARET_BLINK_TIME:Float = 0.5;

	static inline final KEY_ENTER:Int = 13;
	static inline final KEY_BACKSPACE:Int = 8;
	static inline final KEY_DELETE:Int = 46;
	static inline final KEY_LEFT:Int = 37;
	static inline final KEY_RIGHT:Int = 39;

	//Because of bitmap font thank you FlxText memory.
	static inline final DEFAULT_ALLOWED_CHARACTERS:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!;%:?*_+-=.,/|\"'@#$^&(){}[] ";
	
	var box:Box;
	var inputText:UIText;
	var textShift:Int = 0;

	var caret:FlxSprite;
	var caretTimer:Float = 0;

	var label:UIText;

	//Does not update until text entry is over.
	public var value:String;

	var inputtingText:Bool = false;
	var inputString:String;
	var inputIndex:Int = 0;
	public var allowedCharacters:String = DEFAULT_ALLOWED_CHARACTERS;

	public var onValueChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public var allowTyping(default, set):Bool = true;

	public function new(_x:Float, _y:Float, _width:Float, _initialValue:String, _label:String = ""){
		super(_x, _y);
		value = _initialValue;

		box = new Box(0, 0, _width, 24);
		box.fillColor = UIColors.INTERACTION_COLOR;
		box.onClick.add(function(){
			if(!inputtingText && manager.allowInteraction && manager.focused == null && allowTyping){
				startTextInput();
			}
			else if(inputtingText){
				inputIndex = Math.round(FlxMath.bound((FlxG.mouse.viewX - inputText.x)/UIText.X_ADVANCE, 0, inputString.length));
				updateCaretPosition();
				resetCaret();
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

		openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, keyPress);

		elementWidth = box.width;
		elementHeight = box.height;
	}

	override public function update(elapsed:Float):Void{
		if(FlxG.mouse.justPressed && inputtingText && manager.allowInteraction && !box.mouseOverlaps){
			stopTextInput();
		}

		if(inputtingText){
			caretTimer += elapsed;
			if(caretTimer >= CARET_BLINK_TIME){
				caretTimer = 0;
				caret.alpha = 1 - caret.alpha;
			}
			inputText.text = inputString;
		}
		else{
			inputText.text = value;
		}

		updateTextPosition();
		updateCaretPosition();

		while(caret.x > box.x + box.width - Box.BORDER_SIZE){
			textShift++;
			updateTextPosition();
			updateCaretPosition();
		}
		while(caret.x < box.x + Box.BORDER_SIZE){
			textShift--;
			updateTextPosition();
			updateCaretPosition();
		}

		var rectPos = Utils.worldToLocal(inputText, box.x + Box.BORDER_SIZE, box.y + Box.BORDER_SIZE);
		inputText.clipRect = new FlxRect(rectPos.x/inputText.scale.x, rectPos.y/inputText.scale.x, (box.width - Box.BORDER_SIZE*2)/inputText.scale.x, (box.height - Box.BORDER_SIZE*2)/inputText.scale.y);

		super.update(elapsed);
	}

	override function destroy() {
		openfl.Lib.current.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, keyPress);
		super.destroy();
	}

	inline function updateTextPosition():Void{
		inputText.x = box.x + LABEL_PADDING - (UIText.X_ADVANCE * textShift);
	}

	inline function updateCaretPosition():Void{
		caret.x = inputText.x + (inputIndex * UIText.X_ADVANCE);
	}

	inline function resetCaret(shown:Bool = true):Void{
		caret.alpha = shown ? 1 : 0;
		caretTimer = 0;
	}

	function startTextInput():Void{
		inputtingText = true;
		manager.focused = this;
		resetCaret();
		inputString = value;
		inputIndex = value.length;
		updateCaretPosition();
	}

	function stopTextInput():Void{
		inputtingText = false;
		manager.clearFocused();
		value = inputString;
		onValueChanged.dispatch(value);
		resetCaret(false);
	}

	public function set_allowTyping(v:Bool):Bool{
		allowTyping = v;
		if(allowTyping){
			box.fillColor = UIColors.INTERACTION_COLOR;
			inputText.color = UIColors.INTERACTION_TEXT_COLOR;
		}
		else{
			box.fillColor = UIColors.FILL_COLOR;
			inputText.color = UIColors.FILL_TEXT_COLOR;
		}
		return v;
	}

	function keyPress(e:openfl.events.KeyboardEvent):Void{
		if(!inputtingText){ return; }
		if(e.keyCode <= 0){ return; }
		//trace(e.keyCode + "\t" + e.charCode + "\t" + String.fromCharCode(e.charCode));
		switch(e.keyCode){
			case KEY_ENTER:
				stopTextInput();
			case KEY_BACKSPACE:
				if(inputIndex == 0){ return; }
				var start:String = inputString.substring(0, inputIndex-1);
				var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
				inputString = start + end;
				inputIndex--;
				if(textShift > 0){ textShift--; }
				resetCaret();
			case KEY_DELETE:
				if(inputIndex == inputString.length){ return; }
				var start:String = inputString.substring(0, inputIndex);
				var end:String = inputString.substring(inputIndex+1);
				inputString = start + end;
				resetCaret();
			case KEY_LEFT:
				inputIndex--;
				if(inputIndex < 0){ inputIndex = 0; }
				resetCaret();
			case KEY_RIGHT:
				inputIndex++;
				if(inputIndex > inputString.length){ inputIndex = inputString.length; }
				resetCaret();
			default:
				var char:String = String.fromCharCode(e.charCode);
				if(!allowedCharacters.contains(char)){ return; }
				var start:String = inputString.substring(0, inputIndex);
				var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
				inputString = start + char + end;
				inputIndex++;
				resetCaret();
		}
	}
}