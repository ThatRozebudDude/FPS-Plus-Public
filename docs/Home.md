# FPS Plus Modding Wiki

Welcome to the FPS Plus Modding Wiki. Here you will find documentation and guides on how to make a mod using FPS Plus.

*This wiki is very much a work in progress.*

## Getting Started

To create a mod that the game will recognize and load, you have to create a folder in the `mods/` directory of FPS Plus. In that folder you *must* include a `meta.json` file with the following fields:

- `uid`: A unique indentifier that you can use to identify your mod in a script.
	- A good way to ensure that you pick a unique name is using [reverse domain name notation](https://en.wikipedia.org/wiki/Reverse_domain_name_notation), however this string can be whatever you want it to be.
- `api_version`: A string containing the API version this mod was built for. You can find this in the bottom left corner of the main menu screen.
- `mod_version`: The current version of your mod. This can be anything.

You can and should also include other information like the mod's title and a description. If you want to find out everything you can include in the `meta.json` file [check out this page in the Polymod documentation](https://polymod.io/docs/mod-metadata/). *Note that this page doesn't mention `uid` since it is not a standard Polymod feature.*

You can also include an image called `icon.png`. This is an 80x80 image that will be used as the mod's icon in the mod menu in-game.