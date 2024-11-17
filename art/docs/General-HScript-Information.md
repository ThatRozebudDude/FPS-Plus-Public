## Limitations 

There are a few things to keep in mind when working with HScript classes. You can read [the Limitations section of the HScript README](https://github.com/HaxeFoundation/hscript?tab=readme-ov-file#limitations) and [the Abilities and Limitations of Scripted Classes section of Polymod's Scripted Classes documentation](https://polymod.io/docs/scripted-classes/) for a basic rundown of what is and isn't allowed with scripted classes. 

Additionally, the scripted class *are not namespaced*, meaning if you define the class `Boyfriend` as a freeplay character and also define `Boyfriend` as a character select character it will only be able to find one of them despite them being separated into different locations. Each class needs a unique name like `BoyfriendFreeplay` and `BoyfriendCharacterSelect`. Keep the class names descriptive.

## ScriptingUtil

HScript also does not support `enum` or `abstract` types (at least not using the abstract name for them), however there is a `ScriptingUtil` class that provides shortcuts to use some of these types.

- You can use `ScriptingUtil.axis{axisType}` for FlxAxes directions.
- You can use `ScriptingUtil.rank{rankType}` for song rankings.

There are also other useful functions for certain things that I found did not work or behaved strangely. I recommend taking a look through the class to see what you are able to do with it in more detail.

## Blend Modes

Normally you cannot use blend mode names with HScript as they are an `abstract enum`, however, in FPS Plus if you import `openfl.display.BlendMode` you can use `BlendMode.{blendMode}` to use that blend mode the same way you would normal. You must include `BlendMode` at the begining so you can just do `ADD`, you'd need to use `BlendMode.ADD`. You can also use `FlxTextBorderStyle` the same way you use blend modes, including needing the class name before the type and everything, however, this is automatically imported.

## Aliases

All of the scripted class contain helper variables to make accessing certain variables more simple:

- `boyfriend`: The current player character. Alias for `PlayState.instance.boyfriend`.
- `dad`: The current opponent character. Alias for `PlayState.instance.dad`.
- `gf`: The current GF character. Alias for `PlayState.instance.gf`.
- `playstate`: The current instance of `PlayState`. Alias for `PlayState.instance`.
- `tween`: The `PlayState` tween manager. Use this when making tweens in `PlayState` so that they pause when they're supposed to. Alias for `PlayState.instance.tweenManager`.
- `data`: A `Dynamic` map in `PlayState` that can store any type of data. Alias for `PlayState.instance.arbitraryData`.
- `gameover`: The current instance of `GameOverSubstate`. Alias for `GameOverSubstate.instance`.
- `resultsScreen`: The current instance of `ResultsState`. Alias for `results.ResultsState.instance`.
#
- `withDance`: Used to access an abstract enum. Alias for `AttachedAction.withDance`.
- `withSing`: Used to access an abstract enum. Alias for `AttachedAction.withSing`.
- `withPlayAnim`: Used to access an abstract enum. Alias for `AttachedAction.withPlayAnim`.

- `splitVocalTrack`: Used to access an abstract enum. Alias for `VocalType.splitVocalTrack`.
- `combinedVocalTrack`: Used to access an abstract enum. Alias for `VocalType.combinedVocalTrack`.
- `noVocalTrack`: Used to access an abstract enum. Alias for `VocalType.noVocalTrack`.
#
- `left`: Can be used when refering to note directions. Alias for `0`.
- `down`: Can be used when refering to note directions. Alias for `1`.
- `up`: Can be used when refering to note directions. Alias for `2`.
- `right`: Can be used when refering to note directions. Alias for `3`.