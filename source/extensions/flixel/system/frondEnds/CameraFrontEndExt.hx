package extensions.flixel.system.frondEnds;

import flixel.FlxCamera;
import flixel.system.frontEnds.CameraFrontEnd;

class CameraFrontEndExt extends CameraFrontEnd{
	public override function reset(?newCamera:FlxCamera):Void{
		super.reset(newCamera ?? new FlxCameraExt());
	}
}