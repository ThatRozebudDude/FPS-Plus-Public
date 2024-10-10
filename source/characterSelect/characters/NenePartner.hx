package characterSelect.characters;

class NenePartner extends CharacterSelectCharacter
{

    var idleIndex:Int = 0;

    override function setup():Void{
        loadAtlas(Paths.getTextureAtlas("menu/characterSelect/characters/pico/CharacterSelect_Nene"));

        addAnimationByLabel("enter", "Enter", 24, false);
        addAnimationByLabel("idle0", "IdleLeft", 24, false);
        addAnimationByLabel("idle1", "IdleRight", 24, false);
        addAnimationByLabel("confirm", "Confirm", 24, true);
        addAnimationByLabel("cancel", "Cancel", 24, false);
        addAnimationByLabel("exit", "Exit", 24, false);
    }

    override function playEnter():Void{
        playAnim("enter", true);
    }

    override function playIdle():Void{
        if(curAnim != "enter" || finishedAnim){
            playAnim("idle" + idleIndex, true);
            idleIndex = idleIndex == 1 ? 0 : 1;
        }
    }

    override function playConfirm():Void{
        playAnim("confirm", true);
    }

    override function playCancel():Void{
        playAnim("cancel", true);
    }

    override function playExit():Void{
        playAnim("exit", true);
    }

}