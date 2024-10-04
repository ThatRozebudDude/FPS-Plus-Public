package results.characters;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.ui.FileDialogType;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;

class Pico extends ResultsCharacter
{

    var pico:AtlasSprite;

    override function setup():Void{
        goldText =      ["PERFECT", "SHARPSHOOTER", "UNTOUCHABLE", "NOT A SCRATCH", "FLAWLESS", "CLEAN KILL", "TARGET ELIMINATED"];
        perfectText =   ["PERFECT", "MARKSMAN", "CAN'T MISS", "BULLSEYE", "CLEAN KILL", "TARGET ELIMINATED"];
        excellentText = ["EXCELLENT", "EXPERT", "AMAZING EXECUTION", "SUCCESSFUL", "TARGET ELIMINATED"];
        greatText =     ["GREAT", "MISSION COMPLETE", "NICE SHOT", "A JOB WELL DONE", "TARGET ELIMINATED"];
        goodText =      ["GOOD", "MISSION COMPLETE", "ACCEPTABLE PERFORMANCE", "A JOB WELL DONE", "TARGET ELIMINATED"];
        lossText =      ["BLAMMED", "TARGET ESCAPED", "MISSION FAILED", "NO PAY", "COULDN'T KEEP UP", "TOUGH SHIT"];

        switch(rank){
            case perfect | gold :
                pico = new AtlasSprite(385-100, 82-40, Paths.getTextureAtlas("menu/results/characters/pico/perfect"));
                pico.visible = false;
                pico.addAnimationByFrame("anim", 0, null, 24, true, 91);
                pico.antialiasing = true;
                pico.scale.set(0.88, 0.88);

                FlxG.sound.cache(Paths.music("results/pico/perfect-loop")); 

            case excellent:
                pico = new AtlasSprite(350+160, 25+85, Paths.getTextureAtlas("menu/results/characters/pico/excellent"));
                pico.visible = false;
                pico.addAnimationByFrame("anim", 0, null, 24, true, 32);
                pico.antialiasing = true;
                pico.scale.set(1.25, 1.25);

                FlxG.sound.cache(Paths.music("results/pico/excellent-loop")); 

            case loss:
                pico = new AtlasSprite(-185, -125, Paths.getTextureAtlas("menu/results/characters/pico/loss"));
                pico.visible = false;
                pico.addAnimationByFrame("anim", 0, null, 24, true, 0);
                pico.antialiasing = true;

                FlxG.sound.cache(Paths.music("results/pico/shit-loop")); 

            default:
                pico = new AtlasSprite(350+160, 25+85, Paths.getTextureAtlas("menu/results/characters/pico/good"));
                pico.visible = false;
                pico.addAnimationByFrame("anim", 0, null, 24, true, 41);
                pico.antialiasing = true;
                pico.scale.set(1.25, 1.25);

        }

        add(pico);
    }

    final lossWhiteColor = 0xFF000000;
    final lossBlackColor = 0xFF1E152D;
    final lossTextColor = 0xFF201739;

    override function playAnim():Void{
        pico.playAnim("anim", true);
        pico.visible = true;
        switch(rank){
            default:
                case loss:
                    pico.y += 720;

                    var dummyWhite:FlxSprite = new FlxSprite();
                    var dummyBlack:FlxSprite = new FlxSprite();
                    
                    for(text in ResultsState.instance.scrollingTextGroup){
                        text.color = lossTextColor;
                    }

                    FlxTween.color(dummyWhite, 1.5, gradientTopColor, lossWhiteColor, {ease: FlxEase.quintOut, onUpdate: function(t){
                        ResultsState.instance.bgShader.whiteColor = dummyWhite.color;
                    }});
                    FlxTween.color(dummyBlack, 1.5, gradientBottomColor, lossBlackColor, {ease: FlxEase.quintOut, onUpdate: function(t){
                        ResultsState.instance.bgShader.blackColor = dummyBlack.color;
                    }});

                    FlxTween.color(ResultsState.instance.extraGradient, 1.5, gradientBottomColor, lossBlackColor, {ease: FlxEase.quintOut}); 

                    FlxTween.tween(pico, {y: pico.y - 720}, 1.5, {ease: FlxEase.quintOut});

                    ResultsState.instance.camBg.stopFlash();
                    ResultsState.instance.scrollingTextGroup.visible = false;
                    ResultsState.instance.scrollingRankName.visible = false;
                    ResultsState.instance.scrollingRankName.x += 60;

                    new FlxTimer().start(5.333, function(t){
                        ResultsState.instance.scrollingTextGroup.visible = true;
                        ResultsState.instance.camBg.flash(lossTextColor, 1);
                        ResultsState.instance.scrollingRankName.visible = true;
                        ResultsState.instance.scrollingRankName.y -= 210;
                        ResultsState.instance.scrollingRankName.velocity.y = 0;
                        FlxTween.tween(ResultsState.instance.scrollingRankName, {x: ResultsState.instance.scrollingRankName.x - 60}, 1.5, {ease: FlxEase.quintOut});
                        FlxTween.tween(ResultsState.instance.scrollingRankName.velocity, {y: 30}, 1.5, {ease: FlxEase.quintOut});
                    });
        }
    }

    override function playIntroSong():Void{
        FlxG.sound.playMusic(Paths.music("results/bf/excellent-intro"), 1, false);
    }

    override function playSong():Void{
        switch(rank){
            case perfect | gold:
                FlxG.sound.playMusic(Paths.music("results/pico/perfect-intro"), 1, true);
                FlxG.sound.music.onComplete = function() {
                    FlxG.sound.playMusic(Paths.music("results/pico/perfect-loop"), 1, true); 
                }
            case excellent:
                FlxG.sound.playMusic(Paths.music("results/pico/excellent-intro"), 1, true);
                FlxG.sound.music.onComplete = function() {
                    FlxG.sound.playMusic(Paths.music("results/pico/excellent-loop"), 1, true); 
                }
            case loss:
                FlxG.sound.playMusic(Paths.music("results/pico/shit-intro"), 1, true); 
                FlxG.sound.music.onComplete = function() {
                    FlxG.sound.playMusic(Paths.music("results/pico/shit-loop"), 1, true); 
                }
            default:
                FlxG.sound.playMusic(Paths.music("results/pico/normal"), 1, true); 
        }
    }

}