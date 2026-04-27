package editors.ui;

import flixel.util.FlxAxes;
import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxSprite;

using StringTools;

typedef HotbarSlot = {
	var box:Box;
	var graphic:FlxSprite;
}

class Hotbar extends UIElement
{

	public var slots:Array<HotbarSlot> = [];
	public var onSelect:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new(_x:Float, _y:Float, _slotWidth:Float, _slotHeight:Float, _slotCount:Int, _axis:FlxAxes){
		super(_x, _y);
		if(_slotCount < 1){ _slotCount = 1; }
		
		for(i in 0..._slotCount){
			var hotbarSlot:HotbarSlot = {box: null, graphic: null}

			hotbarSlot.box = new Box(	
				(_slotWidth * i - (Box.BORDER_SIZE * i/(_slotCount-1))) * (_axis.x ? 1 : 0),
				(_slotHeight * i - (Box.BORDER_SIZE * i/(_slotCount-1))) * (_axis.y ? 1 : 0), 
				_slotWidth + (_axis.x ? Box.BORDER_SIZE : 0), 
				_slotHeight + (_axis.y ? Box.BORDER_SIZE : 0)
			);
			hotbarSlot.box.onClick.add(function(){ selectSlot(i); });

			slots.push(hotbarSlot);
		}

		for(slot in slots){
			add(slot.box);
		}

		selectSlot(0);

		elementWidth = width;
		elementHeight = height;
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	public function selectSlot(slotIndex:Int):Void{
		for(i in 0...slots.length){
			if(slotIndex == i){
				slots[i].box.fillColor = UIColors.SELECTED_COLOR;
			}
			else{
				slots[i].box.fillColor = UIColors.FILL_COLOR;
			}
		}
		onSelect.dispatch(slotIndex);
	}
	
}