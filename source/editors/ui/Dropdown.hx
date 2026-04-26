package editors.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxAxes;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;
import extensions.flixel.FlxTextExt;
import editors.ui.Box;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import shaders.UIBoxShader;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Dropdown extends FlxTypedSpriteGroup<FlxSprite>
{

	static inline final LABEL_PADDING:Float = 5;

	var box:Box;
	var boxLabel:FlxBitmapText;

	var dropdownBox:Box;
	var dropdownSymbol:FlxSprite;

	var label:FlxBitmapText;

	var values:Array<String>;
	var currentIndex:Int = 0;

	public var selectedValue:String;

	public var onSelect:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public function new(_x:Float, _y:Float, _width:Float, _values:Array<String>, ?_defaultValue:String = null, _label:String = ""){
		super(_x, _y);
		values = _values;
		currentIndex = (_defaultValue != null) ? values.indexOf(_defaultValue) : 0;
		if(currentIndex < 0){ currentIndex = 0; }

		box = new Box(0, 0, _width, 24);

		dropdownBox = new Box(box.x + box.width - 24, 0, 24, 24);
		dropdownBox.fillColor = UIColors.INTERACTION_COLOR;

		dropdownSymbol = new FlxSprite(dropdownBox.x, dropdownBox.y).loadGraphic(Paths.image("fpsPlus/editors/shared/dropdownSymbol"));
		dropdownSymbol.color = UIColors.INTERACTION_TEXT_COLOR;

		label = new FlxBitmapText(box.width + LABEL_PADDING, box.height/2, _label, FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(dropdownBox);
		add(dropdownSymbol);
		add(label);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}
	
}