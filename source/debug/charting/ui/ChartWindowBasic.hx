package debug.charting.ui;

import haxe.ui.containers.dialogs.CollapsibleDialog;
import flixel.FlxG;

@:access(debug.charting.ChartingState)
class ChartWindowBasic extends CollapsibleDialog
{
	public var editor:ChartingState = null;

	public function new(_instance:ChartingState)
	{
		super();

		editor = _instance;
		editor.root.addComponent(this);
	}

	public function close()
	{
		//FlxG.sound.play(Paths.sound('chartingSounds/openWindow'));
		hide();
	}

	public function open()
	{
		//FlxG.sound.play(Paths.sound('chartingSounds/openWindow'));
		showDialog(false);
	}
}