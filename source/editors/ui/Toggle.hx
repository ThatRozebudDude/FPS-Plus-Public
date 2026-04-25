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

class Toggle extends FlxTypedSpriteGroup<FlxSprite>
{

	static inline final LABEL_PADDING:Float = 5;

	var box:Box;
	var symbol:FlxSprite;
	var label:FlxBitmapText;

	public var state:Bool = false;

	public var onToggle:FlxTypedSignal<Bool->Void> = new FlxTypedSignal<Bool->Void>();

	public function new(_x:Float, _y:Float, _initalState:Bool, _label:String = ""){
		super(_x, _y);
		state = _initalState;

		box = new Box(0, 0, 24, 24);
		box.onClick.add(function(){
			setState(!state);
		});

		symbol = new FlxSprite().loadGraphic(Paths.image("fpsPlus/editors/shared/checkBoxSymbol"), true, 24, 24);
		symbol.animation.add("x", [0], 0, false);
		symbol.animation.add("check", [1], 0, false);

		label = new FlxBitmapText(box.width + LABEL_PADDING, box.height/2, _label, FlxBitmapFont.fromAngelCode(Paths.image("fpsPlus/editors/shared/cascadia"), Paths.file("fpsPlus/editors/shared/cascadia", "images", "fnt")));
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(symbol);
		add(label);

		setState(state);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	function setState(v:Bool):Void{
		state = v;

		box.fillColor = state ? UIColors.SELECTED_COLOR : UIColors.INTERACTION_COLOR;

		symbol.animation.play(state ? "check" : "x", true);
		symbol.color = state ? UIColors.SELECTED_TEXT_COLOR : UIColors.INTERACTION_TEXT_COLOR;

		onToggle.dispatch(state);
	}
	
}