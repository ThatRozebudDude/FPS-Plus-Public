package characterSelect;

@:build(modding.GlobalScriptingTypesMacro.build())
class CharacterSelectCharacter extends AtlasSprite
{

	public function new() {
		super(0, 0, null);
	}

	public function setup():Void{}

	public function playEnter():Void{}
	public function playIdle():Void{}
	public function playConfirm():Void{}
	public function playCancel():Void{}
	public function playExit():Void{}

}