package results;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import Highscore.Rank;
import flixel.group.FlxSpriteGroup;
import Utils.OrderedMap;

class ResultsCharacter extends FlxSpriteGroup
{

    var character:String;
    var rank:Rank;

    var flxSprites:OrderedMap<String, FlxSprite> = new OrderedMap<String, FlxSprite>();
    var atlasSprites:OrderedMap<String, AtlasSprite> = new OrderedMap<String, AtlasSprite>();

    public function new(_character:String, _rank:Rank) {
        super();

        character = _character;
        rank = _rank;

        switch(character){
            default:
                switch(rank){
                    case perfect | gold :
                        var bf = new AtlasSprite(1342, 370, Paths.getTextureAtlas("menu/results/characters/bf/perfect"));
                        bf.visible = false;
                        bf.addAnimationByFrame("anim", 0, null, 24, true, 137);
                        bf.antialiasing = true;

                        var hearts = new AtlasSprite(1342, 370, Paths.getTextureAtlas("menu/results/characters/bf/perfect/hearts"));
                        hearts.visible = false;
                        hearts.addAnimationByFrame("anim", 0, null, 24, true, 43);
                        hearts.antialiasing = true;

                        atlasSprites.set("bf", bf);
                        atlasSprites.set("hearts", hearts);

                    case excellent:
                        var bf = new AtlasSprite(1329, 429, Paths.getTextureAtlas("menu/results/characters/bf/excellent"));
                        bf.visible = false;
                        bf.addAnimationByFrame("anim", 0, null, 24, true, 28);
                        bf.antialiasing = true;

                        atlasSprites.set("bf", bf);

                    case great:
                        var gf = new AtlasSprite(802, 331, Paths.getTextureAtlas("menu/results/characters/bf/great/gf"));
                        gf.visible = false;
                        gf.scale.set(0.93, 0.93);
                        gf.addAnimationByFrame("anim", 0, null, 24, true, 9);
                        gf.antialiasing = true;

                        var bf = new AtlasSprite(929, 363, Paths.getTextureAtlas("menu/results/characters/bf/great/bf"));
                        bf.visible = false;
                        bf.scale.set(0.93, 0.93);
                        bf.addAnimationByFrame("anim", 0, null, 24, true, 15);
                        bf.antialiasing = true;

                        atlasSprites.set("gf", gf);
                        atlasSprites.set("bf", bf);

                    case loss:
                        var bf = new AtlasSprite(0, 20, Paths.getTextureAtlas("menu/results/characters/bf/loss"));
                        bf.visible = false;
                        bf.addAnimationByLabel("intro", "Intro", 24, false);
                        bf.addAnimationByLabel("loop", "Loop Start", 24, true);
                        bf.antialiasing = true;
                        bf.animationEndCallback = function(name) {
                            if(name == "intro"){
                                bf.playAnim("loop", true);
                            }
                        }

                        atlasSprites.set("bf", bf);

                    default:
                        var gf = new FlxSprite(625, 325);
                        gf.frames = Paths.getSparrowAtlas("menu/results/characters/bf/good/gf");
                        gf.animation.addByPrefix("clap", "Girlfriend Good Anim", 24, false);
                        gf.visible = false;
                        gf.antialiasing = true;
                        gf.animation.finishCallback = function(name){
                            gf.animation.play('clap', true, false, 9);
                        };

                        var bf = new FlxSprite(640, -200);
                        bf.frames = Paths.getSparrowAtlas("menu/results/characters/bf/good/bf");
                        bf.animation.addByPrefix("fall", "Boyfriend Good Anim0", 24, false);
                        bf.visible = false;
                        bf.antialiasing = true;
                        bf.animation.finishCallback = function(name) {
                            bf.animation.play('fall', true, false, 14);
                        };

                        flxSprites.set("gf", gf);
                        flxSprites.set("bf", bf);

                }
        }

        for(key in flxSprites.keys){
            add(flxSprites.get(key));
        }

        for(key in atlasSprites.keys){
            add(atlasSprites.get(key));
        }

    }

    public function playAnim():Void{
        switch(character){
            default:
                switch(rank){
                    case perfect | gold:
                        atlasSprites.get("bf").playAnim("anim", true);
                        atlasSprites.get("bf").visible = true;
                        new FlxTimer().start((106/24), function(t){
                            atlasSprites.get("hearts").playAnim("anim", true);
                            atlasSprites.get("hearts").visible = true;
                        });
                    case excellent:
                        atlasSprites.get("bf").playAnim("anim", true);
                        atlasSprites.get("bf").visible = true;
                    case great:
                        atlasSprites.get("bf").playAnim("anim", true);
                        atlasSprites.get("bf").visible = true;
                        new FlxTimer().start((6/24), function(t){
                            atlasSprites.get("gf").playAnim("anim", true);
                            atlasSprites.get("gf").visible = true;
                        });
                    case loss:
                        atlasSprites.get("bf").playAnim("intro", true);
                        atlasSprites.get("bf").visible = true;
                    default:
                        flxSprites.get("bf").animation.play('fall', true);
                        flxSprites.get("bf").visible = true;
                        new FlxTimer().start((22/24), function(t){
                            flxSprites.get("gf").animation.play('clap', true);
                            flxSprites.get("gf").visible = true;
                        });
                }
        }
    }

}