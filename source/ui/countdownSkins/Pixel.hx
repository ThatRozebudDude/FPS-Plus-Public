package ui.countdownSkins;

class Pixel extends CountdownSkinBase{

    public function new() {
        super();

        info.first.audioPath = "week6/intro3-pixel";

        info.second.audioPath = "week6/intro2-pixel";
        info.second.graphicPath = "week6/weeb/pixelUI/countDown/ready-pixel";
        info.second.scale = 6 * 0.8;
        info.second.antialiasing = false;
        info.second.offset.y = -120;

        info.third.audioPath = "week6/intro1-pixel";
        info.third.graphicPath = "week6/weeb/pixelUI/countDown/set-pixel";
        info.third.scale = 6 * 0.8;
        info.third.antialiasing = false;
        info.third.offset.y = -120;

        info.fourth.audioPath = "week6/introGo-pixel";
        info.fourth.graphicPath = "week6/weeb/pixelUI/countDown/date-pixel";
        info.fourth.scale = 6 * 0.8;
        info.fourth.antialiasing = false;
        info.fourth.offset.y = -120;
    }

}