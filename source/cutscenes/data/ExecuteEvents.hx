package cutscenes.data;

class ExecuteEvents extends ScriptedCutscene
{

    var e:Array<String>;

    public function new(_e:Array<String>) {
        e = _e;
        super();
    }

    override function init():Void{
        addEvent(0, executeEvents);
    }

    function executeEvents() {
        for(event in e){ playstate.executeEvent(event); }
        next();
    }

}