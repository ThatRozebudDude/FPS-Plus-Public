package debug;

import extensions.flixel.FlxTextExt;
import caching.ImageCache;
import modding.PolymodHandler;
import characters.ScriptableCharacter;
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

	var currentAnimText:FlxTextExt;
	var animListText:FlxTextExt;
	var controlsText:FlxTextExt;

	final controlsInfoText:String = "CONTROLS\n\nW/S - Cycle through animations\nSPACE - Replay animation\nArrow Keys - Move offset by 1 pixel.\nSHIFT + Arrow Keys - Move offset by 10 pixels\nI/J/K/L - Move camera\nQ/E - Zoom Camera In/Out\nBACKSPACE - Toggle character transparency\nCTRL + C - Copy offset code to clipboard\nESCAPE - Leave (Does not auto save offsets)\nTAB - Toggle controls\n";

	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'Bf';
	var bgChar:String;
	var bgMirrorFront:Bool = false;
	var camFollow:FlxObject;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	final zoomSpeed:Float = 0.005;
	final moveSpeed:Float = 400;

	//var flippedChars:Array<String> = ["pico", "tankman"];

	public function new(_character:String = 'Bf', _bgChar:String = null){
		super();
		daAnim = _character;

		if(_bgChar == null){
			bgMirrorFront = true;
			bgChar = _character;
		}
		else{
			bgChar = _bgChar;
		}
	}

	override function create(){

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

		charInfo = ScriptableCharacter.init(dad.charClass);
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

		//dumbTexts = new FlxTypedGroup<FlxTextExt>();
		//add(dumbTexts);

		animListText = new FlxTextExt(10, 40, 1260, "anim list goes here", 15);
		animListText.scrollFactor.set(0);
		animListText.color = 0xFF0000FF;
		animListText.cameras = [camHUD];
		add(animListText);

		controlsText = new FlxTextExt(10, 10, 1260, controlsInfoText, 15);
		controlsText.alignment = FlxTextAlign.RIGHT;
		controlsText.scrollFactor.set(0);
		controlsText.color = 0xFF0000FF;
		controlsText.cameras = [camHUD];
		add(controlsText);

		currentAnimText = new FlxTextExt(300, 16);
		currentAnimText.size = 26;
		currentAnimText.color = 0xFF0000FF;
		currentAnimText.scrollFactor.set(0);
		currentAnimText.cameras = [camHUD];
		add(currentAnimText);

		genBoyOffsets(true);

		dad.playAnim(animList[0], true);

		camFollow = new FlxObject(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y, 2, 2);
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void{
		var daLoop:Int = 0;
		var finalText:String = "";

		for (x in charInfo.info.anims){
			finalText += x.name + ": " + x.data.offset + "\n";
			if(pushList){ animList.push(x.name); }
		}

		animListText.text = finalText;
	}

	override function update(elapsed:Float):Void{
		currentAnimText.text = dad.curAnim;

		if (FlxG.keys.pressed.E){
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		}
		if (FlxG.keys.pressed.Q){	
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;
		}

		if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.C){
			copyOffsetToClipboard();
		}

		if(FlxG.keys.justPressed.TAB){
			controlsText.visible = !controlsText.visible;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L){
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
		else{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W){ curAnim -= 1; }
		if (FlxG.keys.justPressed.S){ curAnim += 1; }

		if (curAnim < 0){ curAnim = animList.length - 1; }
		if (curAnim >= animList.length){ curAnim = 0; }

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE){
			dad.playAnim(animList[curAnim], true);

			if(bgMirrorFront){
				if(animList[curAnim].endsWith("miss"))
					dadBG.playAnim(animList[curAnim].substring(0, animList[curAnim].length - 4), true);
				else
					dadBG.idleEnd(true);
			}

			genBoyOffsets(false);
		}
		
		if (FlxG.keys.justPressed.ESCAPE){
			ImageCache.refreshLocal();
			FlxG.switchState(new PlayState());
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift){
			multiplier = 10;
		}

		if (upP || rightP || downP || leftP){
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
				
			genBoyOffsets(false);
			dad.playAnim(animList[curAnim], true);
		}

		if (FlxG.keys.anyJustPressed([BACKSPACE])){
			if(dad.getSprite().alpha == 0.5){
				dad.getSprite().alpha = 1;
			}
			else{
				dad.getSprite().alpha = 0.5;
			}
		}

		if(Binds.justPressed("polymodReload")){
			PolymodHandler.reload(false);
			FlxG.switchState(new AnimationDebug(daAnim, (daAnim == bgChar) ? null : bgChar));
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
