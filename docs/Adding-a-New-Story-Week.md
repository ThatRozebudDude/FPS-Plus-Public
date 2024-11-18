## Creating the JSON File

First you need to create a new file in `data/weeks/` called `{name}.json`. You can name this file whatever you want but it's recommended that you name it something relevent to the week.

## Week Information

Inside the JSON file you need to add informations about your week. You can set the following fields:

- `name`: The proper name of your week. This will show up on the Story Mode menu and the results screen after completing the week.
- `id`: This is what the game will use to identify the week internally. This is used for saving scores and getting the week name image. *(Optional)* If not defined it will be set to the name of your JSON file.
- `sortOrder`: The number used to sort the week on the Story Mode menu. Higher numbers appear later in the list. *(Optional)* If not defined it will be set to `1000`.
- `songs`: An array of song names that are to be played in the week. Should be the name of the song in the `songs/` folder.
- `characters`: An array of the name of the characters to load at the top of Story Mode. More information about Story Menu characters will be provided below. *(Optional)* If not defined it will be set to `["dad", "bf", "gf"]`.
- `stickerSet`: An array of the stickers names to use when transitioning back to the Story Menu after completeing the week. These are the names of the sticker folders and all stickers in said folder will be used. *(Optional)* If not defined it will be set to `null` meaning all stickers will be used.
- `color`: The color that the top part of the Story Mode menu is set to when the week is selected. It should be in the format of `0xRRGGBB`. *(Optional)* If not defined it will be set to `0xF9CF51`, the default Story Mode yellow.

## Week Name Image

This is the image that used in the week list. It must be in `images/menu/story/weeks/` and have the same name as the week's `id`. You can use a JSON file to add an offset to the image in the week list. It has a single field:

- `offset`: An array containing 2 numbers that are the `x` and `y` offsets for the image in the week list.

## Story Mode Characters

A Story Mode character must be added to `images/menu/story/characters/`. Only sparrow atlases are supported. The character will need to have an animation named `idle`. If you want to add a new playable character that will go in the center of the Story Mode menu, it needs to have another animation called `confirm` that will play when you select the week. You can also add a JSON file with the same name as your character to specify offsets for their animations. It is formatted like so:

- `offsets`: An array containing offset objects. The offset object contains the following fields:
    - `name`: The name of the animation that the offset is applied to.
    - `offset`: An array containing 2 numbers that are what the `x` and `y` offsets are set to when the animation is played.