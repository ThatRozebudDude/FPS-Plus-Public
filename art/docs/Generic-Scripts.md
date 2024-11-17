Generic scripts are classes that don't belong to a specific stage or character but can be added to specific songs to run or added globally to every song. You can use these do make things like UI elements that you want to add to your songs or more advanced mechanics that you want to use in multiple songs.

## Creating the Class File

First you need to create a new file in `data/scripts/` called `{ClassName}.hxc`. Technically the file can be named whatever you want as the class name is defined in the script but keeping the name consistent makes it easier to keep track of.

At the top of the file you need to define the class with `class {ClassName} extends Script`.

## Adding the Script to a Song

To add a script to a song you need to make a file in the song's data folder called `scripts.json` with that contains a single field called `scripts` that's an array of the class names of the scripts you want to load.

## Adding the Script Globally

To make a script run in every song you have to append it to the global scripts list. First need to make a folder in the root directory of the mod called `append/` and inside that a folder called `data/` and inside that another called `scripts/`, then create a text file called `globalScripts.txt`. For every script you want to add make a new line and write it's class name in the text file.

## Functions

Similarly to stages, there are a variety of functions you can override that will be automatically called at specific times:

- `create()`: This is run when the script is created after `PlayState` is created.
- `update(elapsed)`: This is run every frame.
    - `elapsed`: The time in seconds between this frame and the previous frame.
- `beat(curBeat)`: This is run every song beat.
    - `curBeat`: The current beat of the song as an integer.
- `countdownBeat(curBeat)`: This is run every beat of the intro countdown.
    - `curBeat`: The current part of the countdown as an integer.
- `step(curStep)`: This is run every step of the song.
    - `curStep`: The current step of the song as an integer.
- `songStart()`: This is run once the song starts playing.
- `pause()`: This is run whenever the game is paused.
- `unpause()`: This is run whenever the game is unpaused.
- `gameOverStart()`: This is run when the death screen is started.
- `gameOverLoop()`: This is run when the death screen starts the character's looping animation.
- `gameOverEnd()`: This is run when you continue from the death screen.
- `exit()`: This is run when exiting `PlayState`.
- `noteHit(character, note)`: This is run when a character hits a note.
    - `character`: The character object that hit the note. Will either be `boyfriend` or `dad`.
    - `note`: The note object that was just hit.
- `noteMiss(direction, countedMiss)`: This is run when exiting `PlayState`.
    - `direction`: The direction that the player missed in as an integer.
    - `countedMiss`: A boolean that will be `true` if the miss was counted or `false` if it wasn't (for things like wrong taps).

## Adding Objects

Also similar to stages, you can use `addTo{Layer}()` and `removeFrom{Layer}()` where `{Layer}` is either `Background`, `Gf`, `Middle`, `Character`, `Foreground`, `Overlay`, or `Hud` to add objects to those layer groups. You can also use `addGeneric()` and `removeGeneric()` to just add an object to `PlayState`, or you can use `addGenericSubstate()` and `addGenericSubstate()` to add an object to whatever substate is currently open.

## Accessing Scripts From Other Places

When a script is loaded in `PlayState`, it gets added to a map called `scripts` with the script's class name as the key. If you want to access a generic script from another generic script or any other scripted class you can use `playstate.scripts.get({className})`. If the script does not exist it will return `null` so you may want to either do a null check or use `playstate.scripts.exists({className})` before the code that interacts with the script.