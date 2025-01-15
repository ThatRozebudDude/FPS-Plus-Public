package debug.charting.components;

import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import note.Note;
import haxe.ui.focus.FocusManager;
import flixel.FlxSprite;

/*
	Little, current chart preview buddies.

	@author Rozebud
*/

class LilBuddies extends ChartComponentBasic
{

	public var lilStage:FlxSprite;
	public var lilBf:FlxSprite;
	public var lilOpp:FlxSprite;

	override public function create()
	{
		super.create();

		editor.add(this);
	
		scrollFactor.set();
	
		lilStage = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilStage"));
		add(lilStage);

		lilBf = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilBf"), true, 300, 256);
		lilBf.animation.add("idle", [0, 1], 12, true);
		lilBf.animation.add("0", [3, 4, 5], 12, false);
		lilBf.animation.add("1", [6, 7, 8], 12, false);
		lilBf.animation.add("2", [9, 10, 11], 12, false);
		lilBf.animation.add("3", [12, 13, 14], 12, false);
		lilBf.animation.add("yeah", [17, 20, 23], 12, false);
		lilBf.animation.play("idle");
		lilBf.animation.finishCallback = function(name:String){
			lilBf.animation.play(name, true, false, lilBf.animation.getByName(name).numFrames - 2);
		}
		add(lilBf);

		lilOpp = new FlxSprite().loadGraphic(Paths.image("chartEditor/lilOpp"), true, 300, 256);
		lilOpp.animation.add("idle", [0, 1], 12, true);
		lilOpp.animation.add("0", [3, 4, 5], 12, false);
		lilOpp.animation.add("1", [6, 7, 8], 12, false);
		lilOpp.animation.add("2", [9, 10, 11], 12, false);
		lilOpp.animation.add("3", [12, 13, 14], 12, false);
		lilOpp.animation.play("idle");
		lilOpp.animation.finishCallback = function(name:String){
			lilOpp.animation.play(name, true, false, lilOpp.animation.getByName(name).numFrames - 2);
		}
		add(lilOpp);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FocusManager.instance.focus == null)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");
					}
				else
				{
					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");
				}
			}
			if (FlxG.mouse.wheel != 0){
				lilBf.animation.play("idle");
				lilOpp.animation.play("idle");
			}

			if (!FlxG.keys.pressed.SHIFT){
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN){
					lilBf.animation.play("idle");
					lilOpp.animation.play("idle");
				}
			} else {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN){
					if(FlxG.sound.music.playing){
						lilBf.animation.play("idle");
						lilOpp.animation.play("idle");
					}
				}
			}
			if(!editor.justChanged){
				editor.curRenderedNotes.forEach(function(x:Note) {

					if(x.absoluteNumber < 4 && editor._song.notes[editor.curSection].mustHitSection){
						x.editorBFNote = true;
					}
					else if(x.absoluteNumber > 3 && !editor._song.notes[editor.curSection].mustHitSection){
						x.editorBFNote = true;
					}
					
					if(x.y < editor.strumLine.y && !x.playedEditorClick && FlxG.sound.music.playing){
						if(x.editorBFNote){
							if(editor.bfClickSoundCheck.selected){ FlxG.sound.play(Paths.sound("tick"), 0.6); }
							lilBf.animation.play("" + (x.noteData % 4), true);
						}
						else if(!x.editorBFNote){
							if(editor.oppClickSoundCheck.selected){ FlxG.sound.play(Paths.sound("tick"), 0.6); }
							lilOpp.animation.play("" + (x.noteData % 4), true);
						}
					}
	
					if(x.y > editor.strumLine.y && x.alpha != 0.4){
						x.playedEditorClick = false;
					}
	
					if(x.y < editor.strumLine.y && x.alpha != 0.4){
						x.playedEditorClick = true;
					}
	
				});
			}
		}
	}

	override public function resetSection(songBeginning:Bool)
	{
		super.resetSection(songBeginning);

		lilBf.animation.play("idle");
		lilOpp.animation.play("idle");
	}

	override public function changeSection(sec:Int, updateMusic:Bool)
	{
		super.changeSection(sec, updateMusic);
		if (updateMusic)
		{
			lilBf.animation.play("idle");
			lilOpp.animation.play("idle");
		}

		lilBf.animation.play("idle");
		lilOpp.animation.play("idle");
	}
}