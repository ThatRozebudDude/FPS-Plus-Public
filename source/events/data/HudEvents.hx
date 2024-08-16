package events.data;

class HudEvents extends Events
{

    override function defineEvents() {
        addEvent("setHudSkin", setHudSkin);
        addEvent("hudVisible", hudVisible);
    }

    function setHudSkin(tag:String):Void{
        var args = Events.getArgs(tag, ["Default"]);
        playstate.regenerateUiSkin(args[0]);
    }

    function hudVisible(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.camHUD.visible = Events.parseBool(args[0]);
    }
}