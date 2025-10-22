## Limitations 

There are a few things to keep in mind when working with HScript classes. You can read [the Limitations section of the HScript README](https://github.com/HaxeFoundation/hscript?tab=readme-ov-file#limitations) and [the Abilities and Limitations of Scripted Classes section of Polymod's Scripted Classes documentation](https://polymod.io/docs/scripted-classes/) for a basic rundown of what is and isn't allowed with scripted classes. 

Additionally, the scripted class *are not namespaced*, meaning if you define the class `Boyfriend` as a freeplay character and also define `Boyfriend` as a character select character it will only be able to find one of them despite them being separated into different locations. Each class needs a unique name like `BoyfriendFreeplay` and `BoyfriendCharacterSelect`. Keep the class names descriptive.

## ScriptingUtil

`ScriptingUtil` is a class that has a variety of helpful functions that can be useful in scripts or allow you to access some functionality that either doesn't work or could possibly be janky in scripts. It gets new features added to it somewhat often so I recommend [looking through the file](https://github.com/ThatRozebudDude/FPS-Plus-Public/blob/master/source/modding/ScriptingUtil.hx).

## Redefinitions

Normally certain thing like `BlendMode` or `FlxTextBorderStyle` may not work or don't always work properly with hscript. FPS Plus provides redefinitions of certain classes or typedefs to allow for proper use. For example instead of importing `openfl.display.BlendMode` and using `ADD` you can just use `BlendMode.ADD` without an import and it will work properly.

## Aliases

All of the scripted class (except for scripted states) contain helper variables to make interfacing with the current PlayState instance and accessing certain variables more simple:

- `boyfriend`: The current player character. Alias for `PlayState.instance.boyfriend`.
- `dad`: The current opponent character. Alias for `PlayState.instance.dad`.
- `gf`: The current GF character. Alias for `PlayState.instance.gf`.
- `playstate`: The current instance of `PlayState`. Alias for `PlayState.instance`.
- `tween`: The `PlayState` tween manager. Use this when making tweens in `PlayState` so that they pause when they're supposed to. Alias for `PlayState.instance.tweenManager`.
- `data`: A `Dynamic` map in `PlayState` that can store any type of data. Alias for `PlayState.instance.arbitraryData`.
- `gameover`: The current instance of `GameOverSubState`. Alias for `GameOverSubState.instance`.
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
#
- `isInPlayState`: Is `true` if you are in PlayState and `false`.

Note that for variables like `boyfriend` or `dad` you cannot directly set these, you need to use the full variable like `playstate.boyfriend` to set it to a new character object for example.