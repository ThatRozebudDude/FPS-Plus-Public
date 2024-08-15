package ui.countdownSkins;

class Default extends CountdownSkinBase{

    public function new() {
        super();

        info.first.audioPath = "intro3";

        info.second.audioPath = "intro2";
        info.second.graphicPath = "ui/ready";
        info.second.scale = 0.5;
        info.second.offset.y = -120;

        info.third.audioPath = "intro1";
        info.third.graphicPath = "ui/set";
        info.third.scale = 0.5;
        info.third.offset.y = -120;

        info.fourth.audioPath = "introGo";
        info.fourth.graphicPath = "ui/go";
        info.fourth.scale = 0.8;
        info.fourth.offset.y = -120;
    }

}