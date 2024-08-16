package ui.hudNoteSkins;

class Pixel extends HudNoteSkinBase
{
    
    public function new(){
        super();

        info.notes.notePath = "week6/weeb/pixelUI/notes/arrows-pixels";
        info.notes.noteFrameLoadType = load(19, 19);
        info.notes.scale = 6;
        info.notes.anitaliasing = false;

        info.notes.splashClass = "Pixel";
        info.notes.coverPath = "Pixel";

        setStaticAnimFrames(left, [0], 0);
        setPressedAnimFrames(left, [24, 8], 12);
        setConfirmedAnimFrames(left, [28, 12, 16], 24);

        setStaticAnimFrames(down, [1], 0);
        setPressedAnimFrames(down, [25, 9], 12);
        setConfirmedAnimFrames(down, [29, 13, 17], 24);

        setStaticAnimFrames(up, [2], 0);
        setPressedAnimFrames(up, [26, 10], 12);
        setConfirmedAnimFrames(up, [30, 14, 18], 24);

        setStaticAnimFrames(right, [3], 0);
        setPressedAnimFrames(right, [27, 11], 12);
        setConfirmedAnimFrames(right, [31, 15, 19], 24);
    }

}