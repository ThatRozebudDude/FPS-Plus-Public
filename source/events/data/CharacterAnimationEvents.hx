package events.data;

class CharacterAnimationEvents extends Events
{

    override function defineEvents() {
        addEvent("playAnim", playAnim, PLAY_ANIM_DESC);
        addEvent("singAnim", singAnim, SING_ANIM_DESC);
        addEvent("setAnimSet", setAnimSet, SET_ANIM_SET_DESC);

        addEvent("gfBopFreq", gfBopFreq, GF_BOP_FREQ_DESC);
        addEvent("iconBopFreq", iconBopFreq, ICON_BOP_FREQ_DESC);

        addEvent("bfBop", bfBop, BF_BOP_DESC);
        addEvent("dadBop", dadBop, DAD_BOP_DESC);

        addEvent("bfAnimLockToggle", bfAnimLockToggle, BF_ANIM_LOCK_TOGGLE_DESC);
        addEvent("dadAnimLockToggle", dadAnimLockToggle, DAD_ANIM_LOCK_TOGGLE_DESC);
        addEvent("gfAnimLockToggle", gfAnimLockToggle, GF_ANIM_LOCK_TOGGLE_DESC);
    }

    function playAnim(tag:String):Void{
        var args = Events.getArgs(tag, ["bf", "", "false", "false", "0"]);

		switch(args[0]){
			case "dad":
				dad.playAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));

            case "gf":
				gf.playAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));

			default:
				boyfriend.playAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));
		}
    }

    function singAnim(tag:String):Void{
        var args = Events.getArgs(tag, ["bf", "", "false", "false", "0"]);

		switch(args[0]){
			case "dad":
				dad.singAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));

            case "gf":
				gf.singAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));

			default:
				boyfriend.singAnim(args[1], Events.parseBool(args[2]), Events.parseBool(args[3]), Std.parseInt(args[4]));
		}
    }

    function setAnimSet(tag:String):Void{
        var args = Events.getArgs(tag, ["bf", ""]);

		switch(args[0]){
			case "dad":
				dad.animSet = args[1];

			case "gf":
				gf.animSet = args[1];

			default:
				boyfriend.animSet = args[1];
		}
    }

    function gfBopFreq(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.gfBopFrequency = Std.parseInt(args[0]);
    }

    function iconBopFreq(tag:String):Void{
        var args = Events.getArgs(tag);
        playstate.iconBopFrequency = Std.parseInt(args[0]);
    }

    function bfBop(tag:String):Void{
        var args = Events.getArgs(tag);
        switch(args[0]){
            case "EveryBeat":
                playstate.bfBeats = [0, 1, 2, 3];
            case "OddBeats": //Swapped due to event icon starting at 1 instead of 0
                playstate.bfBeats = [0, 2];
            case "EvenBeats": //Swapped due to event icon starting at 1 instead of 0
                playstate.bfBeats = [1, 3];
            case "Never":
                playstate.bfBeats = [];
        }
    }

    function dadBop(tag:String):Void{
        var args = Events.getArgs(tag);
        switch(args[0]){
            case "EveryBeat":
                playstate.dadBeats = [0, 1, 2, 3];
            case "OddBeats": //Swapped due to event icon starting at 1 instead of 0
                playstate.dadBeats = [0, 2];
            case "EvenBeats": //Swapped due to event icon starting at 1 instead of 0
                playstate.dadBeats = [1, 3];
            case "Never":
                playstate.dadBeats = [];
        }
    }

    function bfAnimLockToggle(tag:String):Void{
        boyfriend.canAutoAnim = !boyfriend.canAutoAnim;
    }

    function dadAnimLockToggle(tag:String):Void{
        dad.canAutoAnim = !dad.canAutoAnim;
    }

    function gfAnimLockToggle(tag:String):Void{
        gf.canAutoAnim = !gf.canAutoAnim;
    }



    //Event descriptions. Not required but it helps with charting.
    static inline final PLAY_ANIM_DESC:String = "Plays an animation on a character.\n\nArgs:\n    String: Character (\"bf\", \"dad\", or \"gf\")\n    String: Animation name\n    Bool: Force play animation\n    Bool: Reverse animation\n    Int: Frame to start on";
    static inline final SING_ANIM_DESC:String = "Plays an animation treated as a note sing direction.\n\nArgs:\n    String: Character (\"bf\", \"dad\", or \"gf\")\n    String: Animation name\n    Bool: Force play animation\n    Bool: Reverse animation\n    Int: Frame to start on";
    static inline final SET_ANIM_SET_DESC:String = "Sets the animation set on a character.\n\nArgs:\n    String: Character (\"bf\", \"dad\", or \"gf\")\n    String: Animation set suffix";
    static inline final GF_BOP_FREQ_DESC:String = "Sets the interval that GF does their idle dance.\n\nArgs:\n    Int: Interval (every \"x\" beats)";
    static inline final ICON_BOP_FREQ_DESC:String = "Sets the interval that the health icons bop.\n\nArgs:\n    Int: Interval (every \"x\" beats)";
    static inline final BF_BOP_DESC:String = "Sets the beats that BF does their idle dance.\n\nArgs:\n    String: \"EveryBeat\", \"OddBeats\", \"EvenBeats\", \"Never\"";
    static inline final DAD_BOP_DESC:String = "Sets the beats that Dad does their idle dance.\n\nArgs:\n    String: \"EveryBeat\", \"OddBeats\", \"EvenBeats\", \"Never\"";
    static inline final BF_ANIM_LOCK_TOGGLE_DESC:String = "Toggle whether BF will automatically play animations.";
    static inline final DAD_ANIM_LOCK_TOGGLE_DESC:String = "Toggle whether Dad will automatically play animations.";
    static inline final GF_ANIM_LOCK_TOGGLE_DESC:String = "Toggle whether GF will automatically play animations.";
}