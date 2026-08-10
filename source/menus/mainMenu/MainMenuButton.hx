package menus.mainMenu;

import flixel.FlxSprite;

class MainMenuButton extends FlxSprite
{
	public var listPositionOffset:Float = 0;

	public var action:Dynamic = null;
	public var sortOrder:Float = 0;
	public var transition = {
		instant: false,
		sound: null,
		stopMusic: false
	}

	public var source:String = null;

	public function new(params:Dynamic){
		super();

		if(params.sort != null){
			sortOrder = params.sort;
		}
		
		if(params.action != null){
			action = params.action;
		}

		if(params.transition != null){
			if(params.transition.instant != null)	{ transition.instant = params.transition.instant; }
			if(params.transition.sound != null)		{ transition.sound = params.transition.sound; }
			if(params.transition.stopMusic != null)	{ transition.stopMusic = params.transition.stopMusic; }
		}

		frames = Paths.getSparrowAtlas(params.graphic);
		animation.addByPrefix("idle", "idle", 24);
		animation.addByPrefix("selected", "selected", 24);
		animation.play("idle");

		antialiasing = true;
	}

}