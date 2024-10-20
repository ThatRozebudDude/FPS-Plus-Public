package events.data;

class CaptionEvents extends Events
{

    override function defineEvents() {
        addEvent("cc", cc, CC_DESC);
        addEvent("ccHide", ccHide, CC_HIDE_DESC);
    }

    function cc(tag:String):Void{
        var args = Events.getArgs(tag);
		playstate.ccText.display(args[0]);
    }

    function ccHide(tag:String):Void{
        playstate.ccText.hide();
    }


    
    //Event descriptions. Not required but it helps with charting.
    static inline final CC_DESC:String = "Shows captions.\n\nArgs:\n    String: Text in the caption";
    static inline final CC_HIDE_DESC:String = "Hides the currently displayed captions.";
}