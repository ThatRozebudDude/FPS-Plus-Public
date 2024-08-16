package note.noteSplashSkins;

class Default extends NoteSplashSkinBase
{

    public function new(){
        super();

        info.path = "ui/notes/noteSplashes";
        info.alpha = 0.6;

        addAnim(left, "note impact 1 purple", [21, 28], offset(126, 150));
        addAnim(left, "note impact 2 purple", [21, 28], offset(138, 138));

        addAnim(down, "note impact 1 blue", [21, 28], offset(126, 150));
        addAnim(down, "note impact 2 blue", [21, 28], offset(138, 138));

        addAnim(up, "note impact 1 green", [21, 28], offset(126, 150));
        addAnim(up, "note impact 2 green", [21, 28], offset(138, 138));

        addAnim(right, "note impact 1 red", [21, 28], offset(126, 150));
        addAnim(right, "note impact 2 red", [21, 28], offset(138, 138));
    }
    
}