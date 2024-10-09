package cutscenes.data;

import transition.data.InstantTransition;
import flixel.sound.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;

class LilBuddiesIntro extends ScriptedCutscene
{
    
    override function init():Void{
        if(PlayState.fceForLilBuddies){
            addEvent(0, lilBuddiesIntro);
        }
        else{
            addEvent(0, noIntro);
        }
    }

    function lilBuddiesIntro() {
        playstate.instantStart();

		playstate.healthBar.alpha = 0;
		playstate.healthBarBG.alpha = 0;
		playstate.iconP1.alpha = 0;
		playstate.iconP2.alpha = 0;
		playstate.scoreTxt.alpha = 0;

        for(x in playstate.playerStrums.members){
			x.alpha = 0;
		}
		for(x in playstate.enemyStrums.members){
			x.alpha = 0;
		}

		playstate.customTransIn = new InstantTransition();

		playstate.autoZoom = false;
		var hudElementsFadeInTime = 0.2;
		
		playstate.camChangeZoom(2.8, Conductor.crochet / 1000 * 16, FlxEase.quadInOut, function(t){
			playstate.autoZoom = true;
			tween.tween(playstate.healthBar, {alpha: 1}, hudElementsFadeInTime);
			tween.tween(playstate.healthBarBG, {alpha: 1}, hudElementsFadeInTime);
			tween.tween(playstate.iconP1, {alpha: 1}, hudElementsFadeInTime);
			tween.tween(playstate.iconP2, {alpha: 1}, hudElementsFadeInTime);
			tween.tween(playstate.scoreTxt, {alpha: 1}, hudElementsFadeInTime);
			for(x in playstate.playerStrums.members){
				tween.tween(x, {alpha: 1}, hudElementsFadeInTime);
			}
			for(x in playstate.enemyStrums.members){
				tween.tween(x, {alpha: 1}, hudElementsFadeInTime);
			}
		});
		playstate.camMove(155, 600, Conductor.crochet / 1000 * 16, FlxEase.quadOut, "center");
    }

	function noIntro():Void{
		next(false);
	}

}