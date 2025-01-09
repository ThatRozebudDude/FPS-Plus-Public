package debug.charting.ui;

import haxe.ui.components.*;
import haxe.ui.data.ArrayDataSource;
import note.NoteType;

//Unused. keeping for custom window example.
@:access(debug.charting.ChartingState)

@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/noteWindow.xml"))
class NoteWindow extends ChartWindowBasic
{	
	override public function new(instance:ChartingState)
	{
		super(instance);

		var noteTypesArray:Array<String> = [""];
		for(k => v in NoteType.types){ noteTypesArray.push(k); }
		noteTypeDrop.dataSource = ArrayDataSource.fromArray(noteTypesArray);
		noteTypeDrop.text = noteTypesArray[0];
	}
}