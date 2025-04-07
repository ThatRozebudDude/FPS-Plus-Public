package ui.dialogue;

import flixel.FlxSprite;

class DialoguePortrait extends FlxSprite
{
	public function new(id:String)
	{
		super();
		
		frames = Paths.getSparrowAtlas("ui/dialogue/portraits/" + id);
		animation.addByPrefix("appear", "portraitEnter", 24, false);
		animation.addByPrefix("idle", "portraitTalk", 24, true);

		//Optional json
		if (Utils.exists(Paths.json(id, "images/ui/dialogue/portraits"))){
			var portraitJson = haxe.Json.parse(Utils.getText(Paths.json(id, "images/ui/dialogue/portraits")));

			if(portraitJson.offset != null){
				this.offset.x = (portraitJson.offset.x != null) ? portraitJson.offset.x : 0;
				this.offset.y = (portraitJson.offset.y != null) ? portraitJson.offset.y : 0;
			}

			this.antialiasing = (portraitJson.antialiasing != null) ? portraitJson.antialiasing : true;

			var jsonScale = (portraitJson.scale != null) ? portraitJson.scale : 1;
			this.scale.set(jsonScale, jsonScale);
		}

		// nvm
		screenCenter(Y);
		//this.alpha = 0;
	}

	public function appear(){
		visible = true;

		animation.play("appear");
		animation.onFinish.addOnce(function(anim){
			animation.play("idle");
		});
	}

	public function hide(){
		visible = false;
	}
}