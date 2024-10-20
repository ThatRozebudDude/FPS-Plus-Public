package events.data;

class HudEvents extends Events
{

    override function defineEvents() {
        addEvent("setHudSkin", setHudSkin, SET_HUD_SKIN_DESC);
        addEvent("hudVisible", hudVisible, HUD_VISIBLE_DESC);
    }

    function setHudSkin(tag:String):Void{
        var args = Events.getArgs(tag, ["Default"]);
        playstate.regenerateUiSkin(args[0]);
    }

    function hudVisible(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.camHUD.visible = Events.parseBool(args[0]);
    }
    


    //Event descriptions. Not required but it helps with charting.
    static inline final SET_HUD_SKIN_DESC:String = "Changes the HUD note skin.\n\nArgs:\n    String: Skin name";
    static inline final HUD_VISIBLE_DESC:String = "Sets the visibility of the HUD.\n\nArgs:\n    Bool: HUD visibility";
}