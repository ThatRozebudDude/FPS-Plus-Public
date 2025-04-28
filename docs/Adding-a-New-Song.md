## Song Audio

To add a new song, first you need to add the audio files to a folder with the name of your song in the `songs/` directory. Inside the folder you need at least an audio file named `Inst.ogg`. There are 2 different types of vocals you can use, combined or separated. For combined vocals you just need to add the vocal track as `Voices.ogg` to the folder. For separated vocals you need 2 files named `Voices-Player.ogg` for the player side and `Voices-Opponent.ogg` for the opponent side. The game will favor loading separated vocals over combined vocals.

## Song Data

Next you will need to add a folder in `data/songs/` directory for the all the charts, events, and miscellaneous data. The name of the folder should be the same as the song name but in all lowercase if the song name wasn't. You will need to have a chart for at least 1 difficulty and a `meta.json` file. 

To create a new chart just open the chart editor in-game and click the `Full Blank` button, then you just need to fill out the details and chart then. When saving the chart, it should be named correctly based on the song name and difficulty so you shouldn't need to edit the name of the file. If the song has events, don't forget to save the event chart as well as they are stored in a separate file from the note chart. Also note that Erect and Nightmare difficulties are just normal and hard charts for songs that contain `"erect"` in their name.

You can also create a `meta.json` file that contains extra details about the song. It has the following fields:

- `name`: The full name of the song that will appear in-game.
- `artist`: The name of the song artist(s).
- `album`: The name of the folder to get the album name and image from in Freeplay.
- `difficulties`: An array of 3 numbers from 0 to 20 that show the difficulty of each song's difficulty in order of `[Easy, Normal, Hard]`.
- `dadBeats`: An array that can contain the numbers `[0, 1, 2, or 3]` that determine what beats to play the opponent's idle on.
- `bfBeats`: An array that can contain the numbers `[0, 1, 2, or 3]` that determine what beats to play the player's idle on.
- `compatableInsts`: An array of song names that can have their instrumental played as a song variation in Freeplay.
- `mixName`: The name of the song variation.
- `pauseMusic`: The path to the song that will be played on the pause screen. *Not in current pre-release.*

Additionally you can add a `scripts.json` file and `cutscene.json` file to the song's data folder.

The `scripts.json` file contains the following fields:

- `scripts`: An array containing the names of generic script classes to load.

The `cutscene.json` file contains the following fields:

- `startCutscene`: Can either contain an object with cutscene information or be `null`.
- `endCutscene`: Can either contain an object with cutscene information or be `null`.

    Cutscene information has the following fields:

    - `name`: The name of the cutscene class to load.
    - `storyOnly`: A boolean that denotes whether the cutscene should only load in Story Mode or not.
    - `playOnce`: A boolean that denotes whether the cutscene should play again after restarting a song or not.
    - `args`: An array containing data that can be passed to the cutscene class's constructor.

## Adding the Song to Freeplay 

To add a song to Freeplay you have to include it in a freeplay character's song list file. This can be found in `data/freeplay/songList-{listSuffix}.json`. The `songList-{listSuffix}.json` file contains the following fields:

- `"categories"`: An array containing the categories that will be created in the freeplay menu for the character. The categories will be created in the order they are listed.

- `"songs"`: An array containing objects with the following fields:
	- `"song"`: The name of name of the song. This should be the same name as the folder that the song's audio files are contained in *including capitalization*.
	- `"icon"`: The name of the icon sprite that's loaded. You can also use a value of `"none"` to not display an icon. If you created an icon with the name `none` it will not show up.
	- `"categories"`: An array containing the categories that the song will appear under. If a category is not defined in the song list's `"categories"` list it will be added to the end of list.
	- `"insert"`: An option field that will allow you to insert a song before or after a specified song instead of being appended to the song list in order. The song referenced must be defined before this so it is recommended that you add any inserted songs to the end of the song list. It contains the following fields:
		- `"type"`: Can be either `"before"` or `"after"`. If it is `"before"` the song will be inserted before the song in `"value"` and if it is `"after"` the song will be inserted after the song in `"value"`.
		- `"value"`: The name of the song that it this song will be inserted before or after.

An example of a song list would be the following:

```json
{
	"categories":[
		"ALL",
		"Zardy"
	],
	"songs":[
		{
			"song": "Foolhardy-2023",
			"icon": "none",
			"categories": ["ALL", "Zardy"]
		}
	]
}
```

If you want to add a song to an already existing freeplay song list you need to `merge` the data into the `json`. Create a file called `songList-{listSuffix}.json` in `data/freeplay/songList/`. Inside the file you should add the following:

```json
[
	{
		"op": "add", 
		"path": "/songs/-", 
		"value": {
			"song": "Song-Name",
			"icon": "iconName",
			"categories": ["ALL", "Other Category"]
		}
	}
]
```

The object in the `"value"` field is the same as the object that you put in the `"songs"` list in the actual `songList-{listSuffix}.json` file, so you can also include a `"insert"` field to have the song inserted before or after a specific song. You can also change the `"path"` value to `"/songs/{index}"` to insert the song into the list at a certain position but I recommend just using the `"insert"` field since song positions my move around in the future.

## Creating a Song Variation

In FPS Plus, songs that are remixes of other songs can have their instrumentals selected to be played with the original vocals provided they have the same BPM and song structure. If you want to have variations in your custom songs all you need to do is add the variation's song name to the `compatableInsts` array in your song's `meta.json` file. If you want to add your song as a variation of a pre-existing song you will need to merge your song's name into the other song's `meta.json` file.

To do this first create a file called `meta.json` in `merge/data/songs/{song you want add the variation to}/`. Inside the file you should add the following:
```json
[
	{"op": "add", "path": "/compatableInsts/-", "value": "Song-Name"}
]
```
Where `Song-Name` is replaced with the name of your song. This should be the same name used in the `songs/` folder that contains your instrumental and vocal tracks.