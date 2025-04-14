package config;

class ConfigOption
{

	public var name:String;
	public var setting:String;
	public var description:String;
	public var optionUpdate:Void->Void;
	public var extraData:Array<Dynamic> = [];

	public function new(_name:String, _setting:String, _description:String, ?initFunction:Void->Void){
		name = _name;
		setting = _setting;
		description = _description;
		if(initFunction != null){
			initFunction();
		}
	}

}