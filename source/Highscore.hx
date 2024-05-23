package;

import flixel.FlxG;

typedef SongStats = {
	score:Int,
	accuracy:Float
}

class Highscore
{

	
	//Major versions will be incompatible and will wipe scores. Minor versions should always convert / repair scores.
	static var scoreFormatVersion:String = "1.0";

	public static var songScores:Map<String, SongStats> = new Map<String, SongStats>();

	static final forceResetScores:Bool = false;

	public static function saveScore(_song:String, _score:Int = 0, _accurracy:Float = 0, ?_diff:Int = 1):Void{
		var song:String = formatSong(_song, _diff);

		var proposedStats:SongStats = {
			score: _score,
			accuracy: _accurracy
		};

		if (songScores.exists(song)){
			var currentStats = songScores.get(song);

			if (proposedStats.score < currentStats.score){
				proposedStats.score = currentStats.score;
			}
			if (proposedStats.accuracy < currentStats.accuracy){
				proposedStats.accuracy = currentStats.accuracy;
			}
			
			setScore(song, proposedStats);
		}
		else{
			setScore(song, proposedStats);
		}
	}

	public static function saveWeekScore(_week:Int = 1, _score:Int = 0, _accurracy:Float = 0, ?_diff:Int = 1):Void{
		saveScore("week" + _week, _score, _accurracy, _diff);
	}

	static function setScore(_song:String, _stats:SongStats):Void{
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

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	public static function getScore(song:String, diff:Int):SongStats{
		if (!songScores.exists(formatSong(song, diff))){
			var emptyScore:SongStats = {
				score: 0,
				accuracy: 0
			}
			setScore(formatSong(song, diff), emptyScore);
		}

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):SongStats{
		return getScore("week" + week, diff);
	}

	public static function load():Void{
		SaveManager.scores();

		if(FlxG.save.data.scoreFormatVersion == null || cast (FlxG.save.data.scoreFormatVersio, String).split(".")[0] != scoreFormatVersion.split(".")[0] || forceResetScores){
			FlxG.save.data.songScores = songScores;
		}
		else{
			//Code to update score versions in the future.
		}

		if (FlxG.save.data.songScores != null){
			songScores = FlxG.save.data.songScores;
		}

		FlxG.save.data.scoreFormatVersion = scoreFormatVersion;

		SaveManager.global();
	}
}
