UI Skins are a set of multiple different skins for different UI elements. 

## Defining a UI Skin

A UI skin is defined in a `.json` file in the `data/uiSkins` folder. It should contain the following fields:

- `note`: The default note skin that will be used for all note types that don't have a custom skin set.
- `playerNotes`: The HUD note skin used on the player's side.
- `opponentNotes`: The HUD note skin used on the opponent's side.
- `comboPopup`: The skin used for the combo pop up.
- `countdown`: The skin used for the countdown at the begining of the song.

## Note Skin

> Wiki section not added yet.

## HUD Note Skin

> Wiki section not added yet.

## Combo Popup Skin

Combo Popup skins are defined in a `.json` file in the `data/uiSkins/comboPopup` folder. It should contain the following fields:

- `ratings`: Combo Popup object for the note hit ratings.
- `numbers`: Combo Popup object for the combo numbers.
- `comboBreak`: Combo Popup object for the combo break graphic.

A Combo Popup object holds the data for the graphics and position of its part of the combo display.

- `path`: The path to the folder for the graphics for `ratings` and `numbers` or just the path to the graphic for `comboBreak`. Should not include the file extension.
- `position`: An array that contains 2 numbers that adjust the position of the graphic. The first number is the `x` position, the second is the `y` position. Only used in when the Combo Popup mode is set to world. *(Optional)* If not defined it will be set the default skin values.
- `antialiasing`: Whether the graphic uses antialiasing or not. *(Optional)* If not defined it will be set to `true`.
- `scale`: The scale that the graphic will be displayed at. *(Optional)* If not defined it will be set to `1`.
- `hudScaleMutltiplier`: An additional multiplier that will be applied to the scale when the Combo Popup mode is set to HUD. *(Optional)* If not defined it will be set to `1`.

## Countdown Skin

Countdown skins are defined in a `.json` file in the `data/uiSkins/countdown` folder. It should contain the following fields:

- `first`: Countdown object that plays 4 beats before the song starts.
- `second`: Countdown object that plays 3 beats before the song starts.
- `third`: Countdown object that plays 2 beats before the song starts.
- `fourth`: Countdown object that plays 1 beats before the song starts.

A countdown object holds the data for its part of the countdown. Each field in the countdown object is optional and does not need to be included. It can contain the following fields:

- `graphicPath`: The path of the image that displays during this part of the countdown. Should not include the file extension. If not defined no graphic will be displayed.
- `antialiasing`: Whether the graphic uses antialiasing or not. If not defined it will be set to `true`.
- `scale`: The scale that the graphic will be displayed at. If not defined it will be set to `1`.
- `offset`: An array that contains 2 numbers that offset the graphic from the center of the screen. The first number is the `x` offset, the second is the `y` offset. If not defined it will be set to `[0, 0]`.
- `audioPath`: The path to the audio file that will play during this part of the countdown. Should not include the file extension. If not defined no audio will play.