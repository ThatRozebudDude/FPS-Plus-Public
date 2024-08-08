package events.data;

class CaptionEvents extends Events
{

    override function defineEvents() {
        addEvent("cc", cc);
        addEvent("ccHide", ccHide);
    }

    function cc(tag:String):Void{
        var args = Events.getArgs(tag);
		playstate.ccText.display(args[0]);
    }

    function ccHide(tag:String):Void{
        playstate.ccText.hide();
    }

}