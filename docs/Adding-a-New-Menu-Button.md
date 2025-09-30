## Creating the JSON File

First you need to create a new file in `data/mainMenu/items` called `{name}.json`. You can name this file whatever you want but it's recommended that you name it something relevent to the menu button.

## Button Information

Inside the JSON file you need to add information about the menu button. You can set the following fields:

- `graphic`: The path to the graphic that will be used by the menu button. *String*.
- `sort`: A number used to order the menu buttons. Larger numbers will appear later in the list. *Integer*.
- `action`: An object containing what will happen when the button is pressed. Every action object has the `type` field and may have additional fields depending on the action type. The additional fields are just located under the action object along side the type. *Object*.
	- `type`: 
		- `"story"`: Goes to the Story Mode menu. Has no additional parameters.
		- `"freeplay"`: Goes to the Freeplay menu. Has no additional parameters.
		- `"modManager"`: Goes to the mod manager. Has no additional parameters.
		- `"config"`: Goes to the Options menu. Has no additional parameters.
		- `"customState"`: Opens a scripted state.
			- `state`: The name of the `ScriptedState` class to open. *String*.
		- `"playSong"`: Goes to `PlayState` and loads the specified song.
			- `song`: The name of the song to load. *String*.
			- `difficulty`: The difficulty that will be loaded. Must be `0`, `1`, or `2`. *Integer*.
			- `instrumentalOverride`: The name of the song to override the intrumental to. Will use the song's usual instrumental if `null` or not defined. *String*.
- `transition`: An objcect containing information on how the menu will transition to the next state. *Object*.
	- `instant`: Whether to have the screen flash before transitioning to the next state. *Boolean*.
	- `sound`: The path to the sound effect to play when selecting the button. Won't play anything if it's `null`. *String*.
	- `stopMusic`: Whether to stop the menu music. *Boolean*.

## Button Graphic

The graphic used must be a Sparrow sprite sheet and has to contain animations prefixed with `"idle"` and `"selected"`. The `"idle"` animation will play when the button is not selected and `"selected"` animation will play when the button is currently selected. Menu items will be automatically centered horizontally and the graphic will retain it's midpoint when switching to it's `"selected"` animation.

## Examples

Story Menu button.
```json
{
	"graphic": "menu/main/storymode",
	"action":
	{
		"type": "story"
	},
	"transition":
	{
		"instant": false,
		"sound": "confirmMenu",
		"stopMusic": false
	},
	"sort": 100
}
```

Freeplay button.
```json
{
	"graphic": "menu/main/freeplay",
	"action":
	{
		"type": "freeplay"
	},
	"transition":
	{
		"instant": true,
		"sound": null,
		"stopMusic": false
	},
	"sort": 200
}
```

Custom state.
```json
{
	"graphic": "menu/main/gallery",
	"action":
	{
		"type": "customState",
		"state": "GalleryState"
	},
	"transition":
	{
		"instant": false,
		"sound": "confirmMenu",
		"stopMusic": false
	},
	"sort": 220
}
```

Play song.
```json
{
	"graphic": "menu/main/darnell",
	"action":
	{
		"type": "playSong",
		"song": "Darnell",
		"difficulty": 2
	},
	"transition":
	{
		"instant": false,
		"sound": "confirmMenu",
		"stopMusic": true
	},
	"sort": 700
}
```