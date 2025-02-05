package;

import haxe.display.Position.Range;

class Scoring
{

	public static final SICK_HEAL_AMOUNT:Float = (1.5 / 100) * 2;
	public static final GOOD_HEAL_AMOUNT:Float = (0.75 / 100) * 2;
	public static final BAD_HEAL_AMOUNT:Float = (0 / 100) * 2;
	public static final SHIT_HEAL_AMOUNT:Float = (-1 / 100) * 2;
	public static final HOLD_HEAL_AMOUNT:Float = (0.5 / 100) * 2;

	public static final MISS_DAMAGE_AMOUNT:Float = (4 / 100) * 2;
	public static final WRONG_TAP_DAMAGE_AMOUNT:Float = (2 / 100) * 2;
	public static final HOLD_DROP_INITAL_DAMAGE:Float = (3 / 100) * 2;
	public static final HOLD_DROP_DMAMGE_PER_NOTE:Float = (2 / 100) * 2;

	public static final MAX_NOTE_SCORE:Int = 500;
	public static final MIN_NOTE_SCORE:Int = 9;
	public static final HOLD_SCORE_PER_SECOND:Int = 250;
	
	public static final MISS_PENALTY:Int = 0;
	public static final HOLD_DROP_INITIAL_PENALTY:Int = 0;
	public static final HOLD_DROP_PENALTY:Int = 0;
	public static final WRONG_PRESS_PENALTY:Int = 0;

	//This uses the PBOT1 scoring system added in FNF 0.3.0 
	public static function scoreNote(msTiming:Float):Int{

		var absTiming:Float = Math.abs(msTiming);
		var slope = 0.080;
		var offset = 54.99;

		if(rateNote(absTiming) == "sick"){
			return MAX_NOTE_SCORE;
		}
	  
		var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-slope * (absTiming - offset))));
		var score:Int = Std.int(MAX_NOTE_SCORE * factor + MIN_NOTE_SCORE);
		return score;

	}

	public static function rateNote(msTiming:Float):String{
		var r:String = "sick";
		var absTiming:Float = Math.abs(msTiming);

		if (absTiming > Conductor.shitZone){ r = 'shit'; }
		else if (absTiming > Conductor.badZone){ r = 'bad'; }
		else if (absTiming > Conductor.goodZone){ r = 'good'; }

		return r;
	}

}