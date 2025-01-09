package debug.charting.ui;
import haxe.ui.components.*;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ArrayDataSource;
import events.Events;

//Unused. keeping for custom window example.
@:access(debug.charting.ChartingState)

@:build(haxe.ui.ComponentBuilder.build("art/ui/chart/eventWindow.xml"))
class EventWindow extends ChartWindowBasic
{
	override public function new(instance:ChartingState)
	{
		super(instance);

		usedEventsDrop.dataSource = ArrayDataSource.fromArray(editor.eventTagList);
		usedEventsDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
			eventField.text = usedEventsDrop.text;
			editor.updateEventDescription();
		});

		for(prefix in Events.events.keys()){
			editor.allEventPrefixes.push(prefix);
		}

		editor.allEventPrefixes.sort(function(a:String, b:String):Int{
			a = a.toUpperCase();
			b = b.toUpperCase();
			if(a < b){ return -1; }
			else if(a > b){ return 1; }
			else{ return 0; }
		});

		eventsPrefixesDrop.dataSource = ArrayDataSource.fromArray(editor.allEventPrefixes);

		eventsPrefixesDrop.registerEvent(UIEvent.CLOSE, function(e)
		{
			eventField.text = eventsPrefixesDrop.text;
			editor.updateEventDescription();
		});
	}
}