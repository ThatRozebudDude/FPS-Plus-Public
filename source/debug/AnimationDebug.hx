package debug;

import characters.CharacterInfoBase;
import config.Config;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var dad:Character;
	var dadBG:Character;
	var charInfo:CharacterInfoBase;
	//var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'spooky';
	var bgChar:String;
	var bgMirrorFront:Bool = false;
	var camFollow:FlxObject;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	final zoomSpeed:Float = 0.005;
	final moveSpeed:Float = 400;

	//var flippedChars:Array<String> = ["pico", "tankman"];

	public function new(_character:String = 'spooky', _bgChar:String = null)
	{
		super();
		this.daAnim = _character;

		if(_bgChar == null){
			bgMirrorFront = true;
			bgChar = _character;
		}
		else{
			bgChar = _bgChar;
		}
	}

	override function create()
	{

		Config.setFramerate(144);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);
		add(gridBG);

		dad = new Character(0, 0, daAnim, false, false, true);
		dad.screenCenter();

		var characterClass = Type.resolveClass("characters.data." + dad.charClass);
		charInfo = Type.createInstance(characterClass, []);
		if(charInfo.info.extraData != null){
			for(type => data in charInfo.info.extraData){
				switch(type){
					case "scale":
						camGame.zoom = data;
				}
			}
		}

		dadBG = new Character(dad.x, dad.y, bgChar, false, false, true);
		dadBG.alpha = 0.5;
		dadBG.color = 0xFF000000;

		add(dadBG);
		add(dad);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set(0);
		textAnim.cameras = [camHUD];
		add(textAnim);

		genBoyOffsets();

		dad.playAnim(animList[0], true);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (x in charInfo.info.anims)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, x.name + ": " + x.data.offset, 15);
			text.scrollFactor.set(0);
			text.color = FlxColor.BLUE;
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList)
				animList.push(x.name);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = dad.curAnim;

		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;

		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.C){
			copyOffsetToClipboard();
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -1 * moveSpeed / FlxG.camera.zoom;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = moveSpeed / FlxG.camera.zoom;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -1 * moveSpeed / FlxG.camera.zoom;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = moveSpeed / FlxG.camera.zoom;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			dad.playAnim(animList[curAnim], true);

			if(bgMirrorFront){
				if(animList[curAnim].endsWith("miss"))
					dadBG.playAnim(animList[curAnim].substring(0, animList[curAnim].length - 4), true);
				else
					dadBG.idleEnd(true);
			}

			updateTexts();
			genBoyOffsets(false);
		}
		
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new PlayState());
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			//updateTexts();
			if (upP){
				dad.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
				if(bgMirrorFront)
					dadBG.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			}
				
			if (downP){
				dad.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
				if(bgMirrorFront)
					dadBG.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			}
				
			if (leftP){
				dad.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
				if(bgMirrorFront)
					dadBG.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			}
				
			if (rightP){
				dad.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;
				if(bgMirrorFront)
					dadBG.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;
			}

			for(x in charInfo.info.anims){
				if(x.name != animList[curAnim]){ continue; }
				x.data.offset = [dad.animOffsets.get(animList[curAnim])[0], dad.animOffsets.get(animList[curAnim])[1]];
				break;
			}
				

			updateTexts();
			genBoyOffsets(false);
			dad.playAnim(animList[curAnim], true);
		}

		super.update(elapsed);
	}

	function copyOffsetToClipboard(){

		var r = "";

		for(x in charInfo.info.anims){
			switch(x.type){
				case frames:
					r += "add(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), " + x.data.frames + ", " + x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "), " + x.data.flipX + ", " + x.data.flipY + ");\n";
				case prefix:
					r += "addByPrefix(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), \"" + x.data.prefix + "\", " + x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "), " + x.data.flipX + ", " + x.data.flipY + ");\n";
				case indices:
					r += "addByIndices(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), \"" + x.data.prefix + "\", " + x.data.frames + ", \"" + x.data.postfix + "\", " +  x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "), " + x.data.flipX + ", " + x.data.flipY + ");\n";
				case label:
					r += "addByLabel(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), \"" + x.data.prefix + "\", " + x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "));\n";
				case start:
					r += "addByFrame(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), " + x.data.frames[0] + ", " + x.data.frames[1] + ", " + x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "));\n";
				case startAtLabel:
					r += "addByStartingAtLabel(\"" + x.name + "\", offset(" + dad.animOffsets.get(x.name)[0] + ", " + dad.animOffsets.get(x.name)[1] + "), \"" + x.data.prefix + "\", " + x.data.frames[0] + ", " + x.data.framerate + ", loop(" + x.data.loop.looped + ", " + x.data.loop.loopPoint + "));\n";
			}
		}

		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, r);

	}

}
