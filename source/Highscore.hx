package;

import PlayState.ScoreStats;
import flixel.FlxG;

typedef SongStats = {
	score:Int,
	accuracy:Float,
	rank:Rank
}

enum Rank {
	none;
	loss;
	good;
	great;
	excellent;
	perfect;
	gold;
}

class Highscore
{

	//Major versions will be incompatible and will wipe scores. Minor versions should always convert / repair scores.
	static var scoreFormatVersion:String = "1.3";

	public static var songScores:Map<String, SongStats> = new Map<String, SongStats>();

	static final forceResetScores:Bool = false;

	public static function saveScore(_song:String, _score:Int = 0, _accurracy:Float = 0, _diff:Int = 1, _rank:Rank = none):Void{
		var proposedStats:SongStats = {
			score: _score,
			accuracy: _accurracy,
			rank: _rank
		};

		var currentStats = getScore(_song, _diff);

		if (proposedStats.score < currentStats.score){
			proposedStats.score = currentStats.score;
		}
		if (proposedStats.accuracy < currentStats.accuracy){
			proposedStats.accuracy = currentStats.accuracy;
		}
		if (rankToInt(proposedStats.rank) < rankToInt(currentStats.rank)){
			proposedStats.rank = currentStats.rank;
		}
			
		setScore(formatSong(_song, _diff), proposedStats);
	}

	public static function saveWeekScore(_week:String = "week1", _score:Int = 0, _accurracy:Float = 0, _diff:Int = 1, _rank:Rank = none):Void{
		saveScore(_week, _score, _accurracy, _diff, _rank);
	}

	static function setScore(_song:String, _stats:SongStats):Void{
		if(_stats.score == 0 && _stats.accuracy == 0 && _stats.rank == none){ return; }

		// Reminder that I don't need to format this song, it should come formatted!
		SaveManager.scores();
		songScores.set(_song, _stats);
		FlxG.save.data.songScores = songScores;
		SaveManager.global();
	}

	public static function formatSong(song:String, diff:Int):String{
		if (diff == 0){ song += '-easy'; }
		else if (diff == 2){ song += '-hard'; }
		return song;
	}

	public static function getScore(song:String, diff:Int):SongStats{
		if (!songScores.exists(formatSong(song, diff))){
			var emptyScore:SongStats = {
				score: 0,
				accuracy: 0,
				rank: none
			}
			return emptyScore;
		}

		return songScores.get(formatSong(song, diff));
	}

	public static inline function scoreExists(song:String, diff:Int):Bool{
		return songScores.exists(formatSong(song, diff));
	}

	public static function getWeekScore(week:String, diff:Int):SongStats{
		return getScore(week, diff);
	}

	public static function load():Void{
		SaveManager.scores();

		if(FlxG.save.data.scoreFormatVersion == null || cast (FlxG.save.data.scoreFormatVersion, String).split(".")[0] != scoreFormatVersion.split(".")[0] || forceResetScores){
			FlxG.save.data.songScores = songScores;
		}
		//This is to fix broken score files if the save version is a non-breaking format change. (ex. Version 1.0 only saved score and accuracy, version 1.1 adds a rank to the score format)
		else if(cast (FlxG.save.data.scoreFormatVersion, String).split(".")[1] != scoreFormatVersion.split(".")[1]){
			trace("Score version mismatch!");
			repairScores();
		}

		if (FlxG.save.data.songScores != null){
			songScores = FlxG.save.data.songScores;
		}

		FlxG.save.data.scoreFormatVersion = scoreFormatVersion;

		SaveManager.flush();
		SaveManager.global();
	}

	public static function repairScores():Void{
		trace("Repairing scores...");
		var savedScores:Map<String, Dynamic> = FlxG.save.data.songScores;
		var newSavedScores:Map<String, SongStats> = new Map<String, SongStats>();
		for(key => value in savedScores){
			var newValue:SongStats = {
				score: 0,
				accuracy: 0,
				rank: none
			}
			if(Reflect.hasField(value, "score")){
				newValue.score = value.score;
			}
			if(Reflect.hasField(value, "accuracy")){
				newValue.accuracy = value.accuracy;
			}
			if(Reflect.hasField(value, "rank")){
				newValue.rank = value.rank;
			}

			if(newValue.score != 0 || newValue.accuracy != 0 || newValue.rank != none){
				newSavedScores.set(key, newValue);
			}
		}
		FlxG.save.data.songScores = newSavedScores;
	}

	public static function calculateRank(scoreData:ScoreStats):Rank{

		var totalNotes = scoreData.sickCount + scoreData.goodCount + scoreData.badCount + scoreData.shitCount + scoreData.missCount;

		if(totalNotes <= 0) return loss;
		else if (scoreData.sickCount == totalNotes) return gold;

		
		var grade = (scoreData.sickCount + scoreData.goodCount) / totalNotes;
	  
		if(grade == 1){
			return perfect;
		}
		else if(grade >= 0.90){
			return excellent;
		}
		else if(grade >= 0.80){
			return great;
		}
		else if(grade >= 0.60){
			return good;
		}
		else{
			return loss;
		}

	}

	static inline function rankToInt(rank:Rank):Int{
		switch(rank){
			case loss: return 1;
			case good: return 2;
			case great: return 3;
			case excellent: return 4;
			case perfect: return 5;
			case gold: return 6;
			default: return 0;
		}
	}
}

/**
SCORE FORMAT VERSION INFO

	1.2:
		Blank scores are removed and are not saved.
	
	1.1:
		Ranks are now saved.
		Trying to find a score that doesn't exist won't save a blank score, it will just return a blank score.

	1.0:
		Accuracy is now saved.

	Legacy:
		Old base-game system, just saves score.

**/