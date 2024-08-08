package events.data;

class CharacterAnimationEvents extends Events
{

    override function defineEvents() {
        addEvent("playAnim", playAnim);
        addEvent("setAnimSet", setAnimSet);

        addEvent("gfBopFreq", gfBopFreq);
        addEvent("iconBopFreq", iconBopFreq);

        addEvent("bfBop", bfBop);
        addEvent("dadBop", dadBop);

        addEvent("bfAnimLockToggle", bfAnimLockToggle);
        addEvent("dadAnimLockToggle", dadAnimLockToggle);
        addEvent("gfAnimLockToggle", gfAnimLockToggle);
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

}