package debug.charting.ui;
import haxe.ui.components.*;

//Unused. keeping for custom window example.
@:access(debug.charting.ChartingState)

@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/ui.xml"))
class SectionWindow extends ChartWindowBasic
{
	override public function new(instance:ChartingState)
	{
		super(instance);
	}
}