package characters;

class MomCar extends CharacterInfoBase
{

    override public function new(){

        super();

        info.name = "mom";
        info.spritePath = "week4/momCar";
        info.frameLoadType = sparrow;
        
        info.iconName = "mom";

		addByPrefix('idle', offset(), "Mom Idle", 24, false);
	    addByPrefix('singUP', offset(-1, 81), "Mom Up Pose", 24, false);
	    addByPrefix('singDOWN', offset(20, -157), "MOM DOWN POSE", 24, false);
	    addByPrefix('singLEFT', offset(250, -23), 'Mom Left Pose', 24, false);
	    addByPrefix('singRIGHT', offset(21, -54), 'Mom Pose Left', 24, false);

    }

}