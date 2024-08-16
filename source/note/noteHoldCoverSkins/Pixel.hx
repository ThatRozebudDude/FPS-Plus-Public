package note.noteHoldCoverSkins;

class Pixel extends NoteHoldCoverSkinBase
{

    public function new() {
        super();

        info.path = "week6/weeb/pixelUI/notes/noteHoldCovers-pixel";
        info.offset = offset(36, -16);
        info.positionOffset = offset(54, 60);
        info.alpha = 0.8;
        info.scale = 6;
        info.antialiasing = false;

        addStartAnim(left, "holdCoverStartPurple", [24]);
        addHoldAnim(left, "holdCoverPurple0", [24]);
        addSplashAnim(left, "holdCoverEndPurple", [24, 30]);

        addStartAnim(down, "holdCoverStartBlue", [24]);
        addHoldAnim(down, "holdCoverBlue0", [24]);
        addSplashAnim(down, "holdCoverEndBlue", [24, 30]);

        addStartAnim(up, "holdCoverStartGreen", [24]);
        addHoldAnim(up, "holdCoverGreen0", [24]);
        addSplashAnim(up, "holdCoverEndGreen", [24, 30]);

        addStartAnim(right, "holdCoverStartRed", [24]);
        addHoldAnim(right, "holdCoverRed0", [24]);
        addSplashAnim(right, "holdCoverEndRed", [24, 30]);
    }
    
}