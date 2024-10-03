package cutscenes.data;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class PicoDoppleganger extends ScriptedCutscene
{

    var opPico:AtlasSprite;
    var playerPico:AtlasSprite;

    var playerCigarette:Bool;
    var fuckingDie:Bool;

    var originalZoom:Float;

    override function init():Void{

        playerCigarette = FlxG.random.bool(50);
        fuckingDie = FlxG.random.bool(8);

        originalZoom = playstate.defaultCamZoom;

        opPico = new AtlasSprite(307, 800, Paths.getTextureAtlas("week3/philly/erect/pico_doppleganger"));
        opPico.antialiasing = true;
        opPico.addAnimationByLabel("shootOpponent", "shootOpponent", 24, false);
        opPico.addAnimationByLabel("cigaretteOpponent", "cigaretteOpponent", 24, false);
        opPico.shader = dad.getShader();

        playerPico = new AtlasSprite(847, 787, Paths.getTextureAtlas("week3/philly/erect/pico_doppleganger"));
        playerPico.antialiasing = true;
        playerPico.addAnimationByLabel("cigarettePlayer", "cigarettePlayer", 24, false);
        playerPico.addAnimationByLabel("shootPlayer", "shootPlayer", 24, false);
        playerPico.shader = boyfriend.getShader();
        playerPico.animationEndCallback = function(name){
            end();
        };

        addEvent(0, first);
        addEvent(0.3, gaspSound);
        addEvent(4, panCamera);
        addEvent(6.29, shootSound);
        addEvent(10.33, spinSound);
        addEvent(8.75, panCamera);
        if(!fuckingDie){
            addEvent(3.7, cigaretteSound);
        }
        else{
            addEvent(3.7, cigaretteSoundExplode);
            addEvent(8.75, explodeSound);
        }
    }

    override function update(elapsed:Float) {

        /*var mod = 1;
        if(FlxG.keys.anyPressed([SHIFT])){
            mod = 20;
        }

        if(FlxG.keys.anyJustPressed([W])){ opPico.y -= mod; }
        if(FlxG.keys.anyJustPressed([S])){ opPico.y += mod; }
        if(FlxG.keys.anyJustPressed([A])){ opPico.x -= mod; }
        if(FlxG.keys.anyJustPressed([D])){ opPico.x += mod; }

        if(FlxG.keys.anyJustPressed([UP])){ playerPico.y -= mod; }
        if(FlxG.keys.anyJustPressed([DOWN])){ playerPico.y += mod; }
        if(FlxG.keys.anyJustPressed([LEFT])){ playerPico.x -= mod; }
        if(FlxG.keys.anyJustPressed([RIGHT])){ playerPico.x += mod; }

        if(FlxG.keys.anyJustPressed([SPACE])){
            trace("op: " + opPico.getPosition());
            trace("pl: " + playerPico.getPosition());
        }

        if(FlxG.keys.anyJustPressed([ONE])){
            opPico.playAnim("shootOpponent", true);
            opPico.pause();
            playerPico.playAnim("shootPlayer", true);
            playerPico.pause();
        }

        if(FlxG.keys.anyJustPressed([TWO])){
            opPico.resume();
            playerPico.resume();
        }*/

        super.update(elapsed);
    }

    function first(){

        if(playerCigarette){
            addToCharacterLayer(playerPico);
            addToCharacterLayer(opPico);
            opPico.playAnim("shootOpponent");
            playerPico.playAnim("cigarettePlayer");
        }
        else{
            addToCharacterLayer(opPico);
            addToCharacterLayer(playerPico);
            opPico.playAnim("cigaretteOpponent");
            playerPico.playAnim("shootPlayer");
        }

        playstate.camChangeZoom(originalZoom * 1.5, 0);        
        playstate.camChangeZoom(originalZoom, 1.5, FlxEase.expoOut);        

        boyfriend.visible = false;
        dad.visible = false;
        gf.playAnim("idleLoop", true);

        if(fuckingDie){
            FlxG.sound.play(Paths.music("week3/cutscene/cutscene2"));
        }
        else{
            FlxG.sound.play(Paths.music("week3/cutscene/cutscene"));
        }

    }

    function gaspSound(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoGasp"));
    }

    function panCamera(){
        if(playerCigarette){ playstate.camFocusBF(); }
        else{ playstate.camFocusOpponent(); }
    }

    function shootSound(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoShoot"));
        if(playerCigarette){ playstate.camFocusOpponent(); }
        else{ playstate.camFocusBF(); }
    }

    function spinSound(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoSpin"));
    }

    function cigaretteSound(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoCigarette"));
    }

    function cigaretteSoundExplode(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoCigarette2"));
    }

    function explodeSound(){
        FlxG.sound.play(Paths.sound("week3/cutscene/picoExplode"));
    }

    function end(){
        removeFromCharacterLayer(opPico);
        removeFromCharacterLayer(playerPico);
        boyfriend.visible = true;
        dad.visible = true;
        next();
    }

}