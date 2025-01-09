package debug.charting.ui;
import haxe.ui.components.CheckBox;

@:access(debug.charting.ChartingState)
@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/sectionWindow.xml"))
class SectionWindow extends DialogueBasic
{
	public var mustHitCheck:CheckBox;

	override public function new(instance:ChartingState)
	{
		super(instance);

		clearSectionButton.onClick = function(e) editor.clearSection();
		
		clearOppButton.onClick = function(e) editor.clearSectionOpp();

		clearBfButton.onClick = function(e) editor.clearSectionBF();

		swapSectionButton.onClick = function(e) editor.swapSections();

		//Flips BF Notes
		flipBfButton.onClick = function(e)
		{
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			//[noteStrum, noteData, noteSus]
			for(x in editor._song.notes[editor.curSection].sectionNotes){
				if(editor._song.notes[editor.curSection].mustHitSection){
					if(x[1] < 4)
						x[1] = flipTable[x[1]];
				}
				else{
					if(x[1] > 3)
						x[1] = flipTable[x[1]];
				}
			}

			editor._song.notes[editor.curSection].sectionNotes.sort(editor.sortByNoteStuff);
			
			editor.updateGrid();
		};
		
		//Flips Opponent Notes
		flipOppButton.onClick = function(e){
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			//[noteStrum, noteData, noteSus]
			for(x in editor._song.notes[editor.curSection].sectionNotes){
				if(editor._song.notes[editor.curSection].mustHitSection){
					if(x[1] > 3)
						x[1] = flipTable[x[1]];
				}
				else{
					if(x[1] < 4)
						x[1] = flipTable[x[1]];
				}
			}

			editor._song.notes[editor.curSection].sectionNotes.sort(editor.sortByNoteStuff);
			
			editor.updateGrid();
		};

		mustHitCheck.selected = editor._song.notes[0].mustHitSection;
		mustHitCheck.onClick = function(e){
			editor._song.notes[editor.curSection].mustHitSection = mustHitCheck.selected;
			editor.updateHeads();
			editor.swapSections();
		}

		goSectionButton.onClick = function(e){
			editor.changeSection(Std.int(goSectionStepper.value), true);
			goSectionStepper.value = 0;
		};
	}
}