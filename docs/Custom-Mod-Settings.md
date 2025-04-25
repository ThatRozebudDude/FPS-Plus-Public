## Creating A Setting

In the root of the mod folder you need to create a file called `config.json` with an array object called `"config"`. The array can contain any number of settings object with the following fields:

- `"name"`: The name of setting. This is both the name used to access the value in a script and the name that appears in the mod settings menu.
- `"type"`: The type of setting. This can be one of 4 values, `"bool"`, `"int"`, `"float"`, and `"list"`.
- `"properties"`: An object containing unique properties depending on the value of `"type"`.
	- `"bool"`: A value that is either `true` or `false`.
		- `"defaultBool"`: The default value of the setting. Can be either `true` or `false`.
		- `"trueName"`: The value of the setting that appears when the it's set to `true`.
		- `"falseName"`: The value of the setting that appears when the it's set to `false`.
	- `"int"` and `"float"`: A number. *Note that `"int"` cannot use numbers with a decimal value.*
		- `"defaultValue"`: The default value of the setting. Can be any number.
		- `"range"`: An array containing the minimum and maximum values for the setting. The first index is the minimun and the second index is the maximum.
		- `"increment"`: The amount that the setting will increase or decrease when changing the setting.
	- `"list"`: A string value chosen from an array.
		- `"values"`: An array containing the possible `string` values for the setting.
		- `"defaultIndex"`: The default index into the `"values"` array.

## Accessing A Setting

In a script you can use `ModConfig.get(uid, name)` to get a setting's value.
- `uid`: The `uid` of the mod, specified in the `meta.json` file.
- `name`: The `name` of the setting, specified in the setting object's `"name"` file.

*Note that when getting the value of a list, it will return the `string` value of the list and not the index of the value.*

## Examples

```json
{
	"config":[
		{
			"name": "Example Boolean",
			"type": "bool",
			"properties": {
				"defaultBool": true,
				"trueName": "on",
				"falseName": "off"
			}
		},
		{
			"name": "Example Integer",
			"type": "int",
			"properties": {
				"defaultValue": 0,
				"range": [-5, 5],
				"increment": 1
			}
		},
		{
			"name": "Example Float",
			"type": "float",
			"properties": {
				"defaultValue": 0,
				"range": [-5, 5],
				"increment": 0.5
			}
		},
		{
			"name": "Example List",
			"type": "list",
			"properties": {
				"values": ["Index 0", "Index 1", "Index 2"],
				"defaultIndex": 0
			}
		}
	]
}
```

```haxe
var boolValue:Bool = ModConfig.get("com.fpsPlus.moddingDocumentation", "Example Boolean");
var intValue:Int = ModConfig.get("com.fpsPlus.moddingDocumentation", "Example Integer");
var floatValue:Float = ModConfig.get("com.fpsPlus.moddingDocumentation", "Example Float");
var listValue:String = ModConfig.get("com.fpsPlus.moddingDocumentation", "Example List");
```