As of Modding API 1.3.0 it is now possible to override states.
This can be done by extending "ScriptedState" with the same name as the class you want to override.

```haxe
class FreeplayState extends ScriptedState
{
	override function create(){
		super.create();
	}
}
```