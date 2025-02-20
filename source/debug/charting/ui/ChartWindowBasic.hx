package debug.charting.ui;

import haxe.ui.containers.dialogs.CollapsibleDialog;
import flixel.FlxG;

@:access(debug.charting.ChartingState)
class ChartWindowBasic extends CollapsibleDialog
{
	public var editor:ChartingState = null;

	public function new(_instance:ChartingState){
		super();

		editor = _instance;
		destroyOnClose = false;
		closable = false;
		editor.root.addComponent(this);
		close();
	}

	public function close()
	{
		trace("closing window!!!!");
		//FlxG.sound.play(Paths.sound('chartingSounds/openWindow'));
		visible = false;
		hide();
	}

	public function open()
	{
		trace("opening windoiw!!!!");
		//FlxG.sound.play(Paths.sound('chartingSounds/openWindow'));
		showDialog(false);
	}
}