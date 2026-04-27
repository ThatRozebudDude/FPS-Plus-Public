package editors.ui;

import editors.ui.Box;
import flixel.util.FlxSignal;
import flixel.FlxSprite;

using StringTools;

class Toggle extends UIElement
{

	static inline final LABEL_PADDING:Float = 5;

	var box:Box;
	var symbol:FlxSprite;
	var label:UIText;

	public var state:Bool = false;

	public var onToggle:FlxTypedSignal<Bool->Void> = new FlxTypedSignal<Bool->Void>();

	public function new(_x:Float, _y:Float, _initalState:Bool, _label:String = ""){
		super(_x, _y);
		state = _initalState;

		box = new Box(0, 0, 24, 24);
		box.onClick.add(function(){
			if(manager.allowInteraction && manager.focused == null){ setState(!state); }
		});

		symbol = new FlxSprite().loadGraphic(Paths.image("fpsPlus/editors/shared/checkBoxSymbol"), true, 48, 48);
		symbol.animation.add("x", [0], 0, false);
		symbol.animation.add("check", [1], 0, false);
		symbol.scale.set(0.5, 0.5);
		symbol.updateHitbox();

		label = new UIText(box.width + LABEL_PADDING, (box.height/2), _label);
		label.y -= label.height/2;
		label.color = UIColors.FILL_TEXT_COLOR;

		add(box);
		add(symbol);
		add(label);

		setState(state);

		elementWidth = box.width;
		elementHeight = box.height;
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