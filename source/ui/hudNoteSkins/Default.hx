package ui.hudNoteSkins;

class Default extends HudNoteSkinBase
{
    
    public function new(){
        super();

        info.notes.notePath = "ui/notes/NOTE_assets";
        info.notes.noteFrameLoadType = sparrow;
        info.notes.scale = 0.7;

        info.notes.splashClass = "Default";
        info.notes.coverPath = "Default";

        setStaticAnimPrefix(left, "arrowLEFT", 0);
        setPressedAnimPrefix(left, "left press", 24);
        setConfirmedAnimPrefix(left, "left confirm", 24, offset(-14, -14));

        setStaticAnimPrefix(down, "arrowDOWN", 0);
        setPressedAnimPrefix(down, "down press", 24);
        setConfirmedAnimPrefix(down, "down confirm", 24, offset(-14, -14));

        setStaticAnimPrefix(up, "arrowUP", 0);
        setPressedAnimPrefix(up, "up press", 24);
        setConfirmedAnimPrefix(up, "up confirm", 24, offset(-14, -14));

        setStaticAnimPrefix(right, "arrowRIGHT", 0);
        setPressedAnimPrefix(right, "right press", 24);
        setConfirmedAnimPrefix(right, "right confirm", 24, offset(-14, -14));
    }

}