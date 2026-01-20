package debug;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import modding.PolymodHandler;
import flixel.math.FlxPoint;

using StringTools;

class CharacterCompare extends FlxState
{

	var topCharacter:Character;
	var bottomCharacter:Character;

	var topCharacterCamPoint:FlxSprite;
	var bottomCharacterCamPoint:FlxSprite;

	var camFollow:FlxObject;
	var originalPoint:FlxPoint;

	var topCharOriginalPos:FlxPoint;

	var adjustOffsetMode:Bool = false;
	var offsetDiff:FlxPoint = new FlxPoint();

	final DO_REPOSITION:Bool = false;
	
	public function new() {
		super();
	}

	override function create() {

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, 1280*4, 720*4);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.screenCenter(XY);

		topCharacter = new Character(300, 300, "BfDead", true);
		bottomCharacter = new Character(300, 300, "Bf", true);

		if(DO_REPOSITION){
			topCharacter.setPosition(topCharacter.x - ((topCharacter.getFrameWidth() * topCharacter.getScale().x)/2), topCharacter.y - (topCharacter.getFrameHeight() * topCharacter.getScale().y));
			topCharacter.reposition();
			bottomCharacter.setPosition(bottomCharacter.x - ((bottomCharacter.getFrameWidth() * bottomCharacter.getScale().x)/2), bottomCharacter.y - (bottomCharacter.getFrameHeight() * bottomCharacter.getScale().y));
			bottomCharacter.reposition();
		}

		topCharOriginalPos = topCharacter.getPosition();

		if(!topCharacter.characterInfo.info.extraData.exists("reposition")){
			topCharacter.characterInfo.info.extraData.set("reposition", [0, 0]);
		}

		if(!topCharacter.characterInfo.info.extraData.exists("repositionFlipped")){
			topCharacter.characterInfo.info.extraData.set("repositionFlipped", [topCharacter.characterInfo.info.extraData.get("reposition")[0] * -1, topCharacter.characterInfo.info.extraData.get("reposition")[1]]);
		}

		originalPoint = new FlxPoint(topCharacter.x, topCharacter.y);

		topCharacterCamPoint = new FlxSprite(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y).makeGraphic(1, 1, 0xFFFF0000);
		topCharacterCamPoint.scale.set(10, 10);
		bottomCharacterCamPoint = new FlxSprite(bottomCharacter.getMidpoint().x + bottomCharacter.focusOffset.x, bottomCharacter.getMidpoint().y + bottomCharacter.focusOffset.y).makeGraphic(1, 1, 0xFF00FF00);
		bottomCharacterCamPoint.scale.set(10, 10);

		add(gridBG);
		add(bottomCharacter);
		add(topCharacter);
		add(bottomCharacterCamPoint);
		add(topCharacterCamPoint);

		//trace("pos diff: " + (bottomCharacter.x - topCharacter.x) + ", " + (bottomCharacter.y - topCharacter.y));
		trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	final zoomSpeed:Float = 0.005;
	final moveSpeed:Float = 400;
	
	override function update(elapsed:Float) {

		if(FlxG.keys.justPressed.F5){
			PolymodHandler.reload(false);
			FlxG.resetState();
		}

		if(FlxG.keys.justPressed.ONE){
			if(bottomCharacter.alpha == 0.5){
				bottomCharacter.alpha = 1;
			}
			else{
				bottomCharacter.alpha = 0.5;
			}
		}

		if(FlxG.keys.justPressed.TWO){
			if(topCharacter.alpha == 0.5){
				topCharacter.alpha = 1;
			}
			else{
				topCharacter.alpha = 0.5;
			}
		}

		if (FlxG.keys.pressed.W){
			camFollow.velocity.y = -1 * moveSpeed / FlxG.camera.zoom;
		}
		else if (FlxG.keys.pressed.S){
			camFollow.velocity.y = moveSpeed / FlxG.camera.zoom;
		}
		else{
			camFollow.velocity.y = 0;
		}

		if (FlxG.keys.pressed.A){
			camFollow.velocity.x = -1 * moveSpeed / FlxG.camera.zoom;
		}
		else if (FlxG.keys.pressed.D){
			camFollow.velocity.x = moveSpeed / FlxG.camera.zoom;
		}
		else{
			camFollow.velocity.x = 0;
		}
		

		if (FlxG.keys.pressed.E){
			FlxG.camera.zoom += zoomSpeed * FlxG.camera.zoom;
		}
		if (FlxG.keys.pressed.Q){
			FlxG.camera.zoom -= zoomSpeed * FlxG.camera.zoom;
		}

		if (FlxG.keys.justPressed.B){
			adjustOffsetMode = !adjustOffsetMode;
			trace("offset adjust mode: " + adjustOffsetMode);
		}

		if (FlxG.keys.justPressed.R){
			topCharacter.playAnim(topCharacter.curAnim, true);
			bottomCharacter.playAnim(bottomCharacter.curAnim, true);
		}

		var moveThing:Float = (FlxG.keys.pressed.SHIFT) ? 10 : 1;

		if(!adjustOffsetMode){
			if (FlxG.keys.justPressed.UP){
				topCharacter.y -= moveThing;
				topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
	
				trace("pos diff: " + (topCharacter.x - originalPoint.x) + ", " + (topCharacter.y - originalPoint.y));
				trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
			}
			if (FlxG.keys.justPressed.DOWN){
				topCharacter.y += moveThing;
				topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
	
				trace("pos diff: " + (topCharacter.x - originalPoint.x) + ", " + (topCharacter.y - originalPoint.y));
				trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
			}
			if (FlxG.keys.justPressed.LEFT){
				topCharacter.x -= moveThing;
				topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
	
				trace("pos diff: " + (topCharacter.x - originalPoint.x) + ", " + (topCharacter.y - originalPoint.y));
				trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
			}
			if (FlxG.keys.justPressed.RIGHT){
				topCharacter.x += moveThing;
				topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
	
				trace("pos diff: " + (topCharacter.x - originalPoint.x) + ", " + (topCharacter.y - originalPoint.y));
				trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
			}
		}
		else{
			if (FlxG.keys.justPressed.UP){
				for(k => v in topCharacter.animOffsets){
					v[1] += moveThing;
				}
				offsetDiff.y += moveThing;
				@:privateAccess
				topCharacter.changeOffsets();
				
				trace("off diff: " + (offsetDiff.x) + ", " + (offsetDiff.y));
			}
			if (FlxG.keys.justPressed.DOWN){
				for(k => v in topCharacter.animOffsets){
					v[1] -= moveThing;
				}
				offsetDiff.y -= moveThing;
				@:privateAccess
				topCharacter.changeOffsets();
				
				trace("off diff: " + (offsetDiff.x) + ", " + (offsetDiff.y));
			}
			if (FlxG.keys.justPressed.LEFT){
				for(k => v in topCharacter.animOffsets){
					v[0] += moveThing;
				}
				offsetDiff.x += moveThing;
				@:privateAccess
				topCharacter.changeOffsets();
				
				trace("off diff: " + (offsetDiff.x) + ", " + (offsetDiff.y));
			}
			if (FlxG.keys.justPressed.RIGHT){
				for(k => v in topCharacter.animOffsets){
					v[0] -= moveThing;
				}
				offsetDiff.x -= moveThing;
				@:privateAccess
				topCharacter.changeOffsets();

				trace("off diff: " + (offsetDiff.x) + ", " + (offsetDiff.y));
			}
		}

		if (FlxG.keys.justPressed.I){
			topCharacter.focusOffset.y -= moveThing;
			topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
			trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
		}
		if (FlxG.keys.justPressed.K){
			topCharacter.focusOffset.y += moveThing;
			topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
			trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
		}
		if (FlxG.keys.justPressed.J){
			topCharacter.focusOffset.x -= moveThing;
			topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
			trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
		}
		if (FlxG.keys.justPressed.L){
			topCharacter.focusOffset.x += moveThing;
			topCharacterCamPoint.setPosition(topCharacter.getMidpoint().x + topCharacter.focusOffset.x, topCharacter.getMidpoint().y + topCharacter.focusOffset.y);
			trace("cam diff: " + (bottomCharacterCamPoint.x - topCharacterCamPoint.x) + ", " + (bottomCharacterCamPoint.y - topCharacterCamPoint.y));
		}



		if (FlxG.keys.justPressed.SPACE){
			var newX = (topCharacter.x - originalPoint.x);
			var newY = (topCharacter.y - originalPoint.y);
			trace("");
			trace("repos  : " + (topCharacter.characterInfo.info.extraData.get("reposition")[0] + newX) + ", " + (topCharacter.characterInfo.info.extraData.get("reposition")[1] + newY));
			trace("reposFl: " + (topCharacter.characterInfo.info.extraData.get("repositionFlipped")[0] + newX) + ", " + (topCharacter.characterInfo.info.extraData.get("repositionFlipped")[1] + newY));
			trace("cam pos: " + (topCharacter.focusOffset.x * (topCharacter.isPlayer ? -1 : 1)) + ", " + (topCharacter.focusOffset.y));
			trace("off dif: " + (offsetDiff.x) + ", " + (offsetDiff.y));
			trace("pos dif: " + (topCharacter.x - topCharOriginalPos.x) + ", " + (topCharacter.y - topCharOriginalPos.y));
			trace("");
		}

		super.update(elapsed);
	}

}
