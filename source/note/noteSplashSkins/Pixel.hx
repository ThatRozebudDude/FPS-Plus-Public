package note.noteSplashSkins;

class Pixel extends NoteSplashSkinBase
{

    public function new(){
        super();

        info.path = "week6/weeb/pixelUI/notes/noteSplashes-pixel";
        info.alpha = 0.7;
        info.limitedRotationAngles = true;
        info.scale = 6;
        info.antialiasing = false;

        addAnim(left, "note impact 1 purple", [21, 28], offset(21, 25));
        addAnim(left, "note impact 2 purple", [21, 28], offset(23, 23));

        addAnim(down, "note impact 1 blue", [21, 28], offset(21, 25));
        addAnim(down, "note impact 2 blue", [21, 28], offset(23, 23));

        addAnim(up, "note impact 1 green", [21, 28], offset(21, 25));
        addAnim(up, "note impact 2 green", [21, 28], offset(23, 23));

        addAnim(right, "note impact 1 red", [21, 28], offset(21, 25));
        addAnim(right, "note impact 2 red", [21, 28], offset(23, 23));
    }
    
}