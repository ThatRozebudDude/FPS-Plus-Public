package freeplay;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import flixel.util.FlxTimer;

using StringTools;

typedef CharacterData = {
    var atlas:String;
    var skin:String;
    var selectColor:String;
    var deselectColor:String;
    var selectOutlineColor:String;
    var deselectOutlineColor:String;

    var songs:Array<SongData>;
}

typedef SongData = {
	var name:String;
	var icon:String;
	var category:Array<String>;
    var week:Int;
}

typedef AnimationData = {
	var name:String;
	var frame:String;
	var category:Array<String>;
}

class DJCharacter extends AtlasSprite
{
    public var characterName:String = "bf";
    public var characterData:CharacterData;
    public var introFinish:Void->Void;
    public var freeplaySkin:String = "";
    public var capsuleSelectColor:FlxColor = 0xFFFFFFFF;
    public var capsuleDeselectColor:FlxColor = 0xFF969A9D;
    public var capsuleSelectOutlineColor:FlxColor = 0xFF6B9FBA;
    public var capsuleDeselectOutlineColor:FlxColor = 0xFF3E508C;

    public var songsList:Array<SongData> = [];
    public var freeplayCategories:Array<String> = [];
    public var freeplaySongs:Array<Array<Dynamic>> = [];

    var skipNextIdle:Bool = false;

    public var backingCard:FlxSpriteGroup = new FlxSpriteGroup();

    public function new(chr) {
        super(0, 0, null);
        //doing null safe thing but idk
        //characterName = "bf";
        characterName = chr;
        //setup
        characterData = Json.parse(Utils.getText(Paths.json(chr, "data/freeplay")));

        setPosition(-9, 290);
        loadAtlas(Paths.getTextureAtlas(characterData.atlas));
        antialiasing = true;

        addAnimationByLabel('idle', "Idle", 24, true, -2);
        addAnimationByLabel('intro', "Intro", 24);
        addAnimationByLabel('confirm', "Confirm", 24, true, -8);
        addAnimationByLabel('cheerHold', "RatingHold", 24, true, 0);
        addAnimationByLabel('cheerWin', "Win", 24, true, -4);
        addAnimationByLabel('cheerLose', "Lose", 24, true, -4);
        addAnimationByLabel('jump', "Jump", 24, true, -4);

        animationEndCallback = function(name) {
            switch(name){
                case "intro":
                    introFinish();
                    skipNextIdle = true;
                    playAnim("idle", true);
                case "idle2start":
                    playAnim("idle2loop", true);
            }
        }

        freeplaySkin = characterData.skin;

        capsuleSelectColor = FlxColor.fromString(characterData.selectColor);
        capsuleDeselectColor = FlxColor.fromString(characterData.deselectColor);
        capsuleSelectOutlineColor = FlxColor.fromString(characterData.selectOutlineColor);
        capsuleDeselectOutlineColor = FlxColor.fromString(characterData.deselectOutlineColor);
        
        songsList = characterData.songs;
        
        createCategory("ALL");
        for (song in songsList) {
            addSong(song.name, song.icon, song.week, song.category);
        }
    }

    public function beat(curBeat:Int):Void{}

    public function buttonPress():Void {

    }

    public function playIdle():Void {
        playAnim("idle", true);
    }
    public function playIntro():Void {
        playAnim("intro", true);
    }
    public function playConfirm():Void{
        playAnim("confirm", true);
    }
    public function playCheer(lostSong:Bool):Void {
        playAnim("cheerHold", true);
        new FlxTimer().start(1.3, function(t){
            if(!lostSong)
                playAnim("cheerWin", true);
            else
                playAnim("cheerLose", true);
        });
    }
    public function toCharacterSelect():Void {
        playAnim("jump", true);
    }

    public function backingCardStart():Void{}
    public function backingCardSelect():Void{}

    function createCategory(name:String):Void{
        if(!freeplayCategories.contains(name)){
			freeplayCategories.push(name);
		}
    }

    function addSong(name:String, character:String, week:Int = 0, categories:Array<String>):Void{
        var categ = categories;
        if (!categories.contains("ALL")) {
            categ = categories.concat(["ALL"]);
        }
        freeplaySongs.push([name, character, week, categ]);
		for(cat in categories){
			createCategory(cat);
		}
    }

}