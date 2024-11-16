package characterSelect;

import flixel.math.FlxPoint;
import shaders.HueShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import characterSelect.CharacterSelectState.CharacterSelectGroup;
import flixel.group.FlxSpriteGroup;

class CharacterGrid extends FlxSpriteGroup
{

    var grid:Array<Array<FlxSprite>> = [[]];
    var gridArea:Int;

    var cursor:FlxSprite;
    var cursorBack:FlxSprite;
    var cursorFarBack:FlxSprite;

    var cursorPos:FlxPoint = new FlxPoint();
    var cursorBackPos:FlxPoint = new FlxPoint();
    var cursorFarBackPos:FlxPoint = new FlxPoint();

    var cursorConfrim:FlxSprite;
    var cursorDeny:FlxSprite;

    public var forceTrackPosition:Array<Int> = null;

    public function new(_x:Float = 0, _y:Float = 0, _width:Int, _height:Int, _characterMap:Map<String, CharacterSelectGroup>){
        super(_x,_y);

        gridArea = _width * _height;

        var iconGrid = [];
        for(i in 0..._width){
            var column = [];
            for(j in 0..._height){
                var found:Bool = false;
                for(key => val in _characterMap){
                    if(val.position[0] == i && val.position[1] == j){
                        column.push(key);
                        found = true;
                        break;
                    }
                }
                if(!found){
                    column.push("");
                }
            }
            iconGrid.push(column);
        }

        cursorFarBack = new FlxSprite().loadGraphic(Paths.image("menu/characterSelect/charSelector"));
        cursorFarBack.antialiasing = true;
        cursorFarBack.color = 0xFF3C74F7;
        cursorFarBack.blend = ADD;
        add(cursorFarBack);

        cursorBack = new FlxSprite().loadGraphic(Paths.image("menu/characterSelect/charSelector"));
        cursorBack.antialiasing = true;
        cursorBack.color = 0xFF3EBBFF;
        cursorBack.blend = ADD;
        add(cursorBack);

        cursor = new FlxSprite().loadGraphic(Paths.image("menu/characterSelect/charSelector"));
        cursor.antialiasing = true;
        add(cursor);
        FlxTween.color(cursor, 0.2, 0xFFFFFF00, 0xFFFFCF00, {type: PINGPONG});

        cursorConfrim = new FlxSprite();
        cursorConfrim.frames = Paths.getSparrowAtlas("menu/characterSelect/charSelectorConfirm");
        cursorConfrim.animation.addByPrefix("shake", "", 24, false);
        cursorConfrim.antialiasing = true;
        cursorConfrim.visible = false;
        add(cursorConfrim);

        cursorDeny = new FlxSprite();
        cursorDeny.frames = Paths.getSparrowAtlas("menu/characterSelect/charSelectorDenied");
        cursorDeny.animation.addByPrefix("shake", "", 24, false);
        cursorDeny.antialiasing = true;
        cursorDeny.visible = false;
        add(cursorDeny);

        var idCount = 0;

        for(gx in 0...iconGrid.length){
            for(gy in 0...iconGrid[gx].length){
                var testGraphic:FlxSprite;
                if(iconGrid[gx][gy] != ""){
                    testGraphic = new FlxSprite(40, 40);
                    testGraphic.frames = Paths.getSparrowAtlas("menu/characterSelect/characters/" + iconGrid[gx][gy] + "/icon");
                    testGraphic.antialiasing = true;
                    testGraphic.animation.addByPrefix("hold", "", 0, false);
                    testGraphic.animation.addByPrefix("play", "", 24, false);
                    testGraphic.animation.play("hold");
                    testGraphic.x -= testGraphic.width/2;
                    testGraphic.y -= testGraphic.height/2;
                    testGraphic.ID = idCount;
                }
                else{
                    testGraphic = new FlxSprite(40, 40).loadGraphic(Paths.image("menu/characterSelect/lock"));
                    testGraphic.antialiasing = true;
                    testGraphic.x -= testGraphic.width/2;
                    testGraphic.y -= testGraphic.height/2;
                    var lockShader = new HueShader((15 * gx) + (30 * gy));
                    testGraphic.shader = lockShader.shader;
                    testGraphic.ID = idCount + gridArea;
                }
                testGraphic.x += 100 * gx;
                testGraphic.y += 100 * gy;

                grid[gx].push(testGraphic);
                add(testGraphic);
                idCount++;
            }
            grid.push([]);
        }
        
    }

    override function update(elapsed:Float):Void{

        if(forceTrackPosition != null){
            select(forceTrackPosition, true);
        }

        cursor.setPosition(cursorPos.x + x, cursorPos.y + y);
        cursorBack.setPosition(cursorBackPos.x + x, cursorBackPos.y + y);
        cursorFarBack.setPosition(cursorFarBackPos.x + x, cursorFarBackPos.y + y);

        super.update(elapsed);
    }

    public function select(pos:Array<Int>, ?instant:Bool = false):Void{
        for(gx in 0...grid.length){
            for(gy in 0...grid[gx].length){
                if(gx == pos[0] && gy == pos[1]){
                    FlxTween.cancelTweensOf(grid[gx][gy].scale);
                    FlxTween.tween(grid[gx][gy].scale, {x: 1, y: 1}, 0.4, {ease: FlxEase.expoOut});

                    FlxTween.cancelTweensOf(cursorPos);
                    FlxTween.cancelTweensOf(cursorBackPos);
                    FlxTween.cancelTweensOf(cursorFarBackPos);
                    
                    if(!instant){
                        FlxTween.tween(cursorPos, {x: (40 + (100 * gx)) - cursor.width/2, y: (40 + (100 * gy)) - cursor.height/2}, 0.25, {ease: FlxEase.expoOut});
                        FlxTween.tween(cursorBackPos, {x: (40 + (100 * gx)) - cursorBack.width/2, y: (40 + (100 * gy)) - cursorBack.height/2}, 0.5, {ease: FlxEase.expoOut});
                        FlxTween.tween(cursorFarBackPos, {x: (40 + (100 * gx)) - cursor.width/2, y: (40 + (100 * gy)) - cursor.height/2}, 0.75, {ease: FlxEase.expoOut});
                    }
                    else{
                        cursorPos.set((40 + (100 * gx)) - cursor.width/2, (40 + (100 * gy)) - cursor.height/2);
                        cursorBackPos.set((40 + (100 * gx)) - cursorBack.width/2, (40 + (100 * gy)) - cursorBack.height/2);
                        cursorFarBackPos.set((40 + (100 * gx)) - cursorFarBack.width/2, (40 + (100 * gy)) - cursorFarBack.height/2);
                    }
                }
                else{
                    FlxTween.cancelTweensOf(grid[gx][gy].scale);
                    FlxTween.tween(grid[gx][gy].scale, {x: 0.83, y: 0.83}, 0.4, {ease: FlxEase.expoOut});
                }
            }
        }
    }

    public function confirm(pos:Array<Int>){
        cursorConfrim.animation.play("shake", true);
        cursorConfrim.visible = true;
        cursorConfrim.setPosition(grid[pos[0]][pos[1]].getMidpoint().x - cursorConfrim.width/2, grid[pos[0]][pos[1]].getMidpoint().y - cursorConfrim.height/2);
        cursor.visible = false;
        cursorBack.visible = false;
        cursorFarBack.visible = false;
        select(pos, true);
        if(grid[pos[0]][pos[1]].ID < gridArea){
            grid[pos[0]][pos[1]].animation.play("play", true);
        }
    }

    public function deny(pos:Array<Int>){
        cursorDeny.animation.play("shake", true);
        cursorDeny.visible = true;
        cursorDeny.setPosition(grid[pos[0]][pos[1]].getMidpoint().x - cursorDeny.width/2, grid[pos[0]][pos[1]].getMidpoint().y - cursorDeny.height/2);
        cursor.visible = false;
        cursorBack.visible = false;
        cursorFarBack.visible = false;
        select(pos, true);
    }

    public function showNormalCursor(){
        cursorConfrim.visible = false;
        cursorDeny.visible = false;
        cursor.visible = true;
        cursorBack.visible = true;
        cursorFarBack.visible = true;
    }

    public function reverseIcon(pos:Array<Int>){
        if(grid[pos[0]][pos[1]].ID < gridArea){
            grid[pos[0]][pos[1]].animation.play("play", true, true);
        }
    }

}