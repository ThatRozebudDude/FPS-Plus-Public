package debug.charting.ui;

import haxe.ui.components.*;
import characters.ScriptableCharacter;
import haxe.ui.data.ArrayDataSource;
import characters.CharacterInfoBase;
import haxe.ui.events.UIEvent;

//Unused. keeping for custom window example.
@:access(debug.charting.ChartingState)

@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/dataWindow.xml"))
class DataWindow extends ChartWindowBasic
{
	public var songNameField:TextField;
	public var bpmStepper:NumberStepper;

	public var bfDrop:DropDown;
	public var oppDrop:DropDown;
	
	override public function new(instance:ChartingState)
	{
		super(instance);

		songNameField.text = editor._song.song;

		scrollStepper.pos = editor._song.speed;
		scrollStepper.onClick = function(e){
			editor._song.speed = scrollStepper.pos;
		}

		bpmStepper.pos = Conductor.bpm;
		bpmStepper.onClick = function(e){
			editor.tempBpm = bpmStepper.pos;
			Conductor.mapBPMChanges(editor._song);
			Conductor.changeBPM(bpmStepper.pos);
		}

		var charactersList:Array<String> = [];
		var gfList:Array<String> = [];

		for(x in ScriptableCharacter.listScriptClasses()){
			final getScriptInfo:CharacterInfoBase = ScriptableCharacter.init(x);
			if(getScriptInfo.includeInCharacterList){ charactersList.push(x); }
			if(getScriptInfo.includeInGfList){ gfList.push(x); }
		}

		//makes them be in alphabetical order
		charactersList.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});
		gfList.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});

		bfDrop.dataSource = ArrayDataSource.fromArray(charactersList);
        bfDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
            editor._song.player1 = bfDrop.text;
            editor.updateHeads(true);
		});
		bfDrop.text = editor._song.player1;

        oppDrop.dataSource = ArrayDataSource.fromArray(charactersList);
        oppDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
            editor._song.player2 = oppDrop.text;
            editor.updateHeads(true);
		});
		oppDrop.text = editor._song.player2;

		gfDrop.dataSource = ArrayDataSource.fromArray(gfList);
        gfDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
            editor._song.gf = gfDrop.text;
		});
        gfDrop.text = editor._song.gf;

		//This is so dumbass
		var shit:Array<String> = [];
		for (key in editor.diffList.keys())
			shit.push(key);
		diffDrop.dataSource = ArrayDataSource.fromArray(shit);

        diffDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
			editor.diffDropFinal = editor.diffList.get(diffDrop.text);
			PlayState.storyDifficulty = shit.indexOf(diffDrop.text);
		});
        diffDrop.text = shit[PlayState.storyDifficulty];
		editor.diffDropFinal = editor.diffList.get(diffDrop.text);
	}
}