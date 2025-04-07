package ui.dialogue;

import openfl.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.math.FlxPoint;
import flixel.FlxG;
import haxe.Json;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

typedef DialogueSkin = {
    var path:String;
	var text:DialogueTextData;
	var sounds:Dynamic;
    var antialiasing:Bool;
    var scale:Float;
	var position:Dynamic;
	var animations:Array<DialogueAnimation>;
}

typedef DialogueAnimation = {
	var name:String;
	var prefix:String;
	var offset:Dynamic;
	var fps:Float;
	var flipX:Bool;
	var loop:Bool;
}

typedef DialogueTextData = {
	var font:String;
	var size:Float;
	var color:String;
	var shadow:String;
	var position:Dynamic;
}

typedef DialogueData = {
	var dialogue:Array<DialogueConversation>;
	var ?skin:String;
}
typedef DialogueConversation = {
	var portraits:Array<String>;
	var text:String;
	var box:String;
	var ?skipAnimation:Bool;
}

class DialogueBox extends FlxSpriteGroup
{
	public var skin:DialogueSkin;
	public var data:DialogueData;

	public var finishedDialogue:Bool = true;
	public var curLine:Int = 0;

	var curDisplayedPortraits:Array<String> = [];
	var dialoguePortraits:Map<String, DialoguePortrait> = new Map();

	var bg:FlxSprite;
	var bgAlphaValue:Float;

	var box:FlxSprite;
	var offsetMap:Map<String, FlxPoint> = [];
	var flipMap:Map<String, Bool> = [];

	var dialogueText:FlxTypeText;
	var finishedLine:Bool = false;

	public var onPortraitAppear:FlxTypedSignal<(String) -> Void> = new FlxTypedSignal();
	public var onPortraitHide:FlxTypedSignal<(String) -> Void> = new FlxTypedSignal();

	public var onDialogueChange:FlxTypedSignal<(DialogueBox) -> Void> = new FlxTypedSignal();
	public var onDialogueEnd:FlxTypedSignal<(DialogueBox) -> Void> = new FlxTypedSignal();

	override public function new(data:DialogueData, ?bgColor:FlxColor = 0xFFB3DFD8, ?_bgAlphaValue:Float = 0.7, ?bgBlend:BlendMode = NORMAL){
		super();

		this.data = data;

		if (data.skin != null){
			if(Utils.exists(Paths.json(data.skin, "data/uiSkins/dialogueBox"))){
				skin = Json.parse(Utils.getText(Paths.json(data.skin, "data/uiSkins/dialogueBox")));
			}
		}
		else{
			skin = Json.parse(Utils.getText(Paths.json("Default", "data/uiSkins/dialogueBox")));
		}

		bg = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), bgColor);
		bg.scrollFactor.set();
		bg.alpha = 0;
		bg.blend = bgBlend;
		add(bg);

		bgAlphaValue = _bgAlphaValue;

		// Add characters
		for (conv in data.dialogue){
			for (p in conv.portraits){
				if (!dialoguePortraits.exists(p)){
					final portrait = new DialoguePortrait(p);

					dialoguePortraits.set(p, portrait);
					add(portrait);

					hidePortrait(portrait);
					onPortraitHide.dispatch(p);
				}
			}
		}

		box = new FlxSprite();
		box.setPosition(skin.position.x, skin.position.y);
		box.scale.set(skin.scale, skin.scale);
		box.antialiasing = skin.antialiasing;
		
		box.frames = Paths.getSparrowAtlas(skin.path);
		for (anim in skin.animations){
			box.animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
			offsetMap.set(anim.name, FlxPoint.get(anim.offset.x, anim.offset.y));
			flipMap.set(anim.name, anim.flipX);
		}
		box.updateHitbox();

		//Setup Visuals
		dialogueText = new FlxTypeText(skin.text.position.x, skin.text.position.y, Std.int(box.width * 0.7), "", Std.int(skin.text.size));
		dialogueText.font = Paths.font(skin.text.font.split(".")[0], skin.text.font.split(".")[1]);
		dialogueText.color = FlxColor.fromString(skin.text.color);
		dialogueText.sounds = [FlxG.sound.load(Paths.sound(skin.sounds.speak), 0.6)];

		if (skin.text.shadow != null)
		{
			dialogueText.borderStyle = SHADOW_XY(2, 2);
			dialogueText.borderSize = 2;
			dialogueText.borderColor = FlxColor.fromString(skin.text.shadow);
		}
		//dialogueText.showCursor = true;
	}

	// made function dynamic to make able to override functions like dialogueBox.showPortrait = function(s)
	public dynamic function showPortrait(portrait:DialoguePortrait){
		portrait.visible = true;

		portrait.animation.play("appear");
		portrait.animation.onFinish.addOnce(function(anim){
			portrait.animation.play("idle");
		});
	}

	public dynamic function hidePortrait(portrait:DialoguePortrait){
		portrait.visible = false;
	}

	public function start(){
		curLine = 0;
		finishedDialogue = false;
		curDisplayedPortraits = [];

		FlxTween.tween(bg, {alpha: bgAlphaValue}, 1.6, {ease: FlxEase.quartOut});
		add(box);
		add(dialogueText);

		continueDialogue();
	}

	function continueDialogue(){
		finishedLine = false;

		// replay dialogue animations if next character is not last character
		// compare string representation because memory addresses n shit or whatever
		if (curDisplayedPortraits.toString() != data.dialogue[curLine].portraits.toString()){
			if (skin.sounds.open != null)
				FlxG.sound.play(Paths.sound(skin.sounds.open), 0.6);

			boxPlayAnim(data.dialogue[curLine].box + "Open");
			box.animation.onFinish.addOnce(function(name:String){
				boxPlayAnim(data.dialogue[curLine].box);
			});

			for (portrait in curDisplayedPortraits){
				if (!data.dialogue[curLine].portraits.contains(portrait)){
					hidePortrait(dialoguePortraits.get(portrait));
				}
			}
			
			for (portrait in data.dialogue[curLine].portraits){
				if (!curDisplayedPortraits.contains(portrait)){
					showPortrait(dialoguePortraits.get(portrait));
					onPortraitAppear.dispatch(portrait);
				}
			}

		}

		curDisplayedPortraits = data.dialogue[curLine].portraits;

		dialogueText.resetText(data.dialogue[curLine].text);
		dialogueText.start(0.04, true);
		dialogueText.completeCallback = function(){
			finishedLine = true;
		};

		onDialogueChange.dispatch(this);
	}

	public function finishDialogue(){
		remove(box);
		remove(dialogueText);
		FlxTween.completeTweensOf(bg);
		FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});

		for (key => portrait in dialoguePortraits)
		{
			hidePortrait(portrait);
			onPortraitHide.dispatch(key);
		}

		onDialogueEnd.dispatch(this);
		// new FlxTimer().start(1, function(tmr:FlxTimer){onDialogueEnd.dispatch();});
	}

	public function boxPlayAnim(animation:String){
		box.animation.play(animation, true);

		if (offsetMap.exists(animation))
			box.offset = offsetMap.get(animation);
		if (flipMap.exists(animation))
			box.flipX = flipMap.get(animation);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if ((FlxG.keys.justPressed.ANY || FlxG.gamepads.anyJustPressed(ANY)) && !(FlxG.keys.anyJustPressed(FlxG.sound.volumeDownKeys) || FlxG.keys.anyJustPressed(FlxG.sound.volumeUpKeys)) && !finishedDialogue){
			//if dialogue are still playing, skip it
			if (!finishedLine){
				dialogueText.skip();
				finishedLine = true;
			}
			//Go to next Dialogue
			else if (finishedLine){
				FlxG.sound.play(Paths.sound(skin.sounds.close), 0.6);

				if (curLine <= data.dialogue.length - 2)
				{
					curLine += 1;
					continueDialogue();
				} else {
					finishedDialogue = true;
					finishDialogue();
				}
			}
		}
	}
}