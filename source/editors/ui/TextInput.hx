package editors.ui;

import editors.ui.Box;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxSignal;

using StringTools;

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

	//The characters that are used to break up chunks of text.
	static inline final DELIMITERS:String = ".!?,;:()[]{}-_/ ";
	
	//The amount of time you are locked out of extending the selection box out of the side of the box.
	static inline final SHIFT_LOCK_TIME:Float = 1/24;
	
	var box:Box;
	var inputText:UIText;
	var textShift:Int = 0;

	var caret:FlxSprite;
	var caretTimer:Float = 0;
	
	var selectionBox:FlxSprite;

	var label:UIText;

	//Does not update until text entry is over.
	public var value:String;

	var inputtingText:Bool = false;
	var inputString:String;
	var inputIndex:Int = 0;
	var inputLength:Int = 0;
	var allowDragSelect:Bool = false;
	var shiftLockTimer:Float = 0;

	public var allowedCharacters:String = DEFAULT_ALLOWED_CHARACTERS;

	public var onValueChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	public var onCopyText:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	public var onPasteText:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	public var onCutText:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public static var onCopyTextGlobal:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	public static var onPasteTextGlobal:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	public static var onCutTextGlobal:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

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
				inputIndex = getCharacterIndexUnderMouse();
				inputLength = 0;
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

		selectionBox = Utils.makeColoredSprite(0, 24 - Box.BORDER_SIZE*2 - CARET_VERTICAL_PADDING*2, 0xFFFFFFFF);
		selectionBox.setPosition(inputText.x + inputText.width, box.y + Box.BORDER_SIZE + CARET_VERTICAL_PADDING);
		selectionBox.color = UIColors.SELECTED_COLOR; 

		label = new UIText(box.width + LABEL_PADDING, (box.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(selectionBox);
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
		updateSelectionBox();

		while(caret.x > box.x + box.width - Box.BORDER_SIZE){
			textShift++;
			updateTextPosition();
			updateCaretPosition();
			updateSelectionBox();
			if(FlxG.mouse.pressed && allowDragSelect){ shiftLockTimer = SHIFT_LOCK_TIME; }
		}
		while(caret.x < box.x + Box.BORDER_SIZE){
			textShift--;
			updateTextPosition();
			updateCaretPosition();
			updateSelectionBox();
			if(FlxG.mouse.pressed && allowDragSelect){ shiftLockTimer = SHIFT_LOCK_TIME; }
		}

		super.update(elapsed);

		if(inputtingText){
			if(FlxG.mouse.pressed && allowDragSelect && shiftLockTimer <= 0){
				inputLength = getCharacterIndexUnderMouse() - inputIndex;
			}
			else if(!FlxG.mouse.pressed && !allowDragSelect){
				allowDragSelect = true;
			}
		}

		shiftLockTimer = shiftLockTimer > 0 ? shiftLockTimer - elapsed : 0;

		final rectPos = Utils.worldToLocal(inputText, box.x + Box.BORDER_SIZE, box.y + Box.BORDER_SIZE);
		inputText.clipRect = new FlxRect(rectPos.x/inputText.scale.x, rectPos.y/inputText.scale.y, (box.width - Box.BORDER_SIZE*2)/inputText.scale.x, (box.height - Box.BORDER_SIZE*2)/inputText.scale.y);
	}

	override function destroy() {
		openfl.Lib.current.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, keyPress);
		super.destroy();
	}

	inline function updateTextPosition():Void{
		inputText.x = box.x + LABEL_PADDING - (UIText.X_ADVANCE * textShift);
	}

	inline function updateCaretPosition():Void{
		caret.x = inputText.x + ((inputIndex + inputLength) * UIText.X_ADVANCE);
	}

	inline function updateSelectionBox():Void{
		selectionBox.scale.x = Math.abs(UIText.X_ADVANCE * inputLength);
		selectionBox.x = caret.x - (FlxMath.bound(inputLength, 0, null) * UIText.X_ADVANCE);

		if(inputLength != 0){
			final comparePosition:Float = inputLength < 0 ? box.width - Box.BORDER_SIZE : caret.x - box.x;
			if(selectionBox.x < box.x + Box.BORDER_SIZE){ selectionBox.x = box.x + Box.BORDER_SIZE; }
			if(selectionBox.x + selectionBox.scale.x > box.x + comparePosition){ selectionBox.scale.x = comparePosition - (selectionBox.x - box.x); }
		}

		selectionBox.updateHitbox();
	}

	inline function resetCaret(shown:Bool = true):Void{
		caret.alpha = shown ? 1 : 0;
		caretTimer = 0;
	}

	inline function getCharacterIndexUnderMouse():Int{
		return Math.round(FlxMath.bound((FlxG.mouse.viewX - inputText.x)/UIText.X_ADVANCE, 0, inputString.length));
	}

	function startTextInput():Void{
		allowDragSelect = false;
		inputtingText = true;
		manager.focused = this;
		inputLength = 0;
		resetCaret();
		inputString = value;
		inputIndex = value.length;
		updateCaretPosition();
		updateSelectionBox();
		Binds.allowChangingVolume = false;
	}

	function stopTextInput():Void{
		inputtingText = false;
		manager.clearFocused();
		value = inputString;
		onValueChanged.dispatch(value);
		inputLength = 0;
		allowDragSelect = false;
		resetCaret(false);
		Binds.allowChangingVolume = true;
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
				if(inputLength != 0){
					deleteSelection();
					return;
				}
				if(inputIndex == 0){ return; }
				var start:String = inputString.substring(0, inputIndex-1);
				var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
				inputString = start + end;
				inputIndex--;
				if(textShift > 0){ textShift--; }
				resetCaret();
			case KEY_DELETE:
				if(inputLength != 0){
					deleteSelection();
					return;
				}
				if(inputIndex == inputString.length){ return; }
				var start:String = inputString.substring(0, inputIndex);
				var end:String = inputString.substring(inputIndex+1);
				inputString = start + end;
				resetCaret();
			case KEY_LEFT:
				if(FlxG.keys.anyPressed([SHIFT])){ //Move selection.
					inputLength--;
					allowDragSelect = false;
					if(inputIndex + inputLength < 0){ inputLength++; }
					resetCaret();
				}
				else if(FlxG.keys.anyPressed([CONTROL])){ //Snap caret between delimiters.
					inputLength = 0;
					allowDragSelect = false;
					while(inputIndex > 0){
						inputIndex--;
						if(DELIMITERS.contains(inputString.charAt(inputIndex))){ break; }
					}
					resetCaret();
				}
				else{ //Move caret.
					if(inputLength < 0)			{ inputIndex = inputIndex + inputLength; }
					else if(inputLength > 0)	{} //Do nothing since inputIndex is already in the right spot.
					else						{ inputIndex--; }
					if(inputIndex < 0){ inputIndex = 0; }
					inputLength = 0;
					allowDragSelect = false;
					resetCaret();
				}
			case KEY_RIGHT:
				if(FlxG.keys.anyPressed([SHIFT])){ //Move selection.
					inputLength++;
					allowDragSelect = false;
					if(inputIndex + inputLength > inputString.length){ inputLength--; }
					resetCaret();
				}
				else if(FlxG.keys.anyPressed([CONTROL])){ //Snap caret between delimiters.
					inputLength = 0;
					allowDragSelect = false;
					while(inputIndex < inputString.length){
						inputIndex++;
						if(DELIMITERS.contains(inputString.charAt(inputIndex-1))){ break; }
					}
					resetCaret();
				}
				else{ //Move caret.
					if(inputLength > 0)			{ inputIndex = inputIndex + inputLength; }
					else if(inputLength < 0)	{} //Do nothing since inputIndex is already in the right spot.
					else						{ inputIndex++; }
					if(inputIndex > inputString.length){ inputIndex = inputString.length; }
					inputLength = 0;
					allowDragSelect = false;
					resetCaret();
				}
			default:
				var char:String = String.fromCharCode(e.charCode);
				if(!allowedCharacters.contains(char)){ return; }

				if(inputLength != 0){ deleteSelection(); }

				insertString(char);
				inputLength = 0;
				allowDragSelect = false;
				resetCaret();
		}
	}

	/**
	 * Inserts a string into the text box, making sure only allowed characters are used and advances the caret properly.
	 */
	function insertString(insert:String):Void{
		if(insert == null || insert == ""){ return; }
		for(char in insert.split("")){
			if(!allowedCharacters.contains(char)){ continue; }
			var start:String = inputString.substring(0, inputIndex);
			var end:String = inputIndex == inputString.length ? "" : inputString.substring(inputIndex);
			inputString = start + char + end;
			inputIndex++;
		}
		resetCaret();
	}

	/**
	 * Used by both backspace and delete when selecting multiple characters.
	 */
	function deleteSelection():Void{
		var start:String = inputString.substring(0, inputIndex + Std.int(FlxMath.bound(inputLength, null, 0)));
		var end:String = inputString.substring(inputIndex + Std.int(FlxMath.bound(inputLength, 0, null)));
		inputString = start + end;
		inputIndex = inputIndex + Std.int(FlxMath.bound(inputLength, null, 0));
		inputLength = 0;
		allowDragSelect = false;
		resetCaret();
	}

}