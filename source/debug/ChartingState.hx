package debug;

import haxe.ui.backend.flixel.UIState;
import flixel.FlxG;
import config.Config;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("art/ui/chartEditor.xml"))
class ChartingState extends UIState
{
    public static var instance:ChartingState = null;

    override function create()
    {
        super.create();

        instance = this;

        Config.setFramerate(120);

		PlayState.fromChartEditor = true;
		SaveManager.global();

        FlxG.mouse.visible = true;
    }
}