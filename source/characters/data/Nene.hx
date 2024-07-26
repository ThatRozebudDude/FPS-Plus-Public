package characters.data;

@charList(false)
@gfList(true)
class Nene extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "nene";
        info.spritePath = "weekend1/Nene";
        info.frameLoadType = sparrow;
        
        info.iconName = "face";
        info.hasLeftAndRightIdle = true;

		addByIndices('danceLeft', offset(), 'Idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, loop(false));
		addByIndices('danceRight', offset(), 'Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, loop(false));
        addByIndices("sad", offset(), "Laugh", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 6, 7, 8, 9, 10, 11, 6, 7, 8, 9, 10, 11], "", 24, loop(false));
        addByIndices("laughCutscene", offset(), "Laugh", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11], "", 24, loop(false));
        addByPrefix("comboCheer", offset(), "ComboCheer", 24, loop(false));
        addByIndices("comboCheerHigh", offset(), "ComboFawn", [0, 1, 2, 3, 4, 5, 6, 4, 5, 6, 4, 5, 6, 4, 5, 6], "", 24, loop(false));
        addByPrefix("raiseKnife", offset(0, 52), "KnifeRaise", 24, loop(false));
        addByPrefix("idleKnife", offset(-99, 52), "KnifeIdle", 24, loop(false));
        addByPrefix("lowerKnife", offset(135, 52), "KnifeLower", 24, loop(false));
    }

}