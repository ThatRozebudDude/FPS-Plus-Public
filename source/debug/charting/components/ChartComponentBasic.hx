package debug.charting.components;

import flixel.group.FlxSpriteGroup;

using StringTools;
/*
	A freely extensible (and soon scriptable) basic chart editor component.

	@author Sulkiez
*/
class ChartComponentBasic extends FlxSpriteGroup
{
	public var editor:ChartingState = null;

	override public function new(x:Float, y:Float, _editor:ChartingState)
	{
		super(x, y);

		editor = _editor;

		create();
	}

	public function create() {}

	public function changeSection(sec:Int, updateMusic:Bool) {}

	public function resetSection(songBeginning:Bool) {}
}