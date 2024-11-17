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

To add a song to Freeplay you have to append it to an exitsting character's Freeplay song list or make a new character with a new Freeplay song list. To append a song list, you first need to make a folder in the root directory of the mod called `append/` and inside that a folder called `data/` and inside that another called `freeplay/`. Then create a text file with the same name as the song list you want to append, `songList-bf.txt` for example. Then you need to add a line to the file with the following format:

`song | {songName} | {icon} | [{categories}]` where:

 - `songName` is the name of name of the song specified for the song's audio.
 - `icon` is name of the icon sprite that's loaded. You can also use `none` to not display an icon.
 - `categories` is a comma separated list of at the categories you want the song to appear in. Typically you want to include the `ALL` category but you can omit it if you don't want the song to appear in the default song list. If a category doesn't already exist it will be created and ordered after all previously created categories.

 Note that you don't need to include quotes around any of these as it is just parsed as plain text. Every song that you add needs to be on a new line.

 An example of the format to add a song to a song list would be the following: `song | Foolhardy-2023 | none | [ALL, Zardy]`