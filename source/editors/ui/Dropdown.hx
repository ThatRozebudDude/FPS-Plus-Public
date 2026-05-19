package editors.ui;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Dropdown extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;
	static inline final MAX_DROPDOWN_COUNT:Int = 12;

	var box:Box;
	var boxLabel:UIText;

	var dropdownSymbolBox:Box;
	var dropdownSymbol:FlxSprite;

	var label:UIText;

	public var values:Array<String>;
	public var value(get, never):String;
	public var currentIndex:Int = 0;

	var dropdownOpened:Bool = false;
	var dropdownOverlapIndex:Int = -1;
	var dropdownStartIndex:Int = 0;
	var dropdownBoxes:Array<Box> = [];
	var dropdownLabels:Array<UIText> = [];

	public var onSelect:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public function new(_x:Float, _y:Float, _width:Float, _values:Array<String>, ?_defaultValue:String = null, _label:String = ""){
		super(_x, _y);
		values = _values;
		currentIndex = (_defaultValue != null) ? values.indexOf(_defaultValue) : 0;
		if(currentIndex < 0){ currentIndex = 0; }

		box = new Box(0, 0, _width, 24);
		box.onClick.add(function(){
			if(!dropdownOpened && manager.allowInteraction && manager.focused == null){ openDropdown(); }
		});

		for(i in 0...Std.int(Math.min(values.length, MAX_DROPDOWN_COUNT))){
			var dropdownBox:Box = new Box(0, (box.height - Box.BORDER_SIZE) * (i+1), _width, 24);
			dropdownBox.fillColor = UIColors.INTERACTION_COLOR;
			dropdownBox.visible = false;

			var dropdownLabel:UIText = new UIText(dropdownBox.x + LABEL_PADDING, dropdownBox.y + (dropdownBox.height/2), values[i]);
			dropdownLabel.y -= dropdownLabel.height/2;
			dropdownLabel.color = UIColors.INTERACTION_TEXT_COLOR;
			dropdownLabel.visible = false;

			dropdownBox.onOverlap.add(function(){ dropdownOverlapIndex = i; });

			dropdownBoxes.push(dropdownBox);
			dropdownLabels.push(dropdownLabel);
		}

		dropdownSymbolBox = new Box(box.x + box.width - 24, 0, 24, 24);
		dropdownSymbolBox.fillColor = UIColors.INTERACTION_COLOR;

		dropdownSymbol = new FlxSprite(dropdownSymbolBox.x, dropdownSymbolBox.y).loadGraphic(Paths.image("fpsPlus/editors/shared/dropdownSymbol"));
		dropdownSymbol.scale.set(0.5, 0.5);
		dropdownSymbol.updateHitbox();
		dropdownSymbol.color = UIColors.INTERACTION_TEXT_COLOR;

		label = new UIText(box.width + LABEL_PADDING, (box.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;
		
		boxLabel = new UIText(box.x + LABEL_PADDING, (box.height/2), values[currentIndex]);
		boxLabel.y -= label.height/2;
		boxLabel.color = UIColors.FILL_TEXT_COLOR;

		for(box in dropdownBoxes){ add(box); }
		for(label in dropdownLabels){ add(label); }
		add(box);
		add(boxLabel);
		add(dropdownSymbolBox);
		add(dropdownSymbol);
		add(label);

		closeDropdown();

		elementWidth = box.width;
		elementHeight = box.height;
	}

	override public function update(elapsed:Float):Void{
		var anyBoxOverlaps:Bool = false;
		for(dropdownBox in dropdownBoxes){
			anyBoxOverlaps = anyBoxOverlaps || dropdownBox.mouseOverlaps;
		}
		dropdownOverlapIndex = anyBoxOverlaps ? dropdownOverlapIndex : -1;

		for(i in 0...dropdownBoxes.length){
			if(dropdownOpened){
				dropdownBoxes[i].visible = true;
				dropdownLabels[i].visible = true;
				if(i == dropdownOverlapIndex){
					dropdownBoxes[i].fillColor = UIColors.SELECTED_COLOR;
					dropdownLabels[i].color = UIColors.SELECTED_TEXT_COLOR;
				}
				else{
					dropdownBoxes[i].fillColor = UIColors.INTERACTION_COLOR;
					dropdownLabels[i].color = UIColors.INTERACTION_TEXT_COLOR;
				}
				var rectPos = Utils.worldToLocal(dropdownLabels[i], dropdownBoxes[i].x + Box.BORDER_SIZE, dropdownBoxes[i].y + Box.BORDER_SIZE);
				dropdownLabels[i].clipRect = new FlxRect(rectPos.x/dropdownLabels[i].scale.x, rectPos.y/dropdownLabels[i].scale.y, (dropdownBoxes[i].width - Box.BORDER_SIZE*2)/dropdownLabels[i].scale.x, (dropdownBoxes[i].height - Box.BORDER_SIZE*2)/dropdownLabels[i].scale.y);
			}
			else{
				dropdownBoxes[i].visible = false;
				dropdownLabels[i].visible = false;
			}
		}

		if(values.length > MAX_DROPDOWN_COUNT && dropdownOpened){
			if(FlxG.mouse.wheel != 0){
				dropdownStartIndex -= FlxG.mouse.wheel;
				dropdownStartIndex = Std.int(FlxMath.bound(dropdownStartIndex, 0, Math.max(0, values.length - MAX_DROPDOWN_COUNT)));
				updateDropdownText();
			}
		}

		if(FlxG.mouse.justPressed && dropdownOpened && manager.allowInteraction){
			if(anyBoxOverlaps){
				currentIndex = dropdownStartIndex + dropdownOverlapIndex;
				onSelect.dispatch(values[currentIndex]);
				closeDropdown();
			}
			else{
				closeDropdown();
			}
		}

		boxLabel.text = values[currentIndex];
		var rectPos = Utils.worldToLocal(boxLabel, box.x + Box.BORDER_SIZE, box.y + Box.BORDER_SIZE);
		boxLabel.clipRect = new FlxRect(rectPos.x/boxLabel.scale.x, rectPos.y/boxLabel.scale.y, (box.width - Box.BORDER_SIZE*2)/boxLabel.scale.x, (box.height - Box.BORDER_SIZE*2)/boxLabel.scale.y);

		super.update(elapsed);
	}

	function openDropdown():Void{
		dropdownOpened = true;
		dropdownStartIndex = 0;
		dropdownSymbolBox.fillColor = UIColors.INTERACTION_COLOR;
		dropdownSymbol.flipY = true;
		dropdownSymbol.color = UIColors.INTERACTION_TEXT_COLOR;
		updateDropdownText();
		manager.focused = this;
	}

	function closeDropdown():Void{
		dropdownOpened = false;
		dropdownSymbolBox.fillColor = UIColors.INTERACTION_COLOR;
		dropdownSymbol.flipY = false;
		dropdownSymbol.color = UIColors.INTERACTION_TEXT_COLOR;
		dropdownOverlapIndex = -1;
		if(this == manager.focused){ manager.clearFocused(); }
	}
	
	function updateDropdownText():Void{
		for(i in 0...dropdownLabels.length){
			dropdownLabels[i].text = values[dropdownStartIndex + i];
		}
	}

	override function unfocus():Void{
		closeDropdown();
	}

	function get_value():String{ return values[currentIndex]; }
	
	public function setSelectedTo(v:String):Bool{
		var r:Bool = true;
		currentIndex = (v != null) ? values.indexOf(v) : -1;
		if(currentIndex < 0){
			currentIndex = 0;
			r = false;
		}
		boxLabel.text = values[currentIndex];
		return r;
	}
	
}