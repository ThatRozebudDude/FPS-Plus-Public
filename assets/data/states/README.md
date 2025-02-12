As of Modding API 1.3 it is now possible to override states.
This can be done by extending "ScriptedClass" with the same name as the class you want to replace.

```haxe
class FreeplayState extends ScriptedClass
{
    override function create()
    {
        super.create();
    }
}
```