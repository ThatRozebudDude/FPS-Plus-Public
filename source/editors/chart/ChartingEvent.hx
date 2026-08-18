package editors.chart;

import Chart.EventDefinition;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import shaders.TintShader;

using StringTools;

class ChartingEvent extends FlxSprite
{

	public var lane:Int = 0;
	public var time:Float = 0;
	public var tag(default, set):String = "";

	public var updateVisibility:Bool = true;

	var tintShader:TintShader;

	public function new(){
		super(0, 0);
		tintShader = new TintShader(0xFFFFFFFF, 0);
		shader = tintShader.shader;
	}

	override function update(elapsed:Float){
		if(updateVisibility){
			var positionOnScreen:FlxPoint = getScreenPosition();
			visible = (positionOnScreen.y + ChartingState.GRID_SIZE >= 0 && positionOnScreen.y <= 720);
			positionOnScreen.put();
		}
		super.update(elapsed);
	}

	public function updateProperties(_x:Float, _y:Float, _lane:Int, _time:Float, _tag:String):Void{
		x = _x;
		y = _y;
		lane = _lane;
		time = _time;
		tag = _tag;
	}

	function setEventGraphic():Void{
		for(key => value in ChartingState.eventIconOverrides){
			if(tag == key){
				loadGraphic(Paths.image("fpsPlus/editors/chart/events/" + value));
				setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
				updateHitbox();
				return;
			}
		}

		//Makes sure that more specific overrides end up being used instead of stopping at the first one it finds.
		var specificity:Int = -1;
		var finalIconName:String = null;
		for(key => value in ChartingState.eventIconOverrides){
			if(tag.startsWith(key)){
				var newSpecificity = key.split(";").length;
				if(newSpecificity > specificity){
					specificity = newSpecificity;
					finalIconName = value;
				}
			}
		}
		if(finalIconName != null){
			loadGraphic(Paths.image("fpsPlus/editors/chart/events/" + finalIconName));
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
			return;
		}

		for(icon in ChartingState.eventIconList){
			if(tag == icon){
				loadGraphic(Paths.image("fpsPlus/editors/chart/events/" + icon));
				setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
				updateHitbox();
				return;
			}
		}
		for(icon in ChartingState.eventIconList){
			if(tag.startsWith(icon)){
				loadGraphic(Paths.image("fpsPlus/editors/chart/events/" + icon));
				setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
				updateHitbox();
				return;
			}
		}

		loadGraphic(Paths.image("fpsPlus/editors/chart/events/generic"));
		setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		updateHitbox();
	}

	public function set_tag(v:String):String{
		tag = v;
		setEventGraphic();
		return tag;
	}

	public function select():Void{
		tintShader.amount = 0.5;
	}

	public function deselect():Void{
		tintShader.amount = 0;
	}

	public inline function generateEventDefinition():EventDefinition{
		return {
			time: time,
			lane: lane,
			tag: tag
		};
	}

}